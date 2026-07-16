module main;

int main()
{
    import core.runtime : Runtime;
    import core.stdcpp.new_ : cpp_delete, cpp_new;
    import qt.core.resource : QResource;
    import qt.widgets.application : QApplication;
    import sortingbox : SortingBox;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);
    QResource.registerResource("tooltips.rcc");

    auto sortingBox = cpp_new!SortingBox();
    scope (exit)
        cpp_delete(sortingBox);
    sortingBox.show();

    return app.exec();
}
