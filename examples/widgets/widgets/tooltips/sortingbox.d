module sortingbox;

import std.algorithm.mutation : bringToFront;
import std.random : uniform;
import core.stdcpp.new_ : cpp_new;
import qt.config;
import qt.core.coreevent : QEvent;
import qt.core.global : qreal, qRound;
import qt.core.namespace : MouseButton;
import qt.core.point : QPoint, QPointF;
import qt.core.rect : QRectF;
import qt.core.size : QSize;
import qt.core.string : QString;
import qt.gui.color : QColor;
import qt.gui.event : QHelpEvent, QMouseEvent, QPaintEvent, QResizeEvent;
import qt.gui.icon : QIcon;
import qt.gui.painter : QPainter;
import qt.gui.painterpath : QPainterPath;
import qt.gui.palette : QPalette;
import qt.helpers;
import qt.widgets.style : QStyle;
import qt.widgets.toolbutton : QToolButton;
import qt.widgets.tooltip : QToolTip;
import qt.widgets.widget : QWidget;

import shapeitem : ShapeItem;

//! [h0 0]
class SortingBox : QWidget
{
//! [h0 0]
//! [h0 1]
    mixin(Q_OBJECT_D);
public:
//! [c0 0]
    this(QWidget parent = null)
    {
//! [h0 1]
//! [c0 0]
//! [c0 1]
        super(parent);
        circlePath = QPainterPath.create();
        squarePath = QPainterPath.create();
        trianglePath = QPainterPath.create();
//! [c0 1]
//! [c1]
        setMouseTracking(true);
//! [c1]
//! [c2]
        setBackgroundRole(QPalette.ColorRole.Base);
//! [c2]

        itemInMotionIndex = -1;

//! [c3]
        newCircleButton = createToolButton(tr("New Circle"),
            QIcon(":/images/circle.png"), &createNewCircle);

        newSquareButton = createToolButton(tr("New Square"),
            QIcon(":/images/square.png"), &createNewSquare);

        newTriangleButton = createToolButton(tr("New Triangle"),
            QIcon(":/images/triangle.png"), &createNewTriangle);

        circlePath.addEllipse(QRectF(0, 0, 100, 100));
        squarePath.addRect(QRectF(0, 0, 100, 100));

        qreal x = trianglePath.currentPosition().x();
        qreal y = trianglePath.currentPosition().y();
        trianglePath.moveTo(x + 120 / 2, y);
        trianglePath.lineTo(0, 100);
        trianglePath.lineTo(120, 100);
        trianglePath.lineTo(x + 120 / 2, y);
//! [c3]

//! [c4 0]
        setWindowTitle(tr("Tool Tips"));
        resize(500, 300);

        createShapeItem(circlePath, tr("Circle"), initialItemPosition(circlePath),
            initialItemColor());
        createShapeItem(squarePath, tr("Square"), initialItemPosition(squarePath),
            initialItemColor());
        createShapeItem(trianglePath, tr("Triangle"),
            initialItemPosition(trianglePath), initialItemColor());
//! [c4 0]
//! [h0 2]
//! [c4 1]
    }
//! [c4 1]

protected:
//! [c5]
    extern (C++) override bool event(QEvent event)
    {
//! [c5]
//! [h0 2]
//! [c6 0]
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
//! [c6 0]
//! [h0 3]
//! [c6 1]
    }
//! [c6 1]

//! [c7]
    extern (C++) override void resizeEvent(QResizeEvent event)
    {
//! [h0 3]
        immutable int margin = style().pixelMetric(QStyle.PixelMetric.PM_LayoutTopMargin);
        immutable int x = width() - margin;
        int y = height() - margin;

        y = updateButtonGeometry(newCircleButton, x, y);
        y = updateButtonGeometry(newSquareButton, x, y);
        updateButtonGeometry(newTriangleButton, x, y);
//! [h0 4]
    }
//! [c7]

//! [c8 0]
    extern (C++) override void paintEvent(QPaintEvent event)
    {
//! [c8 0]
//! [h0 4]
//! [c8 1]
        auto painter = QPainter(this);
        painter.setRenderHint(QPainter.RenderHint.Antialiasing);
        foreach (shapeItem; shapeItems)
//! [c8 1]
        {
//! [c9]
            painter.translate(shapeItem.position);
//! [c9]
//! [c10 0]
            painter.setBrush(shapeItem.color);
            painter.drawPath(shapeItem.path);
            /*
            TODO:
             * QPoint.opUnary!("-")()

            painter.translate(-shapeItem.position);
            */
            painter.translate(QPoint(-shapeItem.position.x(), -shapeItem.position.y()));
//! [c10 0]
        }
//! [h0 5]
//! [c10 1]
    }
//! [c10 1]

//! [c11]
    extern (C++) override void mousePressEvent(QMouseEvent event)
    {
//! [h0 5]
        if (event.button() == MouseButton.LeftButton)
        {
            int index = itemAt(event.position().toPoint());
            if (index != -1)
            {
                previousPosition = event.position().toPoint();
                /*
                TODO:
                * QList.move

                shapeItems.move(index, shapeItems.size() - 1);
                */
                bringToFront(shapeItems[index .. index + 1], shapeItems[index + 1 .. $]);
                itemInMotionIndex = cast(int)(shapeItems.length) - 1;
                update();
            }
        }
//! [h0 6]
    }
//! [c11]

//! [c12]
    extern (C++) override void mouseMoveEvent(QMouseEvent event)
    {
//! [h0 6]
        if ((event.buttons() & MouseButton.LeftButton) && itemInMotionIndex != -1)
            moveItemTo(event.position().toPoint());
//! [h0 7]
    }
//! [c12]

//! [c13]
    extern (C++) override void mouseReleaseEvent(QMouseEvent event)
    {
//! [h0 7]
        if (event.button() == MouseButton.LeftButton && itemInMotionIndex != -1)
        {
            moveItemTo(event.position().toPoint());
            itemInMotionIndex = -1;
        }
//! [h0 8]
    }
//! [c13]

private:
//! [c14]
    @QSlot void createNewCircle()
    {
//! [h0 8]
        static int count = 1;
        createShapeItem(circlePath, tr("Circle <%1>").arg(++count),
            randomItemPosition(), randomItemColor());
//! [h0 9]
    }
//! [c14]

//! [c15]
    @QSlot void createNewSquare()
    {
//! [h0 9]
        static int count = 1;
        createShapeItem(squarePath, tr("Square <%1>").arg(++count),
            randomItemPosition(), randomItemColor());
//! [h0 10]
    }
//! [c15]

//! [c16]
    @QSlot void createNewTriangle()
    {
//! [h0 10]
        static int count = 1;
        createShapeItem(trianglePath, tr("Triangle <%1>").arg(++count),
            randomItemPosition(), randomItemColor());
//! [h0 11]
    }
//! [c16]
//! [h0 11]

//! [h1 0]
//! [c20]
    int updateButtonGeometry(QToolButton button, int x, int y)
    {
//! [h1 0]
        auto size = button.sizeHint();
        button.setGeometry(x - size.rwidth(), y - size.rheight(),
            size.rwidth(), size.rheight());

        return y - size.rheight()
            - style().pixelMetric(QStyle.PixelMetric.PM_LayoutVerticalSpacing);
//! [h1 1]
    }
//! [c20]

//! [c21]
    void createShapeItem(ref const(QPainterPath) path, const(QString) toolTip,
        const(QPoint) pos, const(QColor) color)
    {
//! [h1 1]
        auto shapeItem = new ShapeItem(path, pos, color, toolTip);
        shapeItems ~= shapeItem;
        update();
//! [h1 2]
    }
//! [c21]

//! [c17]
    int itemAt(const(QPoint) pos)
    {
//! [h1 2]
        for (int i = cast(int) shapeItems.length - 1; i >= 0; --i)
        {
            auto item = shapeItems[i];
            auto pt = QPointF(pos - item.position);
            if (item.path.contains(pt))
                return i;
        }
        return -1;
//! [h1 3]
    }
//! [c17]

//! [c18 0]
    void moveItemTo(const(QPoint) pos)
    {
//! [c18 0]
//! [c18 1]
//! [h1 3]
        immutable auto offset = pos - previousPosition;
        shapeItems[itemInMotionIndex].position = shapeItems[itemInMotionIndex].position + offset;
//! [c18 1]
//! [c19 0]
        previousPosition = pos;
        update();
//! [c19 0]
//! [h1 4]
//! [c19 1]
    }
//! [c19 1]

//! [c23]
    QPoint initialItemPosition(ref const(QPainterPath) path)
    {
//! [h1 4]
        int x;
        immutable int y = (height() - qRound(path.controlPointRect().height()) / 2);
        if (shapeItems.length == 0)
            x = ((3 * width()) / 2 - qRound(path.controlPointRect().width())) / 2;
        else
            x = cast(int)((width() / shapeItems.length
                    - qRound(path.controlPointRect().width())) / 2);

        return QPoint(x, y);
//! [h1 5]
    }
//! [c23]

//! [c24]
    QPoint randomItemPosition()
    {
//! [h1 5]
        /+
        TODO:
        * QRandomGenerator

        auto x = QRandomGenerator.global().bounded(width() - 120);
        auto y = QRandomGenerator.global().bounded(height() - 120);
        +/
        auto x = uniform(0, width() - 120);
        auto y = uniform(0, height() - 120);
        return QPoint(x, y);
//! [h1 6]
    }
//! [c24]

//! [c25]
    QColor initialItemColor()
    {
//! [h1 6]
        return QColor.fromHsv(((shapeItems.length + 1) * 85) % 256, 255, 190);
//! [h1 7]
    }
//! [c25]

//! [c26]
    QColor randomItemColor()
    {
//! [h1 7]
        /+
        TODO:
        * QRandomGenerator

        auto h = QRandomGenerator.global().bounded(256);
        +/
        auto h = uniform(0, 256);
        return QColor.fromHsv(h, 255, 190);
//! [h1 8]
    }
//! [c26]

//! [c22]
    QToolButton createToolButton(const(QString) toolTip, const(QIcon) icon, void delegate() slot)
    {
//! [h1 8]
        auto button = cpp_new!QToolButton(this);
        button.setToolTip(toolTip);
        button.setIcon(icon);
        button.setIconSize(QSize(32, 32));
        connect(button.signal!"clicked", this, slot);

        return button;
//! [h1 9]
    }
//! [c22]
//! [h1 9]

//! [h2 0]
    ShapeItem[] shapeItems;
    QPainterPath circlePath;
    QPainterPath squarePath;
    QPainterPath trianglePath;

    QPoint previousPosition;
    int itemInMotionIndex = -1;

    QToolButton newCircleButton;
    QToolButton newSquareButton;
    QToolButton newTriangleButton;
//! [h2 0]
//! [h2 1]
}
//! [h2 1]
