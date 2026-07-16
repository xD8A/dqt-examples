module slidersgroup;

import qt.config;
import qt.helpers;
import qt.core.metamacros;
import qt.core.namespace;
import qt.core.string;
import qt.widgets.boxlayout;
import qt.widgets.dial;
import qt.widgets.groupbox;
import qt.widgets.scrollbar;
import qt.widgets.slider;
import qt.widgets.widget;

class SlidersGroup : QGroupBox
{
    mixin(Q_OBJECT_D);

    QSlider slider;
    QScrollBar scrollBar;
    QDial dial;

    this(Orientation orientation, const(QString) title, QWidget parent = null)
    {
        import core.stdcpp.new_;

        super(title, parent);

        slider = cpp_new!QSlider(orientation);
        slider.setFocusPolicy(FocusPolicy.StrongFocus);
        slider.setTickPosition(QSlider.TickPosition.TicksBothSides);
        slider.setTickInterval(10);
        slider.setSingleStep(1);

        scrollBar = cpp_new!QScrollBar(orientation);
        scrollBar.setFocusPolicy(FocusPolicy.StrongFocus);

        dial = cpp_new!QDial();
        dial.setFocusPolicy(FocusPolicy.StrongFocus);

        connect(slider.signal!"valueChanged", scrollBar.slot!"setValue");
        connect(scrollBar.signal!"valueChanged", dial.slot!"setValue");
        connect(dial.signal!"valueChanged", slider.slot!"setValue");
        connect(dial.signal!"valueChanged", this.signal!"valueChanged");

        QBoxLayout.Direction direction;
        if (orientation == Orientation.Horizontal)
            direction = QBoxLayout.Direction.TopToBottom;
        else
            direction = QBoxLayout.Direction.LeftToRight;

        auto slidersLayout = cpp_new!QBoxLayout(direction);
        slidersLayout.addWidget(slider);
        slidersLayout.addWidget(scrollBar);
        slidersLayout.addWidget(dial);
        setLayout(slidersLayout);
    }

    @QSignal void valueChanged(int value)
    {
        mixin(Q_SIGNAL_IMPL_D);
    }

    @QSlot final void setValue(int value)
    {
        slider.setValue(value);
    }

    @QSlot final void setMinimum(int value)
    {
        slider.setMinimum(value);
        scrollBar.setMinimum(value);
        dial.setMinimum(value);
    }

    @QSlot final void setMaximum(int value)
    {
        slider.setMaximum(value);
        scrollBar.setMaximum(value);
        dial.setMaximum(value);
    }

    @QSlot final void invertAppearance(bool invert)
    {
        slider.setInvertedAppearance(invert);
        scrollBar.setInvertedAppearance(invert);
        dial.setInvertedAppearance(invert);
    }

    @QSlot final void invertKeyBindings(bool invert)
    {
        slider.setInvertedControls(invert);
        scrollBar.setInvertedControls(invert);
        dial.setInvertedControls(invert);
    }
}
