module main;

import codeeditor;

int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.widgets.application;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto editor = cpp_new!CodeEditor();
    scope(exit) cpp_delete(editor);
    editor.setWindowTitle(editor.tr("Code Editor Example"));
    editor.show();

    return app.exec();
}
