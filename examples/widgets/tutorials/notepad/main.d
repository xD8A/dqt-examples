module main;

import notepad;
import core.stdcpp.new_;
import core.runtime;
import qt.widgets.application;

int main()
{
    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto notepad = cpp_new!Notepad();
    scope(exit) cpp_delete(notepad);
    notepad.show();

    return app.exec();
}
