module main;

import core.stdcpp.new_ : cpp_delete, cpp_new;
import qt.config;
import qt.helpers;
import qt.widgets.action : QAction;
import qt.widgets.mainwindow : QMainWindow;
import qt.widgets.menu : QMenu;
import qt.widgets.textedit : QTextEdit;
import qt.widgets.widget : QWidget;

class Notepad : QMainWindow
{
    mixin(Q_OBJECT_D);

public:
    this(QWidget parent = null)
    {
        import qt.widgets.application : QApplication;

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
    @QSlot void load()
    {
    }

    @QSlot void save()
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
    import core.runtime : Runtime;
    import qt.widgets.application : QApplication;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto notepad = cpp_new!Notepad();
    scope (exit)
        cpp_delete(notepad);
    notepad.show();

    return app.exec();
}
