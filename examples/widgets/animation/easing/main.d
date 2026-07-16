module main;

int main()
{
    import core.runtime : Runtime;
    import core.stdcpp.new_ : cpp_delete, cpp_new;
    import qt.widgets.application : QApplication;

    import window : Window;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);
    auto w = cpp_new!Window();
    scope (exit)
        cpp_delete(w);
    w.resize(400, 400);
    w.show();
    return app.exec();
}
