module main;

import mainwindow;

import qt.core.namespace;
import qt.core.rect;
import qt.core.string;
import qt.gui.screen;

int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.widgets.application;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto mainWin = cpp_new!MainWindow();
    scope(exit) cpp_delete(mainWin);

    auto availableGeometry = mainWin.screen().availableGeometry();
    mainWin.resize(availableGeometry.width() / 2, availableGeometry.height() * 2 / 3);
    mainWin.move((availableGeometry.width() - mainWin.width()) / 2,
                 (availableGeometry.height() - mainWin.height()) / 2);

    mainWin.show();
    mainWin.setupScreen();
    return app.exec();
}
