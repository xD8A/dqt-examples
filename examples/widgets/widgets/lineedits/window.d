module window;

import qt.config;
import qt.helpers;
import qt.core.namespace;
import qt.core.string;
import qt.widgets.combobox;
import qt.widgets.gridlayout;
import qt.widgets.groupbox;
import qt.widgets.label;
import qt.widgets.lineedit;
import qt.widgets.widget;

//! [h0]
class Window : QWidget
{
    mixin(Q_OBJECT_D);

    QLineEdit echoLineEdit;
    QLineEdit validatorLineEdit;
    QLineEdit alignmentLineEdit;
    QLineEdit inputMaskLineEdit;
    QLineEdit accessLineEdit;
//! [h0]

    this(QWidget parent = null)
    {
        import core.stdcpp.new_;

        super(parent);

//! [1]

        auto echoGroup = cpp_new!QGroupBox(tr("Echo"));

        auto echoLabel = cpp_new!QLabel(tr("Mode:"));
        auto echoComboBox = cpp_new!QComboBox();
        echoComboBox.addItem(tr("Normal"));
        echoComboBox.addItem(tr("Password"));
        echoComboBox.addItem(tr("PasswordEchoOnEdit"));
        echoComboBox.addItem(tr("No Echo"));

        echoLineEdit = cpp_new!QLineEdit();
        echoLineEdit.setPlaceholderText("Placeholder Text");
        echoLineEdit.setFocus();

//! [1]

        auto validatorGroup = cpp_new!QGroupBox(tr("Validator"));

        auto validatorLabel = cpp_new!QLabel(tr("Type:"));
        auto validatorComboBox = cpp_new!QComboBox();
        validatorComboBox.addItem(tr("No validator"));
        validatorComboBox.addItem(tr("Integer validator"));
        validatorComboBox.addItem(tr("Double validator"));

        validatorLineEdit = cpp_new!QLineEdit();
        validatorLineEdit.setPlaceholderText("Placeholder Text");

//! [2]

        auto alignmentGroup = cpp_new!QGroupBox(tr("Alignment"));

        auto alignmentLabel = cpp_new!QLabel(tr("Type:"));
        auto alignmentComboBox = cpp_new!QComboBox();
        alignmentComboBox.addItem(tr("Left"));
        alignmentComboBox.addItem(tr("Centered"));
        alignmentComboBox.addItem(tr("Right"));

        alignmentLineEdit = cpp_new!QLineEdit();
        alignmentLineEdit.setPlaceholderText("Placeholder Text");

//! [3]

        auto inputMaskGroup = cpp_new!QGroupBox(tr("Input mask"));

        auto inputMaskLabel = cpp_new!QLabel(tr("Type:"));
        auto inputMaskComboBox = cpp_new!QComboBox();
        inputMaskComboBox.addItem(tr("No mask"));
        inputMaskComboBox.addItem(tr("Phone number"));
        inputMaskComboBox.addItem(tr("ISO date"));
        inputMaskComboBox.addItem(tr("License key"));

        inputMaskLineEdit = cpp_new!QLineEdit();
        inputMaskLineEdit.setPlaceholderText("Placeholder Text");

//! [4]

        auto accessGroup = cpp_new!QGroupBox(tr("Access"));

        auto accessLabel = cpp_new!QLabel(tr("Read-only:"));
        auto accessComboBox = cpp_new!QComboBox();
        accessComboBox.addItem(tr("False"));
        accessComboBox.addItem(tr("True"));

        accessLineEdit = cpp_new!QLineEdit();
        accessLineEdit.setPlaceholderText("Placeholder Text");

//! [5]

        connect(echoComboBox.signal!"activated", this.slot!"echoChanged");
        connect(validatorComboBox.signal!"activated", this.slot!"validatorChanged");
        connect(alignmentComboBox.signal!"activated", this.slot!"alignmentChanged");
        connect(inputMaskComboBox.signal!"activated", this.slot!"inputMaskChanged");
        connect(accessComboBox.signal!"activated", this.slot!"accessChanged");

//! [6]

        auto echoLayout = cpp_new!QGridLayout();
        echoLayout.addWidget(echoLabel, 0, 0);
        echoLayout.addWidget(echoComboBox, 0, 1);
        echoLayout.addWidget(echoLineEdit, 1, 0, 1, 2);
        echoGroup.setLayout(echoLayout);

//! [7]

        auto validatorLayout = cpp_new!QGridLayout();
        validatorLayout.addWidget(validatorLabel, 0, 0);
        validatorLayout.addWidget(validatorComboBox, 0, 1);
        validatorLayout.addWidget(validatorLineEdit, 1, 0, 1, 2);
        validatorGroup.setLayout(validatorLayout);

        auto alignmentLayout = cpp_new!QGridLayout();
        alignmentLayout.addWidget(alignmentLabel, 0, 0);
        alignmentLayout.addWidget(alignmentComboBox, 0, 1);
        alignmentLayout.addWidget(alignmentLineEdit, 1, 0, 1, 2);
        alignmentGroup.setLayout(alignmentLayout);

        auto inputMaskLayout = cpp_new!QGridLayout();
        inputMaskLayout.addWidget(inputMaskLabel, 0, 0);
        inputMaskLayout.addWidget(inputMaskComboBox, 0, 1);
        inputMaskLayout.addWidget(inputMaskLineEdit, 1, 0, 1, 2);
        inputMaskGroup.setLayout(inputMaskLayout);

        auto accessLayout = cpp_new!QGridLayout();
        accessLayout.addWidget(accessLabel, 0, 0);
        accessLayout.addWidget(accessComboBox, 0, 1);
        accessLayout.addWidget(accessLineEdit, 1, 0, 1, 2);
        accessGroup.setLayout(accessLayout);

//! [8]

        auto layout = cpp_new!QGridLayout();
        layout.addWidget(echoGroup, 0, 0);
        layout.addWidget(validatorGroup, 1, 0);
        layout.addWidget(alignmentGroup, 2, 0);
        layout.addWidget(inputMaskGroup, 0, 1);
        layout.addWidget(accessGroup, 1, 1);
        setLayout(layout);

        setWindowTitle(tr("Line Edits"));
    }

//! [9]

