module mainwindow;

import qt.config;
import qt.helpers;
import core.stdcpp.new_ : cpp_new; 
import qt.core.namespace : Alignment, AlignmentFlag, GlobalColor;
import qt.core.list : QList;
import qt.core.datetime : QDate;
import qt.core.locale : QLocale;
import qt.core.string : QString;
import qt.gui.color : QColor;
import qt.gui.brush : QBrush;
import qt.gui.font : QFont;
import qt.gui.textformat : QTextCharFormat, QTextLength, QTextTableFormat;
import qt.widgets.boxlayout : QHBoxLayout, QVBoxLayout;
import qt.widgets.widget : QWidget;
import qt.widgets.label : QLabel;
import qt.widgets.combobox : QComboBox;
import qt.widgets.datetimeedit : QDateTimeEdit;
import qt.widgets.spinbox : QSpinBox;
import qt.widgets.mainwindow : QMainWindow;
import qt.widgets.textbrowser : QTextBrowser;

//! [h_0]
class MainWindow : QMainWindow
{
    mixin(Q_OBJECT_D);
public:
//! [0]
    this()
    {
//! [h_0]
        super(null);

        selectedDate = QDate.currentDate();
        fontSize = 10;

        auto centralWidget = cpp_new!QWidget();
//! [0]

//! [1]
        auto dateLabel = cpp_new!QLabel(tr("Date:"));
        auto monthCombo = cpp_new!QComboBox();

        for (int month = 1; month <= 12; ++month)
            monthCombo.addItem(QLocale.system().monthName(month));

        auto yearEdit = cpp_new!QDateTimeEdit();
        yearEdit.setDisplayFormat("yyyy");
        yearEdit.setDateRange(QDate(1753, 1, 1), QDate(8000, 1, 1));
//! [1]

        monthCombo.setCurrentIndex(selectedDate.month() - 1);
        yearEdit.setDate(selectedDate);

//! [2]
        auto fontSizeLabel = cpp_new!QLabel(tr("Font size:"));
        auto fontSizeSpinBox = cpp_new!QSpinBox();
        fontSizeSpinBox.setRange(1, 64);

        editor = cpp_new!QTextBrowser();
        insertCalendar();
//! [2]

//! [3]
        connect(monthCombo.signal!"activated", this.slot!"setMonth");
        connect(yearEdit.signal!"dateChanged", this.slot!"setYear");
        connect(fontSizeSpinBox.signal!"valueChanged", this.slot!"setFontSize");
//! [3]

        fontSizeSpinBox.setValue(10);

//! [4]
        auto controlsLayout = cpp_new!QHBoxLayout();
        controlsLayout.addWidget(dateLabel);
        controlsLayout.addWidget(monthCombo);
        controlsLayout.addWidget(yearEdit);
        controlsLayout.addSpacing(24);
        controlsLayout.addWidget(fontSizeLabel);
        controlsLayout.addWidget(fontSizeSpinBox);
        controlsLayout.addStretch(1);

        auto centralLayout = cpp_new!QVBoxLayout();
        centralLayout.addLayout(controlsLayout);
        centralLayout.addWidget(editor, 1);
        centralWidget.setLayout(centralLayout);

        setCentralWidget(centralWidget);
//! [h_1]
    }
//! [4]

//! [15]
    @QSlot void setFontSize(int size)
    {
//! [h_1]
        fontSize = size;
        insertCalendar();
//! [h_2]
    }
//! [15]

//! [16]
    @QSlot void setMonth(int month)
    {
//! [h_2]
        selectedDate = QDate(selectedDate.year(), month + 1, selectedDate.day());
        insertCalendar();
//! [h_3]
    }
//! [16]

//! [17]
    @QSlot void setYear(QDate date)
    {
//! [h_3]
        selectedDate = QDate(date.year(), selectedDate.month(), selectedDate.day());
        insertCalendar();
//! [h_4]
    }
//! [17]

private:
//! [5]
    void insertCalendar()
    {
//! [h_4]
        editor.clear();
        auto cursor = editor.textCursor();
        cursor.beginEditBlock();

        auto date = QDate(selectedDate.year(), selectedDate.month(), 1);
//! [5]

//! [6]
        auto tableFormat = QTextTableFormat.create();
        tableFormat.setAlignment(Alignment(AlignmentFlag.AlignHCenter));
        // TODO: tableFormat.setBackground(QColor("#e0e0e0"));
        tableFormat.base0.setProperty!QBrush(QTextTableFormat.Property.BackgroundBrush, QBrush(QColor("#e0e0e0")));
        tableFormat.setCellPadding(2);
        tableFormat.setCellSpacing(4);
//! [6]//! [7]
        QList!QTextLength constraints;
        constraints ~= QTextLength(QTextLength.Type.PercentageLength, 14);
        constraints ~= QTextLength(QTextLength.Type.PercentageLength, 14);
        constraints ~= QTextLength(QTextLength.Type.PercentageLength, 14);
        constraints ~= QTextLength(QTextLength.Type.PercentageLength, 14);
        constraints ~= QTextLength(QTextLength.Type.PercentageLength, 14);
        constraints ~= QTextLength(QTextLength.Type.PercentageLength, 14);
        constraints ~= QTextLength(QTextLength.Type.PercentageLength, 14);
        tableFormat.setColumnWidthConstraints(constraints);
//! [7]

//! [8]
        auto table = cursor.insertTable(1, 7, tableFormat);
//! [8]

//! [9]
        auto frame = cursor.currentFrame();
        auto frameFormat = frame.frameFormat();
        frameFormat.setBorder(1);
        frame.setFrameFormat(frameFormat);
//! [9]

//! [10]
        auto format = cursor.charFormat();
        format.setFontPointSize(fontSize);

        QTextCharFormat boldFormat;
        boldFormat.setFontPointSize(fontSize);
        boldFormat.setFontWeight(QFont.Weight.Bold);

        QTextCharFormat highlightedFormat;
        highlightedFormat.setFontPointSize(fontSize);
        highlightedFormat.setFontWeight(QFont.Weight.Bold);
        highlightedFormat.base0.setProperty!QBrush(QTextCharFormat.Property.BackgroundBrush,
                                                   QBrush(GlobalColor.yellow));
//! [10]

//! [11]
        for (int weekDay = 1; weekDay <= 7; ++weekDay)
        {
            auto cell = table.cellAt(0, weekDay - 1);
//! [11]//! [12]
            auto cellCursor = cell.firstCursorPosition();
            cellCursor.insertText(QLocale.system().dayName(weekDay), boldFormat);
        }
//! [12]

//! [13]
        table.insertRows(table.rows(), 1);
//! [13]

        while (date.month() == selectedDate.month())
        {
            int weekDay = date.dayOfWeek();
            auto cell = table.cellAt(table.rows() - 1, weekDay - 1);
            auto cellCursor = cell.firstCursorPosition();

            if (date == QDate.currentDate())
                cellCursor.insertText(QString("%1").arg(date.day()), highlightedFormat);
            else
                cellCursor.insertText(QString("%1").arg(date.day()), format);

            date = date.addDays(1);
            if (weekDay == 7 && date.month() == selectedDate.month())
                table.insertRows(table.rows(), 1);
        }

        cursor.endEditBlock();
//! [14]
        setWindowTitle(tr("Calendar for %1 %2"
        ).arg(QLocale.system()
                .monthName(selectedDate.month())
        ).arg(selectedDate.year()));
//! [h_5]
    }
//! [h_5]
//! [h_6]
//! [14]

    int fontSize;
    QDate selectedDate;
    QTextBrowser editor;
}
//! [h_6]
