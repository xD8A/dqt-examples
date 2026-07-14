module main;

int main()
{
    import core.runtime : Runtime;
    import core.stdcpp.new_ : cpp_new, cpp_delete;
    import qt.core.object : QObject;
    import qt.widgets.application : QApplication;
    import qt.widgets.boxlayout : QVBoxLayout;
    import qt.widgets.pushbutton : QPushButton;
    import qt.widgets.textedit : QTextEdit;
    import qt.widgets.widget : QWidget;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto textEdit = cpp_new!QTextEdit();
    auto quitButton = cpp_new!QPushButton("&Quit");

    QObject.connect(quitButton.signal!"clicked", app.slot!"quit");

    auto layout = cpp_new!QVBoxLayout();
    layout.addWidget(textEdit);
    layout.addWidget(quitButton);

    auto window = cpp_new!QWidget();
    window.setLayout(layout);
    scope (exit)
        cpp_delete(window);

    window.show();

    return app.exec();
}
