module addressbook;

import qt.config;
import qt.helpers;
import qt.widgets.lineedit : QLineEdit;
import qt.widgets.textedit : QTextEdit;
import qt.widgets.widget : QWidget;

//! [class definition]
class AddressBook : QWidget
{
    mixin(Q_OBJECT_D);

public:
    //! [constructor and input fields]
    this(QWidget parent = null)
    {
        import core.stdcpp.new_ : cpp_new;
        import qt.core.namespace : Alignment, AlignmentFlag;
        import qt.widgets.gridlayout : QGridLayout;
        import qt.widgets.label : QLabel;

        super(parent);

        auto nameLabel = cpp_new!QLabel(tr("Name:"));
        nameLine = cpp_new!QLineEdit();

        auto addressLabel = cpp_new!QLabel(tr("Address:"));
        addressText = cpp_new!QTextEdit();
        //! [constructor and input fields]

        //! [layout]
        auto mainLayout = cpp_new!QGridLayout();
        mainLayout.addWidget(nameLabel, 0, 0);
        mainLayout.addWidget(nameLine, 0, 1);
        mainLayout.addWidget(addressLabel, 1, 0, Alignment(AlignmentFlag.AlignTop));
        mainLayout.addWidget(addressText, 1, 1);
        //! [layout]

        //![setting the layout]
        setLayout(mainLayout);
        setWindowTitle(tr("Simple Address Book"));
    }
    //! [setting the layout]

private:
    QLineEdit nameLine;
    QTextEdit addressText;
}
//! [class definition]
