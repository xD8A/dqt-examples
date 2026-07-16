module button;

import qt.config;
import qt.core.global : qMax;
import qt.core.size : QSize;
import qt.core.string : QString;
import qt.helpers;
import qt.widgets.sizepolicy : QSizePolicy;
import qt.widgets.toolbutton : QToolButton;
import qt.widgets.widget : QWidget;

//! [h0 0]
class Button : QToolButton
{
    mixin(Q_OBJECT_D);

public:
//! [c0]
    this(const(QString) text, QWidget parent = null)
    {
//! [h0 0]
        super(parent);
        setSizePolicy(QSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Preferred));
        setText(text);
//! [h0 1]
    }
//! [c0]

//! [c1]
    override extern(C++) QSize sizeHint() const
//! [c1] //! [c2]
    {
//! [h0 1]
        auto size = super.sizeHint();
        size.rheight() += 20;
        size.rwidth() = qMax(size.width(), size.height());
        return size;
//! [h0 2]
    }
//! [c2]
}
//! [h0 2]
