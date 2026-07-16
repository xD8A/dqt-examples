module main;

import imageviewer;

int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.widgets.application;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto imageViewer = cpp_new!ImageViewer();
    scope(exit) cpp_delete(imageViewer);
    imageViewer.show();

    return app.exec();
}
