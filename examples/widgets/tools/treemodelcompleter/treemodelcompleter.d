module treemodelcompleter;

import qt.config;
import qt.core.abstractitemmodel : QAbstractItemModel, QModelIndex;
import qt.core.global : qsizetype;
import qt.core.object : QObject;
import qt.core.string : QString;
import qt.core.stringlist : QStringList;
import qt.helpers;
import qt.widgets.completer : QCompleter;

//! [h0 0]
class TreeModelCompleter : QCompleter
{
    mixin(Q_OBJECT_D);

public:
//! [c0]
    this(QObject parent = null)
    {
//! [h0 0]
        super(parent);
//! [h0 1]
    }
//! [c0]

//! [c1]
    this(QAbstractItemModel model, QObject parent = null)
    {
//! [h0 1]
        super(model, parent);
//! [h0 2]
    }
//! [c1]

    @QPropertyDef
    {
//! [c2]
        QString separator() const
        {
//! [h0 2]
            return sep;
//! [h0 3]
        }
//! [c2]

        @QSlot void setSeparator(const(QString) separator)
        {
//! [h0 3]
            sep = separator;
//! [h0 4]
        }

        @QSignal void separatorChanged() { mixin(Q_SIGNAL_IMPL_D); }
    }

protected:
//! [c3]
    extern (C++) override QStringList splitPath(ref const(QString) path) const
    {
//! [h0 4]
        return (sep.isNull() ? QCompleter.splitPath(path) : path.split(sep));
//! [h0 5]
    }
//! [c3]

//! [c4]
    extern (C++) override QString pathFromIndex(ref const(QModelIndex) index) const
    {
//! [h0 5]
        if (sep.isNull())
            return QCompleter.pathFromIndex(index);

        /+
        TODO:
            * QStringList.prepend
            * QStringList.join(QString)

        for (auto i = cast(QModelIndex) index; i.isValid(); i = i.parent())
            dataList.prepend(model().data(i, completionRole()).toString());

        return dataList.join(sep);
        +/

        // navigate up and accumulate data (leaf to root)
        auto dataList = QStringList();
        for (auto i = cast(QModelIndex) index; i.isValid(); i = i.parent())
            dataList.append(model().data(i, completionRole()).toString());

        // iterate backwards (root to leaf) to build the path
        QString result;
        for (qsizetype i = dataList.size(); i-- > 0; )
        {
            if (i < dataList.size() - 1)
                result ~= sep;
            result ~= dataList[i];
        }
        return result;
//! [h0 6]
    }
//! [c4]

private:
    QString sep;
}
//! [h0 6]
