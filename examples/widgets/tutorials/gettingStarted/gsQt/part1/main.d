module main;

int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.widgets.application;
    import qt.widgets.textedit;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto textEdit = cpp_new!QTextEdit();
    scope(exit) cpp_delete(textEdit);
    textEdit.show();

    return app.exec();
}
