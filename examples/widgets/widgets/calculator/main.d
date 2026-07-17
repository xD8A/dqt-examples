module main;

import core.runtime : Runtime;
import core.stdcpp.new_ : cpp_delete, cpp_new;
import qt.widgets.application : QApplication;

import calculator : Calculator;

int main()
{
    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto calc = cpp_new!Calculator();
    scope(exit) cpp_delete(calc);
    calc.show();

    return app.exec();
}
