module main;

import analogclockwindow;

int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.widgets.application;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto clock = cpp_new!AnalogClockWindow();
    scope(exit) cpp_delete(clock);
    clock.show();

    return app.exec();
}
