module characterwidget;

import qt.config;
import qt.helpers;
import qt.core.global;
import qt.core.namespace;
import qt.core.point;
import qt.core.qchar;
import qt.core.rect;
import qt.core.size;
import qt.core.string;
import qt.gui.event;
import qt.gui.font;
import qt.gui.fontdatabase;
import qt.gui.fontmetrics;
import qt.gui.painter;
import qt.gui.brush;
import qt.gui.pen;
import qt.widgets.tooltip;
import qt.widgets.widget;

//! [0]
class CharacterWidget : QWidget
{
    mixin(Q_OBJECT_D);

    QFont displayFont;
    int columns = 16;
    int lastKey = -1;
    int squareSize = 0;

    this(QWidget parent = null)
    {
        super(parent);
        // TODO: QFont must be explicitly constructed (disabled default constructor in DQt)
        displayFont = QFont(QString(""));
        calculateSquareSize();
        setMouseTracking(true);
    }
//! [0]

    void calculateSquareSize()
    {
        QFontMetrics fm = QFontMetrics(displayFont);
        squareSize = qMax(16, 4 + fm.height());
    }

//! [1]
    @QSlot final void updateFont(const(QFont) font)
    {
        displayFont.setFamily(font.family());
        calculateSquareSize();
        adjustSize();
        update();
    }
//! [1]

//! [2]
    @QSlot final void updateSize(const(QString) fontSize)
    {
        displayFont.setPointSize(fontSize.toInt());
        calculateSquareSize();
        adjustSize();
        update();
    }
//! [2]

    @QSlot final void updateStyle(const(QString) fontStyle)
    {
        auto oldStrategy = displayFont.styleStrategy();
        displayFont = QFontDatabase.font(displayFont.family(), fontStyle, displayFont.pointSize());
        displayFont.setStyleStrategy(oldStrategy);
        calculateSquareSize();
        adjustSize();
        update();
    }

    @QSlot final void updateFontMerging(bool enable)
    {
        if (enable)
            displayFont.setStyleStrategy(QFont.StyleStrategy.PreferDefault);
        else
            displayFont.setStyleStrategy(QFont.StyleStrategy.NoFontMerging);
        adjustSize();
        update();
    }

//! [3]
    override extern(C++) QSize sizeHint() const
    {
        return QSize(columns * squareSize, (65536 / columns) * squareSize);
    }
//! [3]

//! [4]
    override extern(C++) void mouseMoveEvent(QMouseEvent event)
    {
        auto point = mapFromGlobal(event.globalPosition().toPoint());
        uint key = (point.y() / squareSize) * columns + point.x() / squareSize;

        QString fmt = QString("<p>Character: <span style=\"font-size: 24pt; font-family: %1\">").arg(displayFont.family());
        QString ch = QString(QChar(key));
        QString footer = QString("</span><p>Value: 0x");
        QString num = QString.number(key, 16);
        QString text = fmt ~ ch ~ footer ~ num;

        auto gpos = event.globalPosition().toPoint();
        QToolTip.showText(gpos, text, this, globalInitVar!QRect);
    }
//! [4]

//! [5]
    override extern(C++) void mousePressEvent(QMouseEvent event)
    {
        if (event.button() == MouseButton.LeftButton) {
            auto pos = event.position().toPoint();
            lastKey = (pos.y() / squareSize) * columns + pos.x() / squareSize;
            if (QChar.category(cast(dchar)lastKey) != QChar.Category.Other_NotAssigned) {
                QString ch = QString(QChar(lastKey));
                characterSelected(ch);
            }
            update();
        }
        else
            super.mousePressEvent(event);
    }
//! [5]

//! [6]
    override extern(C++) void paintEvent(QPaintEvent event)
    {
        QPainter painter = QPainter(this);
        QBrush whiteBrush = QBrush(GlobalColor.white);
        painter.fillRect(event.rect(), whiteBrush);
        painter.setFont(displayFont);
//! [6]

//! [7]
        QRect redrawRect = event.rect();
        int beginRow = redrawRect.top() / squareSize;
        int endRow = redrawRect.bottom() / squareSize;
        int beginColumn = redrawRect.left() / squareSize;
        int endColumn = redrawRect.right() / squareSize;
//! [7]

//! [8]
        QPen grayPen = QPen(GlobalColor.gray);
        painter.setPen(grayPen);
        for (int row = beginRow; row <= endRow; ++row) {
            for (int column = beginColumn; column <= endColumn; ++column) {
                painter.drawRect(column * squareSize, row * squareSize, squareSize, squareSize);
            }
//! [8] //! [9]
        }
//! [9]

//! [10]
        QFontMetrics fontMetrics = QFontMetrics(displayFont);
        QPen blackPen = QPen(GlobalColor.black);
        painter.setPen(blackPen);
        for (int row = beginRow; row <= endRow; ++row) {
            for (int column = beginColumn; column <= endColumn; ++column) {
                int key = row * columns + column;
                QRect clipRect = QRect(column * squareSize, row * squareSize, squareSize, squareSize);
                painter.setClipRect(clipRect);

                if (key == lastKey) {
                    QBrush redBrush = QBrush(GlobalColor.red);
                    painter.fillRect(column * squareSize + 1, row * squareSize + 1,
                                     squareSize, squareSize, redBrush);
                }

                int x = column * squareSize + (squareSize / 2) -
                        fontMetrics.horizontalAdvance(QChar(key)) / 2;
                int y = row * squareSize + 4 + fontMetrics.ascent();
                QString ch = QString(QChar(key));
                painter.drawText(x, y, ch);
            }
        }
    }
//! [10]

    @QSignal final void characterSelected(const(QString) character) { mixin(Q_SIGNAL_IMPL_D); }
}
