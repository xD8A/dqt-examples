module main;

import qt.config;
import qt.helpers;
import qt.widgets.widget;
import qt.widgets.pushbutton;
import qt.widgets.textedit;

class Notepad : QWidget
{
    mixin(Q_OBJECT_D);

public:
    this(QWidget parent = null)
    {
        import core.stdcpp.new_;
        import qt.widgets.boxlayout;

        super(parent);

        textEdit = cpp_new!QTextEdit();
        quitButton = cpp_new!QPushButton(tr("Quit"));

        connect(quitButton.signal!"clicked", this.slot!"quit");

        auto layout = cpp_new!QVBoxLayout();
        layout.addWidget(textEdit);
        layout.addWidget(quitButton);

        setLayout(layout);

        setWindowTitle(tr("Notepad"));
    }

private:
    @QSlot final void quit()
    {
        import core.stdcpp.new_;
        import qt.widgets.application;
        import qt.widgets.messagebox;

        auto msgBox = cpp_new!QMessageBox();
        scope(exit) cpp_delete(msgBox);
        msgBox.setWindowTitle(tr("Notepad"));
        msgBox.setText(tr("Do you really want to quit?"));
        {
            QMessageBox.StandardButtons buttons;
            buttons |= QMessageBox.StandardButton.Yes;
            buttons |= QMessageBox.StandardButton.No;
            msgBox.setStandardButtons(buttons);
        }
        msgBox.setDefaultButton(QMessageBox.StandardButton.No);
        if (msgBox.exec() == QMessageBox.StandardButton.Yes)
            QApplication.quit();
    }

    QTextEdit textEdit;
    QPushButton quitButton;
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
