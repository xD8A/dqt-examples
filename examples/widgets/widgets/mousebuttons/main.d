module main;

import buttontester;

import qt.core.namespace;
import qt.widgets.pushbutton;
import qt.widgets.widget;

int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.core.object;
    import qt.widgets.application;
    import qt.widgets.boxlayout;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto testArea = cpp_new!ButtonTester();
    testArea.setMinimumSize(500, 350);
    testArea.setContextMenuPolicy(ContextMenuPolicy.NoContextMenu);
    testArea.setTextInteractionFlags(TextInteractionFlags(TextInteractionFlag.TextSelectableByMouse));
    testArea.setText("To test your mouse with Qt, press buttons in this area.\nYou may also scroll or tilt your mouse wheel.");

    auto quitButton = cpp_new!QPushButton("Quit");
    QObject.connect(quitButton.signal!"clicked", app.slot!"quit");

    auto layout = cpp_new!QVBoxLayout();
    layout.addWidget(testArea);
    layout.addWidget(quitButton);

    auto window = cpp_new!QWidget();
    window.setLayout(layout);
    window.setWindowTitle("Mouse Button Tester");
    scope(exit) cpp_delete(window);
    window.show();

    return app.exec();
}
