module main;

int main()
{
    import controllerwindow : ControllerWindow;
    import core.runtime : Runtime;
    import core.stdcpp.new_ : cpp_delete, cpp_new;
    import qt.widgets.application : QApplication;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto controller = cpp_new!ControllerWindow();
    scope (exit)
        cpp_delete(controller);
    controller.show();

    return app.exec();
}
