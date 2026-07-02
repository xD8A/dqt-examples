module button;

import qt.config;
import qt.helpers;
import qt.core.size;
import qt.core.string;
import qt.widgets.toolbutton;
import qt.widgets.widget;

//! [h0]
class Button : QToolButton
{
    mixin(Q_OBJECT_D);

public:
    //! [c0]
    this(const(QString) text, QWidget parent = null)
    {
        import qt.widgets.sizepolicy;

        super(parent);
        setSizePolicy(QSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Preferred));
        setText(text);
    }
    //! [c0]

    //! [c1]
    override extern(C++) QSize sizeHint() const
    //! [c1] //! [c2]
    {
        import qt.core.global;

        auto size = super.sizeHint();
        size.rheight() += 20;
        size.rwidth() = qMax(size.width(), size.height());
        return size;
    }
    //! [c2]
}
//! [h0]
