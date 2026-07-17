module main;

import core.runtime : Runtime;
import core.stdcpp.new_ : cpp_delete, cpp_new;
import qt.core.resource : QResource;
import qt.widgets.application : QApplication;

import window : Window;

int main()
{
    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto w = cpp_new!Window();
    scope (exit)
        cpp_delete(w);
    w.show();

    return app.exec();
}
