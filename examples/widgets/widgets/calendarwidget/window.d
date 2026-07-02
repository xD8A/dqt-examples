module window;

import qt.config;
import qt.helpers;
import qt.core.datetime;
import qt.core.locale;
import qt.core.namespace;
import qt.core.string;
import qt.core.variant;
import qt.gui.brush;
import qt.gui.font;
import qt.gui.textformat;
import qt.widgets.boxlayout;
import qt.widgets.calendarwidget;
import qt.widgets.checkbox;
import qt.widgets.combobox;
import qt.widgets.datetimeedit;
import qt.widgets.gridlayout;
import qt.widgets.groupbox;
import qt.widgets.label;
import qt.widgets.layout;
import qt.widgets.widget;

// TODO DQt binding: QTextCharFormat.setForeground(QBrush) is not exposed.
//   Add inline wrapper in libs/dqt/gui/qt/gui/textformat.d:
//     inline void setForeground(const QBrush &brush)
//     { setProperty(ForegroundBrush, brush); }
// Colors are stored as int(GlobalColor.xxx) rather than QColor/QBrush because
// QTextCharFormat.setForeground requires ref const(QBrush), and constructing
// QBrush via QVariant.fromValue!QBrush adds complexity without benefit —
// a GlobalColor cast in the slot is simpler.
// TODO DQt binding: QComboBox.findText is commented out.
//   Uncomment in libs/dqt/widgets/qt/widgets/combobox.d line 79.
// TODO DQt binding: QLocale.matchingLocales is commented out.
//   Uncomment in libs/dqt/core/qt/core/locale.d line 1121.

//! [h0]
class Window : QWidget
{
    mixin(Q_OBJECT_D);

public:
    //! [c0]
    this(QWidget parent = null)
    {
        import core.stdcpp.new_;
        super(parent);

        createPreviewGroupBox();
        createGeneralOptionsGroupBox();
        createDatesGroupBox();
        createTextFormatsGroupBox();

        auto layout = cpp_new!QGridLayout();
        layout.addWidget(previewGroupBox, 0, 0);
        layout.addWidget(generalOptionsGroupBox, 0, 1);
        layout.addWidget(datesGroupBox, 1, 0);
        layout.addWidget(textFormatsGroupBox, 1, 1);
        layout.setSizeConstraint(QLayout.SizeConstraint.SetFixedSize);
        setLayout(layout);

        previewLayout.setRowMinimumHeight(0, calendar.sizeHint().height());
        previewLayout.setColumnMinimumWidth(0, calendar.sizeHint().width());

        setWindowTitle(tr("Calendar Widget"));
    }
    //! [c0]

private:
    @QSlot final void localeChanged(int index)
    {
        auto newLocale = localeCombo.itemData(index).toLocale();
        calendar.setLocale(newLocale);
        auto firstDayData = QVariant(int(newLocale.firstDayOfWeek()));
        int newLocaleFirstDayIndex = firstDayCombo.findData(firstDayData);
        firstDayCombo.setCurrentIndex(newLocaleFirstDayIndex);
    }

    //! [c1]
    @QSlot final void firstDayChanged(int index)
    {
        calendar.setFirstDayOfWeek(cast(DayOfWeek)firstDayCombo.itemData(index).toInt());
    }
    //! [c1]

    @QSlot final void selectionModeChanged(int index)
    {
        calendar.setSelectionMode(cast(QCalendarWidget.SelectionMode)selectionModeCombo.itemData(index).toInt());
    }

    @QSlot final void horizontalHeaderChanged(int index)
    {
        calendar.setHorizontalHeaderFormat(cast(QCalendarWidget.HorizontalHeaderFormat)horizontalHeaderCombo.itemData(index).toInt());
    }

    @QSlot final void verticalHeaderChanged(int index)
    {
        calendar.setVerticalHeaderFormat(cast(QCalendarWidget.VerticalHeaderFormat)verticalHeaderCombo.itemData(index).toInt());
    }

