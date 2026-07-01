module mymodel;

import qt.config;
import qt.core.abstractitemmodel;
import qt.core.namespace;
import qt.core.object;
import qt.core.string;
import qt.core.variant;
import qt.helpers;

class MyModel : QAbstractTableModel
{
    mixin(Q_OBJECT_D);

public:
    this(QObject parent = null)
    {
        super(parent);
    }

    extern(C++) override int rowCount(ref const(QModelIndex) parent = globalInitVar!QModelIndex) const
    {
        return 2;
    }

    extern(C++) override int columnCount(ref const(QModelIndex) parent = globalInitVar!QModelIndex) const
    {
        return 3;
    }

    extern(C++) override QVariant data(ref const(QModelIndex) index, int role = qt.core.namespace.ItemDataRole.DisplayRole) const
    {
        if (role == qt.core.namespace.ItemDataRole.DisplayRole)
            return QVariant(QString("Row%1, Column%2").arg(index.row() + 1).arg(index.column() + 1));
        return QVariant();
    }
}
