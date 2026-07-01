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

        openAction = cpp_new!QAction(tr("&Open"), this);
        saveAction = cpp_new!QAction(tr("&Save"), this);
        exitAction = cpp_new!QAction(tr("E&xit"), this);

        connect(openAction.signal!"triggered", this.slot!"open");
        connect(saveAction.signal!"triggered", this.slot!"save");
        connect(exitAction.signal!"triggered", QApplication.instance().slot!"quit");

        fileMenu = menuBar().addMenu(tr("&File"));
        fileMenu.addAction(openAction);
        fileMenu.addAction(saveAction);
        fileMenu.addSeparator();
        fileMenu.addAction(exitAction);

        textEdit = cpp_new!QTextEdit();
        setCentralWidget(textEdit);

        setWindowTitle(tr("Notepad"));
    }

private:
    @QSlot final void open()
    {
        import core.stdcpp.new_;
        import qt.core.string;
        import qt.core.file;
        import qt.widgets.filedialog;
        import qt.widgets.messagebox;

        auto fileName = QFileDialog.getOpenFileName(this, tr("Open File"), "",
            tr("Text Files (*.txt);;C++ Files (*.cpp *.h)"));

        if (!fileName.isEmpty())
        {
            auto file = cpp_new!QFile(fileName);
            scope(exit) cpp_delete(file);

            if (!file.open(QFile.OpenMode(QFile.OpenModeFlag.ReadOnly)))
            {
                QMessageBox.critical(this, tr("Error"), tr("Could not open file"));
                return;
            }
            textEdit.setPlainText(QString.fromUtf8(file.readAll()));
            file.close();
        }
    }

    @QSlot final void save()
    {
        import core.stdcpp.new_;
        import qt.core.file;
        import qt.widgets.filedialog;

        auto fileName = QFileDialog.getSaveFileName(this, tr("Save File"), "",
            tr("Text Files (*.txt);;C++ Files (*.cpp *.h)"));

        if (!fileName.isEmpty())
        {
            auto file = cpp_new!QFile(fileName);
            scope(exit) cpp_delete(file);

            if (!file.open(QFile.OpenMode(QFile.OpenModeFlag.WriteOnly)))
            {
                // error message
            }
            else
            {
                file.write(textEdit.toPlainText().toUtf8());
                file.close();
            }
        }
    }

    QTextEdit textEdit;
    QAction openAction;
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
