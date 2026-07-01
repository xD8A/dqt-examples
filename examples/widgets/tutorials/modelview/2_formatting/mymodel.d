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
        auto row = index.row();
        auto col = index.column();

        switch (role)
        {
            default: break;
            case qt.core.namespace.ItemDataRole.DisplayRole:
                if (row == 0 && col == 1) return QVariant(QString("<--left"));
                if (row == 1 && col == 1) return QVariant(QString("right-->"));
                return QVariant(QString("Row%1, Column%2").arg(row + 1).arg(col + 1));
            case qt.core.namespace.ItemDataRole.FontRole:
                if (row == 0 && col == 0)
                {
                    import qt.gui.font;
                    auto font = QFont.create();
                    font.setBold(true);
                    return QVariant.fromValue!QFont(font);
                }
                break;
            case qt.core.namespace.ItemDataRole.BackgroundRole:
                if (row == 1 && col == 2)
                {
                    import qt.gui.brush;
                    return QVariant.fromValue!QBrush(QBrush(qt.core.namespace.GlobalColor.red));
                }
                break;
            case qt.core.namespace.ItemDataRole.TextAlignmentRole:
                if (row == 1 && col == 1)
                    return QVariant(int(qt.core.namespace.AlignmentFlag.AlignRight) | int(qt.core.namespace.AlignmentFlag.AlignVCenter));
                break;
            case qt.core.namespace.ItemDataRole.CheckStateRole:
                if (row == 1 && col == 0)
                    return QVariant(int(qt.core.namespace.CheckState.Checked));
                break;
        }
        return QVariant();
    }
}
