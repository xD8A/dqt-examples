module main;

int main()
{
    import core.runtime : Runtime;
    import core.stdcpp.new_ : cpp_delete, cpp_new;
    import qt.core.point : QPoint;
    import qt.widgets.application : QApplication;
    import screenshot : Screenshot;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto screenshot = cpp_new!Screenshot();
    scope (exit)
        cpp_delete(screenshot);
    screenshot.move(screenshot.screen().availableGeometry().topLeft() + QPoint(20, 20));
    screenshot.show();

    return app.exec();
}