    //! [c2]
    @QSlot final void selectedDateChanged()
    {
        currentDateEdit.setDate(calendar.selectedDate());
    }
    //! [c2]

    //! [c3]
    @QSlot final void minimumDateChanged(QDate date)
    {
        calendar.setMinimumDate(date);
        maximumDateEdit.setDate(calendar.maximumDate());
    }
    //! [c3]

    //! [c4]
    @QSlot final void maximumDateChanged(QDate date)
    {
        calendar.setMaximumDate(date);
        minimumDateEdit.setDate(calendar.minimumDate());
    }
    //! [c4]

    //! [c5]
    @QSlot final void weekdayFormatChanged()
    {
        QTextCharFormat format;
        auto colorValue = weekdayColorCombo.itemData(weekdayColorCombo.currentIndex()).toInt();
        auto brush = QBrush(cast(GlobalColor)colorValue);
        // TODO: replace with setForeground(brush) once DQt binding is fixed
        format.base0.setProperty!QBrush(QTextFormat.Property.ForegroundBrush, brush);
        calendar.setWeekdayTextFormat(DayOfWeek.Monday, format);
        calendar.setWeekdayTextFormat(DayOfWeek.Tuesday, format);
        calendar.setWeekdayTextFormat(DayOfWeek.Wednesday, format);
        calendar.setWeekdayTextFormat(DayOfWeek.Thursday, format);
        calendar.setWeekdayTextFormat(DayOfWeek.Friday, format);
    }
    //! [c5]

    //! [c6]
    @QSlot final void weekendFormatChanged()
    {
        QTextCharFormat format;
        auto colorValue = weekendColorCombo.itemData(weekendColorCombo.currentIndex()).toInt();
        auto brush = QBrush(cast(GlobalColor)colorValue);
        format.base0.setProperty!QBrush(QTextFormat.Property.ForegroundBrush, brush);
        calendar.setWeekdayTextFormat(DayOfWeek.Saturday, format);
        calendar.setWeekdayTextFormat(DayOfWeek.Sunday, format);
    }
    //! [c6]

    //! [c7]
    @QSlot final void reformatHeaders()
    {
        auto text = headerTextFormatCombo.currentText();
        QTextCharFormat format;

        if (text == tr("Bold"))
            format.setFontWeight(QFont.Weight.Bold);
        else if (text == tr("Italic"))
            format.setFontItalic(true);
        else if (text == tr("Green")) {
            auto brush = QBrush(GlobalColor.green);
            // TODO: replace with setForeground(brush)
            format.base0.setProperty!QBrush(QTextFormat.Property.ForegroundBrush, brush);
        }
        calendar.setHeaderTextFormat(format);
    }
    //! [c7]

    //! [c8]
    @QSlot final void reformatCalendarPage()
    {
        QTextCharFormat mayFirstFormat;
        auto mayFirst = QDate(calendar.yearShown(), 5, 1);

        QTextCharFormat firstFridayFormat;
        auto firstFriday = QDate(calendar.yearShown(), calendar.monthShown(), 1);
        while (firstFriday.dayOfWeek() != DayOfWeek.Friday)
            firstFriday = firstFriday.addDays(1);

        if (firstFridayCheckBox.isChecked()) {
            auto brush = QBrush(GlobalColor.blue);
            // TODO: replace with setForeground(brush)
            firstFridayFormat.base0.setProperty!QBrush(QTextFormat.Property.ForegroundBrush, brush);
        } else {
            auto dayOfWeek = cast(DayOfWeek)firstFriday.dayOfWeek();
            auto brush = calendar.weekdayTextFormat(dayOfWeek).foreground();
            // TODO: replace with setForeground(brush)
            firstFridayFormat.base0.setProperty!QBrush(QTextFormat.Property.ForegroundBrush, brush);
        }

        calendar.setDateTextFormat(firstFriday, firstFridayFormat);

        if (mayFirstCheckBox.isChecked()) {
            auto brush = QBrush(GlobalColor.red);
            // TODO: replace with setForeground(brush)
            mayFirstFormat.base0.setProperty!QBrush(QTextFormat.Property.ForegroundBrush, brush);
        } else if (!firstFridayCheckBox.isChecked() || firstFriday != mayFirst) {
            auto dayOfWeek = cast(DayOfWeek)mayFirst.dayOfWeek();
            calendar.setDateTextFormat(mayFirst, calendar.weekdayTextFormat(dayOfWeek));
        }

        calendar.setDateTextFormat(mayFirst, mayFirstFormat);
    }
    //! [c8]

