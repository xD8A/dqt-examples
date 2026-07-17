module main;

import core.runtime : Runtime;
import core.stdcpp.new_ : cpp_delete, cpp_new;
import qt.gui.guiapplication : QGuiApplication;

import rasterwindow : RasterWindow;

//! [1]
int main()
{
    scope app = new QGuiApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto window = cpp_new!RasterWindow();
    scope(exit)
        cpp_delete(window);
    window.show();

    return app.exec();
}
//! [1]
