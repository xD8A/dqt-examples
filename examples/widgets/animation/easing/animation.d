module animation;

import qt.core.object : QObject;
import qt.core.propertyanimation : QPropertyAnimation;

class Animation : QPropertyAnimation
{
public:
    enum PathType
    {
        LinearPath,
        CirclePath,
        NPathTypes,
    }

    this(QObject target, const QByteArray prop, QObject parent = null)
    {
        super(target, prop, parent);
        setPathType(PathType.LinearPath);
    }

    void setPathType(PathType pathType)
    {
        import qt.core.logging : qWarning;
        import qt.gui.painter.path : QPainterPath;

        if (pathType >= NPathTypes)
            mixin(qWarning)("Unknown pathType %d", pathType);

        m_pathType = pathType;
        m_path = QPainterPath();
    }

    extern (C++) override void updateCurrentTime(int currentTime)
    {
        import qt.core.global : qreal;
        import qt.core.point : QPointF;

        if (m_pathType == CirclePath)
        {
            if (m_path.isEmpty())
            {
                QPointF to = endValue().toPointF();
                QPointF from = startValue().toPointF();
                m_path.moveTo(from);
                m_path.addEllipse(QRectF(from, to));
            }

            int dura = duration();
            const qreal progress = ((dura == 0) ? 1 : ((((currentTime - 1) % dura) + 1) / qreal(
                    dura)));

            qreal easedProgress = easingCurve().valueForProgress(progress);
            if (easedProgress > 1.0)
            {
                easedProgress -= 1.0;
            }
            else if (easedProgress < 0)
            {
                easedProgress += 1.0;
            }
            QPointF pt = m_path.pointAtPercent(easedProgress);
            updateCurrentValue(pt);
            /+ emit +/
            valueChanged(pt);
        }
        else
        {
            super.updateCurrentTime(currentTime);
        }
    }

    QPainterPath m_path;
    PathType m_pathType;
}
