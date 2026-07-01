module main;

int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.core.object;
    import qt.widgets.application;
    import qt.widgets.boxlayout;
    import qt.widgets.pushbutton;
    import qt.widgets.textedit;
    import qt.widgets.widget;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto textEdit = cpp_new!QTextEdit();
    auto quitButton = cpp_new!QPushButton("&Quit");

    QObject.connect(quitButton.signal!"clicked", app.slot!"quit");

    auto layout = cpp_new!QVBoxLayout();
    layout.addWidget(textEdit);
    layout.addWidget(quitButton);

    auto window = cpp_new!QWidget();
    window.setLayout(layout);
    scope(exit) cpp_delete(window);

    window.show();

    return app.exec();
}
