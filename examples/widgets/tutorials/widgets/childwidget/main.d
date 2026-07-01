module main;

int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.widgets.application;
    import qt.widgets.pushbutton;
    import qt.widgets.widget;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto window = cpp_new!QWidget();
    scope(exit) cpp_delete(window);
    window.resize(320, 240);
    window.setWindowTitle(
        QApplication.translate("childwidget", "Child widget"));
    window.show();

    auto button = cpp_new!QPushButton(
        QApplication.translate("childwidget", "Press me"), window);
    button.move(100, 100);
    button.show();

    return app.exec();
}
