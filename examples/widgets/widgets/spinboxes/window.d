module window;

import qt.config;
import qt.helpers;
import qt.core.namespace;
import qt.core.datetime;
import qt.core.string;
import qt.widgets.boxlayout;
import qt.widgets.checkbox;
import qt.widgets.combobox;
import qt.widgets.datetimeedit;
import qt.widgets.groupbox;
import qt.widgets.label;
import qt.widgets.spinbox;
import qt.widgets.widget;

class Window : QWidget
{
    mixin(Q_OBJECT_D);

public:

    this(QWidget parent = null)
    {
        import core.stdcpp.new_;

        super(parent);

        createSpinBoxes();
        createDateTimeEdits();
        createDoubleSpinBoxes();

        auto layout = cpp_new!QHBoxLayout();
        layout.addWidget(spinBoxesGroup);
        layout.addWidget(editsGroup);
        layout.addWidget(doubleSpinBoxesGroup);
        setLayout(layout);

        setWindowTitle(tr("Spin Boxes"));
    }

    @QSlot final void changePrecision(int decimals)
    {
        doubleSpinBox.setDecimals(decimals);
        scaleSpinBox.setDecimals(decimals);
        priceSpinBox.setDecimals(decimals);
    }

    @QSlot final void setFormatString(const(QString) formatString)
    {
        meetingEdit.setDisplayFormat(formatString);
        if (meetingEdit.displayedSections().testAnyFlag(QDateTimeEdit.Section.DateSections_Mask)) {
            meetingEdit.setDateRange(QDate(2004, 11, 1), QDate(2005, 11, 30));
            meetingLabel.setText(tr("Meeting date (between %0 and %1):")
                .arg(meetingEdit.minimumDate().toString(DateFormat.ISODate))
                .arg(meetingEdit.maximumDate().toString(DateFormat.ISODate)));
        } else {
            meetingEdit.setTimeRange(QTime(0, 7, 20, 0), QTime(21, 0, 0, 0));
            meetingLabel.setText(tr("Meeting time (between %0 and %1):")
                .arg(meetingEdit.minimumTime().toString(DateFormat.ISODate))
                .arg(meetingEdit.maximumTime().toString(DateFormat.ISODate)));
        }
    }

private:
    void createSpinBoxes()
    {
        import core.stdcpp.new_;

        spinBoxesGroup = cpp_new!QGroupBox(tr("Spinboxes"));

        auto integerLabel = cpp_new!QLabel(tr("Enter a value between %1 and %2:").arg(-20).arg(20));
        auto integerSpinBox = cpp_new!QSpinBox();
        integerSpinBox.setRange(-20, 20);
        integerSpinBox.setSingleStep(1);
        integerSpinBox.setValue(0);

        auto zoomLabel = cpp_new!QLabel(tr("Enter a zoom value between %1 and %2:").arg(0).arg(1000));
        auto zoomSpinBox = cpp_new!QSpinBox();
        zoomSpinBox.setRange(0, 1000);
        zoomSpinBox.setSingleStep(10);
        zoomSpinBox.setSuffix("%");
        zoomSpinBox.setSpecialValueText(tr("Automatic"));
        zoomSpinBox.setValue(100);

        auto priceLabel = cpp_new!QLabel(tr("Enter a price between %1 and %2:").arg(0).arg(999));
        auto priceSpinBox = cpp_new!QSpinBox();
        priceSpinBox.setRange(0, 999);
        priceSpinBox.setSingleStep(1);
        priceSpinBox.setPrefix("$");
        priceSpinBox.setValue(99);

        groupSeparatorSpinBox = cpp_new!QSpinBox();
        groupSeparatorSpinBox.setRange(-99_999_999, 99_999_999);
        groupSeparatorSpinBox.setValue(1000);
        groupSeparatorSpinBox.setGroupSeparatorShown(true);
        auto groupSeparatorChkBox = cpp_new!QCheckBox(tr("Show group separator"));
        groupSeparatorChkBox.setChecked(true);
        connect(groupSeparatorChkBox.signal!"toggled", groupSeparatorSpinBox.slot!"setGroupSeparatorShown");

        auto hexLabel = cpp_new!QLabel(tr("Enter a value between %1 and %2:")
            .arg(QString("-") ~ QString.number(31, 16))
            .arg(QString.number(31, 16)));
        auto hexSpinBox = cpp_new!QSpinBox();
        hexSpinBox.setRange(-31, 31);
        hexSpinBox.setSingleStep(1);
        hexSpinBox.setValue(0);
        hexSpinBox.setDisplayIntegerBase(16);

        auto spinBoxLayout = cpp_new!QVBoxLayout();
        spinBoxLayout.addWidget(integerLabel);
        spinBoxLayout.addWidget(integerSpinBox);
        spinBoxLayout.addWidget(zoomLabel);
        spinBoxLayout.addWidget(zoomSpinBox);
        spinBoxLayout.addWidget(priceLabel);
        spinBoxLayout.addWidget(priceSpinBox);
        spinBoxLayout.addWidget(hexLabel);
        spinBoxLayout.addWidget(hexSpinBox);
        spinBoxLayout.addWidget(groupSeparatorChkBox);
        spinBoxLayout.addWidget(groupSeparatorSpinBox);
        spinBoxesGroup.setLayout(spinBoxLayout);
    }

