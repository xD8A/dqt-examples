module testwidget;

import qt.config;
import qt.helpers;
import qt.core.namespace;
import qt.core.string;
import qt.core.stringlist;
import qt.gui.event;
import qt.gui.event;
import qt.widgets.frame;
import qt.widgets.gridlayout;
import qt.widgets.label;
import qt.widgets.pushbutton;
import qt.widgets.slider;
import qt.widgets.widget;

import elidedlabel;

//! [0]

class TestWidget : QWidget
{
    mixin(Q_OBJECT_D);

    int sampleIndex;
    QStringList textSamples;
    ElidedLabel elidedText;
    QSlider heightSlider;
    QSlider widthSlider;

    this(QWidget parent = null)
    {
        import core.stdcpp.new_;

        super(parent);

//! [1]

        auto romeo = QString(
            "But soft, what light through yonder window breaks? / "
            ~ "It is the east, and Juliet is the sun. / "
            ~ "Arise, fair sun, and kill the envious moon, / "
            ~ "Who is already sick and pale with grief / "
            ~ "That thou, her maid, art far more fair than she."
        );

        auto macbeth = QString(
            "To-morrow, and to-morrow, and to-morrow, / "
            ~ "Creeps in this petty pace from day to day, / "
            ~ "To the last syllable of recorded time; / "
            ~ "And all our yesterdays have lighted fools / "
            ~ "The way to dusty death. Out, out, brief candle! / "
            ~ "Life's but a walking shadow, a poor player, / "
            ~ "That struts and frets his hour upon the stage, / "
            ~ "And then is heard no more. It is a tale / "
            ~ "Told by an idiot, full of sound and fury, / "
            ~ "Signifying nothing."
        );

        auto harry = tr("Feeling lucky, punk?");

        textSamples.append(romeo);
        textSamples.append(macbeth);
        textSamples.append(harry);

//! [1]
//! [2]

        sampleIndex = 0;
        elidedText = cpp_new!ElidedLabel(textSamples.at(sampleIndex), this);
        elidedText.setFrameStyle(QFrame.Shape.Box);

//! [2]
//! [3]

        auto switchButton = cpp_new!QPushButton(tr("Switch text"));
        connect(switchButton.signal!"clicked", this.slot!"switchText");

        auto exitButton = cpp_new!QPushButton(tr("Exit"));
        connect(exitButton.signal!"clicked", this.slot!"close");

        auto label = cpp_new!QLabel(tr("Elided"));
        label.setVisible(elidedText.isElided());
        connect(elidedText.signal!"elisionChanged", label.slot!"setVisible");

//! [3]
//! [4]

        widthSlider = cpp_new!QSlider(Orientation.Horizontal);
        widthSlider.setMinimum(0);
        connect(widthSlider.signal!"valueChanged", this.slot!"onWidthChanged");

        heightSlider = cpp_new!QSlider(Orientation.Vertical);
        heightSlider.setInvertedAppearance(true);
        heightSlider.setMinimum(0);
        connect(heightSlider.signal!"valueChanged", this.slot!"onHeightChanged");

//! [4]
//! [5]

        auto layout = cpp_new!QGridLayout();
        layout.addWidget(label, 0, 1, Alignment(AlignmentFlag.AlignCenter));
        layout.addWidget(switchButton, 0, 2);
        layout.addWidget(exitButton, 0, 3);
        layout.addWidget(widthSlider, 1, 1, 1, 3);
        layout.addWidget(heightSlider, 2, 0);
        layout.addWidget(elidedText, 2, 1, 1, 3,
                         Alignment(AlignmentFlag.AlignTop | AlignmentFlag.AlignLeft));

        setLayout(layout);
    }

//! [5]
//! [6]

protected:
    override extern(C++) void resizeEvent(QResizeEvent event)
    {
        int maxWidth = widthSlider.width();
        widthSlider.setMaximum(maxWidth);
        widthSlider.setValue(maxWidth / 2);

        int maxHeight = heightSlider.height();
        heightSlider.setMaximum(maxHeight);
        heightSlider.setValue(maxHeight / 2);

        elidedText.setFixedSize(widthSlider.value(), heightSlider.value());
    }

//! [6]
//! [7]

private:
    @QSlot final void switchText()
    {
        sampleIndex = (sampleIndex + 1) % textSamples.size();
        elidedText.setText(textSamples.at(sampleIndex));
    }

//! [7]
//! [8]

    @QSlot final void onWidthChanged(int width)
    {
        elidedText.setFixedWidth(width);
    }

    @QSlot final void onHeightChanged(int height)
    {
        elidedText.setFixedHeight(height);
    }
};

//! [8]
//! [0]