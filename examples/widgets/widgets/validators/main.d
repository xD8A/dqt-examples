module main;

int main()
{
    import core.runtime : Runtime;
    import core.stdcpp.new_ : cpp_delete, cpp_new;
    import qt.core.resource : QResource;
    import qt.widgets.application : QApplication;
    import validatorwidget : ValidatorWidget;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);
    QResource.registerResource("validators.rcc");

    auto w = cpp_new!ValidatorWidget();
    scope (exit)
        cpp_delete(w);
    w.show();

    return app.exec();
}
