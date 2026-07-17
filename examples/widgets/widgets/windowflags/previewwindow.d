module previewwindow;

import core.stdcpp.new_ : cpp_new;
import qt.config;
import qt.core.namespace : WindowFlags, WindowType;
import qt.core.string : QString;
import qt.helpers;
import qt.widgets.boxlayout : QVBoxLayout;
import qt.widgets.pushbutton : QPushButton;
import qt.widgets.textedit : QTextEdit;
import qt.widgets.widget : QWidget;

//! [h0 0]
class PreviewWindow : QWidget
{
    mixin(Q_OBJECT_D);

public:
//! [c0]
    this(QWidget parent = null)
    {
//! [h0 0]       
        super(parent);

        textEdit = cpp_new!QTextEdit();
        textEdit.setReadOnly(true);
        textEdit.setLineWrapMode(QTextEdit.LineWrapMode.NoWrap);

        closeButton = cpp_new!QPushButton(tr("&Close"));
        connect(closeButton.signal!"clicked", this.slot!"close");

        auto layout = cpp_new!QVBoxLayout();
        layout.addWidget(textEdit);
        layout.addWidget(closeButton);
        setLayout(layout);

        setWindowTitle(tr("Preview"));
//! [h0 1]
    }
//! [c0]

//! [c1]
    void updateWindowFlags(WindowFlags flags)
    {
//! [h0 1]
        super.setWindowFlags(flags);

        QString text;
        immutable WindowFlags type = flags & WindowType.WindowType_Mask;

        if (type == WindowType.Window)
            text = QString("Qt::Window");
        else if (type == WindowType.Dialog)
            text = QString("Qt::Dialog");
        else if (type == WindowType.Sheet)
            text = QString("Qt::Sheet");
        else if (type == WindowType.Drawer)
            text = QString("Qt::Drawer");
        else if (type == WindowType.Popup)
            text = QString("Qt::Popup");
        else if (type == WindowType.Tool)
            text = QString("Qt::Tool");
        else if (type == WindowType.ToolTip)
            text = QString("Qt::ToolTip");
        else if (type == WindowType.SplashScreen)
            text = QString("Qt::SplashScreen");

        if (flags & WindowType.MSWindowsFixedSizeDialogHint)
            text ~= QString("\n| Qt::MSWindowsFixedSizeDialogHint");
        if (flags & WindowType.X11BypassWindowManagerHint)
            text ~= QString("\n| Qt::X11BypassWindowManagerHint");
        if (flags & WindowType.FramelessWindowHint)
            text ~= QString("\n| Qt::FramelessWindowHint");
        if (flags & WindowType.NoDropShadowWindowHint)
            text ~= QString("\n| Qt::NoDropShadowWindowHint");
        if (flags & WindowType.WindowTitleHint)
            text ~= QString("\n| Qt::WindowTitleHint");
        if (flags & WindowType.WindowSystemMenuHint)
            text ~= QString("\n| Qt::WindowSystemMenuHint");
        if (flags & WindowType.WindowMinimizeButtonHint)
            text ~= QString("\n| Qt::WindowMinimizeButtonHint");
        if (flags & WindowType.WindowMaximizeButtonHint)
            text ~= QString("\n| Qt::WindowMaximizeButtonHint");
        if (flags & WindowType.WindowCloseButtonHint)
            text ~= QString("\n| Qt::WindowCloseButtonHint");
        if (flags & WindowType.WindowContextHelpButtonHint)
            text ~= QString("\n| Qt::WindowContextHelpButtonHint");
        if (flags & WindowType.WindowShadeButtonHint)
            text ~= QString("\n| Qt::WindowShadeButtonHint");
        if (flags & WindowType.WindowStaysOnTopHint)
            text ~= QString("\n| Qt::WindowStaysOnTopHint");
        if (flags & WindowType.WindowStaysOnBottomHint)
            text ~= QString("\n| Qt::WindowStaysOnBottomHint");
        if (flags & WindowType.CustomizeWindowHint)
            text ~= QString("\n| Qt::CustomizeWindowHint");

        textEdit.setPlainText(text);
//! [h0 2]
    }
//! [c1]

private:
    QTextEdit textEdit;
    QPushButton closeButton;
}
//! [h0 2]
