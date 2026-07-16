module imageviewer;

import qt.config;
import qt.helpers;
import qt.core.dir;
import qt.core.fileinfo;
import qt.core.namespace;
import qt.core.qchar;
import qt.core.size;
import qt.core.string;
import qt.gui.action;
import qt.gui.clipboard;
import qt.gui.colorspace;
import qt.gui.guiapplication;
import qt.gui.image;
import qt.gui.imagereader;
import qt.gui.keysequence;
import qt.gui.palette;
import qt.gui.painter;
import qt.gui.pixmap;
import qt.gui.screen;
import qt.widgets.application;
import qt.widgets.filedialog;
import qt.widgets.label;
import qt.widgets.mainwindow;
import qt.widgets.menubar;
import qt.widgets.messagebox;
import qt.widgets.scrollarea;
import qt.widgets.scrollbar;
import qt.widgets.sizepolicy;
import qt.widgets.statusbar;
import qt.widgets.widget;

//! [0]
class ImageViewer : QMainWindow
{
    mixin(Q_OBJECT_D);

    QImage image;
    QLabel imageLabel;
    QScrollArea scrollArea;
    double scaleFactor = 1;

    QAction saveAsAct;
    // printsupport not available: QAction printAct;
    QAction copyAct;
    QAction zoomInAct;
    QAction zoomOutAct;
    QAction normalSizeAct;
    QAction fitToWindowAct;

    this(QWidget parent = null)
    {
        import core.stdcpp.new_;

        super(parent);

        imageLabel = cpp_new!QLabel();
        imageLabel.setBackgroundRole(QPalette.ColorRole.Base);
        imageLabel.setSizePolicy(QSizePolicy(QSizePolicy.Policy.Ignored, QSizePolicy.Policy.Ignored));
        imageLabel.setScaledContents(true);

        scrollArea = cpp_new!QScrollArea();
        scrollArea.setBackgroundRole(QPalette.ColorRole.Dark);
        scrollArea.setWidget(imageLabel);
        scrollArea.setVisible(false);
        setCentralWidget(scrollArea);

        createActions();

        resize(QGuiApplication.primaryScreen().availableSize() * 3 / 5);
    }

    bool loadFile(const(QString) fileName)
    {
        auto reader = QImageReader(fileName);
        reader.setAutoTransform(true);
        auto newImage = reader.read();
        if (newImage.isNull()) {
            QMessageBox.information(this, QGuiApplication.applicationDisplayName(),
                                    tr("Cannot load %1: %2")
                                    .arg(QDir.toNativeSeparators(fileName), reader.errorString()));
            return false;
        }

        setImage(newImage);

        setWindowFilePath(fileName);

        auto description = image.colorSpace().isValid()
            ? image.colorSpace().description() : tr("unknown");
        auto message = tr("Opened \"%1\", %2x%3, Depth: %4 (%5)")
            .arg(QDir.toNativeSeparators(fileName)).arg(image.width()).arg(image.height())
            .arg(image.depth()).arg(description);
        statusBar().showMessage(message);
        return true;
    }

    void setImage(const(QImage) newImage)
    {
        image = newImage;
        if (image.colorSpace().isValid())
            image.convertToColorSpace(QColorSpace.SRgb);
        imageLabel.setPixmap(QPixmap.fromImage(image));

        scaleFactor = 1.0;

        scrollArea.setVisible(true);
        // printAct.setEnabled(true);
        fitToWindowAct.setEnabled(true);
        updateActions();

        if (!fitToWindowAct.isChecked())
            imageLabel.adjustSize();
    }

    bool saveFile(const(QString) fileName)
    {
        auto writer = QImageWriter(fileName);

        if (!writer.write(image)) {
            QMessageBox.information(this, QGuiApplication.applicationDisplayName(),
                                    tr("Cannot write %1: %2")
                                    .arg(QDir.toNativeSeparators(fileName), writer.errorString()));
            return false;
        }
        auto message = tr("Wrote \"%1\"").arg(QDir.toNativeSeparators(fileName));
        statusBar().showMessage(message);
        return true;
    }

