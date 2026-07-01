module main;

import qt.config;
import qt.helpers;
import qt.widgets.mainwindow;
import qt.widgets.textedit;
import qt.widgets.widget;
import qt.widgets.menu;
import qt.widgets.action;

class Notepad : QMainWindow
{
    mixin(Q_OBJECT_D);

public:
    this(QWidget parent = null)
    {
        import core.stdcpp.new_;
        import qt.widgets.application;

        super(parent);

        loadAction = cpp_new!QAction(tr("&Load"), this);
        saveAction = cpp_new!QAction(tr("&Save"), this);
        exitAction = cpp_new!QAction(tr("E&xit"), this);

        connect(loadAction.signal!"triggered", this.slot!"load");
        connect(saveAction.signal!"triggered", this.slot!"save");
        connect(exitAction.signal!"triggered", QApplication.instance().slot!"quit");

        fileMenu = menuBar().addMenu(tr("&File"));
        fileMenu.addAction(loadAction);
        fileMenu.addAction(saveAction);
        fileMenu.addSeparator();
        fileMenu.addAction(exitAction);

        textEdit = cpp_new!QTextEdit();
        setCentralWidget(textEdit);

        setWindowTitle(tr("Notepad"));
    }

private:
    @QSlot final void load()
    {
    }

    @QSlot final void save()
    {
    }

    QTextEdit textEdit;
    QAction loadAction;
    QAction saveAction;
    QAction exitAction;
    QMenu fileMenu;
}

int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.widgets.application;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto notepad = cpp_new!Notepad();
    scope(exit) cpp_delete(notepad);
    notepad.show();

    return app.exec();
}
