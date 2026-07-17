module renderarea;

import qt.config;
import qt.core.namespace : BrushStyle, GlobalColor, PenStyle;
import qt.core.rect : QRect;
import qt.core.size : QSize;
import qt.gui.brush : QBrush;
import qt.gui.font : QFont;
import qt.gui.fontmetrics : QFontMetrics;
import qt.gui.event : QPaintEvent;
import qt.gui.painter : QPainter;
import qt.gui.painterpath : QPainterPath;
import qt.helpers;
import qt.widgets.widget : QWidget;

//! [h0]
enum Operation { NoTransformation, Translate, Rotate, Scale }
//! [h0]

//! [h1 0]
class RenderArea : QWidget
{
//! [h1 0]
//! [h1 1]
    mixin(Q_OBJECT_D);

public:
//! [c0]
    this(QWidget parent = null)
    {
//! [h1 1]
        super(parent);
        shape = QPainterPath.create();

        auto newFont = QFont(font());
        newFont.setPixelSize(12);
        setFont(newFont);

        auto fontMetrics = QFontMetrics(newFont);
        xBoundingRect = fontMetrics.boundingRect(tr("x"));
        yBoundingRect = fontMetrics.boundingRect(tr("y"));
//! [h1 2]
    }
//! [c0]

//! [c1]
    void setOperations(ref const Operation[] operations)
    {
//! [h1 2]
        this.operations = operations.dup;
        update();
//! [h1 3]
    }
//! [c1]

//! [c2]
    void setShape(ref const (QPainterPath) shape)
    {
//! [h1 3]
        this.shape = shape;
        update();
//! [h1 4]
    }
//! [c2]

//! [c3]
    extern (C++) override QSize minimumSizeHint() const
    {
//! [h1 4]
        return QSize(182, 182);
//! [h1 5]
    }
//! [c3]

//! [c4]
    extern (C++) override QSize sizeHint() const 
    {
//! [h1 5]
        return QSize(232, 232);
//! [h1 6]
    }
//! [c4]

protected:
//! [c5 0]
    extern (C++) override void paintEvent(QPaintEvent event)
    {
//! [h1 6]
//! [c5 0]
//! [c5 1]
        auto painter = QPainter(this);
        painter.setRenderHint(QPainter.RenderHint.Antialiasing);
        painter.fillRect(event.rect(), QBrush(GlobalColor.white));

        painter.translate(66, 66);
//! [c5 1]

//! [c6]
        painter.save();
        transformPainter(painter);
        drawShape(painter);
        painter.restore();
//! [c6]

//! [c7]
        drawOutline(painter);
//! [c7]

//! [c8 0]
        transformPainter(painter);
        drawCoordinates(painter);
//! [c8 0]
//! [c8 1]
//! [h1 7]
    }
//! [c8 1]
//! [h1 7]

//! [h2 0]
private:
//! [c9]
    void drawCoordinates(ref QPainter painter)
    {
//! [h2 0]
        painter.setPen(GlobalColor.red);

        painter.drawLine(0, 0, 50, 0);
        painter.drawLine(48, -2, 50, 0);
        painter.drawLine(48, 2, 50, 0);
        painter.drawText(60 - xBoundingRect.width() / 2,
                        0 + xBoundingRect.height() / 2, tr("x"));

        painter.drawLine(0, 0, 0, 50);
        painter.drawLine(-2, 48, 0, 50);
        painter.drawLine(2, 48, 0, 50);
        painter.drawText(0 - yBoundingRect.width() / 2,
                        60 + yBoundingRect.height() / 2, tr("y"));
//! [h2 1]
    }
//! [c9]

//! [c10]
    void drawOutline(ref QPainter painter)
    {
//! [h2 1]
        painter.setPen(GlobalColor.darkGreen);
        painter.setPen(PenStyle.DashLine);
        painter.setBrush(BrushStyle.NoBrush);
        painter.drawRect(0, 0, 100, 100);
//! [h2 2]
    }
//! [c10]

//! [c11]
    void drawShape(ref QPainter painter)
    {
//! [h2 2]
        painter.fillPath(shape, QBrush(GlobalColor.blue));
//! [h2 3]
    }
//! [c11]

//! [c12]
    void transformPainter(ref QPainter painter)
    {
//! [h2 3]
        for (int i = 0; i < operations.length; ++i) {
            switch (operations[i]) {
            case Operation.Translate:
                painter.translate(50, 50);
                break;
            case Operation.Scale:
                painter.scale(0.75, 0.75);
                break;
            case Operation.Rotate:
                painter.rotate(60);
                break;
            case Operation.NoTransformation:
            default:
               {}
            }
        }
//! [h2 4]
    }
//! [c12]

    Operation[] operations;
    QPainterPath shape;
    QRect xBoundingRect;
    QRect yBoundingRect;
//! [h2 4]
//! [h2 5]
}
//! [h2 5]
