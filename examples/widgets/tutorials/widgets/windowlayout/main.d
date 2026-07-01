module main;

int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.widgets.application;
    import qt.widgets.boxlayout;
    import qt.widgets.label;
    import qt.widgets.lineedit;
    import qt.widgets.widget;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto window = cpp_new!QWidget();
    scope(exit) cpp_delete(window);

    auto label = cpp_new!QLabel(
        QApplication.translate("windowlayout", "Name:"));
    auto lineEdit = cpp_new!QLineEdit();

    auto layout = cpp_new!QHBoxLayout();
    layout.addWidget(label);
    layout.addWidget(lineEdit);
    window.setLayout(layout);

    window.setWindowTitle(
        QApplication.translate("windowlayout", "Window layout"));
    window.show();

    return app.exec();
}
