module main;

import addressbook : AddressBook;

//! [main function]
int main()
{
    import core.runtime : Runtime;
    import core.stdcpp.new_ : cpp_new, cpp_delete;
    import qt.widgets.application : QApplication;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto addressBook = cpp_new!AddressBook();
    scope (exit)
        cpp_delete(addressBook);
    addressBook.show();

    return app.exec();
}
//! [main function]