    //! [c9]
    void createPreviewGroupBox()
    {
        import core.stdcpp.new_;

        previewGroupBox = cpp_new!QGroupBox(tr("Preview"));

        calendar = cpp_new!QCalendarWidget();
        calendar.setMinimumDate(QDate(1900, 1, 1));
        calendar.setMaximumDate(QDate(3000, 1, 1));
        calendar.setGridVisible(true);

        connect(calendar.signal!"currentPageChanged", this, &reformatCalendarPage);

        previewLayout = cpp_new!QGridLayout();
        previewLayout.addWidget(calendar, 0, 0, Alignment(AlignmentFlag.AlignCenter));
        previewGroupBox.setLayout(previewLayout);
    }
    //! [c9]

    //! [c10]
    void createGeneralOptionsGroupBox()
    {
        import core.stdcpp.new_;

        generalOptionsGroupBox = cpp_new!QGroupBox(tr("General Options"));

        localeCombo = cpp_new!QComboBox();
        int curLocaleIndex = -1;
        int index = 0;
        // TODO: replace with QLocale.matchingLocales(lang, AnyScript, AnyTerritory)
        // once DQt binding is fixed
        for (int _lang = QLocale.Language.C; _lang <= QLocale.Language.LastLanguage; ++_lang) {
            auto lang = cast(QLocale.Language)_lang;
            auto loc = QLocale(lang);
            if (loc.language() != lang)
                continue;
            auto territory = loc.territory();
            QString label = QLocale.languageToString(lang);
            label = label ~ "/" ~ QLocale.territoryToString(territory);
            if (locale().language() == lang && locale().territory() == territory)
                curLocaleIndex = index;
            auto localeData = QVariant.fromValue!QLocale(loc);
            localeCombo.addItem(label, localeData);
            ++index;
        }
        if (curLocaleIndex != -1)
            localeCombo.setCurrentIndex(curLocaleIndex);
        localeLabel = cpp_new!QLabel(tr("&Locale"));
        localeLabel.setBuddy(localeCombo);

        firstDayCombo = cpp_new!QComboBox();
        firstDayCombo.addItem(tr("Sunday"), QVariant(int(DayOfWeek.Sunday)));
        firstDayCombo.addItem(tr("Monday"), QVariant(int(DayOfWeek.Monday)));
        firstDayCombo.addItem(tr("Tuesday"), QVariant(int(DayOfWeek.Tuesday)));
        firstDayCombo.addItem(tr("Wednesday"), QVariant(int(DayOfWeek.Wednesday)));
        firstDayCombo.addItem(tr("Thursday"), QVariant(int(DayOfWeek.Thursday)));
        firstDayCombo.addItem(tr("Friday"), QVariant(int(DayOfWeek.Friday)));
        firstDayCombo.addItem(tr("Saturday"), QVariant(int(DayOfWeek.Saturday)));

        firstDayLabel = cpp_new!QLabel(tr("Wee&k starts on:"));
        firstDayLabel.setBuddy(firstDayCombo);

        selectionModeCombo = cpp_new!QComboBox();
        selectionModeCombo.addItem(tr("Single selection"),
            QVariant(int(QCalendarWidget.SelectionMode.SingleSelection)));
        selectionModeCombo.addItem(tr("None"),
            QVariant(int(QCalendarWidget.SelectionMode.NoSelection)));

        selectionModeLabel = cpp_new!QLabel(tr("&Selection mode:"));
        selectionModeLabel.setBuddy(selectionModeCombo);

        gridCheckBox = cpp_new!QCheckBox(tr("&Grid"));
        gridCheckBox.setChecked(calendar.isGridVisible());

        navigationCheckBox = cpp_new!QCheckBox(tr("&Navigation bar"));
        navigationCheckBox.setChecked(true);

        horizontalHeaderCombo = cpp_new!QComboBox();
        horizontalHeaderCombo.addItem(tr("Single letter day names"),
            QVariant(int(QCalendarWidget.HorizontalHeaderFormat.SingleLetterDayNames)));
        horizontalHeaderCombo.addItem(tr("Short day names"),
            QVariant(int(QCalendarWidget.HorizontalHeaderFormat.ShortDayNames)));
        horizontalHeaderCombo.addItem(tr("None"),
            QVariant(int(QCalendarWidget.HorizontalHeaderFormat.NoHorizontalHeader)));
        horizontalHeaderCombo.setCurrentIndex(1);

        horizontalHeaderLabel = cpp_new!QLabel(tr("&Horizontal header:"));
        horizontalHeaderLabel.setBuddy(horizontalHeaderCombo);

        verticalHeaderCombo = cpp_new!QComboBox();
        verticalHeaderCombo.addItem(tr("ISO week numbers"),
            QVariant(int(QCalendarWidget.VerticalHeaderFormat.ISOWeekNumbers)));
        verticalHeaderCombo.addItem(tr("None"),
            QVariant(int(QCalendarWidget.VerticalHeaderFormat.NoVerticalHeader)));

        verticalHeaderLabel = cpp_new!QLabel(tr("&Vertical header:"));
        verticalHeaderLabel.setBuddy(verticalHeaderCombo);
    //! [c10]

    //! [c11]
        connect(localeCombo.signal!"currentIndexChanged", this, &localeChanged);
        connect(firstDayCombo.signal!"currentIndexChanged", this, &firstDayChanged);
        connect(selectionModeCombo.signal!"currentIndexChanged", this, &selectionModeChanged);
        connect(gridCheckBox.signal!"toggled", calendar.slot!"setGridVisible");
        connect(navigationCheckBox.signal!"toggled", calendar.slot!"setNavigationBarVisible");
        connect(horizontalHeaderCombo.signal!"currentIndexChanged", this, &horizontalHeaderChanged);
        connect(verticalHeaderCombo.signal!"currentIndexChanged", this, &verticalHeaderChanged);
    //! [c11]

    //! [c12]
        auto checkBoxLayout = cpp_new!QHBoxLayout();
        checkBoxLayout.addWidget(gridCheckBox);
        checkBoxLayout.addStretch();
        checkBoxLayout.addWidget(navigationCheckBox);

        auto outerLayout = cpp_new!QGridLayout();
        outerLayout.addWidget(localeLabel, 0, 0);
        outerLayout.addWidget(localeCombo, 0, 1);
        outerLayout.addWidget(firstDayLabel, 1, 0);
        outerLayout.addWidget(firstDayCombo, 1, 1);
        outerLayout.addWidget(selectionModeLabel, 2, 0);
        outerLayout.addWidget(selectionModeCombo, 2, 1);
        outerLayout.addLayout(checkBoxLayout, 3, 0, 1, 2);
        outerLayout.addWidget(horizontalHeaderLabel, 4, 0);
        outerLayout.addWidget(horizontalHeaderCombo, 4, 1);
        outerLayout.addWidget(verticalHeaderLabel, 5, 0);
        outerLayout.addWidget(verticalHeaderCombo, 5, 1);
        generalOptionsGroupBox.setLayout(outerLayout);

        firstDayChanged(firstDayCombo.currentIndex());
        selectionModeChanged(selectionModeCombo.currentIndex());
        horizontalHeaderChanged(horizontalHeaderCombo.currentIndex());
        verticalHeaderChanged(verticalHeaderCombo.currentIndex());
    }
    //! [c12]

