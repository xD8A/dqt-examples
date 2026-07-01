module rasterwindow;

import qt.config;
import qt.core.coreevent;
import qt.core.global;
import qt.core.rect;
import qt.core.string;
import qt.gui.backingstore;
import qt.gui.brush;
import qt.gui.event;
import qt.gui.painter;
import qt.gui.window;
import qt.helpers;

//! [0]
class RasterWindow : QWindow
{
    mixin(Q_OBJECT_D);
//! [0]

public:
    //! [1]
    this(QWindow parent = null)
    {
        import core.stdcpp.new_;

        super(parent);
        backingStore = cpp_new!QBackingStore(this);
        setGeometry(100, 100, 300, 200);
    }
    //! [1]

    ~this()
    {
        import core.stdcpp.new_;
        cpp_delete(backingStore);
    }

    //! [4]
    void render(ref QPainter painter)
    {
        import qt.core.namespace;

        painter.drawText(QRectF(0, 0, cast(qreal)width(), cast(qreal)height()),
            cast(int)AlignmentFlag.AlignCenter, QString("QWindow"));
    }
    //! [4]

protected:
    //! [7]
    extern(C++) override bool event(QEvent event)
    {
        if (event.type() == QEvent.Type.UpdateRequest)
        {
            renderNow();
            return true;
        }
        return QWindow.event(event);
    }
    //! [7]

    //! [6]
    void renderLater()
    {
        requestUpdate();
    }
    //! [6]

    //! [3]
    void renderNow()
    {
        import qt.core.namespace;
        import qt.gui.paintdevice;
        import qt.gui.region;

        if (!isExposed())
            return;

        auto rect = QRect(0, 0, width(), height());
        backingStore.beginPaint(QRegion(rect));

        auto device = backingStore.paintDevice();
        auto painter = QPainter(device);

        painter.fillRect(0, 0, width(), height(),
            QBrush(QGradient(QGradient.Preset.NightFade)));
        render(painter);
        painter.end();

        backingStore.endPaint();
        backingStore.flush(QRegion(rect));
    }
    //! [3]

    //! [5]
    extern(C++) override void resizeEvent(QResizeEvent resizeEvent)
    {
        backingStore.resize(resizeEvent.size());
    }
    //! [5]

    //! [2]
    extern(C++) override void exposeEvent(QExposeEvent)
    {
        if (isExposed())
            renderNow();
    }
    //! [2]

private:
    QBackingStore* backingStore;
}
