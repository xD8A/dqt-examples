module main;

import testwidget;

//! [0]

int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.widgets.application;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto w = cpp_new!TestWidget();
    scope(exit) cpp_delete(w);
    w.showFullScreen();

    return app.exec();
}

//! [0]