    void createDateTimeEdits()
    {
        import core.stdcpp.new_;

        editsGroup = cpp_new!QGroupBox(tr("Date and time spin boxes"));

        auto dateLabel = cpp_new!QLabel();
        auto dateEdit = cpp_new!QDateEdit(QDate.currentDate());
        dateEdit.setDateRange(QDate(2005, 1, 1), QDate(2010, 12, 31));
        dateLabel.setText(tr("Appointment date (between %0 and %1):")
            .arg(dateEdit.minimumDate().toString(DateFormat.ISODate))
            .arg(dateEdit.maximumDate().toString(DateFormat.ISODate)));

        auto timeLabel = cpp_new!QLabel();
        auto timeEdit = cpp_new!QTimeEdit(QTime.currentTime());
        timeEdit.setTimeRange(QTime(9, 0, 0, 0), QTime(16, 30, 0, 0));
        timeLabel.setText(tr("Appointment time (between %0 and %1):")
            .arg(timeEdit.minimumTime().toString(DateFormat.ISODate))
            .arg(timeEdit.maximumTime().toString(DateFormat.ISODate)));

        meetingLabel = cpp_new!QLabel();
        // NOTE: Use a named local to avoid QDateTime being bitwise-copied by
        // cpp_new's auto ref (rvalue → by-value capture), which causes a
        // double-free since QDateTime has a destructor but no D-side postblit.
        auto now = QDateTime.currentDateTime();
        meetingEdit = cpp_new!QDateTimeEdit(now);

        auto formatLabel = cpp_new!QLabel(tr("Format string for the meeting date and time:"));
        auto formatComboBox = cpp_new!QComboBox();
        formatComboBox.addItem("yyyy-MM-dd hh:mm:ss (zzz 'ms')");
        formatComboBox.addItem("hh:mm:ss MM/dd/yyyy");
        formatComboBox.addItem("hh:mm:ss dd/MM/yyyy");
        formatComboBox.addItem("hh:mm:ss");
        formatComboBox.addItem("hh:mm ap");

        connect(formatComboBox.signal!"textActivated", this.slot!"setFormatString");

        setFormatString(formatComboBox.currentText());

        auto editsLayout = cpp_new!QVBoxLayout();
        editsLayout.addWidget(dateLabel);
        editsLayout.addWidget(dateEdit);
        editsLayout.addWidget(timeLabel);
        editsLayout.addWidget(timeEdit);
        editsLayout.addWidget(meetingLabel);
        editsLayout.addWidget(meetingEdit);
        editsLayout.addWidget(formatLabel);
        editsLayout.addWidget(formatComboBox);
        editsGroup.setLayout(editsLayout);
    }

