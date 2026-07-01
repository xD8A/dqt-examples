module addressbook;

import qt.config;
import qt.helpers;
import qt.widgets.widget;
import qt.widgets.lineedit;
import qt.widgets.textedit;

class AddressBook : QWidget
{
    mixin(Q_OBJECT_D);

public:
    this(QWidget parent = null)
    {
        import core.stdcpp.new_;
        import qt.widgets.label;
        import qt.widgets.gridlayout;
        import qt.core.string;
        import qt.core.namespace;

        super(parent);

        auto nameLabel = cpp_new!QLabel(tr("Name:"));
        nameLine = cpp_new!QLineEdit();

        auto addressLabel = cpp_new!QLabel(tr("Address:"));
        addressText = cpp_new!QTextEdit();

        auto mainLayout = cpp_new!QGridLayout();
        mainLayout.addWidget(nameLabel, 0, 0);
        mainLayout.addWidget(nameLine, 0, 1);
        mainLayout.addWidget(addressLabel, 1, 0, Alignment(AlignmentFlag.AlignTop));
        mainLayout.addWidget(addressText, 1, 1);

        setLayout(mainLayout);
        setWindowTitle(tr("Simple Address Book"));
    }

private:
    QLineEdit nameLine;
    QTextEdit addressText;
}