    @QSlot final void open()
    {
        auto dialog = cpp_new!QFileDialog(this, tr("Open File"));
        initializeImageFileDialog(dialog, QFileDialog.AcceptMode.AcceptOpen);

        while (dialog.exec() == QDialog.DialogCode.Accepted && !loadFile(dialog.selectedFiles().constFirst())) {}
    }

    @QSlot final void saveAs()
    {
        auto dialog = cpp_new!QFileDialog(this, tr("Save File As"));
        initializeImageFileDialog(dialog, QFileDialog.AcceptMode.AcceptSave);

        while (dialog.exec() == QDialog.DialogCode.Accepted && !saveFile(dialog.selectedFiles().constFirst())) {}
    }

/* printsupport not available in DQt
    @QSlot final void print() {}
*/

    @QSlot final void copy()
    {
        QGuiApplication.clipboard().setImage(image);
    }

    @QSlot final void paste()
    {
        auto newImage = clipboardImage();
        if (newImage.isNull()) {
            statusBar().showMessage(tr("No image in clipboard"));
        } else {
            setImage(newImage);
            setWindowFilePath(QString());
            auto message = tr("Obtained image from clipboard, %1x%2, Depth: %3")
                .arg(newImage.width()).arg(newImage.height()).arg(newImage.depth());
            statusBar().showMessage(message);
        }
    }

    @QSlot final void zoomIn()
    {
        scaleImage(1.25);
    }

    @QSlot final void zoomOut()
    {
        scaleImage(0.8);
    }

    @QSlot final void normalSize()
    {
        imageLabel.adjustSize();
        scaleFactor = 1.0;
    }

    @QSlot final void fitToWindow()
    {
        bool fit = fitToWindowAct.isChecked();
        scrollArea.setWidgetResizable(fit);
        if (!fit)
            normalSize();
        updateActions();
    }

    @QSlot final void about()
    {
        QMessageBox.about(this, tr("About Image Viewer"),
                tr("<p>The <b>Image Viewer</b> example shows how to combine QLabel "
                   ~ "and QScrollArea to display an image. QLabel is typically used "
                   ~ "for displaying a text, but it can also display an image. "
                   ~ "QScrollArea provides a scrolling view around another widget. "
                   ~ "If the child widget exceeds the size of the frame, QScrollArea "
                   ~ "automatically provides scroll bars. </p><p>The example "
                   ~ "demonstrates how QLabel's ability to scale its contents "
                   ~ "(QLabel::scaledContents), and QScrollArea's ability to "
                   ~ "automatically resize its contents "
                   ~ "(QScrollArea::widgetResizable), can be used to implement "
                   ~ "zooming and scaling features. </p><p>In addition the example "
                   ~ "shows how to use QPainter to print an image.</p>"));
    }

private:
    void createActions()
    {
        auto fileMenu = menuBar().addMenu(tr("&File"));

        auto openAct = fileMenu.addAction(tr("&Open..."), this, &ImageViewer.open);
        openAct.setShortcut(QKeySequence.StandardKey.Open);

        saveAsAct = fileMenu.addAction(tr("&Save As..."), this, &ImageViewer.saveAs);
        saveAsAct.setEnabled(false);

        /* printsupport not available
        printAct = fileMenu.addAction(tr("&Print..."), this, &ImageViewer.print);
        printAct.setShortcut(QKeySequence.StandardKey.Print);
        printAct.setEnabled(false); */

        fileMenu.addSeparator();

        auto exitAct = fileMenu.addAction(tr("E&xit"), this, &QWidget.close);
        exitAct.setShortcut(tr("Ctrl+Q"));

        auto editMenu = menuBar().addMenu(tr("&Edit"));

        copyAct = editMenu.addAction(tr("&Copy"), this, &ImageViewer.copy);
        copyAct.setShortcut(QKeySequence.StandardKey.Copy);
        copyAct.setEnabled(false);

        auto pasteAct = editMenu.addAction(tr("&Paste"), this, &ImageViewer.paste);
        pasteAct.setShortcut(QKeySequence.StandardKey.Paste);

        auto viewMenu = menuBar().addMenu(tr("&View"));

        zoomInAct = viewMenu.addAction(tr("Zoom &In (25%)"), this, &ImageViewer.zoomIn);
        zoomInAct.setShortcut(QKeySequence.StandardKey.ZoomIn);
        zoomInAct.setEnabled(false);

        zoomOutAct = viewMenu.addAction(tr("Zoom &Out (25%)"), this, &ImageViewer.zoomOut);
        zoomOutAct.setShortcut(QKeySequence.StandardKey.ZoomOut);
        zoomOutAct.setEnabled(false);

        normalSizeAct = viewMenu.addAction(tr("&Normal Size"), this, &ImageViewer.normalSize);
        normalSizeAct.setShortcut(tr("Ctrl+S"));
        normalSizeAct.setEnabled(false);

        viewMenu.addSeparator();

        fitToWindowAct = viewMenu.addAction(tr("&Fit to Window"), this, &ImageViewer.fitToWindow);
        fitToWindowAct.setEnabled(false);
        fitToWindowAct.setCheckable(true);
        fitToWindowAct.setShortcut(tr("Ctrl+F"));

        auto helpMenu = menuBar().addMenu(tr("&Help"));

        helpMenu.addAction(tr("&About"), this, &ImageViewer.about);
        helpMenu.addAction(tr("About &Qt"), this, &QApplication.aboutQt);
    }

