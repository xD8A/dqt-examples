module main;

int main()
{
    import core.runtime : Runtime;
    import core.stdcpp.new_ : cpp_delete, cpp_new;
    import mainwindow : MainWindow;
    import qt.widgets.application : QApplication;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto window = cpp_new!MainWindow();
    scope (exit)
        cpp_delete(window);
    window.show();

    return app.exec();
}
