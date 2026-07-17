module ledwidget;

import core.stdcpp.new_ : cpp_delete, cpp_new;
import qt.config;
import qt.helpers;
import qt.core.timer : QTimer;
import qt.gui.pixmap : QPixmap;
import qt.widgets.label : QLabel;
import qt.widgets.widget : QWidget;

class LEDWidget : QLabel
{
    mixin(Q_OBJECT_D);
public:
    this(QWidget parent = null)
    {
        super(parent);
        onPixmap = QPixmap(":/ledon.png");
        offPixmap = QPixmap(":/ledoff.png");

        setPixmap(offPixmap);
        flashTimer = cpp_new!QTimer(this);
        flashTimer.setInterval(200);
        flashTimer.setSingleShot(true);
        connect(flashTimer.signal!"timeout", this.slot!"extinguish");
    }

    ~this()
    {
        cpp_delete(flashTimer);
    }

    @QSlot final void flash()
    {
        setPixmap(onPixmap);
        flashTimer.start();
    }

private:
    @QSlot void extinguish()
    {
        setPixmap(offPixmap);
    }

    QPixmap onPixmap;
    QPixmap offPixmap;
    QTimer flashTimer;
}