    void updateActions()
    {
        saveAsAct.setEnabled(!image.isNull());
        copyAct.setEnabled(!image.isNull());
        zoomInAct.setEnabled(!fitToWindowAct.isChecked());
        zoomOutAct.setEnabled(!fitToWindowAct.isChecked());
        normalSizeAct.setEnabled(!fitToWindowAct.isChecked());
    }

    void scaleImage(double factor)
    {
        scaleFactor *= factor;
        imageLabel.resize(scaleFactor * imageLabel.pixmap().size());

        adjustScrollBar(scrollArea.horizontalScrollBar(), factor);
        adjustScrollBar(scrollArea.verticalScrollBar(), factor);

        zoomInAct.setEnabled(scaleFactor < 3.0);
        zoomOutAct.setEnabled(scaleFactor > 0.333);
    }

    void adjustScrollBar(QScrollBar scrollBar, double factor)
    {
        scrollBar.setValue(cast(int)(factor * scrollBar.value()
                            + ((factor - 1) * scrollBar.pageStep() / 2)));
    }

    QImage clipboardImage()
    {
        auto mimeData = QGuiApplication.clipboard().mimeData();
        if (mimeData) {
            if (mimeData.hasImage()) {
                auto img = qvariant_cast!QImage(mimeData.imageData());
                if (!img.isNull())
                    return img;
            }
        }
        return QImage();
    }

    void initializeImageFileDialog(QFileDialog dialog, QFileDialog.AcceptMode acceptMode)
    {
        static bool firstDialog = true;

        if (firstDialog) {
            firstDialog = false;
            auto picturesLocations = QStandardPaths.standardLocations(QStandardPaths.StandardLocation.PicturesLocation);
            dialog.setDirectory(picturesLocations.isEmpty() ? QDir.currentPath() : picturesLocations.last());
        }

        auto mimeTypeFilters = QStringList();
        auto supportedMimeTypes = acceptMode == QFileDialog.AcceptMode.AcceptOpen
            ? QImageReader.supportedMimeTypes() : QImageWriter.supportedMimeTypes();
        for (int i = 0; i < supportedMimeTypes.size(); ++i)
            mimeTypeFilters.append(QString(supportedMimeTypes.at(i)));
        mimeTypeFilters.sort();
        dialog.setMimeTypeFilters(mimeTypeFilters);
        dialog.selectMimeTypeFilter("image/jpeg");
        dialog.setAcceptMode(acceptMode);
        if (acceptMode == QFileDialog.AcceptMode.AcceptSave)
            dialog.setDefaultSuffix("jpg");
    }
}
//! [0]