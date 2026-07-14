module addressbook;

import qt.config;
import qt.core.string : QString;
import qt.helpers;
import qt.widgets.lineedit : QLineEdit;
import qt.widgets.pushbutton : QPushButton;
import qt.widgets.textedit : QTextEdit;
import qt.widgets.widget : QWidget;

class AddressBook : QWidget
{
    mixin(Q_OBJECT_D);

public:
    this(QWidget parent = null)
    {
        import core.stdcpp.new_ : cpp_new;
        import qt.core.namespace : Alignment, AlignmentFlag;
        import qt.widgets.boxlayout : QVBoxLayout;
        import qt.widgets.gridlayout : QGridLayout;
        import qt.widgets.label : QLabel;

        super(parent);

        auto nameLabel = cpp_new!QLabel(tr("Name:"));
        nameLine = cpp_new!QLineEdit();
        //! [setting readonly 1]
        nameLine.setReadOnly(true);
        //! [setting readonly 1]
        auto addressLabel = cpp_new!QLabel(tr("Address:"));
        addressText = cpp_new!QTextEdit();
        //! [setting readonly 2]
        addressText.setReadOnly(true);
        //! [setting readonly 2]

        //! [pushbutton declaration]
        addButton = cpp_new!QPushButton(tr("&Add"));
        addButton.show();
        submitButton = cpp_new!QPushButton(tr("&Submit"));
        submitButton.hide();
        cancelButton = cpp_new!QPushButton(tr("&Cancel"));
        cancelButton.hide();
        //! [pushbutton declaration]
        //! [connecting signals and slots]
        connect(addButton.signal!"clicked", this.slot!"addContact");
        connect(submitButton.signal!"clicked", this.slot!"submitContact");
        connect(cancelButton.signal!"clicked", this.slot!"cancel");
        //! [connecting signals and slots]
        //! [vertical layout]
        auto buttonLayout = cpp_new!QVBoxLayout();
        buttonLayout.addWidget(addButton, 0, Alignment(AlignmentFlag.AlignTop));
        buttonLayout.addWidget(submitButton);
        buttonLayout.addWidget(cancelButton);
        buttonLayout.addStretch();
        //! [vertical layout]
        //! [grid layout]
        auto mainLayout = cpp_new!QGridLayout();
        mainLayout.addWidget(nameLabel, 0, 0);
        mainLayout.addWidget(nameLine, 0, 1);
        mainLayout.addWidget(addressLabel, 1, 0, Alignment(AlignmentFlag.AlignTop));
        mainLayout.addWidget(addressText, 1, 1);
        mainLayout.addLayout(buttonLayout, 1, 2);
        //! [grid layout]
        setLayout(mainLayout);
        setWindowTitle(tr("Simple Address Book"));
    }

    //! [slots]
    //! [addContact]
    @QSlot final void addContact()
    {
        import qt.core.namespace : FocusReason;

        oldName = nameLine.text();
        oldAddress = addressText.toPlainText();

        nameLine.clear();
        addressText.clear();

        nameLine.setReadOnly(false);
        nameLine.setFocus(FocusReason.OtherFocusReason);
        addressText.setReadOnly(false);

        addButton.setEnabled(false);
        submitButton.show();
        cancelButton.show();
    }
    //! [addContact]

    //! [submitContact part1]
    @QSlot final void submitContact()
    {
        import qt.widgets.messagebox : QMessageBox;

        QString name = nameLine.text();
        string nameStr = name.toUtf8().toConstCharArray().idup; // TODO: QString.toDString?
        QString address = addressText.toPlainText();

        if (name.isEmpty() || address.isEmpty())
        {
            QMessageBox.information(this, tr("Empty Field"),
                tr("Please enter a name and address."));
            return;
        }
        //! [submitContact part1]
        //! [submitContact part2]
        if (nameStr !in contacts) // TODO: if (!contacts.contains(name))
        {
            contacts[nameStr] = address; // TODO: contacts.insert(name, address);
            QMessageBox.information(this, tr("Add Successful"),
                tr("\"%1\" has been added to your address book.").arg(name));
        }
        else
        {
            QMessageBox.information(this, tr("Add Unsuccessful"),
                tr("Sorry, \"%1\" is already in your address book.").arg(name));
            return;
        }
        //! [submitContact part2]
        //! [submitContact part3]
        if (contacts.length == 0) // TODO: if (contacts.isEmpty())
        {
            nameLine.clear();
            addressText.clear();
        }
        nameLine.setReadOnly(true);
        addressText.setReadOnly(true);
        addButton.setEnabled(true);
        submitButton.hide();
        cancelButton.hide();
    }
    //! [submitContact part3]
    //! [cancel]
    @QSlot final void cancel()
    {
        nameLine.setText(oldName);
        nameLine.setReadOnly(true);

        addressText.setText(oldAddress);
        addressText.setReadOnly(true);

        addButton.setEnabled(true);
        submitButton.hide();
        cancelButton.hide();
    }
    //! [cancel]
    //! [slots]

    //! [pushbutton declaration]
private:
    QPushButton addButton;
    QPushButton submitButton;
    QPushButton cancelButton;
    QLineEdit nameLine;
    QTextEdit addressText;
    //! [pushbutton declaration]

    //! [remaining private variables]
    QString[string] contacts; // TODO: QMap!(QString, QString) contacts;
    QString oldName;
    QString oldAddress;
}
//! [remaining private variables]
