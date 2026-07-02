module mainwindow;

import qt.config;
import qt.helpers;
import qt.core.global;
import qt.core.namespace;
import qt.core.object;
import qt.core.point;
import qt.core.qchar;
import qt.core.rect;
import qt.core.size;
import qt.core.string;
import qt.core.variant;
import qt.core.coreevent;
import qt.gui.brush;
import qt.gui.clipboard;
import qt.gui.font;
import qt.gui.fontdatabase;
import qt.gui.guiapplication;
import qt.gui.pen;
import qt.widgets.application;
import qt.widgets.boxlayout;
import qt.widgets.checkbox;
import qt.widgets.combobox;
import qt.widgets.dialog;
import qt.widgets.dialogbuttonbox;
import qt.widgets.fontcombobox;
import qt.widgets.label;
import qt.widgets.layout;
import qt.widgets.lineedit;
import qt.widgets.mainwindow;
import qt.widgets.menu;
import qt.widgets.menubar;
import qt.widgets.plaintextedit;
import qt.widgets.pushbutton;
import qt.widgets.scrollarea;
import qt.widgets.statusbar;
import qt.widgets.widget;

import characterwidget;

//! [0]
class MainWindow : QMainWindow
{
    mixin(Q_OBJECT_D);

    CharacterWidget characterWidget;
    QComboBox filterCombo;
    QComboBox styleCombo;
    QComboBox sizeCombo;
    QFontComboBox fontCombo;
    QLineEdit lineEdit;
    QScrollArea scrollArea;
    QCheckBox fontMerging;

    this(QWidget parent = null)
    {
        import core.stdcpp.new_;
        super(parent);

        auto fileMenu = menuBar().addMenu(tr("File"));
        auto quitAction = fileMenu.addAction(tr("Quit"));
        connect(quitAction.signal!"triggered", this, &close);

        auto helpMenu = menuBar().addMenu(tr("&Help"));
        auto showFontInfoAction = helpMenu.addAction(tr("Show Font Info"));
        connect(showFontInfoAction.signal!"triggered", this, &showInfo);
        auto aboutQtAction = helpMenu.addAction(tr("About &Qt"));
        connect(aboutQtAction.signal!"triggered", this, &aboutQt);

        auto centralWidget = cpp_new!QWidget();

        auto filterLabel = cpp_new!QLabel(tr("Filter:"));
        filterCombo = cpp_new!QComboBox();
        filterCombo.addItem(tr("All"), QVariant.fromValue(QFontComboBox.FontFilter.AllFonts));
        filterCombo.addItem(tr("Scalable"), QVariant.fromValue(QFontComboBox.FontFilter.ScalableFonts));
        filterCombo.addItem(tr("Monospaced"), QVariant.fromValue(QFontComboBox.FontFilter.MonospacedFonts));
        filterCombo.addItem(tr("Proportional"), QVariant.fromValue(QFontComboBox.FontFilter.ProportionalFonts));
        filterCombo.setCurrentIndex(0);
        connect(filterCombo.signal!"currentIndexChanged", this, &filterChanged);

        auto fontLabel = cpp_new!QLabel(tr("Font:"));
        fontCombo = cpp_new!QFontComboBox();
        auto sizeLabel = cpp_new!QLabel(tr("Size:"));
        sizeCombo = cpp_new!QComboBox();
        auto styleLabel = cpp_new!QLabel(tr("Style:"));
        styleCombo = cpp_new!QComboBox();
        auto fontMergingLabel = cpp_new!QLabel(tr("Automatic Font Merging:"));
        fontMerging = cpp_new!QCheckBox();
        fontMerging.setChecked(true);

        scrollArea = cpp_new!QScrollArea();
        characterWidget = cpp_new!CharacterWidget();
        scrollArea.setWidget(characterWidget);

//! [0]

//! [1]
        findStyles(fontCombo.currentFont());
//! [1]
        findSizes(fontCombo.currentFont());

//! [2]
        lineEdit = cpp_new!QLineEdit();
        lineEdit.setClearButtonEnabled(true);
        auto clipboardButton = cpp_new!QPushButton(tr("&To clipboard"));
//! [2]

//! [4]
        connect(fontCombo.signal!"currentFontChanged", this, &findStyles);
        connect(fontCombo.signal!"currentFontChanged", this, &findSizes);
        connect(fontCombo.signal!"currentFontChanged", characterWidget.slot!"updateFont");
        connect(sizeCombo.signal!"currentTextChanged", characterWidget.slot!"updateSize");
        connect(styleCombo.signal!"currentTextChanged", characterWidget.slot!"updateStyle");
//! [4] //! [5]
        connect(characterWidget.signal!"characterSelected", this, &insertCharacter);
        connect(clipboardButton.signal!"clicked", this, &updateClipboard);
//! [5]
        connect(fontMerging.signal!"toggled", characterWidget.slot!"updateFontMerging");

//! [6]
        auto controlsLayout = cpp_new!QHBoxLayout();
        controlsLayout.addWidget(filterLabel);
        controlsLayout.addWidget(filterCombo, 1);
        controlsLayout.addWidget(fontLabel);
        controlsLayout.addWidget(fontCombo, 1);
        controlsLayout.addWidget(sizeLabel);
        controlsLayout.addWidget(sizeCombo, 1);
        controlsLayout.addWidget(styleLabel);
        controlsLayout.addWidget(styleCombo, 1);
        controlsLayout.addWidget(fontMergingLabel);
        controlsLayout.addWidget(fontMerging, 1);
        controlsLayout.addStretch(1);

        auto lineLayout = cpp_new!QHBoxLayout();
        lineLayout.addWidget(lineEdit, 1);
        lineLayout.addSpacing(12);
        lineLayout.addWidget(clipboardButton);

        auto centralLayout = cpp_new!QVBoxLayout();
        centralLayout.addLayout(controlsLayout);
        centralLayout.addWidget(scrollArea, 1);
        centralLayout.addSpacing(4);
        centralLayout.addLayout(lineLayout);
        centralWidget.setLayout(centralLayout);

        setCentralWidget(centralWidget);
        setWindowTitle(tr("Character Map"));
    }
//! [6]

