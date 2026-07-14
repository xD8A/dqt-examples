module main;

import core.stdcpp.new_ : cpp_delete, cpp_new;
import qt.config;
import qt.helpers;
import qt.widgets.action : QAction;
import qt.widgets.mainwindow : QMainWindow;
import qt.widgets.menu : QMenu;
import qt.widgets.textedit : QTextEdit;

class Notepad : QMainWindow
{
    mixin(Q_OBJECT_D);

public:
    this(QWidget parent = null)
    {
        import qt.widgets.application : QApplication;

        super(parent);

        openAction = cpp_new!QAction(tr("&Load"), this);
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
    @QSlot void open()
    {
        import qt.core.file : QFile;
        import qt.core.iodevice : QIODevice;
        import qt.core.string : QString;
        import qt.widgets.filedialog : QFileDialog;
        import qt.widgets.messagebox : QMessageBox;

        auto fileName = QFileDialog.getOpenFileName(this, tr("Open File"), "",
            tr("Text Files (*.txt);;C++ Files (*.cpp *.h)"));

        if (!fileName.isEmpty())
        {
            auto file = cpp_new!QFile(fileName);
            scope (exit)
                cpp_delete(file);
            if (!file.open(QIODevice.OpenMode.ReadOnly))
            {
                QMessageBox.critical(this, tr("Error"), tr("Could not open file"));
                return;
            }
            /+
            TODO: 
            * QTextStream

            auto in_ = cpp_new!QTextStream(file);
            scope (exit)
                cpp_delete(in_);
            textEdit.setText(in_.readAll());
            +/
            textEdit.setText(QString.fromUtf8(file.readAll()));
            file.close();
        }
    }

    @QSlot void save()
    {
        import qt.core.file : QFile;
        import qt.core.iodevice : QIODevice;
        import qt.widgets.filedialog : QFileDialog;

        auto fileName = QFileDialog.getSaveFileName(this, tr("Save File"), "",
            tr("Text Files (*.txt);;C++ Files (*.cpp *.h)"));

        if (!fileName.isEmpty())
        {
            auto file = cpp_new!QFile(fileName);
            scope (exit)
                cpp_delete(file);

            if (!file.open(QIODevice.OpenModeFlag.WriteOnly))
            {
                // error message
            }
            else
            {
                /+
                TODO: 
                * QTextStream

                auto stream = cpp_new!QTextStream(file);
                scope (exit)
                    cpp_delete(stream);
                stream << textEdit.toPlainText();
                stream.flush();
                +/
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
    import core.runtime : Runtime;
    import qt.widgets.application : QApplication;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto notepad = cpp_new!Notepad();
    scope (exit)
        cpp_delete(notepad);
    notepad.show();

    return app.exec();
}
