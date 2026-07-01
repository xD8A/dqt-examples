module mainwindow;

import qt.config;
import qt.helpers;
import qt.widgets.widget;
import qt.widgets.mainwindow;
import qt.widgets.treeview;
import qt.gui.standarditemmodel;
import qt.core.abstractitemmodel;
import qt.core.itemselectionmodel;
import qt.core.list;
import qt.core.string;
import qt.core.variant;

class MainWindow : QMainWindow
{
    mixin(Q_OBJECT_D);

public:
    this(QWidget parent = null)
    {
        import core.stdcpp.new_;

        super(parent);

        treeView = cpp_new!QTreeView(this);
        standardModel = cpp_new!QStandardItemModel(this);
        setCentralWidget(treeView);
        treeView.setModel(standardModel);

        auto rootNode = standardModel.invisibleRootItem();

        auto americaItem = cpp_new!QStandardItem(QString("America"));
        auto canadaItem = cpp_new!QStandardItem(QString("Canada"));
        auto usaItem = cpp_new!QStandardItem(QString("USA"));
        auto bostonItem = cpp_new!QStandardItem(QString("Boston"));
        auto europeItem = cpp_new!QStandardItem(QString("Europe"));
        auto italyItem = cpp_new!QStandardItem(QString("Italy"));
        auto romeItem = cpp_new!QStandardItem(QString("Rome"));
        auto veronaItem = cpp_new!QStandardItem(QString("Verona"));

        {
            auto row = QList!QStandardItem();
            row.append(americaItem);
            rootNode.appendRow(row);
        }
        {
            auto row = QList!QStandardItem();
            row.append(europeItem);
            rootNode.appendRow(row);
        }
        {
            auto row = QList!QStandardItem();
            row.append(canadaItem);
            americaItem.appendRow(row);
        }
        {
            auto row = QList!QStandardItem();
            row.append(usaItem);
            americaItem.appendRow(row);
        }
        {
            auto row = QList!QStandardItem();
            row.append(bostonItem);
            usaItem.appendRow(row);
        }
        {
            auto row = QList!QStandardItem();
            row.append(italyItem);
            europeItem.appendRow(row);
        }
        {
            auto row = QList!QStandardItem();
            row.append(romeItem);
            italyItem.appendRow(row);
        }
        {
            auto row = QList!QStandardItem();
            row.append(veronaItem);
            italyItem.appendRow(row);
        }

        auto selectionModel = treeView.selectionModel();
        connect(selectionModel.signal!"selectionChanged", this.slot!"selectionChangedSlot");
    }

    @QSlot final void selectionChangedSlot(ref const(QItemSelection) newSelection, ref const(QItemSelection) oldSelection)
    {
        import qt.core.namespace;

        auto index = treeView.selectionModel().currentIndex();
        auto selectedText = index.data(ItemDataRole.DisplayRole).toString();
        int hierarchyLevel = 1;
        auto seekRoot = index;
        while (seekRoot.parent().isValid())
        {
            seekRoot = seekRoot.parent();
            hierarchyLevel++;
        }
        auto showString = QString("%1, Level %2").arg(selectedText).arg(hierarchyLevel);
        setWindowTitle(showString);
    }

private:
    QTreeView treeView;
    QStandardItemModel standardModel;
}
