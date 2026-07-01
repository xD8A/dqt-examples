module mainwindow;

import qt.config;
import qt.helpers;
import qt.widgets.mainwindow;
import qt.widgets.tableview;
import qt.widgets.widget;

import mymodel;

class MainWindow : QMainWindow
{
    mixin(Q_OBJECT_D);

    this(QWidget parent = null)
    {
        import core.stdcpp.new_;

        super(parent);
        tableView = cpp_new!QTableView(this);
        setCentralWidget(tableView);

        auto myModel = cpp_new!MyModel(this);
        tableView.setModel(myModel);
        connect(myModel.signal!"editCompleted", this.slot!"setWindowTitle");
    }

    QTableView tableView;
}
