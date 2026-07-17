module shapeitem;

import qt.core.point : QPoint;
import qt.core.string : QString;
import qt.gui.color : QColor;
import qt.gui.painterpath : QPainterPath;

//! [h0 0]
class ShapeItem
{
//! [h0 0]
//! [h0 1]
public:
//! [c4]
    this(ref const(QPainterPath) path, ref const(QPoint) position, ref const QColor color, ref const(
            QString) toolTip)
    {
//! [h0 1]
        myPath = path;
        myPosition = position;
        myColor = color;
        myToolTip = toolTip;
//! [h0 2]
    }
//! [c4]

//! [c6]
    @property void position(const(QPoint) position)
    {
//! [h0 2]
        myPosition = position;
//! [h0 3]
    }
//! [c6]

//! [c0]
    @property ref const(QPainterPath) path() const
    {
//! [h0 3]
        return myPath;
//! [h0 4]
    }
//! [c0]

//! [c1]
    @property ref const(QPoint) position() const
    {
//! [h0 4]
        return myPosition;
//! [h0 5]
    }
//! [c1]

//! [c2]
    @property ref const(QColor) color() const
    {
//! [h0 5]
        return myColor;
//! [h0 6]
    }
//! [c2]

//! [c3]
    @property ref const(QString) toolTip() const
    {
//! [h0 6]
        return myToolTip;
//! [h0 7]
    }
//! [c3]

private:
    QPainterPath myPath;
    QPoint myPosition;
    QColor myColor;
    QString myToolTip;
//! [h0 7]
//! [h0 8]
}
//! [h0 8]
