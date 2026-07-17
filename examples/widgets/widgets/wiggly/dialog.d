module dialog;

import core.stdcpp.new_ : cpp_new;
import qt.config;
import qt.helpers;
import qt.widgets.boxlayout : QVBoxLayout;
import qt.widgets.dialog : QDialog;
import qt.widgets.lineedit : QLineEdit;
import qt.widgets.widget : QWidget;

import wigglywidget : WigglyWidget;

//! [h0 0]
class Dialog : QDialog
{
    mixin(Q_OBJECT_D);
public:
//! [c0]
    this(QWidget parent = null)
    {
//! [h0 0]
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
//! [h0 1]
    }
//! [c0]
}
//! [h0 1]
