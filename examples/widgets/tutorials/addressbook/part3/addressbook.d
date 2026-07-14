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
        submitButton = cpp_new!QPushButton(tr("&Submit"));
        submitButton.hide();
        cancelButton = cpp_new!QPushButton(tr("&Cancel"));
        cancelButton.hide();
        //! [navigation pushbuttons]
        nextButton = cpp_new!QPushButton(tr("&Next"));
        nextButton.setEnabled(false);
        previousButton = cpp_new!QPushButton(tr("&Previous"));
        previousButton.setEnabled(false);
        //! [navigation pushbuttons]
        connect(addButton.signal!"clicked", this.slot!"addContact");
        connect(submitButton.signal!"clicked", this.slot!"submitContact");
        connect(cancelButton.signal!"clicked", this.slot!"cancel");
        //! [connecting navigation signals]
        connect(nextButton.signal!"clicked", this.slot!"next");
        connect(previousButton.signal!"clicked", this.slot!"previous");
        //! [connecting navigation signals]

        auto buttonLayout1 = cpp_new!QVBoxLayout();
        buttonLayout1.addWidget(addButton, Alignment(AlignmentFlag.AlignTop));
        buttonLayout1.addWidget(submitButton);
        buttonLayout1.addWidget(cancelButton);
        buttonLayout1.addStretch();
        //! [navigation layout]
        auto buttonLayout2 = cpp_new!QHBoxLayout();
        buttonLayout2.addWidget(previousButton);
        buttonLayout2.addWidget(nextButton);
        //! [navigation layout]
        auto mainLayout = cpp_new!QGridLayout();
        mainLayout.addWidget(nameLabel, 0, 0);
        mainLayout.addWidget(nameLine, 0, 1);
        mainLayout.addWidget(addressLabel, 1, 0, Alignment(AlignmentFlag.AlignTop));
        mainLayout.addWidget(addressText, 1, 1);
        mainLayout.addLayout(buttonLayout1, 1, 2);
        //! [adding navigation layout]
        mainLayout.addLayout(buttonLayout2, 2, 1);
        //! [adding navigation layout]
        setLayout(mainLayout);
        setWindowTitle(tr("Simple Address Book"));
    }

    @QSlot final void addContact()
    {
        oldName = nameLine.text();
        oldAddress = addressText.toPlainText();

        nameLine.clear();
        addressText.clear();

        nameLine.setReadOnly(false);
        addressText.setReadOnly(false);

        addButton.setEnabled(false);
        nextButton.setEnabled(false);
        previousButton.setEnabled(false);
        submitButton.show();
        cancelButton.show();
    }

    @QSlot final void submitContact()
    {
        import qt.widgets.messagebox : QMessageBox;

        QString name = nameLine.text();
        QString address = addressText.toPlainText();

        if (name.isEmpty() || address.isEmpty())
        {
            QMessageBox.information(this, tr("Empty Field"),
                tr("Please enter a name and address."));
            return;
        }

        /+ 
        TODO:
        * QString.toHash()
        * QString.toDString()
        * QMap

        if (!contacts.contains(name)) {
            contacts.insert(name, address);
            QMessageBox.information(this, tr("Add Successful"),
                tr("\"%1\" has been added to your address book.").arg(name));
        } else {
            QMessageBox.information(this, tr("Add Unsuccessful"),
                tr("Sorry, \"%1\" is already in your address book.").arg(name));
        }

        if (contacts.isEmpty()) {
            nameLine.clear();
            addressText.clear();
        }
        +/
        string nameStr = name.toUtf8().toConstCharArray().idup;

        if (nameStr !in contacts)
        {
            contacts[nameStr] = address;
            QMessageBox.information(this, tr("Add Successful"),
                tr("\"%1\" has been added to your address book.").arg(name));
        }
        else
        {
            QMessageBox.information(this, tr("Add Unsuccessful"),
                tr("Sorry, \"%1\" is already in your address book.").arg(name));
        }

        if (contacts.length == 0) // TODO: QMap.isEmpty()
        {
            nameLine.clear();
            addressText.clear();
        }

        nameLine.setReadOnly(true);
        addressText.setReadOnly(true);
        addButton.setEnabled(true);

        //! [enabling navigation]
        auto number = contacts.length;
        nextButton.setEnabled(number > 1);
        previousButton.setEnabled(number > 1);
        //! [enabling navigation]

        submitButton.hide();
        cancelButton.hide();
    }

    @QSlot final void cancel()
    {
        nameLine.setText(oldName);
        addressText.setText(oldAddress);

        if (contacts.length == 0) // TODO: QMap.isEmpty()
        {
            nameLine.clear();
            addressText.clear();
        }

        nameLine.setReadOnly(true);
        addressText.setReadOnly(true);
        addButton.setEnabled(true);

        auto number = contacts.length;
        nextButton.setEnabled(number > 1);
        previousButton.setEnabled(number > 1);

        submitButton.hide();
        cancelButton.hide();
    }
    //! [navigation functions]
    //! [next() function]
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
    //! [next() function]

    //! [previous() function]
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
    //! [previous() function]
    //! [navigation functions]

private:
    QPushButton addButton;
    QPushButton submitButton;
    QPushButton cancelButton;
    QPushButton nextButton;
    QPushButton previousButton;
    QLineEdit nameLine;
    QTextEdit addressText;

    QString[string] contacts; // TODO: QMap!(QString, QString) contacts;
    QString oldName;
    QString oldAddress;
}
