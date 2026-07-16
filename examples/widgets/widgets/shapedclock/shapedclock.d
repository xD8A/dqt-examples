module shapedclock;

import qt.config;
import qt.helpers;
import qt.core.namespace;
import qt.core.global;
import qt.core.datetime;
import qt.core.point;
import qt.core.size;
import qt.core.string;
import qt.core.timer;
import qt.gui.action;
import qt.gui.color;
import qt.gui.event;
import qt.gui.painter;
import qt.gui.region;
import qt.gui.keysequence;
import qt.core.coreapplication;
import qt.widgets.widget;

class ShapedClock : QWidget
{
    mixin(Q_OBJECT_D);

    QPoint dragPosition;

    this(QWidget parent = null)
    {
        import core.stdcpp.new_;

        super(parent, WindowFlags(WindowType.FramelessWindowHint | WindowType.WindowSystemMenuHint));

        setAttribute(WidgetAttribute.WA_TranslucentBackground);

        auto timer = cpp_new!QTimer(this);
        connect(timer.signal!"timeout", this.slot!"update");
        timer.start(1000);

        auto quitAction = cpp_new!QAction(tr("E&xit"), this);
        quitAction.setShortcut(QKeySequence(tr("Ctrl+Q")));
        connect(quitAction.signal!"triggered", this.slot!"quitApp");
        addAction(quitAction);

        setContextMenuPolicy(ContextMenuPolicy.ActionsContextMenu);
        setToolTip(tr("Drag the clock with the left mouse button.\n"
                      ~ "Use the right mouse button to open a context menu."));
        setWindowTitle(tr("Shaped Analog Clock"));
    }

    @QSlot final void quitApp()
    {
        QCoreApplication.quit();
    }

    override extern(C++) void mousePressEvent(QMouseEvent event)
    {
        if (event.button() == MouseButton.LeftButton) {
            auto gp = event.globalPosition().toPoint();
            auto tl = frameGeometry().topLeft();
            dragPosition.setX(gp.x() - tl.x());
            dragPosition.setY(gp.y() - tl.y());
            event.accept();
        }
    }

    override extern(C++) void mouseMoveEvent(QMouseEvent event)
    {
        if (event.buttons() & MouseButton.LeftButton) {
            auto gp = event.globalPosition().toPoint();
            move(gp.x() - dragPosition.x(), gp.y() - dragPosition.y());
            event.accept();
        }
    }

    override extern(C++) void paintEvent(QPaintEvent)
    {
        static QPoint[3] hourHand = [
            QPoint(7, 8),
            QPoint(-7, 8),
            QPoint(0, -40)
        ];
        static QPoint[3] minuteHand = [
            QPoint(7, 8),
            QPoint(-7, 8),
            QPoint(0, -70)
        ];

        auto hourColor = QColor(127, 0, 127);
        auto minuteColor = QColor(0, 127, 127, 191);

        int side = qMin(width(), height());
        auto time = QTime.currentTime();

        auto painter = QPainter(this);
        painter.setRenderHint(QPainter.RenderHint.Antialiasing);
        painter.translate(width() / 2, height() / 2);
        painter.scale(side / 200.0, side / 200.0);

        painter.setPen(PenStyle.NoPen);
        painter.setBrush(palette().window());
        painter.drawEllipse(QPoint(0, 0), 98, 98);

        painter.setPen(PenStyle.NoPen);
        painter.setBrush(hourColor);

        painter.save();
        painter.rotate(30.0 * (time.hour() + time.minute() / 60.0));
        painter.drawConvexPolygon(hourHand.ptr, cast(int)hourHand.length);
        painter.restore();

        painter.setPen(hourColor);

        for (int i = 0; i < 12; ++i) {
            painter.drawLine(88, 0, 96, 0);
            painter.rotate(30.0);
        }

        painter.setPen(PenStyle.NoPen);
        painter.setBrush(minuteColor);

        painter.save();
        painter.rotate(6.0 * (time.minute() + time.second() / 60.0));
        painter.drawConvexPolygon(minuteHand.ptr, cast(int)minuteHand.length);
        painter.restore();

        painter.setPen(minuteColor);

        for (int j = 0; j < 60; ++j) {
            if ((j % 5) != 0)
                painter.drawLine(92, 0, 96, 0);
            painter.rotate(6.0);
        }
    }

    override extern(C++) void resizeEvent(QResizeEvent)
    {
        int side = qMin(width(), height());
        auto maskedRegion = QRegion(width() / 2 - side / 2, height() / 2 - side / 2,
                                    side, side, QRegion.RegionType.Ellipse);
        setMask(maskedRegion);
    }

    override extern(C++) QSize sizeHint() const
    {
        return QSize(200, 200);
    }
}
