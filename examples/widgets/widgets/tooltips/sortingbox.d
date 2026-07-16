module sortingbox;

import qt.config;
import qt.core.coreevent : QEvent;
import qt.core.point : QPoint;
import qt.core.string : QString;
import qt.gui.color : QColor;
import qt.gui.event : QMouseEvent, QPaintEvent, QResizeEvent;
import qt.gui.icon : QIcon;
import qt.gui.painterpath : QPainterPath;
import qt.helpers;
import qt.widgets.toolbutton : QToolButton;
import qt.widgets.widget : QWidget;
import shapeitem : ShapeItem;

class SortingBox : QWidget
{
    mixin(Q_OBJECT_D);
public:
    this(QWidget parent = null)
    {
        import qt.core.global : qreal;
        import qt.core.rect : QRectF;
        import qt.gui.palette : QPalette;

        super(parent);
        circlePath = QPainterPath.create();
        squarePath = QPainterPath.create();
        trianglePath = QPainterPath.create();

        setMouseTracking(true);
        setBackgroundRole(QPalette.ColorRole.Base);

        itemInMotionIndex = -1;

        newCircleButton = createToolButton!"createNewCircle"(tr("New Circle"),
            QIcon(":/images/circle.png"));

        newSquareButton = createToolButton!"createNewSquare"(tr("New Square"),
            QIcon(":/images/square.png"));

        newTriangleButton = createToolButton!"createNewTriangle"(tr("New Triangle"),
            QIcon(":/images/triangle.png"));

        circlePath.addEllipse(QRectF(0, 0, 100, 100));
        squarePath.addRect(QRectF(0, 0, 100, 100));

        circlePath.addEllipse(QRectF(0, 0, 100, 100));
        squarePath.addRect(QRectF(0, 0, 100, 100));

        qreal x = trianglePath.currentPosition().x();
        qreal y = trianglePath.currentPosition().y();
        trianglePath.moveTo(x + 120 / 2, y);
        trianglePath.lineTo(0, 100);
        trianglePath.lineTo(120, 100);
        trianglePath.lineTo(x + 120 / 2, y);

        setWindowTitle(tr("Tool Tips"));
        resize(500, 300);

        createShapeItem(circlePath, tr("Circle"), initialItemPosition(circlePath),
            initialItemColor());
        createShapeItem(squarePath, tr("Square"), initialItemPosition(squarePath),
            initialItemColor());
        createShapeItem(trianglePath, tr("Triangle"),
            initialItemPosition(trianglePath), initialItemColor());
    }

protected:
    extern (C++) override bool event(QEvent event)
    {
        import qt.gui.event : QHelpEvent;
        import qt.widgets.tooltip : QToolTip;

        if (event.type() == QEvent.Type.ToolTip)
        {
            auto helpEvent = cast(QHelpEvent)(event);
            int index = itemAt(helpEvent.pos());
            if (index != -1)
            {
                QToolTip.showText(helpEvent.globalPos(), shapeItems[index].toolTip);
            }
            else
            {
                QToolTip.hideText();
                event.ignore();
            }

            return true;
        }
        return super.event(event);
    }

    extern (C++) override void resizeEvent(QResizeEvent event)
    {
        import qt.widgets.style : QStyle;

        immutable int margin = style().pixelMetric(QStyle.PixelMetric.PM_LayoutTopMargin);
        immutable int x = width() - margin;
        int y = height() - margin;

        y = updateButtonGeometry(newCircleButton, x, y);
        y = updateButtonGeometry(newSquareButton, x, y);
        updateButtonGeometry(newTriangleButton, x, y);
    }

    extern (C++) override void paintEvent(QPaintEvent event)
    {
        import qt.gui.painter : QPainter;

        auto painter = QPainter(this);
        painter.setRenderHint(QPainter.RenderHint.Antialiasing);
        foreach (shapeItem; shapeItems)
        {
            painter.translate(shapeItem.position);
            painter.setBrush(shapeItem.color);
            painter.drawPath(shapeItem.path);
            /+ 
            TODO:
             * QPoint.opUnary!("-")()

            painter.translate(-shapeItem.position);
             +/
            painter.translate(QPoint(-shapeItem.position.x(), -shapeItem.position.y()));
        }
    }

    extern (C++) override void mousePressEvent(QMouseEvent event)
    {
        import qt.core.namespace : MouseButton;
        import std.algorithm.mutation : bringToFront;

        if (event.button() == MouseButton.LeftButton)
        {
            int index = itemAt(event.position().toPoint());
            if (index != -1)
            {
                previousPosition = event.position().toPoint();
                /+
                TODO:
                * QList.move

                shapeItems.move(index, shapeItems.size() - 1);
                +/
                bringToFront(shapeItems[index + 1 .. $], shapeItems[index .. index + 1]);
                itemInMotionIndex = cast(int)(shapeItems.length) - 1;
                update();
            }
        }
    }

