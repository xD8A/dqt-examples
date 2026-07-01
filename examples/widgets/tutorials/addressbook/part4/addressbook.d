module addressbook;

import qt.config;
import qt.helpers;
import qt.widgets.widget;
import qt.widgets.label;
import qt.widgets.lineedit;
import qt.widgets.textedit;
import qt.widgets.pushbutton;
import qt.widgets.gridlayout;
import qt.widgets.boxlayout;
import qt.core.string;
import qt.core.bytearray;

class AddressBook : QWidget
{
    mixin(Q_OBJECT_D);

public:
    enum Mode
    {
        NavigationMode,
        AddingMode,
        EditingMode
    }

    this(QWidget parent = null)
    {
        import core.stdcpp.new_;
        import qt.core.namespace;

        super(parent);

        auto nameLabel = cpp_new!QLabel(tr("Name:"));
        nameLine = cpp_new!QLineEdit();
        nameLine.setReadOnly(true);

        auto addressLabel = cpp_new!QLabel(tr("Address:"));
        addressText = cpp_new!QTextEdit();
        addressText.setReadOnly(true);

        addButton = cpp_new!QPushButton(tr("&Add"));
        editButton = cpp_new!QPushButton(tr("&Edit"));
        editButton.setEnabled(false);
        removeButton = cpp_new!QPushButton(tr("&Remove"));
        removeButton.setEnabled(false);
        submitButton = cpp_new!QPushButton(tr("&Submit"));
        submitButton.hide();
        cancelButton = cpp_new!QPushButton(tr("&Cancel"));
        cancelButton.hide();

        nextButton = cpp_new!QPushButton(tr("&Next"));
        nextButton.setEnabled(false);
        previousButton = cpp_new!QPushButton(tr("&Previous"));
        previousButton.setEnabled(false);

        connect(addButton.signal!"clicked", this.slot!"addContact");
        connect(editButton.signal!"clicked", this.slot!"editContact");
        connect(removeButton.signal!"clicked", this.slot!"removeContact");
        connect(submitButton.signal!"clicked", this.slot!"submitContact");
        connect(cancelButton.signal!"clicked", this.slot!"cancel");
        connect(nextButton.signal!"clicked", this.slot!"next");
        connect(previousButton.signal!"clicked", this.slot!"previous");

        auto buttonLayout1 = cpp_new!QVBoxLayout();
        buttonLayout1.addWidget(addButton);
        buttonLayout1.addWidget(editButton);
        buttonLayout1.addWidget(removeButton);
        buttonLayout1.addWidget(submitButton);
        buttonLayout1.addWidget(cancelButton);
        buttonLayout1.addStretch();

        auto buttonLayout2 = cpp_new!QHBoxLayout();
        buttonLayout2.addWidget(previousButton);
        buttonLayout2.addWidget(nextButton);

        auto mainLayout = cpp_new!QGridLayout();
        mainLayout.addWidget(nameLabel, 0, 0);
        mainLayout.addWidget(nameLine, 0, 1);
        mainLayout.addWidget(addressLabel, 1, 0, Alignment(AlignmentFlag.AlignTop));
        mainLayout.addWidget(addressText, 1, 1);
        mainLayout.addLayout(buttonLayout1, 1, 2);
        mainLayout.addLayout(buttonLayout2, 2, 1);

        setLayout(mainLayout);
        setWindowTitle(tr("Simple Address Book"));

        currentMode = Mode.NavigationMode;
    }

    @QSlot final void addContact()
    {
        oldName = qsToStr(nameLine.text());
        oldAddress = qsToStr(addressText.toPlainText());

        nameLine.clear();
        addressText.clear();

        updateInterface(Mode.AddingMode);
    }

    @QSlot final void editContact()
    {
        oldName = qsToStr(nameLine.text());
        oldAddress = qsToStr(addressText.toPlainText());

        updateInterface(Mode.EditingMode);
    }