    @QSlot final void filterChanged(int f)
    {
        auto filter = qvariant_cast!(QFontComboBox.FontFilter)(filterCombo.itemData(f));
        fontCombo.setFontFilters(QFontComboBox.FontFilters(filter));
        QString msg = QString.number(fontCombo.count()) ~ QString(" font(s) found");
        statusBar().showMessage(msg);
    }

//! [7]
    @QSlot final void findStyles(const(QFont) font)
    {
        import core.stdcpp.new_;
        QString currentItem = styleCombo.currentText();
        styleCombo.clear();
//! [7]

//! [8]
        auto styles = QFontDatabase.styles(font.family());
        foreach (QString style; styles.toConstSlice()) {
            styleCombo.addItem(style);
        }

        QVariant currentItemData = QVariant(currentItem);
        int styleIndex = styleCombo.findData(currentItemData, ItemDataRole.DisplayRole);

        if (styleIndex == -1)
            styleCombo.setCurrentIndex(0);
        else
            styleCombo.setCurrentIndex(styleIndex);
    }
//! [8]

    @QSlot final void findSizes(const(QFont) font)
    {
        QString currentSize = sizeCombo.currentText();

        {
            // TODO: QSignalBlocker not available in DQt; use manual blockSignals / scope(exit) instead
            sizeCombo.blockSignals(true);
            scope(exit) sizeCombo.blockSignals(false);
            sizeCombo.clear();

            if (QFontDatabase.isSmoothlyScalable(font.family(), QFontDatabase.styleString(font))) {
                auto sizes = QFontDatabase.standardSizes();
                foreach (int sizeValue; sizes.toConstSlice()) {
                    sizeCombo.addItem(QVariant(sizeValue).toString());
                    sizeCombo.setEditable(true);
                }
            } else {
                auto sizes = QFontDatabase.smoothSizes(font.family(), QFontDatabase.styleString(font));
                foreach (int sizeValue; sizes.toConstSlice()) {
                    sizeCombo.addItem(QVariant(sizeValue).toString());
                    sizeCombo.setEditable(false);
                }
            }
        }

        QVariant currentSizeData = QVariant(currentSize);
        int sizeIndex = sizeCombo.findData(currentSizeData, ItemDataRole.DisplayRole);
        if (sizeIndex == -1)
            sizeCombo.setCurrentIndex(qMax(0, sizeCombo.count() / 3));
        else
            sizeCombo.setCurrentIndex(sizeIndex);
    }

//! [9]
    @QSlot final void insertCharacter(const(QString) character)
    {
        lineEdit.insert(character);
    }
//! [9]

//! [10]
    @QSlot final void updateClipboard()
    {
        auto clip = QGuiApplication.clipboard();
//! [11]
        QString txt = lineEdit.text();
        clip.setText(txt, QClipboard.Mode.Clipboard);
        clip.setText(txt, QClipboard.Mode.Selection);
//! [11]
    }

