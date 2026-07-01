module main;

import mainwindow;

int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.widgets.application;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto mainWindow = cpp_new!MainWindow();
    scope(exit) cpp_delete(mainWindow);
    mainWindow.show();

    return app.exec();
}
