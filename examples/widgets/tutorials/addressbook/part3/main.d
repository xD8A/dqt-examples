module main;

import addressbook;

int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.widgets.application;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto addressBook = cpp_new!AddressBook();
    scope(exit) cpp_delete(addressBook);
    addressBook.show();

    return app.exec();
}
