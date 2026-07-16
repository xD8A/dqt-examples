module window;

import qt.config;
import qt.helpers;
import qt.core.namespace;
import qt.core.string;
import qt.gui.event;
import qt.widgets.checkbox;
import qt.widgets.combobox;
import qt.widgets.gridlayout;
import qt.widgets.groupbox;
import qt.widgets.label;
import qt.widgets.spinbox;
import qt.widgets.stackedwidget;
import qt.widgets.widget;
import slidersgroup;

class Window : QWidget
{
    mixin(Q_OBJECT_D);

    SlidersGroup horizontalSliders;
    SlidersGroup verticalSliders;
    QStackedWidget stackedWidget;

    QGroupBox controlsGroup;
    QLabel minimumLabel;
    QLabel maximumLabel;
    QLabel valueLabel;
    QCheckBox invertedAppearance;
    QCheckBox invertedKeyBindings;
    QSpinBox minimumSpinBox;
    QSpinBox maximumSpinBox;
    QSpinBox valueSpinBox;
    QComboBox orientationCombo;
    QGridLayout layout;
    double oldAspectRatio;

    this(QWidget parent = null)
    {
        import core.stdcpp.new_;

        super(parent);

        horizontalSliders = cpp_new!SlidersGroup(Orientation.Horizontal, tr("Horizontal"));
        verticalSliders = cpp_new!SlidersGroup(Orientation.Vertical, tr("Vertical"));

        stackedWidget = cpp_new!QStackedWidget();
        stackedWidget.addWidget(horizontalSliders);
        stackedWidget.addWidget(verticalSliders);

        createControls(tr("Controls"));

        connect(horizontalSliders.signal!"valueChanged", verticalSliders.slot!"setValue");
        connect(verticalSliders.signal!"valueChanged", valueSpinBox.slot!"setValue");
        connect(valueSpinBox.signal!"valueChanged", horizontalSliders.slot!"setValue");

        layout = cpp_new!QGridLayout();
        layout.addWidget(stackedWidget, 0, 1);
        layout.addWidget(controlsGroup, 0, 0);

        setLayout(layout);

        minimumSpinBox.setValue(0);
        maximumSpinBox.setValue(20);
        valueSpinBox.setValue(5);

        setWindowTitle(tr("Sliders"));
    }

protected:

    override extern(C++) void resizeEvent(QResizeEvent e)
    {
        if (width() == 0 || height() == 0)
            return;

        const double aspectRatio = double(width()) / double(height());

        if ((aspectRatio < 1.0) && (oldAspectRatio > 1.0)) {
            layout.removeWidget(controlsGroup);
            layout.removeWidget(stackedWidget);

            layout.addWidget(stackedWidget, 1, 0);
            layout.addWidget(controlsGroup, 0, 0);

            oldAspectRatio = aspectRatio;
        }
        else if ((aspectRatio > 1.0) && (oldAspectRatio < 1.0)) {
            layout.removeWidget(controlsGroup);
            layout.removeWidget(stackedWidget);

            layout.addWidget(stackedWidget, 0, 1);
            layout.addWidget(controlsGroup, 0, 0);

            oldAspectRatio = aspectRatio;
        }
    }

private:

    void createControls(const(QString) title)
    {
        import core.stdcpp.new_;

        controlsGroup = cpp_new!QGroupBox(title);

        minimumLabel = cpp_new!QLabel(tr("Minimum value:"));
        maximumLabel = cpp_new!QLabel(tr("Maximum value:"));
        valueLabel = cpp_new!QLabel(tr("Current value:"));

        invertedAppearance = cpp_new!QCheckBox(tr("Inverted appearance"));
        invertedKeyBindings = cpp_new!QCheckBox(tr("Inverted key bindings"));

        minimumSpinBox = cpp_new!QSpinBox();
        minimumSpinBox.setRange(-100, 100);
        minimumSpinBox.setSingleStep(1);

        maximumSpinBox = cpp_new!QSpinBox();
        maximumSpinBox.setRange(-100, 100);
        maximumSpinBox.setSingleStep(1);

        valueSpinBox = cpp_new!QSpinBox();
        valueSpinBox.setRange(-100, 100);
        valueSpinBox.setSingleStep(1);

        orientationCombo = cpp_new!QComboBox();
        orientationCombo.addItem(tr("Horizontal slider-like widgets"));
        orientationCombo.addItem(tr("Vertical slider-like widgets"));

        connect(orientationCombo.signal!"activated", stackedWidget.slot!"setCurrentIndex");
        connect(minimumSpinBox.signal!"valueChanged", horizontalSliders.slot!"setMinimum");
        connect(minimumSpinBox.signal!"valueChanged", verticalSliders.slot!"setMinimum");
        connect(maximumSpinBox.signal!"valueChanged", horizontalSliders.slot!"setMaximum");
        connect(maximumSpinBox.signal!"valueChanged", verticalSliders.slot!"setMaximum");
        connect(invertedAppearance.signal!"toggled", horizontalSliders.slot!"invertAppearance");
        connect(invertedAppearance.signal!"toggled", verticalSliders.slot!"invertAppearance");
        connect(invertedKeyBindings.signal!"toggled", horizontalSliders.slot!"invertKeyBindings");
        connect(invertedKeyBindings.signal!"toggled", verticalSliders.slot!"invertKeyBindings");

        auto controlsLayout = cpp_new!QGridLayout();
        controlsLayout.addWidget(minimumLabel, 0, 0);
        controlsLayout.addWidget(maximumLabel, 1, 0);
        controlsLayout.addWidget(valueLabel, 2, 0);
        controlsLayout.addWidget(minimumSpinBox, 0, 1);
        controlsLayout.addWidget(maximumSpinBox, 1, 1);
        controlsLayout.addWidget(valueSpinBox, 2, 1);
        controlsLayout.addWidget(invertedAppearance, 0, 2);
        controlsLayout.addWidget(invertedKeyBindings, 1, 2);
        controlsLayout.addWidget(orientationCombo, 3, 0, 1, 3);
        controlsGroup.setLayout(controlsLayout);
    }
}
