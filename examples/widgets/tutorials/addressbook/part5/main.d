module main;

import core.runtime : Runtime;
import core.stdcpp.new_ : cpp_delete, cpp_new;
import qt.widgets.application : QApplication;

import addressbook : AddressBook;

int main()
{
    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto addressBook = cpp_new!AddressBook();
    scope (exit)
        cpp_delete(addressBook);
    addressBook.show();

    return app.exec();
}
