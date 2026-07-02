module buttontester;

import qt.config;
import qt.helpers;
import qt.core.global;
import qt.core.namespace;
import qt.core.string;
import qt.gui.event;
import qt.widgets.textedit;
import qt.widgets.widget;

class ButtonTester : QTextEdit
{
    mixin(Q_OBJECT_D);

    this(QWidget parent = null)
    {
        super(parent);
    }

protected:
    override extern(C++) void mousePressEvent(QMouseEvent e)
    {
        int j = buttonByNumber(e.button());
        auto result = QString("Mouse Press: raw button=") ~ QString.number(j)
                    ~ QString("  Qt=") ~ enumNameFromValue(e.button());
        auto buttonsString = enumNamesFromMouseButtons(e.buttons());
        result = result ~ QString("\n heldbuttons ") ~ buttonsString;
        debug_text(result);
        setText(result);
        repaint();
    }

    override extern(C++) void mouseReleaseEvent(QMouseEvent e)
    {
        int j = buttonByNumber(e.button());
        auto result = QString("Mouse Release: raw button=") ~ QString.number(j)
                    ~ QString("  Qt=") ~ enumNameFromValue(e.button());
        auto buttonsString = enumNamesFromMouseButtons(e.buttons());
        result = result ~ QString("\n heldbuttons ") ~ buttonsString;
        debug_text(result);
        setText(result);
        repaint();
    }

    override extern(C++) void mouseDoubleClickEvent(QMouseEvent e)
    {
        int j = buttonByNumber(e.button());
        auto result = QString("Mouse DoubleClick: raw button=") ~ QString.number(j)
                    ~ QString("  Qt=") ~ enumNameFromValue(e.button());
        auto buttonsString = enumNamesFromMouseButtons(e.buttons());
        result = result ~ QString("\n heldbuttons") ~ buttonsString;
        debug_text(result);
        setText(result);
    }

    override extern(C++) void wheelEvent(QWheelEvent e)
    {
        auto result = QString();
        bool vertical = qAbs(e.angleDelta().y()) >= qAbs(e.angleDelta().x());
        int delta = vertical ? e.angleDelta().y() : e.angleDelta().x();
        if (delta > 0) {
            if (vertical)
                result = QString("Mouse Wheel Event: UP");
            else
                result = QString("Mouse Wheel Event: LEFT");
        } else if (delta < 0) {
            if (vertical)
                result = QString("Mouse Wheel Event: DOWN");
            else
                result = QString("Mouse Wheel Event: RIGHT");
        }
        debug_text(result);
        setText(result);
    }

private:
    int buttonByNumber(MouseButton button)
    {
        if (button == MouseButton.NoButton)      return 0;
        if (button == MouseButton.LeftButton)     return 1;
        if (button == MouseButton.RightButton)    return 2;
        if (button == MouseButton.MiddleButton)   return 3;
        if (button == MouseButton.BackButton)     return 8;
        if (button == MouseButton.ForwardButton)  return 9;
        if (button == MouseButton.TaskButton)     return 10;
        if (button == MouseButton.ExtraButton4)   return 11;
        if (button == MouseButton.ExtraButton5)   return 12;
        if (button == MouseButton.ExtraButton6)   return 13;
        if (button == MouseButton.ExtraButton7)   return 14;
        if (button == MouseButton.ExtraButton8)   return 15;
        if (button == MouseButton.ExtraButton9)   return 16;
        if (button == MouseButton.ExtraButton10)  return 17;
        if (button == MouseButton.ExtraButton11)  return 18;
        if (button == MouseButton.ExtraButton12)  return 19;
        if (button == MouseButton.ExtraButton13)  return 20;
        if (button == MouseButton.ExtraButton14)  return 21;
        if (button == MouseButton.ExtraButton15)  return 22;
        if (button == MouseButton.ExtraButton16)  return 23;
        if (button == MouseButton.ExtraButton17)  return 24;
        if (button == MouseButton.ExtraButton18)  return 25;
        if (button == MouseButton.ExtraButton19)  return 26;
        if (button == MouseButton.ExtraButton20)  return 27;
        if (button == MouseButton.ExtraButton21)  return 28;
        if (button == MouseButton.ExtraButton22)  return 29;
        if (button == MouseButton.ExtraButton23)  return 30;
        if (button == MouseButton.ExtraButton24)  return 31;
        return 0;
    }

