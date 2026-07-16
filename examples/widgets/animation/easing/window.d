module window;

import qt.config;
import qt.core.easingcurve : QEasingCurve;
import qt.core.size : QSize;
import qt.helpers;
import qt.qui.pixmap : QPixmap;
import qt.widgets.abstractbutton : QAbstractButton;
import qt.widgets.graphicsitem : QGraphicsPixmapItem;
import qt.widgets.graphicsscene : QGraphicsScene;
import qt.widgets.widget : QWidget;

import animation : Animation;

class PixmapItem : QGraphicsPixmapItem
{
    mixin(Q_OBJECT_D);
public:
    this(const QPixmap pix)
    {
        super(pix);
    }
}

QEasingCurve createEasingCurve(QEasingCurve.Type curveType)
{
    import qt.core.point : QPointF;

    auto curve = QEasingCurve(curveType);
    if (curveType == QEasingCurve.Type.BezierSpline)
    {
        curve.addCubicBezierSegment(QPointF(0.4, 0.1), QPointF(0.6, 0.9), QPointF(1.0, 1.0));
    }
    else if (curveType == QEasingCurve.Type.TCBSpline)
    {
        curve.addTCBSegment(QPointF(0.0, 0.0), 0, 0, 0);
        curve.addTCBSegment(QPointF(0.3, 0.4), 0.2, 1, -0.2);
        curve.addTCBSegment(QPointF(0.7, 0.6), -0.2, 1, 0.2);
        curve.addTCBSegment(QPointF(1.0, 1.0), 0, 0, 0);
    }
    return curve;
}

class Window : QWidget
{
    mixin(Q_OBJECT_D);
public:

    this(QWidget parent = null)
    {
        import core.stdcpp.new_ : cpp_new;
        import qt.core.string : QString;

        super(parent);
        m_iconSize = QSize(64, 64);
        m_ui = cpp_new!(typeof(*m_ui));
        m_ui.setupUi(this);

        auto dummy = QEasingCurve();
        m_ui.periodSpinBox.setValue(dummy.period());
        m_ui.amplitudeSpinBox.setValue(dummy.amplitude());
        m_ui.overshootSpinBox.setValue(dummy.overshoot());

        connect(m_ui.easingCurvePicker.signal!"currentRowChanged", this.slot!"curveChanged");
        connect(m_ui.buttonGroup.signal!"buttonClicked", this.slot!"pathChanged");
        connect(m_ui.periodSpinBox.signal!"valueChanged", this.slot!"periodChanged");
        connect(m_ui.amplitudeSpinBox.signal!"valueChanged", this.slot!"amplitudeChanged");
        connect(m_ui.overshootSpinBox.signal!"valueChanged", this.slot!"overshootChanged");
        createCurveIcons();

        auto pix = QPixmap(QString.fromLatin1(":/images/qt-logo.png"));
        m_item = cpp_new!PixmapItem(pix);
        m_scene.addItem(m_item);
        m_ui.graphicsView.setScene(m_scene);

        m_anim = cpp_new!Animation(m_item, "pos", this);
        m_anim.setEasingCurve(QEasingCurve.Type.OutBounce);
        m_ui.easingCurvePicker.setCurrentRow(cast(int) QEasingCurve.Type.OutBounce);

        startAnimation();
    }

    ~this()
    {
        import core.stdcpp.new_ : cpp_delete;

        cpp_delete(m_ui);
    }

private:
    @QSlot void curveChanged(int row)
    {
        auto curveType = cast(QEasingCurve.Type) row;
        m_anim.setEasingCurve(createEasingCurve(curveType));
        m_anim.setCurrentTime(0);

        auto isElastic = curveType >= QEasingCurve.Type.InElastic && curveType <= QEasingCurve
            .Type.OutInElastic;
        auto isBounce = curveType >= QEasingCurve.Type.InBounce && curveType <= QEasingCurve
            .Type.OutInBounce;
        m_ui.periodSpinBox.setEnabled(isElastic);
        m_ui.amplitudeSpinBox.setEnabled(isElastic || isBounce);
        m_ui.overshootSpinBox.setEnabled(curveType >= QEasingCurve.Type.InBack && curveType <= QEasingCurve
                .Type.OutInBack);
    }

    @QSlot void pathChanged(QAbstractButton button)
    {
        const index = m_ui.buttonGroup.id(button);
        m_anim.setPathType(Animation.PathType(index));
    }

