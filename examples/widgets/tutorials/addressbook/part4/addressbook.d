module addressbook;

import std.algorithm.sorting : sort;
import std.array : array;
import std.range : assumeSorted, empty;
import core.stdcpp.new_ : cpp_new;
import qt.config;
import qt.core.namespace : Alignment, AlignmentFlag, FocusReason;
import qt.core.string : QString;
import qt.helpers;
import qt.widgets.boxlayout : QHBoxLayout, QVBoxLayout;
import qt.widgets.gridlayout : QGridLayout;
import qt.widgets.label : QLabel;
import qt.widgets.lineedit : QLineEdit;
import qt.widgets.messagebox : QMessageBox;
import qt.widgets.pushbutton : QPushButton;
import qt.widgets.textedit : QTextEdit;
import qt.widgets.widget : QWidget;

class AddressBook : QWidget
{
    mixin(Q_OBJECT_D);

public:
//! [Mode enum]
    enum Mode
    {
        NavigationMode,
        AddingMode,
        EditingMode
    }
//! [Mode enum]

    this(QWidget parent = null)
    {
        super(parent);

        auto nameLabel = cpp_new!QLabel(tr("Name:"));
        nameLine = cpp_new!QLineEdit();
        nameLine.setReadOnly(true);

        auto addressLabel = cpp_new!QLabel(tr("Address:"));
        addressText = cpp_new!QTextEdit();
        addressText.setReadOnly(true);

        addButton = cpp_new!QPushButton(tr("&Add"));
//! [edit and remove buttons]
        editButton = cpp_new!QPushButton(tr("&Edit"));
        editButton.setEnabled(false);
        removeButton = cpp_new!QPushButton(tr("&Remove"));
        removeButton.setEnabled(false);
//! [edit and remove buttons]
        submitButton = cpp_new!QPushButton(tr("&Submit"));
        submitButton.hide();
        cancelButton = cpp_new!QPushButton(tr("&Cancel"));
        cancelButton.hide();

        nextButton = cpp_new!QPushButton(tr("&Next"));
        nextButton.setEnabled(false);
        previousButton = cpp_new!QPushButton(tr("&Previous"));
        previousButton.setEnabled(false);

        connect(addButton.signal!"clicked", this.slot!"addContact");
//! [connecting edit and remove]
        connect(editButton.signal!"clicked", this.slot!"editContact");
        connect(removeButton.signal!"clicked", this.slot!"removeContact");
//! [connecting edit and remove]
        connect(submitButton.signal!"clicked", this.slot!"submitContact");
        connect(cancelButton.signal!"clicked", this.slot!"cancel");
        connect(nextButton.signal!"clicked", this.slot!"next");
        connect(previousButton.signal!"clicked", this.slot!"previous");

        auto buttonLayout1 = cpp_new!QVBoxLayout();
        buttonLayout1.addWidget(addButton);
//! [adding edit and remove to the layout]
        buttonLayout1.addWidget(editButton);
        buttonLayout1.addWidget(removeButton);
//! [adding edit and remove to the layout]
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
    }

    @QSlot final void addContact()
    {
        oldName = nameLine.text();
        oldAddress = addressText.toPlainText();

        nameLine.clear();
        addressText.clear();

        updateInterface(Mode.AddingMode);
    }

//! [submitContact() function beginning]
    @QSlot final void submitContact()
    {
//! [submitContact() function beginning]
        auto name = nameLine.text();
        auto address = addressText.toPlainText();

        if (name.isEmpty() || address.isEmpty())
        {
            QMessageBox.information(this, tr("Empty Field"),
                tr("Please enter a name and address."));
            return;
        }

//! [submitContact() function part1]
        string nameStr = name.toUtf8().toConstCharArray().idup;
        string oldNameStr = oldName.toUtf8().toConstCharArray().idup;
        if (currentMode == Mode.AddingMode)
        {
            if (nameStr !in contacts)
            {
                contacts[nameStr] = address; // TODO: QMap!(K, V).insert(K, V);
                QMessageBox.information(this, tr("Add Successful"),
                    tr("\"%1\" has been added to your address book.").arg(name));
            }
            else
            {
                QMessageBox.information(this, tr("Add Unsuccessful"),
                    tr("Sorry, \"%1\" is already in your address book.").arg(name));

            }
        }
//! [submitContact() function part1]
//! [submitContact() function part2]
        else if (currentMode == Mode.EditingMode)
        {
            if (oldName != name)
            {
                if (nameStr !in contacts)
                {
                    QMessageBox.information(this, tr("Edit Successful"),
                        tr("\"%1\" has been edited in your address book.").arg(oldName));
                    contacts.remove(oldNameStr);
                    contacts[nameStr] = address; // TODO: QMap!(K, V).insert(K, V);
                }
                else
                {
                    QMessageBox.information(this, tr("Edit Unsuccessful"),
                        tr("Sorry, \"%1\" is already in your address book.").arg(name));
                }
            }
            else if (oldAddress != address)
            {
                QMessageBox.information(this, tr("Edit Successful"),
                    tr("\"%1\" has been edited in your address book.").arg(name));
                contacts[nameStr] = address;
            }
        }

        updateInterface(Mode.NavigationMode);
    }
//! [submitContact() function part2]

