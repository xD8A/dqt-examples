module notepad;

import qt.config;
import qt.core.string : QString;
import qt.helpers;
import qt.widgets.mainwindow : QMainWindow;
import qt.widgets.ui : UIStruct;
import qt.widgets.widget : QWidget;

class Notepad : QMainWindow
{
    mixin(Q_OBJECT_D);

public:
    this(QWidget parent = null)
    {
        import core.stdcpp.new_ : cpp_new;

        super(parent);

        ui = cpp_new!(typeof(*ui));
        ui.setupUi(this);

        connect(ui.actionNew.signal!"triggered", this.slot!"newDocument");
        connect(ui.actionOpen.signal!"triggered", this.slot!"open");
        connect(ui.actionSave.signal!"triggered", this.slot!"save");
        connect(ui.actionSave_as.signal!"triggered", this.slot!"saveAs");
        connect(ui.actionPrint.signal!"triggered", this.slot!"print");
        connect(ui.actionExit.signal!"triggered", this.slot!"close");

        connect(ui.textEdit.signal!"copyAvailable", ui.actionCopy.slot!"setEnabled");

        /+
        TODO:
        * QTextEdit.copy()

        connect(ui.actionCopy.signal!"triggered", ui.textEdit.slot!"copy");
        +/
        connect(ui.actionCopy.signal!"triggered", this.slot!"copyText");
        connect(ui.actionCut.signal!"triggered", ui.textEdit.slot!"cut");
        connect(ui.actionPaste.signal!"triggered", ui.textEdit.slot!"paste");

        connect(ui.textEdit.signal!"undoAvailable", ui.actionUndo.slot!"setEnabled");
        connect(ui.textEdit.signal!"redoAvailable", ui.actionRedo.slot!"setEnabled");

        connect(ui.actionUndo.signal!"triggered", ui.textEdit.slot!"undo");
        connect(ui.actionRedo.signal!"triggered", ui.textEdit.slot!"redo");

        connect(ui.actionFont.signal!"triggered", this.slot!"selectFont");
        connect(ui.actionBold.signal!"triggered", this.slot!"setFontBold");
        connect(ui.actionItalic.signal!"triggered", this.slot!"setFontItalic");
        connect(ui.actionUnderline.signal!"triggered", this.slot!"setFontUnderline");

        connect(ui.actionAbout.signal!"triggered", this.slot!"about");

        ui.actionCopy.setEnabled(false);
        ui.actionCut.setEnabled(false);
        ui.actionUndo.setEnabled(false);
        ui.actionRedo.setEnabled(false);
    }

    ~this()
    {
        import core.stdcpp.new_ : cpp_delete;

        cpp_delete(ui);
    }

private:
    @QSlot void newDocument()
    {
        currentFile = QString();
        ui.textEdit.setText(QString.create());
    }

    @QSlot void open()
    {
        import core.stdcpp.new_ : cpp_delete, cpp_new;
        import qt.core.file : QFile;
        import qt.widgets.filedialog : QFileDialog;
        import qt.widgets.messagebox : QMessageBox;

        auto fileName = QFileDialog.getOpenFileName(this, tr("Open File"));
        if (fileName.isEmpty())
            return;

        auto file = cpp_new!QFile(fileName);
        scope (exit)
            cpp_delete(file);

        if (!file.open(QFile.OpenMode(QFile.OpenModeFlag.ReadOnly | QFile.OpenModeFlag.Text)))
        {
            QMessageBox.warning(this, tr("Warning"),
                tr("Cannot open file: ") ~ file.errorString());
            return;
        }

        currentFile = fileName;
        setWindowTitle(fileName);
        ui.textEdit.setText(QString.fromUtf8(file.readAll()));
        file.close();
    }

    @QSlot void save()
    {
        if (currentFile.isEmpty())
        {
            saveAs();
            return;
        }

        import core.stdcpp.new_ : cpp_delete, cpp_new;
        import qt.core.file : QFile;
        import qt.widgets.messagebox : QMessageBox;

        auto file = cpp_new!QFile(currentFile);
        scope (exit)
            cpp_delete(file);

        if (!file.open(QFile.OpenMode(QFile.OpenModeFlag.WriteOnly | QFile.OpenModeFlag.Text)))
        {
            QMessageBox.warning(this, tr("Warning"),
                tr("Cannot save file: ") ~ file.errorString());
            return;
        }

        setWindowTitle(currentFile);
        file.write(ui.textEdit.toPlainText().toUtf8());
        file.close();
    }

    @QSlot void saveAs()
    {
        import core.stdcpp.new_ : cpp_delete, cpp_new;
        import qt.core.file : QFile;
        import qt.widgets.filedialog : QFileDialog;
        import qt.widgets.messagebox : QMessageBox;

        auto fileName = QFileDialog.getSaveFileName(this, tr("Save As"));
        if (fileName.isEmpty())
            return;

        auto file = cpp_new!QFile(fileName);
        scope (exit)
            cpp_delete(file);

        if (!file.open(QFile.OpenMode(QFile.OpenModeFlag.WriteOnly | QFile.OpenModeFlag.Text)))
        {
            QMessageBox.warning(this, tr("Warning"),
                tr("Cannot save file: ") ~ file.errorString());
            return;
        }

        currentFile = fileName;
        setWindowTitle(fileName);
        file.write(ui.textEdit.toPlainText().toUtf8());
        file.close();
    }

    @QSlot void print()
    {
        /+
        TODO:
        * PrintSupport

        import core.stdcpp.new_ : cpp_delete, cpp_new;
        import qt.printsupport.printdialog : QPrintDialog;
        import qt.printsupport.printer : QPrinter;
        import qt.widgets.dialog : QDialog;

        auto printer = cpp_new!QPrinter;
        scope (exit)
            cpp_delete(printer);

        auto dialog = cpp_new!QPrintDialog(printer, this);
        scope (exit)
            cpp_delete(dialog);

        if (dialog.exec() == QDialog.DialogCode.Accepted)
            ui.textEdit.print(printer);
        +/
    }

    @QSlot void selectFont()
    {
        import qt.widgets.fontdialog : QFontDialog;

        bool ok = false;
        auto font = QFontDialog.getFont(&ok, this);
        if (ok)
            ui.textEdit.setFont(font);
    }

    @QSlot void setFontBold(bool bold)
    {
        import qt.gui.font : QFont;

        if (bold)
            ui.textEdit.setFontWeight(QFont.Weight.Bold);
        else
            ui.textEdit.setFontWeight(QFont.Weight.Normal);
    }

    @QSlot void setFontItalic(bool italic)
    {
        ui.textEdit.setFontItalic(italic);
    }

    @QSlot void setFontUnderline(bool underline)
    {
        ui.textEdit.setFontUnderline(underline);
    }

    @QSlot void copyText()
    {
        import qt.gui.clipboard : QClipboard;
        import qt.widgets.application : QApplication;

        auto clipboard = QApplication.clipboard();
        clipboard.setText(ui.textEdit.textCursor().selectedText());
    }

    @QSlot void about()
    {
        import qt.widgets.messagebox : QMessageBox;

        QMessageBox.about(this, tr("About Notepad"),
            tr(
                "The <b>Notepad</b> example demonstrates how to code a basic text editor using QtWidgets"));
    }

    UIStruct!"notepad.ui"* ui;
    QString currentFile;
}
