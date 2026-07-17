module analogclockwindow;

import qt.config;
import qt.core.coreevent : QTimerEvent;
import qt.core.datetime : QTime;
import qt.core.global : qMin;
import qt.core.namespace : PenStyle;
import qt.core.point : QPoint;
import qt.gui.brush : QBrush;
import qt.gui.color : QColor;
import qt.gui.painter : QPainter;
import qt.gui.pen : QPen;
import qt.helpers;

import rasterwindow : RasterWindow;

//! [h5 0]
class AnalogClockWindow : RasterWindow
{
    mixin(Q_OBJECT_D);

public:
//! [c6]
    this()
    {
//! [h5 0]
        super();
        this.setTitle("Analog Clock");
        this.resize(200, 200);

        timerId = startTimer(1000);
//! [h5 1]
    }
//! [c6]

protected:
//! [c7]
    extern(C++) override void timerEvent(QTimerEvent event)
    {
//! [h5 1]
        if (event.timerId() == timerId)
            renderLater();
//! [h5 2]
    }
//! [c7]

//! [c1] //! [c14]
    override void render(ref QPainter p)
    {
//! [h5 2]
//! [c14]
//! [c8]
        static immutable hourHand = [QPoint(7, 8), QPoint(-7, 8), QPoint(0, -40)];
        static immutable minuteHand = [QPoint(7, 8), QPoint(-7, 8), QPoint(0, -70)];

        auto hourColor = QColor(127, 0, 127);
        auto minuteColor = QColor(0, 127, 127, 191);
//! [c8]

//! [c9]
        p.setRenderHint(QPainter.RenderHint.Antialiasing);
//! [c9] //! [c10]
        p.translate(width() / 2, height() / 2);

        immutable int side = qMin(width(), height());
        p.scale(side / 200.0, side / 200.0);
//! [c1] //! [c10]

//! [c11]
        p.setPen(PenStyle.NoPen);
        p.setBrush(QBrush(hourColor));
//! [c11]

//! [c2]
        auto time = QTime.currentTime();

        p.save();
        p.rotate(30.0 * (time.hour() + time.minute() / 60.0));
        p.drawConvexPolygon(hourHand.ptr, 3);
        p.restore();
//! [c2]

//! [c12]
        p.setPen(QPen(hourColor));

        for (int i = 0; i < 12; i++)
        {
            p.drawLine(88, 0, 96, 0);
            p.rotate(30.0);
        }
//! [c12] //! [c13]
        p.setPen(PenStyle.NoPen);
        p.setBrush(QBrush(minuteColor));
//! [c13]

//! [c3]
        p.save();
        p.rotate(6.0 * (time.minute() + time.second() / 60.0));
        p.drawConvexPolygon(minuteHand.ptr, 3);
        p.restore();
//! [c3]

//! [c4]
        p.setPen(QPen(minuteColor));

        for (int j = 0; j < 60; j++)
        {
            if ((j % 5) != 0)
                p.drawLine(92, 0, 96, 0);
            p.rotate(6.0);
        }
//! [c4]
//! [h5 2]
    }

private:
    int timerId;
}
//! [h5 2]