    @QSlot final void showInfo()
    {
        import core.stdcpp.new_;
        auto screenGeometry = screen().geometry();
        auto dialog = cpp_new!FontInfoDialog(this);
        dialog.setWindowTitle(tr("Fonts"));
        dialog.setAttribute(WidgetAttribute.WA_DeleteOnClose);
        dialog.resize(screenGeometry.width() / 4, screenGeometry.height() / 4);
        dialog.show();
    }

    @QSlot final void aboutQt()
    {
        QApplication.aboutQt();
    }
};
//! [10]

class FontInfoDialog : QDialog
{
    mixin(Q_OBJECT_D);

    this(QWidget parent = null)
    {
        import core.stdcpp.new_;
        super(parent);
        setWindowFlags(windowFlags() & ~WindowFlags(WindowType.WindowContextHelpButtonHint));

        auto mainLayout = cpp_new!QVBoxLayout(this);
        auto textEdit = cpp_new!QPlainTextEdit(text(), this);
        textEdit.setReadOnly(true);
        textEdit.setFont(QFontDatabase.systemFont(QFontDatabase.SystemFont.FixedFont));
        mainLayout.addWidget(textEdit);

        auto buttonBox = cpp_new!QDialogButtonBox(
            QDialogButtonBox.StandardButtons(QDialogButtonBox.StandardButton.Close), this);
        connect(buttonBox.signal!"rejected", this, &reject);
        mainLayout.addWidget(buttonBox);
    }

    QString text() const
    {
        auto defaultFont = QFontDatabase.systemFont(QFontDatabase.SystemFont.GeneralFont);
        auto fixedFont = QFontDatabase.systemFont(QFontDatabase.SystemFont.FixedFont);
        auto titleFont = QFontDatabase.systemFont(QFontDatabase.SystemFont.TitleFont);
        auto smallestReadableFont = QFontDatabase.systemFont(QFontDatabase.SystemFont.SmallestReadableFont);

        // QTextStream is not wrapped in DQt; build the string via QString concatenation instead
        QString result;
        result = result ~ "Default font : " ~ defaultFont.family() ~ ", " ~ QString.number(defaultFont.pointSizeF()) ~ "pt\n";
        result = result ~ "Fixed font   : " ~ fixedFont.family() ~ ", " ~ QString.number(fixedFont.pointSizeF()) ~ "pt\n";
        result = result ~ "Title font   : " ~ titleFont.family() ~ ", " ~ QString.number(titleFont.pointSizeF()) ~ "pt\n";
        result = result ~ "Smallest font: " ~ smallestReadableFont.family() ~ ", " ~ QString.number(smallestReadableFont.pointSizeF()) ~ "pt\n";
        return result;
    }
}
