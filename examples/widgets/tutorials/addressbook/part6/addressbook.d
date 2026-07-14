module addressbook;

import qt.config;
import qt.core.string : QString;
import qt.helpers;
import qt.widgets.lineedit : QLineEdit;
import qt.widgets.pushbutton : QPushButton;
import qt.widgets.textedit : QTextEdit;
import qt.widgets.widget : QWidget;

import finddialog : FindDialog;

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
        import core.stdcpp.new_ : cpp_new;
        import qt.core.namespace : Alignment, AlignmentFlag;
        import qt.widgets.boxlayout : QHBoxLayout, QVBoxLayout;
        import qt.widgets.gridlayout : QGridLayout;
        import qt.widgets.label : QLabel;

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
        findButton = cpp_new!QPushButton(tr("&Find"));
        findButton.setEnabled(false);
        submitButton = cpp_new!QPushButton(tr("&Submit"));
        submitButton.hide();
        cancelButton = cpp_new!QPushButton(tr("&Cancel"));
        cancelButton.hide();

        nextButton = cpp_new!QPushButton(tr("&Next"));
        nextButton.setEnabled(false);
        previousButton = cpp_new!QPushButton(tr("&Previous"));
        previousButton.setEnabled(false);

        loadButton = cpp_new!QPushButton(tr("&Load..."));
        //! [tooltip 1]
        loadButton.setToolTip(tr("Load contacts from a file"));
        //! [tooltip 1]
        saveButton = cpp_new!QPushButton(tr("&Save..."));
        //! [tooltip 2]
        saveButton.setToolTip(tr("Save contacts to a file"));
        //! [tooltip 2]
        saveButton.setEnabled(false);

        dialog = cpp_new!FindDialog(this);

        connect(addButton.signal!"clicked", this.slot!"addContact");
        connect(submitButton.signal!"clicked", this.slot!"submitContact");
        connect(editButton.signal!"clicked", this.slot!"editContact");
        connect(removeButton.signal!"clicked", this.slot!"removeContact");
        connect(cancelButton.signal!"clicked", this.slot!"cancel");
        connect(findButton.signal!"clicked", this.slot!"findContact");
        connect(nextButton.signal!"clicked", this.slot!"next");
        connect(previousButton.signal!"clicked", this.slot!"previous");
        connect(loadButton.signal!"clicked", this.slot!"loadFromFile");
        connect(saveButton.signal!"clicked", this.slot!"saveToFile");

        auto buttonLayout1 = cpp_new!QVBoxLayout();
        buttonLayout1.addWidget(addButton);
        buttonLayout1.addWidget(editButton);
        buttonLayout1.addWidget(removeButton);
        buttonLayout1.addWidget(findButton);
        buttonLayout1.addWidget(submitButton);
        buttonLayout1.addWidget(cancelButton);
        buttonLayout1.addWidget(loadButton);
        buttonLayout1.addWidget(saveButton);
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

    @QSlot final void editContact()
    {
        oldName = nameLine.text();
        oldAddress = addressText.toPlainText();

        updateInterface(Mode.EditingMode);
    }

    @QSlot final void submitContact()
    {
        import qt.widgets.messagebox : QMessageBox;

        auto name = nameLine.text();
        auto address = addressText.toPlainText();

        if (name.isEmpty() || address.isEmpty())
        {
            QMessageBox.information(this, tr("Empty Field"),
                tr("Please enter a name and address."));
            return;
        }

        string nameStr = name.toUtf8().toConstCharArray().idup;
        string oldNameStr = oldName.toUtf8().toConstCharArray().idup;
        if (currentMode == Mode.AddingMode)
        {
            if (nameStr !in contacts)
            {
                contacts[nameStr] = address; // TODO: contacts.insert(name, address);
                QMessageBox.information(this, tr("Add Successful"),
                    tr("\"%1\" has been added to your address book.").arg(name));
            }
            else
            {
                QMessageBox.information(this, tr("Add Unsuccessful"),
                    tr("Sorry, \"%1\" is already in your address book.").arg(name));

            }
        }
        else if (currentMode == Mode.EditingMode)
        {
            if (oldName != name)
            {
                if (nameStr !in contacts)
                {
                    QMessageBox.information(this, tr("Edit Successful"),
                        tr("\"%1\" has been edited in your address book.").arg(oldName));
                    contacts.remove(oldNameStr);
                    contacts[nameStr] = address; // TODO: contacts.insert(name, address);
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

    @QSlot final void cancel()
    {
        nameLine.setText(oldName);
        addressText.setText(oldAddress);
        updateInterface(Mode.NavigationMode);
    }

    @QSlot final void removeContact()
    {
        import qt.widgets.messagebox : QMessageBox;

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
    }

    @QSlot final void next()
    {
        import std.algorithm.sorting : sort;
        import std.array : array;
        import std.range : assumeSorted, empty;

        QString name = nameLine.text();
        /+ 
        TODO:
        * QMap

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
        import std.algorithm.sorting : sort;
        import std.array : array;
        import std.range : assumeSorted, empty;

        QString name = nameLine.text();

        /+ 
        TODO:
        * QMap

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

    @QSlot final void findContact()
    {
        import qt.widgets.dialog : QDialog;
        import qt.widgets.messagebox : QMessageBox;

        dialog.show();

        if (dialog.exec() == QDialog.DialogCode.Accepted)
        {
            auto contactName = dialog.getFindText();
            string contactNameStr = contactName.toUtf8().toConstCharArray().idup;

            if (contactNameStr in contacts)
            {
                nameLine.setText(contactName);
                addressText.setText(contacts[contactNameStr]);
            }
            else
            {
                QMessageBox.information(this, tr("Contact Not Found"),
                    tr("Sorry, \"%1\" is not in your address book.").arg(contactName));
                return;
            }
        }

        updateInterface(Mode.NavigationMode);
    }

    //! [save and load functions declaration]
    //! [saveToFile() function part1]
    @QSlot final void saveToFile()
    {
        import core.stdcpp.new_ : cpp_new, cpp_delete;
        import qt.core.datastream : QDataStream;
        import qt.core.file : QFile;
        import qt.core.iodevice : QIODevice;
        import qt.widgets.filedialog : QFileDialog;
        import qt.widgets.messagebox : QMessageBox;

        auto fileName = QFileDialog.getSaveFileName(this,
            tr("Save Address Book"), "",
            tr("Address Book (*.abk);;All Files (*)"));

        //! [saveToFile() function part1]
        //! [saveToFile() function part2]
        if (fileName.isEmpty())
            return;

        auto file = cpp_new!QFile(fileName);
        scope (exit)
            cpp_delete(file);

        if (!file.open(QIODevice.OpenMode.WriteOnly))
        {
            QMessageBox.information(this, tr("Unable to open file"),
                file.errorString());
            return;
        }

        //! [saveToFile() function part2]
        //! [saveToFile() function part3]
        auto out_ = cpp_new!QDataStream(file);
        scope (exit)
            cpp_delete(out_);
        out_.setVersion(QDataStream.Version.Qt_4_5);

        /+ 
        TODO:
        * operator<< (QDataStream, const QMap!(QString, QString));
        +/
        auto count = cast(int) contacts.length;
        out_.writeRawData(cast(const(char)*)&count, cast(int) int.sizeof);

        foreach (name, address; contacts)
        {
            auto nameBA = QString(name).toUtf8();
            auto addrBA = QString(address).toUtf8();

            auto nameLen = nameBA.length;
            out_.writeRawData(cast(const(char)*)&nameLen, cast(int) int.sizeof);
            out_.writeRawData(nameBA.constData(), cast(int) nameLen);

            auto addrLen = addrBA.length;
            out_.writeRawData(cast(const(char)*)&addrLen, cast(int) int.sizeof);
            out_.writeRawData(addrBA.constData(), cast(int) addrLen);
        }
    }
    //! [saveToFile() function part3]

    //! [loadFromFile() function part1]
    @QSlot final void loadFromFile()
    {
        import core.stdcpp.new_ : cpp_new, cpp_delete;
        import qt.core.datastream : QDataStream;
        import qt.core.file : QFile;
        import qt.core.iodevice : QIODevice;
        import qt.widgets.filedialog : QFileDialog;
        import qt.widgets.messagebox : QMessageBox;

        auto fileName = QFileDialog.getOpenFileName(this,
            tr("Open Address Book"), "",
            tr("Address Book (*.abk);;All Files (*)"));
        //! [loadFromFile() function part1]

        //! [loadFromFile() function part2]
        if (fileName.isEmpty())
            return;

        auto file = cpp_new!QFile(fileName);
        scope (exit)
            cpp_delete(file);

        if (!file.open(QIODevice.OpenMode.ReadOnly))
        {
            QMessageBox.information(this, tr("Unable to open file"),
                file.errorString());
            return;
        }

        auto dataIn = cpp_new!QDataStream(file);
        scope (exit)
            cpp_delete(dataIn);
        dataIn.setVersion(QDataStream.Version.Qt_4_5);

        contacts.clear();
        /+ 
        TODO:
        * operator>> (const QDataStream, QMap!(QString, QString));
        +/
        int count;
        dataIn.readRawData(cast(char*)&count, cast(int) int.sizeof);

        for (int i = 0; i < count; i++)
        {
            int nameLen;
            dataIn.readRawData(cast(char*)&nameLen, cast(int) int.sizeof);
            auto nameBuf = new char[nameLen];
            dataIn.readRawData(nameBuf.ptr, nameLen);
            string name = nameBuf[0 .. nameLen].idup;

            int addrLen;
            dataIn.readRawData(cast(char*)&addrLen, cast(int) int.sizeof);
            auto addrBuf = new char[addrLen];
            dataIn.readRawData(addrBuf.ptr, addrLen);
            string address = addrBuf[0 .. addrLen].idup;

            contacts[name] = QString(address);
        }

        //! [loadFromFile() function part2]

        //! [loadFromFile() function part3]
        if (contacts.length > 0)
        {
            auto keys = contacts.keys;
            import std.algorithm.sorting;

            keys.sort; // QMap stores keys in sorted order; D's AA keys need explicit sort for deterministic navigation
            nameLine.setText(QString(keys[0]));
            addressText.setText(QString(contacts[keys[0]]));
        }

        updateInterface(Mode.NavigationMode);
    }
    //! [loadFromFile() function part3]
    //! [save and load functions declaration]

private:

    void updateInterface(Mode mode)
    {
        import qt.core.namespace : FocusReason;

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

            loadButton.setEnabled(false);
            saveButton.setEnabled(false);
            break;

        case Mode.NavigationMode:
            if (contacts.length == 0) // TODO: QMap.isEmpty()
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

            loadButton.setEnabled(true);
            saveButton.setEnabled(number >= 1);
            break;

        default:
            break;
        }
    }

    QPushButton addButton;
    QPushButton editButton;
    QPushButton removeButton;
    QPushButton findButton;
    QPushButton submitButton;
    QPushButton cancelButton;
    QPushButton nextButton;
    QPushButton previousButton;
    //! [save and load buttons declaration]
    QPushButton loadButton;
    QPushButton saveButton;
    //! [save and load buttons declaration]
    QLineEdit nameLine;
    QTextEdit addressText;

    QString[string] contacts; // TODO: QMap!(QString, QString) contacts;
    FindDialog dialog;
    QString oldName;
    QString oldAddress;
    Mode currentMode;
}
