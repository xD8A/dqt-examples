module notepad;

import qt.config;
import qt.helpers;
import qt.core.string;
import qt.gui.font;
import qt.widgets.mainwindow;
import qt.widgets.textedit;
import qt.widgets.widget;
import qt.widgets.ui;
import qt.widgets.action;
import qt.widgets.filedialog;
import qt.widgets.messagebox;
import qt.widgets.fontdialog;

class Notepad : QMainWindow
{
    mixin(Q_OBJECT_D);

public:
    this(QWidget parent = null)
    {
        import core.stdcpp.new_;
        import qt.widgets.application;

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

        connect(ui.actionCopy.signal!"triggered", ui.textEdit.slot!"copy");
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

        ui.actionPrint.setEnabled(false);
        ui.actionCopy.setEnabled(false);
        ui.actionCut.setEnabled(false);
        ui.actionUndo.setEnabled(false);
        ui.actionRedo.setEnabled(false);
    }

    ~this()
    {
        import core.stdcpp.new_;
        cpp_delete(ui);
    }

private:
    @QSlot final void newDocument()
    {
        currentFile = QString();
        ui.textEdit.setText(QString());
    }

    @QSlot final void open()
    {
        import core.stdcpp.new_;
        import qt.core.file;

        auto fileName = QFileDialog.getOpenFileName(this, tr("Open File"));
        if (fileName.isEmpty())
            return;

        auto file = cpp_new!QFile(fileName);
        scope(exit) cpp_delete(file);

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

    @QSlot final void save()
    {
        if (currentFile.isEmpty())
        {
            saveAs();
            return;
        }

        import core.stdcpp.new_;
        import qt.core.file;

        auto file = cpp_new!QFile(currentFile);
        scope(exit) cpp_delete(file);

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

    @QSlot final void saveAs()
    {
        import core.stdcpp.new_;
        import qt.core.file;

        auto fileName = QFileDialog.getSaveFileName(this, tr("Save As"));
        if (fileName.isEmpty())
            return;

        auto file = cpp_new!QFile(fileName);
        scope(exit) cpp_delete(file);

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

    @QSlot final void print()
    {
        // TODO: implement using QPdfWriter or QPrinter when available
    }

    @QSlot final void selectFont()
    {
        bool ok = false;
        auto font = QFontDialog.getFont(&ok, this);
        if (ok)
            ui.textEdit.setFont(font);
    }

    @QSlot final void setFontBold(bool bold)
    {
        if (bold)
            ui.textEdit.setFontWeight(QFont.Weight.Bold);
        else
            ui.textEdit.setFontWeight(QFont.Weight.Normal);
    }

    @QSlot final void setFontItalic(bool italic)
    {
        ui.textEdit.setFontItalic(italic);
    }

    @QSlot final void setFontUnderline(bool underline)
    {
        ui.textEdit.setFontUnderline(underline);
    }

    @QSlot final void about()
    {
        QMessageBox.about(this, tr("About Notepad"),
            tr("The <b>Notepad</b> example demonstrates how to code a basic text editor using QtWidgets"));
    }

    UIStruct!"notepad.ui"* ui;
    QString currentFile;
}
