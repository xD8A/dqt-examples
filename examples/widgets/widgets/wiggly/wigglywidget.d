module wigglywidget;

import qt.config;
import qt.core.basictimer : QBasicTimer;
import qt.core.coreevent : QTimerEvent;
import qt.core.string : QString;
import qt.gui.event : QPaintEvent;
import qt.helpers;
import qt.widgets.widget : QWidget;

//! [class]
class WigglyWidget : QWidget
{
    mixin(Q_OBJECT_D);
public:
    //! [constructor]
    this(QWidget parent = null)
    {
        import core.stdcpp.new_ : cpp_new;
        import qt.gui.font : QFont;
        import qt.gui.palette : QPalette;

        super(parent);
        timer = QBasicTimer.init;
        step = 0;

        setBackgroundRole(QPalette.ColorRole.Midlight);
        setAutoFillBackground(true);

        auto newFont = QFont(font());
        newFont.setPointSize(newFont.pointSize() + 20);
        setFont(newFont);

        timer.start(60, this);
    }
    //! [constructor]

    @QSlot final void setText(const(QString) newText)
    {
        storedText = newText;
    }

protected:
    //! [paintEvent_1]
    override extern (C++) void paintEvent(QPaintEvent event) //! [paintEvent_1] //! [paintEvent_2]
    {
        import qt.gui.color : QColor;
        import qt.gui.font : QFont;
        import qt.gui.fontmetrics : QFontMetrics;
        import qt.gui.painter : QPainter;

        static immutable int[16] sineTable = [
            0, 38, 71, 92, 100, 92, 71, 38, 0, -38, -71, -92, -100, -92, -71, -38
        ];

        auto f = QFont(font());
        QFontMetrics metrics = QFontMetrics(f);
        int x = (width() - metrics.horizontalAdvance(storedText)) / 2;
        int y = (height() + metrics.ascent() - metrics.descent()) / 2;
        QColor color;
        //! [paintEvent_2]

        //! [paintEvent_3]
        auto painter = QPainter(this);
        //! [paintEvent_3] //! [paintEvent_4]
        for (int i = 0; i < storedText.size(); ++i)
        {
            immutable int index = (step + i) % 16;
            color.setHsv((15 - index) * 16, 255, 191);
            painter.setPen(color);
            painter.drawText(x, y - ((sineTable[index] * metrics.height()) / 400),
                QString(storedText[i]));
            x += metrics.horizontalAdvance(storedText[i]);
        }
    }
    //! [paintEvent_4]

    //! [timerEvent]
    override extern (C++) void timerEvent(QTimerEvent event)
    {
        if (event.timerId() == timer.timerId())
        {
            ++step;
            update();
        }
        else
        {
            super.timerEvent(event);
        }
    }
    //! [timerEvent]

    QBasicTimer timer;
    QString storedText;
    int step;
}
//! [class]
