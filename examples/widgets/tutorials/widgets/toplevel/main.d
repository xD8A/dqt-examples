module main;

int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.widgets.application;
    import qt.widgets.widget;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto window = cpp_new!QWidget();
    scope(exit) cpp_delete(window);
    window.resize(320, 240);
    window.setWindowTitle(
        QApplication.translate("toplevel", "Top-level widget"));
    window.show();

    return app.exec();
}