    //! [c13]
    void createDatesGroupBox()
    {
        import core.stdcpp.new_;

        datesGroupBox = cpp_new!QGroupBox(tr("Dates"));

        minimumDateEdit = cpp_new!QDateEdit();
        minimumDateEdit.setDisplayFormat("MMM d yyyy");
        minimumDateEdit.setMinimumDate(calendar.minimumDate());
        minimumDateEdit.setMaximumDate(calendar.maximumDate());
        minimumDateEdit.setDate(calendar.minimumDate());

        minimumDateLabel = cpp_new!QLabel(tr("&Minimum Date:"));
        minimumDateLabel.setBuddy(minimumDateEdit);

        currentDateEdit = cpp_new!QDateEdit();
        currentDateEdit.setDisplayFormat("MMM d yyyy");
        currentDateEdit.setDate(calendar.selectedDate());
        currentDateEdit.setMinimumDate(calendar.minimumDate());
        currentDateEdit.setMaximumDate(calendar.maximumDate());

        currentDateLabel = cpp_new!QLabel(tr("&Current Date:"));
        currentDateLabel.setBuddy(currentDateEdit);

        maximumDateEdit = cpp_new!QDateEdit();
        maximumDateEdit.setDisplayFormat("MMM d yyyy");
        maximumDateEdit.setMinimumDate(calendar.minimumDate());
        maximumDateEdit.setMaximumDate(calendar.maximumDate());
        maximumDateEdit.setDate(calendar.maximumDate());

        maximumDateLabel = cpp_new!QLabel(tr("Ma&ximum Date:"));
        maximumDateLabel.setBuddy(maximumDateEdit);
    //! [c13]

    //! [c14]
        connect(currentDateEdit.signal!"dateChanged", calendar.slot!"setSelectedDate");
        connect(calendar.signal!"selectionChanged", this, &selectedDateChanged);
        connect(minimumDateEdit.signal!"dateChanged", this, &minimumDateChanged);
        connect(maximumDateEdit.signal!"dateChanged", this, &maximumDateChanged);
    //! [c14]

    //! [c15]
        auto dateBoxLayout = cpp_new!QGridLayout();
        dateBoxLayout.addWidget(currentDateLabel, 1, 0);
        dateBoxLayout.addWidget(currentDateEdit, 1, 1);
        dateBoxLayout.addWidget(minimumDateLabel, 0, 0);
        dateBoxLayout.addWidget(minimumDateEdit, 0, 1);
        dateBoxLayout.addWidget(maximumDateLabel, 2, 0);
        dateBoxLayout.addWidget(maximumDateEdit, 2, 1);
        dateBoxLayout.setRowStretch(3, 1);

        datesGroupBox.setLayout(dateBoxLayout);
    }
    //! [c15]

