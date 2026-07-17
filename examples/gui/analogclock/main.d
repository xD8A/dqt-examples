module main;

import core.runtime : Runtime;
import core.stdcpp.new_ : cpp_delete, cpp_new;
import qt.widgets.application : QApplication;

import analogclockwindow : AnalogClockWindow;

int main()
{
    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto clock = cpp_new!AnalogClockWindow();
    scope(exit)
        cpp_delete(clock);
    clock.show();

    return app.exec();
}