    @QSlot final void submitContact()
    {
        import qt.widgets.messagebox;

        auto name = qsToStr(nameLine.text());
        auto address = qsToStr(addressText.toPlainText());

        if (name.length == 0 || address.length == 0)
        {
            QMessageBox.information(this, tr("Empty Field"),
                tr("Please enter a name and address."));
            return;
        }

        if (currentMode == Mode.AddingMode)
        {
            if (name in contacts)
            {
                QMessageBox.information(this, tr("Add Unsuccessful"),
                    tr("Sorry, \"%1\" is already in your address book.").arg(nameLine.text()));
            }
            else
            {
                contacts[name] = address;
                QMessageBox.information(this, tr("Add Successful"),
                    tr("\"%1\" has been added to your address book.").arg(nameLine.text()));
            }
        }
        else if (currentMode == Mode.EditingMode)
        {
            if (oldName != name)
            {
                if (name in contacts)
                {
                    QMessageBox.information(this, tr("Edit Unsuccessful"),
                        tr("Sorry, \"%1\" is already in your address book.").arg(nameLine.text()));
                }
                else
                {
                    contacts.remove(oldName);
                    contacts[name] = address;
                    QMessageBox.information(this, tr("Edit Successful"),
                        tr("\"%1\" has been edited in your address book.").arg(QString(oldName)));
                }
            }
            else if (oldAddress != address)
            {
                contacts[name] = address;
                QMessageBox.information(this, tr("Edit Successful"),
                    tr("\"%1\" has been edited in your address book.").arg(nameLine.text()));
            }
        }

        updateInterface(Mode.NavigationMode);
    }

    @QSlot final void cancel()
    {
        nameLine.setText(QString(oldName));
        addressText.setText(QString(oldAddress));
        updateInterface(Mode.NavigationMode);
    }

    @QSlot final void removeContact()
    {
        import qt.widgets.messagebox;

        auto name = qsToStr(nameLine.text());

        if (name in contacts)
        {
            auto button = QMessageBox.question(this, tr("Confirm Remove"),
                tr("Are you sure you want to remove \"%1\"?").arg(nameLine.text()),
                QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No);

            if (button == QMessageBox.StandardButton.Yes)
            {
                previous();
                contacts.remove(name);

                QMessageBox.information(this, tr("Remove Successful"),
                    tr("\"%1\" has been removed from your address book.").arg(nameLine.text()));
            }
        }

        updateInterface(Mode.NavigationMode);
    }

    @QSlot final void next()
    {
        import std.array;
        import std.algorithm.sorting;

        auto name = qsToStr(nameLine.text());
        auto keys = contacts.keys;
        keys.sort; // QMap stores keys in sorted order; D's AA keys need explicit sort for deterministic navigation

        if (keys.length == 0)
            return;

        size_t idx = keys.length - 1;
        foreach (i, k; keys)
        {
            if (k == name)
            {
                idx = i;
                break;
            }
        }
        idx++;
        if (idx >= keys.length)
            idx = 0;

        nameLine.setText(QString(keys[idx]));
        addressText.setText(QString(contacts[keys[idx]]));
    }

    @QSlot final void previous()
    {
        import std.array;
        import std.algorithm.sorting;

        auto name = qsToStr(nameLine.text());
        auto keys = contacts.keys;
        keys.sort; // QMap stores keys in sorted order; D's AA keys need explicit sort for deterministic navigation

        if (keys.length == 0)
        {
            nameLine.clear();
            addressText.clear();
            return;
        }

        size_t idx = 0;
        foreach (i, k; keys)
        {
            if (k == name)
            {
                idx = i;
                break;
            }
        }

        if (idx == 0)
            idx = keys.length - 1;
        else
            idx--;

        nameLine.setText(QString(keys[idx]));
        addressText.setText(QString(contacts[keys[idx]]));
    }

private:
    void updateInterface(Mode mode)
    {
        currentMode = mode;

        switch (currentMode)
        {
        case Mode.AddingMode:
        case Mode.EditingMode:
            nameLine.setReadOnly(false);
            addressText.setReadOnly(false);

            addButton.setEnabled(false);
            editButton.setEnabled(false);
            removeButton.setEnabled(false);
            nextButton.setEnabled(false);
            previousButton.setEnabled(false);

            submitButton.show();
            cancelButton.show();
            break;

        case Mode.NavigationMode:
            if (contacts.length == 0)
            {
                nameLine.clear();
                addressText.clear();
            }

            nameLine.setReadOnly(true);
            addressText.setReadOnly(true);
            addButton.setEnabled(true);

            auto number = contacts.length;
            editButton.setEnabled(number >= 1);
            removeButton.setEnabled(number >= 1);
            nextButton.setEnabled(number > 1);
            previousButton.setEnabled(number > 1);

            submitButton.hide();
            cancelButton.hide();
            break;

        default:
            break;
        }
    }

    static string qsToStr(QString qs)
    {
        return qs.toUtf8().toConstCharArray().idup;
    }

    QPushButton addButton;
    QPushButton editButton;
    QPushButton removeButton;
    QPushButton submitButton;
    QPushButton cancelButton;
    QPushButton nextButton;
    QPushButton previousButton;
    QLineEdit nameLine;
    QTextEdit addressText;

    string[string] contacts;
    string oldName;
    string oldAddress;
    Mode currentMode;
}
