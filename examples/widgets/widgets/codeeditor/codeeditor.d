module codeeditor;

import qt.config;
import qt.helpers;
import qt.core.global;
import qt.core.list;
import qt.core.namespace;
import qt.core.object;
import qt.core.qchar;
import qt.core.rect;
import qt.core.size;
import qt.core.string;
import qt.gui.brush;
import qt.gui.color;
import qt.gui.event;
import qt.gui.fontmetrics;
import qt.gui.painter;
import qt.gui.pen;
import qt.gui.textformat;
import qt.widgets.plaintextedit;
import qt.widgets.textedit;
import qt.widgets.widget;

//![codeeditordefinition]

class CodeEditor : QPlainTextEdit
{
    mixin(Q_OBJECT_D);

    QWidget lineNumberArea;

public:
//![constructor]

    this(QWidget parent = null)
    {
        import core.stdcpp.new_;
        super(parent);

        lineNumberArea = cpp_new!LineNumberArea(this);

        connect(this.signal!"blockCountChanged", this.slot!"updateLineNumberAreaWidth");
        connect(this.signal!"updateRequest", this.slot!"updateLineNumberArea");
        connect(this.signal!"cursorPositionChanged", this.slot!"highlightCurrentLine");

        updateLineNumberAreaWidth(0);
        highlightCurrentLine();
    }

//![constructor]
//![extraAreaWidth]

    int lineNumberAreaWidth() const
    {
        int digits = 1;
        int max = qMax(1, blockCount());
        while (max >= 10) {
            max /= 10;
            ++digits;
        }
        int space = 3 + fontMetrics().horizontalAdvance(QChar('9')) * digits;
        return space;
    }

//![extraAreaWidth]
//![extraAreaPaintEvent_0]

    void lineNumberAreaPaintEvent(QPaintEvent event)
    {
        QPainter painter = QPainter(lineNumberArea);
        painter.fillRect(event.rect(), QBrush(GlobalColor.lightGray));

//![extraAreaPaintEvent_0]
//![extraAreaPaintEvent_1]
        auto block = firstVisibleBlock();
        int blockNumber = block.blockNumber();
        int top = qRound(blockBoundingGeometry(block).translated(contentOffset()).top());
        int bottom = top + qRound(blockBoundingRect(block).height());
//![extraAreaPaintEvent_1]
//![extraAreaPaintEvent_2]

        while (block.isValid() && top <= event.rect().bottom()) {
            if (block.isVisible() && bottom >= event.rect().top()) {
                auto number = QString.number(blockNumber + 1);
                painter.setPen(QPen(GlobalColor.black));
                painter.drawText(0, top, lineNumberArea.width(), fontMetrics().height(),
                                 AlignmentFlag.AlignRight, number);
            }

            block = block.next();
            top = bottom;
            bottom = top + qRound(blockBoundingRect(block).height());
            ++blockNumber;
        }
    }
//![extraAreaPaintEvent_2]

private:
//![slotUpdateExtraAreaWidth]

    @QSlot final void updateLineNumberAreaWidth(int newBlockCount)
    {
        setViewportMargins(lineNumberAreaWidth(), 0, 0, 0);
    }

//![slotUpdateExtraAreaWidth]
//![cursorPositionChanged]

    @QSlot final void highlightCurrentLine()
    {
        if (!isReadOnly()) {
            auto selections = QList!(QTextEdit.ExtraSelection)(1);
            auto lineColor = QColor(GlobalColor.yellow).lighter(160);

            selections[0].format.base0.setProperty!QBrush(QTextFormat.Property.BackgroundBrush, QBrush(lineColor));
            selections[0].format.base0.setProperty!bool(QTextFormat.Property.FullWidthSelection, true);
            selections[0].cursor = textCursor();
            selections[0].cursor.clearSelection();
            setExtraSelections(selections);
        } else {
            setExtraSelections(QList!(QTextEdit.ExtraSelection).create());
        }
    }

//![cursorPositionChanged]
//![slotUpdateRequest]

    @QSlot final void updateLineNumberArea(const(QRect) rect, int dy)
    {
        if (dy)
            lineNumberArea.scroll(0, dy);
        else
            lineNumberArea.update(0, rect.y(), lineNumberArea.width(), rect.height());

        auto viewPortRect = viewport().rect();
        if (rect.contains(viewPortRect))
            updateLineNumberAreaWidth(0);
    }

//![slotUpdateRequest]
//![resizeEvent]

protected:
    override extern(C++) void resizeEvent(QResizeEvent e)
    {
        super.resizeEvent(e);

        auto cr = contentsRect();
        lineNumberArea.setGeometry(QRect(cr.left(), cr.top(), lineNumberAreaWidth(), cr.height()));
    }
};

//![resizeEvent]
//![codeeditordefinition]
//![extraarea]

class LineNumberArea : QWidget
{
    mixin(Q_OBJECT_D);

    CodeEditor codeEditor;

    this(CodeEditor editor)
    {
        super(editor);
        codeEditor = editor;
    }

    override extern(C++) QSize sizeHint() const
    {
        return QSize(codeEditor.lineNumberAreaWidth(), 0);
    }

protected:
    override extern(C++) void paintEvent(QPaintEvent event)
    {
        codeEditor.lineNumberAreaPaintEvent(event);
    }
};

//![extraarea]
