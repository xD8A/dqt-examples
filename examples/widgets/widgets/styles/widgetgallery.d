module widgetgallery;

import core.stdcpp.new_;
import qt.config;
import qt.helpers;
import qt.core.coreevent;
import qt.widgets.dialog;
import qt.widgets.checkbox;
import qt.widgets.combobox;
import qt.widgets.datetimeedit;
import qt.widgets.dial;
import qt.widgets.groupbox;
import qt.widgets.label;
import qt.widgets.lineedit;
import qt.widgets.progressbar;
import qt.widgets.pushbutton;
import qt.widgets.radiobutton;
import qt.widgets.scrollbar;
import qt.widgets.slider;
import qt.widgets.spinbox;
import qt.widgets.tabwidget;
import qt.widgets.tablewidget;
import qt.widgets.textedit;

class WidgetGallery : QDialog
{
    mixin(Q_OBJECT_D);
public:
    this(QWidget parent = null)
    {
        super(parent);

        styleComboBox = new QComboBox;
        auto defaultStyleName = QApplication.style().objectName();
        auto styleNames = QStyleFactory.keys();
        styleNames.append("NorwegianWood");
        for (int i = 1, size = styleNames.size(); i < size; ++i) {
            if (defaultStyleName.compare(styleNames.at(i), CaseSensitivity.CaseInsensitive) == 0) {
                styleNames.swapItemsAt(0, i);
                break;
            }
        }
        styleComboBox.addItems(styleNames);

        styleLabel = cpp_new!QLabel(tr("&Style:"));
        styleLabel.setBuddy(styleComboBox);

        useStylePaletteCheckBox = cpp_new!QCheckBox(tr("&Use style's standard palette"));
        useStylePaletteCheckBox.setChecked(true);

        disableWidgetsCheckBox = cpp_new!QCheckBox(tr("&Disable widgets"));

        createTopLeftGroupBox();
        createTopRightGroupBox();
        createBottomLeftTabWidget();
        createBottomRightGroupBox();
        createProgressBar();

        connect(styleComboBox.signal!"textActivated",
                this.slot!"changeStyle");
        connect(useStylePaletteCheckBox.signal!"toggled",
                this.slot!"changePalette");
        connect(disableWidgetsCheckBox.signal!"toggled",
                topLeftGroupBox.slot!"setDisabled");
        connect(disableWidgetsCheckBox.signal!"toggled",
                topRightGroupBox.slot!"setDisabled");
        connect(disableWidgetsCheckBox.signal!"toggled",
                bottomLeftTabWidget.slot!"setDisabled");
        connect(disableWidgetsCheckBox.signal!"toggled",
                bottomRightGroupBox.slot!"setDisabled");

        auto topLayout = cpp_new!QHBoxLayout();
        topLayout.addWidget(styleLabel);
        topLayout.addWidget(styleComboBox);
        topLayout.addStretch(1);
        topLayout.addWidget(useStylePaletteCheckBox);
        topLayout.addWidget(disableWidgetsCheckBox);

        auto mainLayout = cpp_new!QGridLayout();
        mainLayout.addLayout(topLayout, 0, 0, 1, 2);
        mainLayout.addWidget(topLeftGroupBox, 1, 0);
        mainLayout.addWidget(topRightGroupBox, 1, 1);
        mainLayout.addWidget(bottomLeftTabWidget, 2, 0);
        mainLayout.addWidget(bottomRightGroupBox, 2, 1);
        mainLayout.addWidget(progressBar, 3, 0, 1, 2);
        mainLayout.setRowStretch(1, 1);
        mainLayout.setRowStretch(2, 1);
        mainLayout.setColumnStretch(0, 1);
        mainLayout.setColumnStretch(1, 1);
        setLayout(mainLayout);

        setWindowTitle(tr("Styles"));
        styleChanged();
    }
protected:
    override extern(C++) void changeEvent(QEvent event)
    {
        if (event.type() == QEvent.Type.StyleChange)
            styleChanged();
    }

private:
    @QSlot final void changeStyle(ref const(QString) styleName)
    {
        QStyle style;
        if (styleName == "NorwegianWood")
            style = cpp_new!NorwegianWoodStyle();
        else
            style = QStyleFactory.create(styleName);
        QApplication.setStyle(style);
    }

    @QSlot final void styleChanged()
    {
        auto styleName = QApplication.style().objectName();
        for (int i = 0; i < styleComboBox.count(); ++i) {
            if (QString.compare(styleComboBox.itemText(i), styleName, CaseSensitivity.CaseInsensitive) == 0) {
                styleComboBox.setCurrentIndex(i);
                break;
            }
        }

        changePalette();
    }

    @QSlot final void changePalette()
    {
        QApplication.setPalette(useStylePaletteCheckBox.isChecked() ?
        QApplication.style().standardPalette() : QPalette());
    }

    @QSlot final void advanceProgressBar()
    {
        int curVal = progressBar.value();
        int maxVal = progressBar.maximum();
        progressBar.setValue(curVal + (maxVal - curVal) / 100);
    }