    QString enumNameFromValue(MouseButton button)
    {
        if (button == MouseButton.NoButton)      return QString("NoButton");
        if (button == MouseButton.LeftButton)    return QString("LeftButton");
        if (button == MouseButton.RightButton)   return QString("RightButton");
        if (button == MouseButton.MiddleButton)  return QString("MiddleButton");
        if (button == MouseButton.BackButton)    return QString("BackButton");
        if (button == MouseButton.ForwardButton) return QString("ForwardButton");
        if (button == MouseButton.TaskButton)    return QString("TaskButton");
        if (button == MouseButton.ExtraButton4)  return QString("ExtraButton4");
        if (button == MouseButton.ExtraButton5)  return QString("ExtraButton5");
        if (button == MouseButton.ExtraButton6)  return QString("ExtraButton6");
        if (button == MouseButton.ExtraButton7)  return QString("ExtraButton7");
        if (button == MouseButton.ExtraButton8)  return QString("ExtraButton8");
        if (button == MouseButton.ExtraButton9)  return QString("ExtraButton9");
        if (button == MouseButton.ExtraButton10) return QString("ExtraButton10");
        if (button == MouseButton.ExtraButton11) return QString("ExtraButton11");
        if (button == MouseButton.ExtraButton12) return QString("ExtraButton12");
        if (button == MouseButton.ExtraButton13) return QString("ExtraButton13");
        if (button == MouseButton.ExtraButton14) return QString("ExtraButton14");
        if (button == MouseButton.ExtraButton15) return QString("ExtraButton15");
        if (button == MouseButton.ExtraButton16) return QString("ExtraButton16");
        if (button == MouseButton.ExtraButton17) return QString("ExtraButton17");
        if (button == MouseButton.ExtraButton18) return QString("ExtraButton18");
        if (button == MouseButton.ExtraButton19) return QString("ExtraButton19");
        if (button == MouseButton.ExtraButton20) return QString("ExtraButton20");
        if (button == MouseButton.ExtraButton21) return QString("ExtraButton21");
        if (button == MouseButton.ExtraButton22) return QString("ExtraButton22");
        if (button == MouseButton.ExtraButton23) return QString("ExtraButton23");
        if (button == MouseButton.ExtraButton24) return QString("ExtraButton24");
        return QString("NoButton");
    }

    QString enumNamesFromMouseButtons(MouseButtons buttons)
    {
        auto returnText = QString("");
        if (buttons == MouseButton.NoButton) return QString("NoButton");
        if ((buttons & MouseButton.LeftButton) != 0)    returnText = returnText ~ QString("LeftButton ");
        if ((buttons & MouseButton.RightButton) != 0)   returnText = returnText ~ QString("RightButton ");
        if ((buttons & MouseButton.MiddleButton) != 0)  returnText = returnText ~ QString("MiddleButton ");
        if ((buttons & MouseButton.BackButton) != 0)    returnText = returnText ~ QString("BackButton ");
        if ((buttons & MouseButton.ForwardButton) != 0) returnText = returnText ~ QString("ForwardButton ");
        if ((buttons & MouseButton.TaskButton) != 0)    returnText = returnText ~ QString("TaskButton ");
        if ((buttons & MouseButton.ExtraButton4) != 0)  returnText = returnText ~ QString("ExtraButton4 ");
        if ((buttons & MouseButton.ExtraButton5) != 0)  returnText = returnText ~ QString("ExtraButton5 ");
        if ((buttons & MouseButton.ExtraButton6) != 0)  returnText = returnText ~ QString("ExtraButton6 ");
        if ((buttons & MouseButton.ExtraButton7) != 0)  returnText = returnText ~ QString("ExtraButton7 ");
        if ((buttons & MouseButton.ExtraButton8) != 0)  returnText = returnText ~ QString("ExtraButton8 ");
        if ((buttons & MouseButton.ExtraButton9) != 0)  returnText = returnText ~ QString("ExtraButton9 ");
        if ((buttons & MouseButton.ExtraButton10) != 0) returnText = returnText ~ QString("ExtraButton10 ");
        if ((buttons & MouseButton.ExtraButton11) != 0) returnText = returnText ~ QString("ExtraButton11 ");
        if ((buttons & MouseButton.ExtraButton12) != 0) returnText = returnText ~ QString("ExtraButton12 ");
        if ((buttons & MouseButton.ExtraButton13) != 0) returnText = returnText ~ QString("ExtraButton13 ");
        if ((buttons & MouseButton.ExtraButton14) != 0) returnText = returnText ~ QString("ExtraButton14 ");
        if ((buttons & MouseButton.ExtraButton15) != 0) returnText = returnText ~ QString("ExtraButton15 ");
        if ((buttons & MouseButton.ExtraButton16) != 0) returnText = returnText ~ QString("ExtraButton16 ");
        if ((buttons & MouseButton.ExtraButton17) != 0) returnText = returnText ~ QString("ExtraButton17 ");
        if ((buttons & MouseButton.ExtraButton18) != 0) returnText = returnText ~ QString("ExtraButton18 ");
        if ((buttons & MouseButton.ExtraButton19) != 0) returnText = returnText ~ QString("ExtraButton19 ");
        if ((buttons & MouseButton.ExtraButton20) != 0) returnText = returnText ~ QString("ExtraButton20 ");
        if ((buttons & MouseButton.ExtraButton21) != 0) returnText = returnText ~ QString("ExtraButton21 ");
        if ((buttons & MouseButton.ExtraButton22) != 0) returnText = returnText ~ QString("ExtraButton22 ");
        if ((buttons & MouseButton.ExtraButton23) != 0) returnText = returnText ~ QString("ExtraButton23 ");
        if ((buttons & MouseButton.ExtraButton24) != 0) returnText = returnText ~ QString("ExtraButton24 ");
        return returnText;
    }

    void debug_text(const(QString) msg)
    {
        import std.stdio;
        stderr.writeln(msg);
    }
}
