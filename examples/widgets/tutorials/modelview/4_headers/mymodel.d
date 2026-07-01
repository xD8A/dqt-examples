module mymodel;

import qt.config;
import qt.helpers;
import qt.core.abstractitemmodel;
import qt.core.object;
import qt.core.string;
import qt.core.variant;
import qt.core.namespace;

class MyModel : QAbstractTableModel
{
    mixin(Q_OBJECT_D);

    this(QObject parent = null)
    {
        super(parent);
    }

    extern(C++) override int rowCount(const ref QModelIndex parent) const
    {
        return 2;
    }

    extern(C++) override int columnCount(const ref QModelIndex parent) const
    {
        return 3;
    }

    extern(C++) override QVariant data(const ref QModelIndex index, int role) const
    {
        if (role == ItemDataRole.DisplayRole)
        {
            auto row = index.row();
            auto col = index.column();
            return QVariant(QString("Row%1, Column%2").arg(row + 1).arg(col + 1));
        }
        return QVariant();
    }

    extern(C++) override QVariant headerData(int section, Orientation orientation, int role) const
    {
        if (role == ItemDataRole.DisplayRole && orientation == Orientation.Horizontal)
        {
            switch (section)
            {
            case 0: return QVariant(QString("first"));
            case 1: return QVariant(QString("second"));
            case 2: return QVariant(QString("third"));
            default: break;
            }
        }
        return QVariant();
    }
}
