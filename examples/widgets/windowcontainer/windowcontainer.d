module windowcontainer;

import openglwindow : OpenGLWindow;
import qt.config;
import qt.gui.event : QMouseEvent;
import qt.gui.painter : QPainter;
import qt.helpers;

class Window : OpenGLWindow
{
    mixin(Q_OBJECT_D);
public:
    extern (C++) override void render(QPainter* p)
    {
        import qt.core.namespace : AlignmentFlag, GlobalColor;
        import qt.core.rect : QRect;
        import qt.core.string : QLatin1String;
        import qt.gui.brush : QLinearGradient;
        import qt.gui.color : QColor;

        auto g = QLinearGradient(0, 0, 0, height());
        g.setColorAt(0, QColor("lightsteelblue"));
        g.setColorAt(1, GlobalColor.black);
        p.fillRect(0, 0, width(), height(), g);

        p.setPen(QColor(GlobalColor.white));

        p.drawText(20, 30, QLatin1String("This is an OpenGL based QWindow"));

        if (m_key.trimmed().length() > 0)
        {
            QRect bounds = p.boundingRect(QRect(0, 0, width(), height()), AlignmentFlag.AlignTop | AlignmentFlag
                    .AlignLeft, m_key);
            p.save();
            p.translate(width() / 2.0, height() / 2.0);
            p.scale(10, 10);
            p.translate(-bounds.width() / 2.0, -bounds.height() / 2.0);
            p.drawText(bounds, AlignmentFlag.AlignCenter, m_key);
            p.restore();
        }

        if (m_focus)
            p.drawText(20, height() - 20, QLatin1String("Window has focus!"));

        p.setRenderHint(QPainter.RenderHint.Antialiasing);
        p.drawPolyline(m_polygon);
    }

protected:
    extern (C++) override void mousePressEvent(QMouseEvent e)
    {
        if (!m_mouseDown)
        {
            m_mouseDown = true;
            m_polygon.clear();
            m_polygon.append(e.position().toPoint());
            renderLater();
        }
    }

    extern (C++) override void mouseMoveEvent(QMouseEvent e)
    {
        if (m_mouseDown)
        {
            m_polygon.append(e.position().toPoint());
            renderLater();
        }
    }

    extern (C++) override void mouseReleaseEvent(QMouseEvent e)
    {
        if (m_mouseDown)
        {
            m_mouseDown = false;
            m_polygon.append(e.position().toPoint());
            renderLater();
        }
    }

    extern (C++) override void focusInEvent(QFocusEvent _)
    {
        m_focus = true;
        renderLater();
    }

    extern (C++) override void focusOutEvent(QFocusEvent _)
    {
        m_focus = false;
        m_polygon.clear();
        renderLater();
    }

    extern (C++) override void keyPressEvent(QKeyEvent e)
    {
        m_key = e.text();
        renderLater();
    }

    extern (C++) override void keyReleaseEvent(QKeyEvent _)
    {
        import qt.core.string : QString;

        m_key = QString.create();
        renderLater();
    }

private:
    QPolygon m_polygon;
    QString m_key;
    bool m_mouseDown = false;
    bool m_focus = false;
}

int main()
{
    import core.runtime : Runtime;
    import core.stdcpp.new_ : cpp_delete, cpp_new;
    import qt.core.string : QLatin1String;
    import qt.widgets.application : QApplication;
    import qt.widgets.boxlayout : QHBoxLayout;
    import qt.widgets.lineedit : QLineEdit;
    import qt.widgets.widget : QWidget;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto widget = cpp_new!QWidget();
    scope (exit)
        cpp_delete(widget);
    auto layout = cpp_new!QHBoxLayout(widget);

    auto window = cpp_new!Window();

    auto container = QWidget.createWindowContainer(window);
    container.setMinimumSize(300, 300);
    container.setMaximumSize(600, 600);
    container.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Expanding);
    container.setFocusPolicy(Qt.FocusPolicy.StrongFocus);

    window.setGeometry(100, 100, 300, 200);

    layout.addWidget(cpp_new!QLineEdit(QLatin1String("A QLineEdit")));
    layout.addWidget(container);
    layout.addWidget(cpp_new!QLineEdit(QLatin1String("A QLabel")));

    widget.show();

    return app.exec();
}