    @QSlot final void echoChanged(int index)
    {
        final switch (index) {
        case 0:
            echoLineEdit.setEchoMode(QLineEdit.EchoMode.Normal);
            break;
        case 1:
            echoLineEdit.setEchoMode(QLineEdit.EchoMode.Password);
            break;
        case 2:
            echoLineEdit.setEchoMode(QLineEdit.EchoMode.PasswordEchoOnEdit);
            break;
        case 3:
            echoLineEdit.setEchoMode(QLineEdit.EchoMode.NoEcho);
            break;
        }
    }

//! [10]

    @QSlot final void validatorChanged(int index)
    {
        import core.stdcpp.new_;
        import qt.gui.validator;

        final switch (index) {
        case 0:
            validatorLineEdit.setValidator(null);
            break;
        case 1:
            validatorLineEdit.setValidator(cpp_new!QIntValidator(validatorLineEdit));
            break;
        case 2:
            validatorLineEdit.setValidator(cpp_new!QDoubleValidator(-999.0, 999.0, 2, validatorLineEdit));
            break;
        }

        validatorLineEdit.clear();
    }

//! [11]

    @QSlot final void alignmentChanged(int index)
    {
        final switch (index) {
        case 0:
            alignmentLineEdit.setAlignment(Alignment(AlignmentFlag.AlignLeft));
            break;
        case 1:
            alignmentLineEdit.setAlignment(Alignment(AlignmentFlag.AlignCenter));
            break;
        case 2:
            alignmentLineEdit.setAlignment(Alignment(AlignmentFlag.AlignRight));
            break;
        }
    }

//! [12]

    @QSlot final void inputMaskChanged(int index)
    {
        final switch (index) {
        case 0:
            inputMaskLineEdit.setInputMask("");
            break;
        case 1:
            inputMaskLineEdit.setInputMask("+99 99 99 99 99;_");
            break;
        case 2:
            inputMaskLineEdit.setInputMask("0000-00-00");
            inputMaskLineEdit.setText("00000000");
            inputMaskLineEdit.setCursorPosition(0);
            break;
        case 3:
            inputMaskLineEdit.setInputMask(">AAAAA-AAAAA-AAAAA-AAAAA-AAAAA;#");
            break;
        }
    }

//! [13]

    @QSlot final void accessChanged(int index)
    {
        final switch (index) {
        case 0:
            accessLineEdit.setReadOnly(false);
            break;
        case 1:
            accessLineEdit.setReadOnly(true);
            break;
        }
    }
}