    //! [c16]
    void createTextFormatsGroupBox()
    {
        import core.stdcpp.new_;

        textFormatsGroupBox = cpp_new!QGroupBox(tr("Text Formats"));

        weekdayColorCombo = createColorComboBox();
        auto blackData = QVariant(tr("Black"));
        // TODO: replace with findText(tr("Black")) once DQt binding is fixed
        weekdayColorCombo.setCurrentIndex(
            weekdayColorCombo.findData(blackData, ItemDataRole.DisplayRole));

        weekdayColorLabel = cpp_new!QLabel(tr("&Weekday color:"));
        weekdayColorLabel.setBuddy(weekdayColorCombo);

        weekendColorCombo = createColorComboBox();
        auto redData = QVariant(tr("Red"));
        // TODO: replace with findText(tr("Red")) once DQt binding is fixed
        weekendColorCombo.setCurrentIndex(
            weekendColorCombo.findData(redData, ItemDataRole.DisplayRole));

        weekendColorLabel = cpp_new!QLabel(tr("Week&end color:"));
        weekendColorLabel.setBuddy(weekendColorCombo);
    //! [c16]

    //! [c17]
        headerTextFormatCombo = cpp_new!QComboBox();
        headerTextFormatCombo.addItem(tr("Bold"));
        headerTextFormatCombo.addItem(tr("Italic"));
        headerTextFormatCombo.addItem(tr("Plain"));

        headerTextFormatLabel = cpp_new!QLabel(tr("&Header text:"));
        headerTextFormatLabel.setBuddy(headerTextFormatCombo);

        firstFridayCheckBox = cpp_new!QCheckBox(tr("&First Friday in blue"));

        mayFirstCheckBox = cpp_new!QCheckBox(tr("May &1 in red"));
    //! [c17]

    //! [c18]
        connect(weekdayColorCombo.signal!"currentIndexChanged", this, &weekdayFormatChanged);
        connect(weekdayColorCombo.signal!"currentIndexChanged", this, &reformatCalendarPage);
        connect(weekendColorCombo.signal!"currentIndexChanged", this, &weekendFormatChanged);
        connect(weekendColorCombo.signal!"currentIndexChanged", this, &reformatCalendarPage);
        connect(headerTextFormatCombo.signal!"currentIndexChanged", this, &reformatHeaders);
        connect(firstFridayCheckBox.signal!"toggled", this, &reformatCalendarPage);
        connect(mayFirstCheckBox.signal!"toggled", this, &reformatCalendarPage);
    //! [c18]

    //! [c19]
        auto checkBoxLayout = cpp_new!QHBoxLayout();
        checkBoxLayout.addWidget(firstFridayCheckBox);
        checkBoxLayout.addStretch();
        checkBoxLayout.addWidget(mayFirstCheckBox);

        auto outerLayout = cpp_new!QGridLayout();
        outerLayout.addWidget(weekdayColorLabel, 0, 0);
        outerLayout.addWidget(weekdayColorCombo, 0, 1);
        outerLayout.addWidget(weekendColorLabel, 1, 0);
        outerLayout.addWidget(weekendColorCombo, 1, 1);
        outerLayout.addWidget(headerTextFormatLabel, 2, 0);
        outerLayout.addWidget(headerTextFormatCombo, 2, 1);
        outerLayout.addLayout(checkBoxLayout, 3, 0, 1, 2);
        textFormatsGroupBox.setLayout(outerLayout);

        weekdayFormatChanged();
        weekendFormatChanged();
        reformatHeaders();
        reformatCalendarPage();
    }
    //! [c19]