    extern (C++) override void mouseMoveEvent(QMouseEvent event)
    {
        import qt.core.namespace : MouseButton;

        if ((event.buttons() & MouseButton.LeftButton) && itemInMotionIndex != -1)
            moveItemTo(event.position().toPoint());
    }

    extern (C++) override void mouseReleaseEvent(QMouseEvent event)
    {
        import qt.core.namespace : MouseButton;

        if (event.button() == MouseButton.LeftButton && itemInMotionIndex != -1)
        {
            moveItemTo(event.position().toPoint());
            itemInMotionIndex = -1;
        }
    }

private:
    @QSlot void createNewCircle()
    {
        static int count = 1;
        createShapeItem(circlePath, tr("Circle <%1>").arg(++count),
            randomItemPosition(), randomItemColor());
    }

    @QSlot void createNewSquare()
    {
        static int count = 1;
        createShapeItem(squarePath, tr("Square <%1>").arg(++count),
            randomItemPosition(), randomItemColor());
    }

    @QSlot void createNewTriangle()
    {
        static int count = 1;
        createShapeItem(trianglePath, tr("Triangle <%1>").arg(++count),
            randomItemPosition(), randomItemColor());
    }

    int updateButtonGeometry(QToolButton button, int x, int y)
    {
        import qt.widgets.style : QStyle;

        auto size = button.sizeHint();
        button.setGeometry(x - size.rwidth(), y - size.rheight(),
            size.rwidth(), size.rheight());

        return y - size.rheight()
            - style().pixelMetric(QStyle.PixelMetric.PM_LayoutVerticalSpacing);
    }

    void createShapeItem(ref const(QPainterPath) path, const(QString) toolTip,
        const(QPoint) pos, const(QColor) color)
    {
        auto shapeItem = new ShapeItem(path, pos, color, toolTip);

        shapeItems ~= shapeItem;
        update();
    }

    int itemAt(const(QPoint) pos)
    {
        import qt.core.point : QPointF;

        for (int i = cast(int) shapeItems.length - 1; i >= 0; --i)
        {
            auto item = shapeItems[i];
            auto pt = QPointF(pos - item.position);
            if (item.path.contains(pt))
                return i;
        }
        return -1;
    }

    void moveItemTo(const(QPoint) pos)
    {
        immutable auto offset = pos - previousPosition;
        shapeItems[itemInMotionIndex].position = shapeItems[itemInMotionIndex].position + offset;
        previousPosition = pos;
        update();
    }

    QPoint initialItemPosition(ref const(QPainterPath) path)
    {
        import qt.core.global : qRound;

        int x;
        immutable int y = (height() - qRound(path.controlPointRect().height()) / 2);
        if (shapeItems.length == 0)
            x = ((3 * width()) / 2 - qRound(path.controlPointRect().width())) / 2;
        else
            x = cast(int)((width() / shapeItems.length
                    - qRound(path.controlPointRect().width())) / 2);

        return QPoint(x, y);
    }

    QPoint randomItemPosition()
    {
        /+
        TODO:
        * QRandomGenerator

        auto x = QRandomGenerator.global().bounded(width() - 120);
        auto y = QRandomGenerator.global().bounded(height() - 120);
        +/
        import std.random : uniform;

        auto x = uniform(0, width() - 120);
        auto y = uniform(0, height() - 120);
        return QPoint(x, y);
    }

    QColor initialItemColor()
    {
        return QColor.fromHsv(((shapeItems.length + 1) * 85) % 256, 255, 190);
    }

    QColor randomItemColor()
    {
        /+
        TODO:
        * QRandomGenerator

        auto h = QRandomGenerator.global().bounded(256);
        +/
        import std.random : uniform;

        auto h = uniform(0, 256);
        return QColor.fromHsv(h, 255, 190);
    }

    QToolButton createToolButton(string member)(const(QString) toolTip, const(QIcon) icon)
    {
        import core.stdcpp.new_ : cpp_new;
        import qt.core.size : QSize;

        auto button = cpp_new!QToolButton(this);
        button.setToolTip(toolTip);
        button.setIcon(icon);
        button.setIconSize(QSize(32, 32));
        connect(button.signal!"clicked", this.slot!member);

        return button;
    }

    ShapeItem[] shapeItems;
    QPainterPath circlePath;
    QPainterPath squarePath;
    QPainterPath trianglePath;

    QPoint previousPosition;
    int itemInMotionIndex = -1;

    QToolButton newCircleButton;
    QToolButton newSquareButton;
    QToolButton newTriangleButton;
}
