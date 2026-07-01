module mainwindow;

import qt.config;
import qt.helpers;
import qt.widgets.widget;
import qt.widgets.mainwindow;
import qt.widgets.treeview;
import qt.gui.standarditemmodel;
import qt.core.list;
import qt.core.string;

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

        auto item = standardModel.invisibleRootItem();

        auto row1 = QList!QStandardItem();
        row1.append(cpp_new!QStandardItem(QString("first")));
        row1.append(cpp_new!QStandardItem(QString("second")));
        row1.append(cpp_new!QStandardItem(QString("third")));
        item.appendRow(row1);

        auto row2 = QList!QStandardItem();
        row2.append(cpp_new!QStandardItem(QString("111")));
        row2.append(cpp_new!QStandardItem(QString("222")));
        row2.append(cpp_new!QStandardItem(QString("333")));
        row1.first().appendRow(row2);

        treeView.setModel(standardModel);
        treeView.expandAll();
    }

private:
    QTreeView treeView;
    QStandardItemModel standardModel;
}
