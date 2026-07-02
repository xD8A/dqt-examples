module analogclock;

import qt.config;
import qt.helpers;
import qt.core.timer;
import qt.core.point;
import qt.core.datetime;
import qt.core.namespace;
import qt.gui.painter;
import qt.gui.color;
import qt.gui.pen;
import qt.gui.brush;
import qt.gui.event;
import qt.widgets.widget;

//! [0]
class AnalogClock : QWidget
{
    mixin(Q_OBJECT_D);
//! [0]

public:
    //! [1]
    this(QWidget parent = null)
    {
        import core.stdcpp.new_;
        super(parent);

        auto timer = cpp_new!QTimer(this);
        connect(timer.signal!"timeout", this.slot!"update");
        timer.start(1000);

        setWindowTitle(tr("Analog Clock"));
        resize(200, 200);
    }
    //! [1]

protected:
    //! [8]
    override extern(C++) void paintEvent(QPaintEvent e)
    //! [8] //! [10]
    {
        import std.algorithm;

        static immutable hourHand = [QPoint(7, 8), QPoint(-7, 8), QPoint(0, -40)];
        static immutable minuteHand = [QPoint(7, 8), QPoint(-7, 8), QPoint(0, -70)];

        auto hourColor = QColor(127, 0, 127);
        auto minuteColor = QColor(0, 127, 127, 191);

        int side = min(width(), height());
        auto time = QTime.currentTime();
    //! [10]

    //! [11]
        auto p = QPainter(this);
    //! [11] //! [12]
        p.setRenderHint(QPainter.RenderHint.Antialiasing);
    //! [12] //! [13]
        p.translate(width() / 2, height() / 2);
    //! [13] //! [14]
        p.scale(side / 200.0, side / 200.0);
    //! [14]

    //! [15]
        p.setPen(PenStyle.NoPen);
    //! [15] //! [16]
        p.setBrush(QBrush(hourColor));
    //! [16]

    //! [17]
        p.save();
    //! [17] //! [19]
        p.rotate(30.0 * (time.hour() + time.minute() / 60.0));
        p.drawConvexPolygon(hourHand.ptr, 3);
        p.restore();
    //! [19]

    //! [20]
        p.setPen(QPen(hourColor));
    //! [20] //! [21]

        for (int i = 0; i < 12; ++i)
        {
            p.drawLine(88, 0, 96, 0);
            p.rotate(30.0);
        }
    //! [21]

    //! [22]
        p.setPen(PenStyle.NoPen);
    //! [22] //! [23]
        p.setBrush(QBrush(minuteColor));
    //! [23]

        p.save();
        p.rotate(6.0 * (time.minute() + time.second() / 60.0));
        p.drawConvexPolygon(minuteHand.ptr, 3);
        p.restore();

    //! [25]
        p.setPen(QPen(minuteColor));
    //! [25] //! [26]

        for (int j = 0; j < 60; ++j)
        {
            if ((j % 5) != 0)
                p.drawLine(92, 0, 96, 0);
            p.rotate(6.0);
        }
    //! [26]
    }
}
