module shapeitem;

import qt.core.point : QPoint;
import qt.core.string : QString;
import qt.gui.color : QColor;
import qt.gui.painterpath : QPainterPath;

class ShapeItem
{
public:
    this(ref const(QPainterPath) path, ref const(QPoint) position, ref const QColor color, ref const(
            QString) toolTip)
    {
        myPath = path;
        myPosition = position;
        myColor = color;
        myToolTip = toolTip;
    }

    @property void position(const(QPoint) position)
    {
        myPosition = position;
    }

    @property ref const(QPainterPath) path() const
    {
        return myPath;
    }

    @property ref const(QPoint) position() const
    {
        return myPosition;
    }

    @property ref const(QColor) color() const
    {
        return myColor;
    }

    @property ref const(QString) toolTip() const
    {
        return myToolTip;
    }

private:
    QPainterPath myPath;
    QPoint myPosition;
    QColor myColor;
    QString myToolTip;
}
