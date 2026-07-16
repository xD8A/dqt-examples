module screenshot;

import qt.config;
import qt.gui.event : QResizeEvent;
import qt.gui.pixmap : QPixmap;
import qt.helpers;
import qt.widgets.checkbox : QCheckBox;
import qt.widgets.label : QLabel;
import qt.widgets.pushbutton : QPushButton;
import qt.widgets.spinbox : QSpinBox;
import qt.widgets.widget : QWidget;

class Screenshot : QWidget
{
    mixin(Q_OBJECT_D);
public:
    //! [0]
    this(QWidget parent = null)
    {
        import core.stdcpp.new_ : cpp_new;
        import qt.core.namespace : Alignment, AlignmentFlag, Key, Modifier;
        import qt.gui.keysequence : QKeySequence;
        import qt.widgets.boxlayout : QHBoxLayout, QVBoxLayout;
        import qt.widgets.gridlayout : QGridLayout;
        import qt.widgets.groupbox : QGroupBox;
        import qt.widgets.sizepolicy : QSizePolicy;

        super(parent);

        originalPixmap = QPixmap.create();

        screenshotLabel = cpp_new!QLabel(this);
        screenshotLabel.setSizePolicy(QSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy
                .Policy.Expanding));
        screenshotLabel.setAlignment(Alignment(AlignmentFlag.AlignCenter));

        auto screenGeometry = screen().geometry();
        screenshotLabel.setMinimumSize(screenGeometry.width() / 8, screenGeometry.height() / 8);

        auto mainLayout = cpp_new!QVBoxLayout(this);
        mainLayout.addWidget(screenshotLabel);

        auto optionsGroupBox = cpp_new!QGroupBox(tr("Options"), this);
        delaySpinBox = cpp_new!QSpinBox(optionsGroupBox);
        delaySpinBox.setSuffix(tr(" s"));
        delaySpinBox.setMaximum(60);

        connect(delaySpinBox.signal!"valueChanged", this.slot!"updateCheckBox");

        hideThisWindowCheckBox = cpp_new!QCheckBox(tr("Hide This Window"), optionsGroupBox);

        auto optionsGroupBoxLayout = cpp_new!QGridLayout(optionsGroupBox);
        optionsGroupBoxLayout.addWidget(cpp_new!QLabel(tr("Screenshot Delay:"), this), 0, 0);
        optionsGroupBoxLayout.addWidget(delaySpinBox, 0, 1);
        optionsGroupBoxLayout.addWidget(hideThisWindowCheckBox, 1, 0, 1, 2);

        mainLayout.addWidget(optionsGroupBox);

        auto buttonsLayout = cpp_new!QHBoxLayout();
        newScreenshotButton = cpp_new!QPushButton(tr("New Screenshot"), this);
        connect(newScreenshotButton.signal!"clicked", this.slot!"newScreenshot");
        buttonsLayout.addWidget(newScreenshotButton);
        auto saveScreenshotButton = cpp_new!QPushButton(tr("Save Screenshot"), this);
        connect(saveScreenshotButton.signal!"clicked", this.slot!"saveScreenshot");
        buttonsLayout.addWidget(saveScreenshotButton);
        auto quitScreenshotButton = cpp_new!QPushButton(tr("Quit"), this);
        quitScreenshotButton.setShortcut(QKeySequence(Modifier.CTRL | Key.Key_Q));
        connect(quitScreenshotButton.signal!"clicked", this.slot!"close");
        buttonsLayout.addWidget(quitScreenshotButton);
        buttonsLayout.addStretch();
        mainLayout.addLayout(buttonsLayout);

        shootScreen();
        delaySpinBox.setValue(5);
        setWindowTitle(tr("Screenshot"));
        resize(300, 200);
    }
    //! [0]

protected:
    //! [1]
    extern (C++) override void resizeEvent(QResizeEvent _)
    {
        import qt.core.namespace : AspectRatioMode, ReturnByValueConstant;

        auto scaledSize = originalPixmap.size();
        scaledSize.scale(screenshotLabel.size(), AspectRatioMode.KeepAspectRatio);
        if (scaledSize != screenshotLabel.pixmap(ReturnByValueConstant.ReturnByValue).size())
            updateScreenshotLabel();
    }
    //! [1]

