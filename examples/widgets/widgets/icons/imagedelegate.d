module imagedelegate;

import qt.config;
import qt.helpers;
import qt.core.abstractitemmodel;
import qt.core.namespace;
import qt.core.object;
import qt.core.size;
import qt.core.string;
import qt.gui.painter;
import qt.widgets.abstractitemdelegate;
import qt.widgets.combobox;
import qt.widgets.styleoption;
import qt.widgets.widget;

import iconpreviewarea;

class ImageDelegate : QAbstractItemDelegate
{
    mixin(Q_OBJECT_D);

    this(QObject parent = null)
    {
        super(parent);
    }

    override extern(C++) void paint(QPainter* painter, ref const(QStyleOptionViewItem) option,
                                    ref const(QModelIndex) index) const
    {
    }

    override extern(C++) QSize sizeHint(ref const(QStyleOptionViewItem) option,
                                        ref const(QModelIndex) index) const
    {
        return QSize(0, 0);
    }

    override extern(C++) QWidget createEditor(QWidget parent,
                                              ref const(QStyleOptionViewItem) option,
                                              ref const(QModelIndex) index) const
    {
        import core.stdcpp.new_;

        auto comboBox = cpp_new!QComboBox(parent);
        if (index.column() == 1)
            comboBox.addItems(IconPreviewArea.iconModeNames());
        else if (index.column() == 2)
            comboBox.addItems(IconPreviewArea.iconStateNames());

        connect(comboBox.signal!"activated", this.slot!"emitCommitData");

        return comboBox;
    }

    override extern(C++) void setEditorData(QWidget editor,
                                            ref const(QModelIndex) index) const
    {
        auto comboBox = qobject_cast!QComboBox(editor);
        if (!comboBox)
            return;

        int pos = comboBox.findText(index.model().data(index).toString(),
                                    Qt.MatchExactly);
        comboBox.setCurrentIndex(pos);
    }

    override extern(C++) void setModelData(QWidget editor, QAbstractItemModel model,
                                           ref const(QModelIndex) index) const
    {
        auto comboBox = qobject_cast!QComboBox(editor);
        if (!comboBox)
            return;

        model.setData(index, comboBox.currentText());
    }

    @QSlot final void emitCommitData()
    {
        commitData(qobject_cast!QWidget(QObject.sender()));
    }
}
