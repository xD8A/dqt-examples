module controllerwindow;

import core.stdcpp.new_ : cpp_new;
import qt.config;
import qt.core.namespace : WindowFlags, WindowType;
import qt.core.string : QString;
import qt.helpers;
import qt.widgets.application : QApplication;
import qt.widgets.boxlayout : QHBoxLayout;
import qt.widgets.checkbox : QCheckBox;
import qt.widgets.gridlayout : QGridLayout;
import qt.widgets.groupbox : QGroupBox;
import qt.widgets.pushbutton : QPushButton;
import qt.widgets.radiobutton : QRadioButton;
import qt.widgets.widget : QWidget;

import previewwindow : PreviewWindow;

//! [h0 0]
class ControllerWindow : QWidget
{
    mixin(Q_OBJECT_D);
public:
//! [c0]
    this(QWidget parent = null)
    {
//! [h0 0]
        super(parent);

        previewWindow = cpp_new!PreviewWindow(this);

        createTypeGroupBox();
        createHintsGroupBox();

        quitButton = cpp_new!QPushButton(tr("&Quit"));
        connect(quitButton.signal!"clicked", QApplication.instance().slot!"quit");

        auto bottomLayout = cpp_new!QHBoxLayout();
        bottomLayout.addStretch();
        bottomLayout.addWidget(quitButton);

        auto mainLayout = cpp_new!QHBoxLayout();
        mainLayout.addWidget(typeGroupBox);
        mainLayout.addWidget(hintsGroupBox);
        mainLayout.addLayout(bottomLayout);
        setLayout(mainLayout);

        setWindowTitle(tr("Window Flags"));
        updatePreview();
//! [h0 1]
    }
//! [c0]

private:

//! [c1]
    @QSlot void updatePreview()
    {
//! [h0 1]
        WindowFlags flags;

        if (windowRadioButton.isChecked())
            flags = WindowFlags(WindowType.Window);
        else if (dialogRadioButton.isChecked())
            flags = WindowFlags(WindowType.Dialog);
        else if (sheetRadioButton.isChecked())
            flags = WindowFlags(WindowType.Sheet);
        else if (drawerRadioButton.isChecked())
            flags = WindowFlags(WindowType.Drawer);
        else if (popupRadioButton.isChecked())
            flags = WindowFlags(WindowType.Popup);
        else if (toolRadioButton.isChecked())
            flags = WindowFlags(WindowType.Tool);
        else if (toolTipRadioButton.isChecked())
            flags = WindowFlags(WindowType.ToolTip);
        else if (splashScreenRadioButton.isChecked())
            flags = WindowFlags(WindowType.SplashScreen);
//! [c1] //! [c2]
//! [c2] //! [c3]

        if (msWindowsFixedSizeDialogCheckBox.isChecked())
            flags |= WindowType.MSWindowsFixedSizeDialogHint;
        if (x11BypassWindowManagerCheckBox.isChecked())
            flags |= WindowType.X11BypassWindowManagerHint;
        if (framelessWindowCheckBox.isChecked())
            flags |= WindowType.FramelessWindowHint;
        if (windowNoShadowCheckBox.isChecked())
            flags |= WindowType.NoDropShadowWindowHint;
        if (windowTitleCheckBox.isChecked())
            flags |= WindowType.WindowTitleHint;
        if (windowSystemMenuCheckBox.isChecked())
            flags |= WindowType.WindowSystemMenuHint;
        if (windowMinimizeButtonCheckBox.isChecked())
            flags |= WindowType.WindowMinimizeButtonHint;
        if (windowMaximizeButtonCheckBox.isChecked())
            flags |= WindowType.WindowMaximizeButtonHint;
        if (windowCloseButtonCheckBox.isChecked())
            flags |= WindowType.WindowCloseButtonHint;
        if (windowContextHelpButtonCheckBox.isChecked())
            flags |= WindowType.WindowContextHelpButtonHint;
        if (windowShadeButtonCheckBox.isChecked())
            flags |= WindowType.WindowShadeButtonHint;
        if (windowStaysOnTopCheckBox.isChecked())
            flags |= WindowType.WindowStaysOnTopHint;
        if (windowStaysOnBottomCheckBox.isChecked())
            flags |= WindowType.WindowStaysOnBottomHint;
        if (customizeWindowHintCheckBox.isChecked())
            flags |= WindowType.CustomizeWindowHint;

        previewWindow.updateWindowFlags(flags);
//! [c3] //! [c4]

        auto pos = previewWindow.pos();
        if (pos.x() < 0)
            pos.setX(0);
        if (pos.y() < 0)
            pos.setY(0);
        previewWindow.move(pos);
        previewWindow.show();
//! [h0 2]
    }
//! [c4]

//! [c5]
    void createTypeGroupBox()
    {
//! [h0 2]
        typeGroupBox = cpp_new!QGroupBox(tr("Type"));

        windowRadioButton = createRadioButton(tr("Window"));
        dialogRadioButton = createRadioButton(tr("Dialog"));
        sheetRadioButton = createRadioButton(tr("Sheet"));
        drawerRadioButton = createRadioButton(tr("Drawer"));
        popupRadioButton = createRadioButton(tr("Popup"));
        toolRadioButton = createRadioButton(tr("Tool"));
        toolTipRadioButton = createRadioButton(tr("Tooltip"));
        splashScreenRadioButton = createRadioButton(tr("Splash screen"));
        windowRadioButton.setChecked(true);

        auto layout = cpp_new!QGridLayout();
        layout.addWidget(windowRadioButton, 0, 0);
        layout.addWidget(dialogRadioButton, 1, 0);
        layout.addWidget(sheetRadioButton, 2, 0);
        layout.addWidget(drawerRadioButton, 3, 0);
        layout.addWidget(popupRadioButton, 0, 1);
        layout.addWidget(toolRadioButton, 1, 1);
        layout.addWidget(toolTipRadioButton, 2, 1);
        layout.addWidget(splashScreenRadioButton, 3, 1);
        typeGroupBox.setLayout(layout);
//! [h0 3]
    }
//! [c5]

//! [c6]
    void createHintsGroupBox()
    {
//! [h0 3]
        hintsGroupBox = cpp_new!QGroupBox(tr("Hints"));

        msWindowsFixedSizeDialogCheckBox =
            createCheckBox(tr("MS Windows fixed size dialog"));
        x11BypassWindowManagerCheckBox =
            createCheckBox(tr("X11 bypass window manager"));
        framelessWindowCheckBox = createCheckBox(tr("Frameless window"));
        windowNoShadowCheckBox = createCheckBox(tr("No drop shadow"));
        windowTitleCheckBox = createCheckBox(tr("Window title"));
        windowSystemMenuCheckBox = createCheckBox(tr("Window system menu"));
        windowMinimizeButtonCheckBox = createCheckBox(tr("Window minimize button"));
        windowMaximizeButtonCheckBox = createCheckBox(tr("Window maximize button"));
        windowCloseButtonCheckBox = createCheckBox(tr("Window close button"));
        windowContextHelpButtonCheckBox =
            createCheckBox(tr("Window context help button"));
        windowShadeButtonCheckBox = createCheckBox(tr("Window shade button"));
        windowStaysOnTopCheckBox = createCheckBox(tr("Window stays on top"));
        windowStaysOnBottomCheckBox = createCheckBox(tr("Window stays on bottom"));
        customizeWindowHintCheckBox = createCheckBox(tr("Customize window"));

        auto layout = cpp_new!QGridLayout();
        layout.addWidget(msWindowsFixedSizeDialogCheckBox, 0, 0);
        layout.addWidget(x11BypassWindowManagerCheckBox, 1, 0);
        layout.addWidget(framelessWindowCheckBox, 2, 0);
        layout.addWidget(windowNoShadowCheckBox, 3, 0);
        layout.addWidget(windowTitleCheckBox, 4, 0);
        layout.addWidget(windowSystemMenuCheckBox, 5, 0);
        layout.addWidget(customizeWindowHintCheckBox, 6, 0);
        layout.addWidget(windowMinimizeButtonCheckBox, 0, 1);
        layout.addWidget(windowMaximizeButtonCheckBox, 1, 1);
        layout.addWidget(windowCloseButtonCheckBox, 2, 1);
        layout.addWidget(windowContextHelpButtonCheckBox, 3, 1);
        layout.addWidget(windowShadeButtonCheckBox, 4, 1);
        layout.addWidget(windowStaysOnTopCheckBox, 5, 1);
        layout.addWidget(windowStaysOnBottomCheckBox, 6, 1);
        hintsGroupBox.setLayout(layout);
//! [h0 4]
    }
//! [c6]

//! [c7]
    QCheckBox createCheckBox(const(QString) text)
    {
//! [h0 4]
        auto checkBox = cpp_new!QCheckBox(text);
        connect(checkBox.signal!"clicked", this.slot!"updatePreview");
        return checkBox;
//! [h0 5]
    }
//! [c7]

//! [c8]
    QRadioButton createRadioButton(const(QString) text)
    {
//! [h0 5]
        auto button = cpp_new!QRadioButton(text);
        connect(button.signal!"clicked", this.slot!"updatePreview");
        return button;
//! [h0 6]
    }
//! [c8]

