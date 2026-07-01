module analogclockwindow;

import qt.config;
import qt.helpers;
import rasterwindow;
import qt.core.coreevent;
import qt.core.datetime;
import qt.core.namespace;
import qt.core.point;
import qt.core.rect;
import qt.core.string;
import qt.gui.brush;
import qt.gui.color;
import qt.gui.painter;
import qt.gui.pen;
import qt.widgets.widget;

//! [6]
class AnalogClockWindow : RasterWindow
{
    mixin(Q_OBJECT_D);
//! [6]

public:
    //! [5]
    this()
    {
        import qt.widgets.widget;

        super();
        this.setTitle("Analog Clock");
        this.resize(200, 200);

        //! [7]
        timerId = startTimer(1000);
        //! [7]
    }
    //! [5]

protected:
    //! [14]
    extern(C++) override void timerEvent(QTimerEvent event)
    {
        if (event.timerId() == timerId)
            renderLater();
    }
    //! [14]

    //! [8]
    override void render(ref QPainter p)
    {
        import std.algorithm;
        import qt.core.global;

        //! [9]
        static immutable hourHand = [QPoint(7, 8), QPoint(-7, 8), QPoint(0, -40)];
        static immutable minuteHand = [QPoint(7, 8), QPoint(-7, 8), QPoint(0, -70)];
        //! [9]

        auto hourColor = QColor(127, 0, 127);
        auto minuteColor = QColor(0, 127, 127, 191);

        //! [10]
        p.setRenderHint(QPainter.RenderHint.Antialiasing);
        p.translate(width() / 2, height() / 2);

        int side = min(width(), height());
        p.scale(side / 200.0, side / 200.0);
        //! [10]

        //! [2]
        p.setPen(PenStyle.NoPen);
        p.setBrush(QBrush(hourColor));
        //! [2]

        auto time = QTime.currentTime();

        //! [11]
        p.save();
        p.rotate(30.0 * (time.hour() + time.minute() / 60.0));
        p.drawConvexPolygon(hourHand.ptr, 3);
        p.restore();
        //! [11]

        p.setPen(QPen(hourColor));

        //! [12]
        for (int i = 0; i < 12; i++)
        {
            p.drawLine(88, 0, 96, 0);
            p.rotate(30.0);
        }
        //! [12]

        //! [3]
        p.setPen(PenStyle.NoPen);
        p.setBrush(QBrush(minuteColor));
        //! [3]

        //! [13]
        p.save();
        p.rotate(6.0 * (time.minute() + time.second() / 60.0));
        p.drawConvexPolygon(minuteHand.ptr, 3);
        p.restore();
        //! [13]

        p.setPen(QPen(minuteColor));

        //! [4]
        for (int j = 0; j < 60; j++)
        {
            if ((j % 5) != 0)
                p.drawLine(92, 0, 96, 0);
            p.rotate(6.0);
        }
        //! [4]
    }
    //! [8]

private:
    int timerId;
}
