module main;

import calculator;

int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.widgets.application;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto calc = cpp_new!Calculator();
    scope(exit) cpp_delete(calc);
    calc.show();

    return app.exec();
}
