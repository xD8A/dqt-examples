module addressbook;

import qt.config;
import qt.helpers;
import qt.widgets.widget;
import qt.widgets.pushbutton;
import qt.widgets.lineedit;
import qt.widgets.textedit;
import qt.core.string;

class AddressBook : QWidget
{
    mixin(Q_OBJECT_D);

public:
    this(QWidget parent = null)
    {
        import core.stdcpp.new_;
        import qt.widgets.label;
        import qt.widgets.gridlayout;
        import qt.widgets.boxlayout;
        import qt.core.namespace;

        super(parent);

        auto nameLabel = cpp_new!QLabel(tr("Name:"));
        nameLine = cpp_new!QLineEdit();
        nameLine.setReadOnly(true);

        auto addressLabel = cpp_new!QLabel(tr("Address:"));
        addressText = cpp_new!QTextEdit();
        addressText.setReadOnly(true);

        addButton = cpp_new!QPushButton(tr("&Add"));
        addButton.show();
        submitButton = cpp_new!QPushButton(tr("&Submit"));
        submitButton.hide();
        cancelButton = cpp_new!QPushButton(tr("&Cancel"));
        cancelButton.hide();

        connect(addButton.signal!"clicked", this.slot!"addContact");
        connect(submitButton.signal!"clicked", this.slot!"submitContact");
        connect(cancelButton.signal!"clicked", this.slot!"cancel");

        auto buttonLayout = cpp_new!QVBoxLayout();
        buttonLayout.addWidget(addButton, 0, Alignment(AlignmentFlag.AlignTop));
        buttonLayout.addWidget(submitButton);
        buttonLayout.addWidget(cancelButton);
        buttonLayout.addStretch();

        auto mainLayout = cpp_new!QGridLayout();
        mainLayout.addWidget(nameLabel, 0, 0);
        mainLayout.addWidget(nameLine, 0, 1);
        mainLayout.addWidget(addressLabel, 1, 0, Alignment(AlignmentFlag.AlignTop));
        mainLayout.addWidget(addressText, 1, 1);
        mainLayout.addLayout(buttonLayout, 1, 2);

        setLayout(mainLayout);
        setWindowTitle(tr("Simple Address Book"));
    }

private:
    @QSlot final void addContact()
    {
        import qt.core.namespace;

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

    @QSlot final void submitContact()
    {
        import qt.widgets.messagebox;

        QString name = nameLine.text();
        QString address = addressText.toPlainText();

        if (name.isEmpty() || address.isEmpty())
        {
            QMessageBox.information(this, tr("Empty Field"),
                tr("Please enter a name and address."));
            return;
        }

        foreach (n; contactNames)
        {
            if (n == name)
            {
                QMessageBox.information(this, tr("Add Unsuccessful"),
                    tr("Sorry, \"%1\" is already in your address book.").arg(name));
                return;
            }
        }

        contactNames ~= name;
        contactAddresses ~= address;
        QMessageBox.information(this, tr("Add Successful"),
            tr("\"%1\" has been added to your address book.").arg(name));

        nameLine.setReadOnly(true);
        addressText.setReadOnly(true);
        addButton.setEnabled(true);
        submitButton.hide();
        cancelButton.hide();
    }

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

    QPushButton addButton;
    QPushButton submitButton;
    QPushButton cancelButton;
    QLineEdit nameLine;
    QTextEdit addressText;
    QString[] contactNames;
    QString[] contactAddresses;
    QString oldName;
    QString oldAddress;
}