    void createTopLeftGroupBox()
    {
        topLeftGroupBox = cpp_new!QGroupBox(tr("Group 1"));

        radioButton1 = cpp_new!QRadioButton(tr("Radio button 1"));
        radioButton2 = cpp_new!QRadioButton(tr("Radio button 2"));
        radioButton3 = cpp_new!QRadioButton(tr("Radio button 3"));
        radioButton1.setChecked(true);

        checkBox = cpp_new!QCheckBox(tr("Tri-state check box"));
        checkBox.setTristate(true);
        checkBox.setCheckState(CheckState.PartiallyChecked);

        auto layout = cpp_new!QVBoxLayout();
        layout.addWidget(radioButton1);
        layout.addWidget(radioButton2);
        layout.addWidget(radioButton3);
        layout.addWidget(checkBox);
        layout.addStretch(1);
        topLeftGroupBox.setLayout(layout);
    }

    void createTopRightGroupBox()
    {
        topRightGroupBox = cpp_new!QGroupBox(tr("Group 2"));

        defaultPushButton = cpp_new!QPushButton(tr("Default Push Button"));
        defaultPushButton.setDefault(true);

        togglePushButton = cpp_new!QPushButton(tr("Toggle Push Button"));
        togglePushButton.setCheckable(true);
        togglePushButton.setChecked(true);

        flatPushButton = cpp_new!QPushButton(tr("Flat Push Button"));
        flatPushButton.setFlat(true);

        auto layout = cpp_new!QVBoxLayout();
        layout.addWidget(defaultPushButton);
        layout.addWidget(togglePushButton);
        layout.addWidget(flatPushButton);
        layout.addStretch(1);
        topRightGroupBox.setLayout(layout);
    }

    void createBottomLeftTabWidget()
    {
        bottomLeftTabWidget = cpp_new!QTabWidget();
        bottomLeftTabWidget.setSizePolicy(Policy.Preferred, Policy.Ignored);

        auto tab1 = cpp_new!QWidget();
        tableWidget = cpp_new!QTableWidget(10, 10);

        auto tab1hbox = cpp_new!QHBoxLayout();
        tab1hbox.setContentsMargins(5,5, 5, 5);
        tab1hbox.addWidget(tableWidget);
        tab1.setLayout(tab1hbox);

        auto tab2 = cpp_new!QWidget();
        textEdit = cpp_new!QTextEdit();

        textEdit.setPlainText(tr("Twinkle, twinkle, little star,\n"
                                 ~ "How I wonder what you are.\n"
                                 ~ "Up above the world so high,\n"
                                 ~ "Like a diamond in the sky.\n"
                                 ~ "Twinkle, twinkle, little star,\n"
                                 ~ "How I wonder what you are!\n"));

        auto tab2hbox = cpp_new!QHBoxLayout();
        tab2hbox.setContentsMargins(5, 5, 5, 5);
        tab2hbox.addWidget(textEdit);
        tab2.setLayout(tab2hbox);

        bottomLeftTabWidget.addTab(tab1, tr("&Table"));
        bottomLeftTabWidget.addTab(tab2, tr("Text &Edit"));
    }

    void createBottomRightGroupBox()
    {
        bottomRightGroupBox = cpp_new!QGroupBox(tr("Group 3"));
        bottomRightGroupBox.setCheckable(true);
        bottomRightGroupBox.setChecked(true);

        lineEdit = cpp_new!QLineEdit("s3cRe7");
        lineEdit.setEchoMode(EchoMode.Password);

        spinBox = cpp_new!QSpinBox(bottomRightGroupBox);
        spinBox.setValue(50);

        dateTimeEdit = cpp_new!QDateTimeEdit(bottomRightGroupBox);
        auto now = QDateTime.currentDateTime();
        dateTimeEdit.setDateTime(now);

        slider = cpp_new!QSlider(Orientation.Horizontal, bottomRightGroupBox);
        slider.setValue(40);

        scrollBar = cpp_new!QScrollBar(Orientation.Horizontal, bottomRightGroupBox);
        scrollBar.setValue(60);

        dial = cpp_new!QDial(bottomRightGroupBox);
        dial.setValue(30);
        dial.setNotchesVisible(true);

        auto layout = cpp_new!QGridLayout();
        layout.addWidget(lineEdit, 0, 0, 1, 2);
        layout.addWidget(spinBox, 1, 0, 1, 2);
        layout.addWidget(dateTimeEdit, 2, 0, 1, 2);
        layout.addWidget(slider, 3, 0);
        layout.addWidget(scrollBar, 4, 0);
        layout.addWidget(dial, 3, 1, 2, 1);
        layout.setRowStretch(5, 1);
        bottomRightGroupBox.setLayout(layout);
    }

    void createProgressBar()
    {
        progressBar = cpp_new!QProgressBar();
        progressBar.setRange(0, 10_000);
        progressBar.setValue(0);

        auto timer = cpp_new!QTimer(this);
        connect(timer.signal!"timeout", this.slot!"advanceProgressBar");
        timer.start(1000);
    }

    QLabel styleLabel;
    QComboBox styleComboBox;
    QCheckBox useStylePaletteCheckBox;
    QCheckBox disableWidgetsCheckBox;

    QGroupBox topLeftGroupBox;
    QRadioButton radioButton1;
    QRadioButton radioButton2;
    QRadioButton radioButton3;
    QCheckBox checkBox;

    QGroupBox topRightGroupBox;
    QPushButton defaultPushButton;
    QPushButton togglePushButton;
    QPushButton flatPushButton;

    QTabWidget bottomLeftTabWidget;
    QTableWidget tableWidget;
    QTextEdit textEdit;

    QGroupBox bottomRightGroupBox;
    QLineEdit lineEdit;
    QSpinBox spinBox;
    QDateTimeEdit dateTimeEdit;
    QSlider slider;
    QScrollBar scrollBar;
    QDial dial;

    QProgressBar progressBar;
}
