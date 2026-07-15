module main;

int main()
{
    import core.runtime : Runtime;
    import core.stdcpp.new_ : cpp_delete, cpp_new;
    import notepad : Notepad;
    import qt.core.resource : QResource;
    import qt.widgets.application : QApplication;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);
    QResource.registerResource("notepad.rcc");

    auto notepad = cpp_new!Notepad();
    scope (exit)
        cpp_delete(notepad);
    notepad.show();

    return app.exec();
}
