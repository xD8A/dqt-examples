//! [FindDialog header 0]
module finddialog;

import core.stdcpp.new_ : cpp_new;
import qt.config;
import qt.core.string : QString;
import qt.helpers;
import qt.widgets.boxlayout : QHBoxLayout;
import qt.widgets.dialog : QDialog;
import qt.widgets.label : QLabel;
import qt.widgets.lineedit : QLineEdit;
import qt.widgets.messagebox : QMessageBox;
import qt.widgets.pushbutton : QPushButton;
import qt.widgets.widget : QWidget;

class FindDialog : QDialog
{
    mixin(Q_OBJECT_D);

public:
//! [constructor]
    this(QWidget parent = null)
    {
//! [FindDialog header 0]
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
//! [FindDialog header 1]
    }
//! [constructor]

//! [findClicked() function]
    @QSlot final void findClicked()
    {
//! [FindDialog header 1]
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
//! [FindDialog header 2]
    }
//! [findClicked() function]

//! [getFindText() function]
    QString getFindText()
    {
//! [FindDialog header 2]
        return findText;
//! [FindDialog header 3]
    }
//! [getFindText() function]

private:
    QPushButton findButton;
    QLineEdit lineEdit;
    QString findText;
}
//! [FindDialog header 3]