    //! [c20]
    QComboBox createColorComboBox()
    {
        import core.stdcpp.new_;

        auto comboBox = cpp_new!QComboBox();
        comboBox.addItem(tr("Red"), QVariant(int(GlobalColor.red)));
        comboBox.addItem(tr("Blue"), QVariant(int(GlobalColor.blue)));
        comboBox.addItem(tr("Black"), QVariant(int(GlobalColor.black)));
        comboBox.addItem(tr("Magenta"), QVariant(int(GlobalColor.magenta)));
        return comboBox;
    }
    //! [c20]

    QGroupBox previewGroupBox;
    QGridLayout previewLayout;
    QCalendarWidget calendar;

    QGroupBox generalOptionsGroupBox;
    QLabel localeLabel;
    QLabel firstDayLabel;
    QLabel selectionModeLabel;
    QLabel horizontalHeaderLabel;
    QLabel verticalHeaderLabel;
    QComboBox localeCombo;
    QComboBox firstDayCombo;
    QComboBox selectionModeCombo;
    QCheckBox gridCheckBox;
    QCheckBox navigationCheckBox;
    QComboBox horizontalHeaderCombo;
    QComboBox verticalHeaderCombo;

    QGroupBox datesGroupBox;
    QLabel currentDateLabel;
    QLabel minimumDateLabel;
    QLabel maximumDateLabel;
    QDateEdit currentDateEdit;
    QDateEdit minimumDateEdit;
    QDateEdit maximumDateEdit;

    QGroupBox textFormatsGroupBox;
    QLabel weekdayColorLabel;
    QLabel weekendColorLabel;
    QLabel headerTextFormatLabel;
    QComboBox weekdayColorCombo;
    QComboBox weekendColorCombo;
    QComboBox headerTextFormatCombo;

    QCheckBox firstFridayCheckBox;
//! [h1]
    QCheckBox mayFirstCheckBox;
};
//! [h1]
