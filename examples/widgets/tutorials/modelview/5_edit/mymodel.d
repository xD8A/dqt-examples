module mymodel;

import qt.config;
import qt.helpers;
import qt.core.abstractitemmodel;
import qt.core.flags;
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
        if (role == ItemDataRole.DisplayRole && checkIndex(index))
            return QVariant(QString(m_gridData[index.row()][index.column()]));
        return QVariant();
    }

    extern(C++) override bool setData(const ref QModelIndex index, const ref QVariant value, int role)
    {
        if (role == ItemDataRole.EditRole)
        {
            if (!checkIndex(index))
                return false;
            m_gridData[index.row()][index.column()] = qsToStr(value.toString());

            QString result;
            for (int row = 0; row < 2; row++)
            {
                for (int col = 0; col < 3; col++)
                    result = result ~ QString(m_gridData[row][col]) ~ " ";
            }
            editCompleted(result);
            return true;
        }
        return false;
    }

    extern(C++) override QFlags!ItemFlag flags(const ref QModelIndex index) const
    {
        return QFlags!ItemFlag.fromInt(ItemFlag.ItemIsEditable | QAbstractTableModel.flags(index).toInt());
    }

    @QSignal final void editCompleted(ref const(QString) result)
    {
        mixin(Q_SIGNAL_IMPL_D);
    }

private:
    string[3][2] m_gridData;

    static string qsToStr(QString qs)
    {
        return qs.toUtf8().toConstCharArray().idup;
    }
}
