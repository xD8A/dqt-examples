module rasterwindow;

import core.stdcpp.new_ : cpp_delete, cpp_new;
import qt.config;
import qt.core.coreevent : QEvent;
import qt.core.global : qreal;
import qt.core.namespace : AlignmentFlag;
import qt.core.rect : QRect, QRectF;
import qt.core.string : QString;
import qt.gui.backingstore : QBackingStore;
import qt.gui.brush : QBrush, QGradient;
import qt.gui.event : QExposeEvent, QResizeEvent;
import qt.gui.painter : QPainter;
import qt.gui.window : QWindow;
import qt.helpers;

//! [h1 0]
class RasterWindow : QWindow
{
    mixin(Q_OBJECT_D);
 
public:
//! [c1]
    this(QWindow parent = null)
    {
//! [h1 0]
        super(parent);
        backingStore = cpp_new!QBackingStore(this);
        setGeometry(100, 100, 300, 200);
//! [h1 1]
    }
//! [c1]

    ~this()
    {
//! [h1 1]
        cpp_delete(backingStore);
//! [h1 2]
    }

//! [c4]
    void render(ref QPainter painter)
    {
//! [h1 2]
        painter.drawText(QRectF(0, 0, cast(qreal)width(), cast(qreal)height()),
            cast(int)AlignmentFlag.AlignCenter, QString("QWindow"));
//! [h1 3]
    }
//! [c4]

protected:
//! [c7]
    extern(C++) override bool event(QEvent event)
    {
//! [h1 3]
        if (event.type() == QEvent.Type.UpdateRequest)
        {
            renderNow();
            return true;
        }
        return QWindow.event(event);
//! [h1 4]
    }
//! [c7]

//! [c6]
    void renderLater()
    {
//! [h1 4]
        requestUpdate();
//! [h1 5]
    }
//! [c6]

//! [c3]
    void renderNow()
    {
//! [h1 5]
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
//! [h1 6]
    }
//! [c3]

//! [c5]
    extern(C++) override void resizeEvent(QResizeEvent resizeEvent)
    {
//! [h1 6]
        backingStore.resize(resizeEvent.size());
//! [h1 7]
    }
//! [c5]

//! [c2]
    extern(C++) override void exposeEvent(QExposeEvent _)
    {
//! [h1 7]
        if (isExposed())
            renderNow();
//! [h1 8]
    }
//! [c2]

private:
    QBackingStore* backingStore;
}
//! [h1 8]
