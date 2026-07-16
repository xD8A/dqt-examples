module dialog;

import qt.config;
import qt.helpers;
import qt.widgets.dialog : QDialog;
import qt.widgets.widget : QWidget;

//! [class]
class Dialog : QDialog
{
    mixin(Q_OBJECT_D);
public:
    //! [constructor]
    this(QWidget parent = null)
    {
        import core.stdcpp.new_ : cpp_new;
        import qt.widgets.boxlayout : QVBoxLayout;
        import qt.widgets.lineedit : QLineEdit;
        import wigglywidget : WigglyWidget;

        super(parent);

        auto wigglyWidget = cpp_new!WigglyWidget();
        auto lineEdit = cpp_new!QLineEdit();

        auto layout = cpp_new!QVBoxLayout(this);
        layout.addWidget(wigglyWidget);
        layout.addWidget(lineEdit);

        connect(lineEdit.signal!"textChanged", wigglyWidget.slot!"setText");
        lineEdit.setText(tr("Hello world!"));

        setWindowTitle(tr("Wiggly"));
        resize(360, 145);
    }
    //! [constructor]
}
//! [class]