    @QSlot void periodChanged(double value)
    {
        auto curve = m_anim.easingCurve();
        curve.setPeriod(value);
        m_anim.setEasingCurve(curve);
    }

    @QSlot void amplitudeChanged(double value)
    {
        auto curve = m_anim.easingCurve();
        curve.setAmplitude(value);
        m_anim.setEasingCurve(curve);
    }

    @QSlot void overshootChanged(double value)
    {
        auto curve = m_anim.easingCurve();
        curve.setOvershoot(value);
        m_anim.setEasingCurve(curve);
    }

    void createCurveIcons()
    {
        import qt.core.namespace : GlobalColor, PenStyle;
        import qt.core.point : QPoint;
        import qt.core.rect : QRect;
        import qt.gui.brush : QBrush;
        import qt.gui.color : QColor;
        import qt.gui.icon : QIcon;
        import qt.gui.lineargradient : QLinearGradient;
        import qt.gui.painter : QPainter;
        import qt.gui.painterpath : QPainterPath;
        import qt.gui.pixmap : QPixmap;
        import qt.widgets.listwidget : QListWidgetItem;

        auto pix = QPixmap(m_iconSize);
        auto painter = QPainter(pix);
        auto gradient = QLinearGradient(0, 0, 0, m_iconSize.height());
        gradient.setColorAt(0.0, QColor(240, 240, 240));
        gradient.setColorAt(1.0, QColor(224, 224, 224));
        auto brush = QBrush(gradient);
        auto mo = QEasingCurve.staticMetaObject;
        auto metaEnum = mo.enumerator(mo.indexOfEnumerator("Type"));
        // Skip QEasingCurve::Custom
        for (auto i = 0; i < QEasingCurve.Type.NCurveTypes - 1; ++i)
        {
            painter.fillRect(QRect(QPoint(0, 0), m_iconSize), brush);
            auto curve = createEasingCurve(i);
            painter.setPen(QColor(0, 0, 255, 64));
            auto xAxis = m_iconSize.height() / 1.5;
            auto yAxis = m_iconSize.width() / 3;
            painter.drawLine(0, xAxis, m_iconSize.width(), xAxis);
            painter.drawLine(yAxis, 0, yAxis, m_iconSize.height());

            auto curveScale = m_iconSize.height() / 2;

            painter.setPen(PenStyle.NoPen);

            // start point
            painter.setBrush(QBrush(GlobalColor.red));
            auto start = QPoint(yAxis, xAxis - curveScale * curve.valueForProgress(0));
            painter.drawRect(start.x() - 1, start.y() - 1, 3, 3);

            // end point
            painter.setBrush(QBrush(GlobalColor.blue));
            auto end = QPoint(yAxis + curveScale, xAxis - curveScale * curve.valueForProgress(1));
            painter.drawRect(end.x() - 1, end.y() - 1, 3, 3);

            auto curvePath = QPainterPath();
            curvePath.moveTo(start);
            for (auto t = 0; t <= 1.0; t += 1.0 / curveScale)
            {
                auto to = QPoint();
                to.setX(yAxis + curveScale * t);
                to.setY(xAxis - curveScale * curve.valueForProgress(t));
                curvePath.lineTo(to);
            }
            painter.setRenderHint(QPainter.RenderHint.Antialiasing, true);
            painter.strokePath(curvePath, QPen(QColor.QColor(32, 32, 32)));
            painter.setRenderHint(QPainter.RenderHint.Antialiasing, false);
            auto item = cpp_new!QListWidgetItem();
            item.setIcon(QIcon(pix));
            item.setText(QString(metaEnum.key(i)));
            m_ui.easingCurvePicker.addItem(item);
        }
    }

    void startAnimation()
    {
        import qt.core.point : QPointF;
        import qt.core.variant : QVariant;

        m_anim.setStartValue(QVariant(QPointF(0, 0)));
        m_anim.setEndValue(QVariant(QPointF(100, 100)));
        m_anim.setDuration(2000);
        m_anim.setLoopCount(-1); // forever
        m_anim.start();
    }

    int m_ui;
    UIStruct!"form.ui"* m_ui;
    QGraphicsScene m_scene;
    PixmapItem m_item;
    Animation m_anim;
    QSize m_iconSize;
}
