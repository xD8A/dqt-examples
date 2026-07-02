module digitalclock;

import qt.config;
import qt.helpers;
import qt.core.datetime;
import qt.core.string;
import qt.core.qchar;
import qt.widgets.widget;
import qt.widgets.lcdnumber;


//! [0]

class DigitalClock : QLCDNumber
{
    mixin(Q_OBJECT_D);


public:
//! [1]

    this(QWidget parent = null)
    {
        import core.stdcpp.new_;
        import qt.core.timer;

        super(parent);

        setSegmentStyle(SegmentStyle.Filled);

        auto timer = cpp_new!QTimer(this);
        connect(timer.signal!"timeout", this.slot!"showTime");
        timer.start(1000);

        showTime();

        setWindowTitle(tr("Digital Clock"));
        resize(150, 60);
    } //! [1]
//! [2]

    @QSlot final void showTime() 
    {
        auto time = QTime.currentTime();
        auto text = time.toString("hh:mm");
//! [3]
        if ((time.second() % 2) == 0)
            text[2] = QChar(' ');
//! [3]
        display(text);
    } //! [2]
}
//! [0]

