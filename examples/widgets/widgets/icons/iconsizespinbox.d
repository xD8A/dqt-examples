module iconsizespinbox;

import qt.config;
import qt.helpers;
import qt.core.string;
import qt.widgets.spinbox;
import qt.widgets.widget;

class IconSizeSpinBox : QSpinBox
{
    mixin(Q_OBJECT_D);

    this(QWidget parent = null)
    {
        super(parent);
    }

    override extern(C++) int valueFromText(ref const(QString) text) const
    {
        import qt.core.qchar;

        auto result = QString();
        for (int i = 0; i < text.length(); ++i) {
            auto c = text.at(i);
            if (c == QChar('x') || c == QChar('X'))
                break;
            result = result ~ c;
        }
        return result.toInt();
    }

    override extern(C++) QString textFromValue(int value) const
    {
        return tr("%1 x %1").arg(value);
    }
}