    PreviewWindow previewWindow;

    QGroupBox typeGroupBox;
    QGroupBox hintsGroupBox;
    QPushButton quitButton;

    QRadioButton windowRadioButton;
    QRadioButton dialogRadioButton;
    QRadioButton sheetRadioButton;
    QRadioButton drawerRadioButton;
    QRadioButton popupRadioButton;
    QRadioButton toolRadioButton;
    QRadioButton toolTipRadioButton;
    QRadioButton splashScreenRadioButton;

    QCheckBox msWindowsFixedSizeDialogCheckBox;
    QCheckBox x11BypassWindowManagerCheckBox;
    QCheckBox framelessWindowCheckBox;
    QCheckBox windowNoShadowCheckBox;
    QCheckBox windowTitleCheckBox;
    QCheckBox windowSystemMenuCheckBox;
    QCheckBox windowMinimizeButtonCheckBox;
    QCheckBox windowMaximizeButtonCheckBox;
    QCheckBox windowCloseButtonCheckBox;
    QCheckBox windowContextHelpButtonCheckBox;
    QCheckBox windowShadeButtonCheckBox;
    QCheckBox windowStaysOnTopCheckBox;
    QCheckBox windowStaysOnBottomCheckBox;
    QCheckBox customizeWindowHintCheckBox;
}
//! [h0 6]