    @QSlot final void cancel()
    {
        nameLine.setText(oldName);
        addressText.setText(oldAddress);
        updateInterface(Mode.NavigationMode);
    }

//! [edit and remove slots 0]
//! [editContact() function]
    @QSlot final void editContact()
    {
//! [edit and remove slots 0]
        oldName = nameLine.text();
        oldAddress = addressText.toPlainText();

        updateInterface(Mode.EditingMode);
//! [edit and remove slots 1]
    }
//! [editContact() function]

//! [removeContact() function]
    @QSlot final void removeContact()
    {
//! [edit and remove slots 1]
        auto name = nameLine.text();
        // auto address = addressText.toPlainText();
        string nameStr = name.toUtf8().toConstCharArray().idup;

        if (nameStr in contacts)
        {
            immutable auto button = QMessageBox.question(this, tr("Confirm Remove"),
                tr("Are you sure you want to remove \"%1\"?")
                    .arg(name),
                    QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No);

            if (button == QMessageBox.StandardButton.Yes)
            {
                previous();
                contacts.remove(nameStr);

                QMessageBox.information(this, tr("Remove Successful"),
                    tr("\"%1\" has been removed from your address book.").arg(nameLine.text()));
            }
        }

        updateInterface(Mode.NavigationMode);
//! [edit and remove slots 2]
    }
//! [removeContact() function]
//! [edit and remove slots 2]

    @QSlot final void next()
    {
        QString name = nameLine.text();
        /+ 
        TODO:
        * QMap!(K, V)

        auto i = contacts.find(name);

        if (i != contacts.end())
            i++;

        if (i == contacts.end())
            i = contacts.begin();

        nameLine.setText(i.key());
        addressText.setText(i.value());
        +/
        auto keys = contacts.byKey().array();
        keys.sort();
        if (keys.empty)
            return;

        string nameStr = name.toUtf8().toConstCharArray().idup;
        auto r = assumeSorted(keys).trisect(nameStr);
        string nextKey = (!r[1].empty && !r[2].empty) ? r[2][0] : keys[0];
        nameLine.setText(QString(nextKey));
        addressText.setText(contacts[nextKey]);
    }

    @QSlot final void previous()
    {
        QString name = nameLine.text();

        /+ 
        TODO:
        * QMap!(K, V)

        auto i = contacts.find(name);

        if (i == contacts.end()){
            nameLine.clear();
            addressText.clear();
            return;
        }

        if (i == contacts.begin())
            i = contacts.end();

        i--;
        nameLine.setText(i.key());
        addressText.setText(i.value());
        +/
        auto keys = contacts.byKey().array();
        keys.sort();

        string nameStr = name.toUtf8().toConstCharArray().idup; // TODO: QString.toDString?        
        auto r = assumeSorted(keys).trisect(nameStr);
        if (r[1].empty)
        {
            nameLine.clear();
            addressText.clear();
            return;
        }

        string prevKey = (!r[0].empty) ? r[0][$ - 1] : keys[$ - 1];
        nameLine.setText(QString(prevKey));
        addressText.setText(contacts[prevKey]);
    }

private:
//! [updateInterface() declaration 0]
    void updateInterface(Mode mode)
    {
//! [updateInterface() declaration 0]
//! [update interface() part 1]
        currentMode = mode;

        switch (currentMode)
        {
        case Mode.AddingMode:
        case Mode.EditingMode:
            nameLine.setReadOnly(false);
            nameLine.setFocus(FocusReason.OtherFocusReason);
            addressText.setReadOnly(false);

            addButton.setEnabled(false);
            editButton.setEnabled(false);
            removeButton.setEnabled(false);

            nextButton.setEnabled(false);
            previousButton.setEnabled(false);

            submitButton.show();
            cancelButton.show();
            break;
//! [update interface() part 1]
//! [update interface() part 2]
        case Mode.NavigationMode:
            if (contacts.length == 0) // TODO: QMap!(K, V).isEmpty()
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
//! [update interface() part 2]
//! [updateInterface() declaration 1]
    }
//! [updateInterface() declaration 1]

    QPushButton addButton;
//! [buttons declaration]
    QPushButton editButton;
    QPushButton removeButton;
//! [buttons declaration]
    QPushButton submitButton;
    QPushButton cancelButton;
    QPushButton nextButton;
    QPushButton previousButton;
    QLineEdit nameLine;
    QTextEdit addressText;

    QString[string] contacts; // TODO: QMap!(K, V)
    QString oldName;
    QString oldAddress;
//! [mode declaration]
    Mode currentMode;
//! [mode declaration]
}
