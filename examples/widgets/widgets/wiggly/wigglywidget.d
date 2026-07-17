module wigglywidget;

import core.stdcpp.new_ : cpp_new;
import qt.config;
import qt.core.basictimer : QBasicTimer;
import qt.core.coreevent : QTimerEvent;
import qt.core.string : QString;
import qt.gui.color : QColor;
import qt.gui.event : QPaintEvent;      
import qt.gui.font : QFont;
import qt.gui.fontmetrics : QFontMetrics;
import qt.gui.painter : QPainter;
import qt.gui.palette : QPalette;
import qt.helpers;
import qt.widgets.widget : QWidget;

//! [h0 0]
class WigglyWidget : QWidget
{
    mixin(Q_OBJECT_D);
public:
//! [c0]
    this(QWidget parent = null)
    {
//! [h0 0]
        super(parent);
        timer = QBasicTimer.init;
        step = 0;

        setBackgroundRole(QPalette.ColorRole.Midlight);
        setAutoFillBackground(true);

        auto newFont = QFont(font());
        newFont.setPointSize(newFont.pointSize() + 20);
        setFont(newFont);

        timer.start(60, this);
//! [h0 1]
    }
//! [c0]

    @QSlot final void setText(const(QString) newText)
    {
        storedText = newText;
    }

protected:
//! [c1]
    override extern (C++) void paintEvent(QPaintEvent event) //! [paintEvent_1] //! [paintEvent_2]
//! [c1] //! [c2]
    {
//! [h0 1]
        static immutable int[16] sineTable = [
            0, 38, 71, 92, 100, 92, 71, 38, 0, -38, -71, -92, -100, -92, -71, -38
        ];

        auto f = QFont(font());
        QFontMetrics metrics = QFontMetrics(f);
        int x = (width() - metrics.horizontalAdvance(storedText)) / 2;
        int y = (height() + metrics.ascent() - metrics.descent()) / 2;
        QColor color;
//! [c2]

//! [c3]
        auto painter = QPainter(this);
//! [c3] //! [c4]
        for (int i = 0; i < storedText.size(); ++i)
        {
            immutable int index = (step + i) % 16;
            color.setHsv((15 - index) * 16, 255, 191);
            painter.setPen(color);
            painter.drawText(x, y - ((sineTable[index] * metrics.height()) / 400),
                QString(storedText[i]));
            x += metrics.horizontalAdvance(storedText[i]);
        }
//! [h0 2]
    }
//! [c4]

//! [c5]
    override extern (C++) void timerEvent(QTimerEvent event)
//! [c5] //! [c6]
    {
//! [h0 2]
        if (event.timerId() == timer.timerId())
        {
            ++step;
            update();
        }
        else
        {
            super.timerEvent(event);
        }
//! [h0 3]
    }
//! [c6]

    QBasicTimer timer;
    QString storedText;
    int step;
}
//! [h0 3]
