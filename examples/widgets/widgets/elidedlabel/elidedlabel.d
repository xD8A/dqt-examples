module elidedlabel;

import qt.config;
import qt.helpers;
import qt.core.namespace;
import qt.core.point;
import qt.core.string;
import qt.gui.event;
import qt.gui.font;
import qt.gui.fontmetrics;
import qt.gui.painter;
import qt.gui.textlayout;
import qt.widgets.frame;
import qt.widgets.sizepolicy;
import qt.widgets.widget;

//! [0]

class ElidedLabel : QFrame
{
    mixin(Q_OBJECT_D);

    bool elided;
    QString content;

public:
//! [1]

    this(const(QString) text, QWidget parent = null)
    {
        import qt.core.size;

        super(parent);
        setSizePolicy(QSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Preferred));
        elided = false;
        content = text;
    }

//! [1]
//! [2]

    void setText(const(QString) newText)
    {
        content = newText;
        update();
    }

//! [2]

    const(QString) labelText() const
    {
        return content;
    }

    bool isElided() const
    {
        return elided;
    }

    @QSignal final void elisionChanged(bool elided) { mixin(Q_SIGNAL_IMPL_D); }

protected:
//! [3]

    override extern(C++) void paintEvent(QPaintEvent event)
    {
        super.paintEvent(event);

        QPainter painter = QPainter(this);
        QFontMetrics fontMetrics = painter.fontMetrics();

        bool didElide = false;
        int lineSpacing = fontMetrics.lineSpacing();
        int y = 0;

        auto textLayout = QTextLayout(content, painter.font());
        textLayout.beginLayout();
        while (true) {
            auto line = textLayout.createLine();

            if (!line.isValid())
                break;

            line.setLineWidth(width());
            int nextLineY = y + lineSpacing;

            if (height() >= nextLineY + lineSpacing) {
                line.draw(&painter, QPointF(0, y));
                y = nextLineY;

//! [3]
//! [4]

            } else {
                auto lastLine = content.mid(line.textStart());
                auto elidedLastLine = fontMetrics.elidedText(lastLine, TextElideMode.ElideRight, width());
                painter.drawText(0, y + fontMetrics.ascent(), elidedLastLine);
                line = textLayout.createLine();
                didElide = line.isValid();
                break;
            }
        }
        textLayout.endLayout();

//! [4]
//! [5]

        if (didElide != elided) {
            elided = didElide;
            elisionChanged(didElide);
        }
    }
};

//! [5]
//! [0]