    void createDoubleSpinBoxes()
    {
        import core.stdcpp.new_;

        doubleSpinBoxesGroup = cpp_new!QGroupBox(tr("Double precision spinboxes"));

        auto precisionLabel = cpp_new!QLabel(tr("Number of decimal places to show:"));
        auto precisionSpinBox = cpp_new!QSpinBox();
        precisionSpinBox.setRange(0, 100);
        precisionSpinBox.setValue(2);

        auto doubleLabel = cpp_new!QLabel(tr("Enter a value between %1 and %2:").arg(-20).arg(20));
        doubleSpinBox = cpp_new!QDoubleSpinBox();
        doubleSpinBox.setRange(-20.0, 20.0);
        doubleSpinBox.setSingleStep(1.0);
        doubleSpinBox.setValue(0.0);

        auto scaleLabel = cpp_new!QLabel(tr("Enter a scale factor between %1 and %2:").arg(0).arg(1000.0));
        scaleSpinBox = cpp_new!QDoubleSpinBox();
        scaleSpinBox.setRange(0.0, 1000.0);
        scaleSpinBox.setSingleStep(10.0);
        scaleSpinBox.setSuffix("%");
        scaleSpinBox.setSpecialValueText(tr("No scaling"));
        scaleSpinBox.setValue(100.0);

        auto priceLabel = cpp_new!QLabel(tr("Enter a price between %1 and %2:").arg(0).arg(1000));
        priceSpinBox = cpp_new!QDoubleSpinBox();
        priceSpinBox.setRange(0.0, 1000.0);
        priceSpinBox.setSingleStep(1.0);
        priceSpinBox.setPrefix("$");
        priceSpinBox.setValue(99.99);

        connect(precisionSpinBox.signal!"valueChanged", this.slot!"changePrecision");

        groupSeparatorSpinBox_d = cpp_new!QDoubleSpinBox();
        groupSeparatorSpinBox_d.setRange(-99999999, 99999999);
        groupSeparatorSpinBox_d.setDecimals(2);
        groupSeparatorSpinBox_d.setValue(1000.00);
        groupSeparatorSpinBox_d.setGroupSeparatorShown(true);
        auto groupSeparatorChkBox = cpp_new!QCheckBox(tr("Show group separator"));
        groupSeparatorChkBox.setChecked(true);
        connect(groupSeparatorChkBox.signal!"toggled", groupSeparatorSpinBox_d.slot!"setGroupSeparatorShown");

        auto spinBoxLayout = cpp_new!QVBoxLayout();
        spinBoxLayout.addWidget(precisionLabel);
        spinBoxLayout.addWidget(precisionSpinBox);
        spinBoxLayout.addWidget(doubleLabel);
        spinBoxLayout.addWidget(doubleSpinBox);
        spinBoxLayout.addWidget(scaleLabel);
        spinBoxLayout.addWidget(scaleSpinBox);
        spinBoxLayout.addWidget(priceLabel);
        spinBoxLayout.addWidget(priceSpinBox);
        spinBoxLayout.addWidget(groupSeparatorChkBox);
        spinBoxLayout.addWidget(groupSeparatorSpinBox_d);
        doubleSpinBoxesGroup.setLayout(spinBoxLayout);
    }

    QDateTimeEdit meetingEdit;
    QDoubleSpinBox doubleSpinBox;
    QDoubleSpinBox priceSpinBox;
    QDoubleSpinBox scaleSpinBox;
    QGroupBox spinBoxesGroup;
    QGroupBox editsGroup;
    QGroupBox doubleSpinBoxesGroup;
    QLabel meetingLabel;
    QSpinBox groupSeparatorSpinBox;
    QDoubleSpinBox groupSeparatorSpinBox_d;
}
