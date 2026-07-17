module main;

import core.runtime : Runtime;
import core.stdcpp.new_ : cpp_delete, cpp_new;
import qt.widgets.application : QApplication;

import dialog : Dialog;

int main()
{
    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto dialog = cpp_new!Dialog();
    scope (exit)
        cpp_delete(dialog);
    dialog.show();

    return app.exec();
}
