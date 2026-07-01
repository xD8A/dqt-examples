module mymodel;

import qt.config;
import qt.core.abstractitemmodel;
import qt.core.namespace;
import qt.core.object;
import qt.core.string;
import qt.core.timer;
import qt.core.variant;
import qt.helpers;

class MyModel : QAbstractTableModel
{
    mixin(Q_OBJECT_D);

public:
    this(QObject parent = null)
    {
        import core.stdcpp.new_;
        import qt.core.datetime;

        super(parent);
        timer = cpp_new!QTimer(this);
        timer.setInterval(1000);
        connect(timer.signal!"timeout", this.slot!"timerHit");
        timer.start();
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
        import qt.core.datetime;
        if (role == qt.core.namespace.ItemDataRole.DisplayRole && index.row() == 0 && index.column() == 0)
            return QVariant(QTime.currentTime().toString());
        return QVariant();
    }

private:
    @QSlot final void timerHit()
    {
        import qt.core.vector;
        auto topLeft = createIndex(0, 0);
        auto roles = QVector!(int).create();
        roles.append(qt.core.namespace.ItemDataRole.DisplayRole);
        dataChanged(topLeft, topLeft, roles);
    }

    QTimer timer;
}
