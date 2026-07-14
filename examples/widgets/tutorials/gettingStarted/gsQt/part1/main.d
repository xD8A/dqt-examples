module main;

int main()
{
    import core.runtime : Runtime;
    import core.stdcpp.new_ : cpp_new, cpp_delete;
    import qt.widgets.application : QApplication;
    import qt.widgets.textedit : QTextEdit;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto textEdit = cpp_new!QTextEdit();
    scope (exit)
        cpp_delete(textEdit);
    textEdit.show();

    return app.exec();
}