private:
    //! [2]
    @QSlot void newScreenshot()
    {
        import qt.core.timer : QTimer;

        if (hideThisWindowCheckBox.isChecked())
            hide();
        newScreenshotButton.setDisabled(true);
        QTimer.singleShot(delaySpinBox.value() * 1000, this, { shootScreen(); });
    }
    //! [2]

    //! [3]
    @QSlot void saveScreenshot()
    {
        import core.stdcpp.new_ : cpp_delete, cpp_new;
        import qt.core.bytearray : QByteArray;
        import qt.core.dir : QDir;
        import qt.core.standardpaths : QStandardPaths;
        import qt.core.string : QString;
        import qt.core.stringlist : QStringList;
        import qt.gui.imagewriter : QImageWriter;
        import qt.widgets.dialog : QDialog;
        import qt.widgets.filedialog : QFileDialog;
        import qt.widgets.messagebox : QMessageBox;

        auto format = QString("png");
        auto initialPath = QStandardPaths.writableLocation(
            QStandardPaths.StandardLocation.PicturesLocation);
        if (initialPath.isEmpty())
            initialPath = QDir.currentPath();
        initialPath ~= tr("/untitled.") ~ format;
        auto fileDialog = cpp_new!QFileDialog(this, tr("Save As"), initialPath);
        scope (exit)
            cpp_delete(fileDialog);

        fileDialog.setAcceptMode(QFileDialog.AcceptMode.AcceptSave);
        fileDialog.setFileMode(QFileDialog.FileMode.AnyFile);
        fileDialog.setDirectory(initialPath);
        auto mimeTypes = QStringList();
        const auto baMimeTypes = QImageWriter.supportedMimeTypes();
        foreach (const bf; baMimeTypes)
        {
            mimeTypes.append(QString.fromLatin1(bf));
        }
        fileDialog.setMimeTypeFilters(mimeTypes);
        fileDialog.selectMimeTypeFilter(QString("image/") ~ format);
        fileDialog.setDefaultSuffix(format);
        if (fileDialog.exec() != QDialog.DialogCode.Accepted)
            return;
        auto fileName = fileDialog.selectedFiles().first();
        if (!originalPixmap.save(fileName))
        {
            QMessageBox.warning(this, tr("Save Error"), tr(
                    "The image could not be saved to \"%1\".")
                    .arg(QDir.toNativeSeparators(fileName)));
        }
    }
    //! [3]

    //! [4]
    @QSlot void shootScreen()
    {
        import qt.gui.guiapplication : QGuiApplication;
        import qt.widgets.application : QApplication;

        auto screen = QGuiApplication.primaryScreen();
        if (const window = windowHandle())
            screen = window.screen();
        if (!screen)
            return;

        if (delaySpinBox.value() != 0)
            QApplication.beep();

        originalPixmap = screen.grabWindow(0);
        updateScreenshotLabel();

        newScreenshotButton.setDisabled(false);
        if (hideThisWindowCheckBox.isChecked())
            show();
    }
    //! [4]

    //! [6]
    @QSlot void updateCheckBox()
    {
        if (delaySpinBox.value() == 0)
        {
            hideThisWindowCheckBox.setDisabled(true);
            hideThisWindowCheckBox.setChecked(false);
        }
        else
        {
            hideThisWindowCheckBox.setDisabled(false);
        }
    }
    //! [6]

    //! [10]
    void updateScreenshotLabel()
    {
        import qt.core.namespace : AspectRatioMode, TransformationMode;

        screenshotLabel.setPixmap(originalPixmap.scaled(screenshotLabel.size(),
                AspectRatioMode.KeepAspectRatio,
                TransformationMode.SmoothTransformation));
    }
    //! [10]

    QPixmap originalPixmap;
    QLabel screenshotLabel;
    QSpinBox delaySpinBox;
    QCheckBox hideThisWindowCheckBox;
    QPushButton newScreenshotButton;
}
