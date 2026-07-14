module finddialog;

import qt.config;
import qt.core.string : QString;
import qt.helpers;
import qt.widgets.dialog : QDialog;
import qt.widgets.lineedit : QLineEdit;
import qt.widgets.pushbutton : QPushButton;
import qt.widgets.widget : QWidget;

class FindDialog : QDialog
{
    mixin(Q_OBJECT_D);

public:
    this(QWidget parent = null)
    {
        import core.stdcpp.new_ : cpp_new;
        import qt.widgets.boxlayout : QHBoxLayout;
        import qt.widgets.label : QLabel;

        super(parent);

        auto findLabel = cpp_new!QLabel(tr("Enter the name of a contact:"));
        lineEdit = cpp_new!QLineEdit();

        findButton = cpp_new!QPushButton(tr("&Find"));
        findText = QString.create();

        auto layout = cpp_new!QHBoxLayout();
        layout.addWidget(findLabel);
        layout.addWidget(lineEdit);
        layout.addWidget(findButton);

        setLayout(layout);
        setWindowTitle(tr("Find a Contact"));

        connect(findButton.signal!"clicked", this.slot!"findClicked");
        connect(findButton.signal!"clicked", this.slot!"accept");
    }

    @QSlot final void findClicked()
    {
        import qt.widgets.messagebox : QMessageBox;

        auto text = lineEdit.text();
        if (text.isEmpty())
        {
            QMessageBox.information(this, tr("Empty Field"),
                tr("Please enter a name."));
            return;
        }
        else
        {
            findText = text;
            lineEdit.clear();
            hide();
        }
    }

    QString getFindText()
    {
        return findText;
    }

private:
    QPushButton findButton;
    QLineEdit lineEdit;
    QString findText;
}
