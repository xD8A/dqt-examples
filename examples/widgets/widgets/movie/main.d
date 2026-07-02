module main;

import movieplayer;
import qt.widgets.application;

int main()
{
    import core.runtime;
    import core.stdcpp.new_;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto player = cpp_new!MoviePlayer();
    scope(exit) cpp_delete(player);
    player.show();
    // player.show();

    return app.exec();
}
