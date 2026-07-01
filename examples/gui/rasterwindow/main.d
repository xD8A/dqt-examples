module main;

import rasterwindow;

//! [1]
int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.gui.guiapplication;

    scope app = new QGuiApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto window = cpp_new!RasterWindow();
    scope(exit) cpp_delete(window);
    window.show();

    return app.exec();
}
//! [1]
