module validatorwidget;

import core.stdcpp.new_ : cpp_delete, cpp_new;
import qt.config;
import qt.helpers;
import qt.gui.validator : QDoubleValidator, QIntValidator, QValidator;
import qt.widgets.ui : UIStruct;
import qt.widgets.widget : QWidget;

class ValidatorWidget : QWidget
{
    mixin(Q_OBJECT_D);
public:
    this(QWidget parent = null)
    {
        super(parent);

        ui = cpp_new!(typeof(*ui));
        ui.setupUi(this);

        connect(ui.localeSelector.signal!"localeSelected", this.slot!"setLocale");
        connect(ui.localeSelector.signal!"localeSelected", this.slot!"updateValidator");
        connect(ui.localeSelector.signal!"localeSelected", this.slot!"updateDoubleValidator");

        connect(ui.minVal.signal!"editingFinished", this.slot!"updateValidator");
        connect(ui.maxVal.signal!"editingFinished", this.slot!"updateValidator");
        connect(ui.editor.signal!"editingFinished", ui.ledWidget.slot!"flash");

        connect(ui.doubleMaxVal.signal!"editingFinished", this.slot!"updateDoubleValidator");
        connect(ui.doubleMinVal.signal!"editingFinished", this.slot!"updateDoubleValidator");
        connect(ui.doubleDecimals.signal!"valueChanged", this.slot!"updateDoubleValidator");
        connect(ui.doubleFormat.signal!"activated", this.slot!"updateDoubleValidator");
        connect(ui.doubleEditor.signal!"editingFinished", ui.doubleLedWidget.slot!"flash");

        updateValidator();
        updateDoubleValidator();
    }

    ~this()
    {
        cpp_delete(ui);
    }

private:
    @QSlot void updateValidator()
    {
        auto v = cpp_new!QIntValidator(ui.minVal.value(), ui.maxVal.value(), this);
        v.setLocale(locale());
        cpp_delete(cast(QIntValidator) ui.editor.validator());
        ui.editor.setValidator(v);

        auto s = ui.editor.text();
        int i = 0;
        if (v.validate(s, i) == QValidator.State.Invalid)
        {
            ui.editor.clear();
        }
        else
        {
            ui.editor.setText(s);
        }
    }

    @QSlot void updateDoubleValidator()
    {
        auto v = cpp_new!QDoubleValidator(
            ui.doubleMinVal.value(), ui.doubleMaxVal.value(), ui.doubleDecimals.value(), this);
        v.setNotation(cast(QDoubleValidator.Notation)(ui.doubleFormat.currentIndex()));
        v.setLocale(locale());
        cpp_delete(cast(QDoubleValidator) ui.doubleEditor.validator());
        ui.doubleEditor.setValidator(v);

        auto s = ui.doubleEditor.text();
        int i = 0;
        if (v.validate(s, i) == QValidator.State.Invalid)
        {
            ui.doubleEditor.clear();
        }
        else
        {
            ui.doubleEditor.setText(s);
        }
    }

    UIStruct!"validators.ui"* ui;
}
