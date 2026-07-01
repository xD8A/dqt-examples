module main;

import mymodel;

int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.widgets.application;
    import qt.widgets.tableview;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto tableView = cpp_new!QTableView();
    scope(exit) cpp_delete(tableView);
    auto myModel = cpp_new!MyModel();
    scope(exit) cpp_delete(myModel);
    tableView.setModel(myModel);
    tableView.show();

    return app.exec();
}
