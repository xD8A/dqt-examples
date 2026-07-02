module main;

import mainwindow;
import qt.widgets.application;

int main()
{
    import core.runtime;
    import core.stdcpp.new_;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto window = cpp_new!MainWindow();
    scope(exit) cpp_delete(window);
    window.show();

    return app.exec();
}
