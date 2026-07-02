module window;

import qt.config;
import qt.helpers;
import qt.core.string;
import qt.widgets.boxlayout;
import qt.widgets.checkbox;
import qt.widgets.gridlayout;
import qt.widgets.groupbox;
import qt.widgets.menu;
import qt.widgets.pushbutton;
import qt.widgets.radiobutton;
import qt.widgets.widget;

//! [0]
class Window : QWidget
{
    mixin(Q_OBJECT_D);

//! [1]

    this(QWidget parent = null)
    {
        import core.stdcpp.new_;

        super(parent);

        auto grid = cpp_new!QGridLayout();
        grid.addWidget(createFirstExclusiveGroup(), 0, 0);
        grid.addWidget(createSecondExclusiveGroup(), 1, 0);
        grid.addWidget(createNonExclusiveGroup(), 0, 1);
        grid.addWidget(createPushButtonGroup(), 1, 1);
        setLayout(grid);

        setWindowTitle(tr("Group Boxes"));
        resize(480, 320);
    }

//! [1]

private:
//! [2]

    QGroupBox createFirstExclusiveGroup()
    {
        import core.stdcpp.new_;

        auto groupBox = cpp_new!QGroupBox(tr("Exclusive Radio Buttons"));

        auto radio1 = cpp_new!QRadioButton(tr("&Radio button 1"));
        auto radio2 = cpp_new!QRadioButton(tr("R&adio button 2"));
        auto radio3 = cpp_new!QRadioButton(tr("Ra&dio button 3"));

        radio1.setChecked(true);

//! [2] //! [3]

        auto vbox = cpp_new!QVBoxLayout();
        vbox.addWidget(radio1);
        vbox.addWidget(radio2);
        vbox.addWidget(radio3);
        vbox.addStretch(1);
        groupBox.setLayout(vbox);

//! [3]

        return groupBox;
    }

//! [4]

    QGroupBox createSecondExclusiveGroup()
    {
        import core.stdcpp.new_;

        auto groupBox = cpp_new!QGroupBox(tr("E&xclusive Radio Buttons"));
        groupBox.setCheckable(true);
        groupBox.setChecked(false);

//! [4] //! [5]

        auto radio1 = cpp_new!QRadioButton(tr("Rad&io button 1"));
        auto radio2 = cpp_new!QRadioButton(tr("Radi&o button 2"));
        auto radio3 = cpp_new!QRadioButton(tr("Radio &button 3"));
        radio1.setChecked(true);
        auto checkBox = cpp_new!QCheckBox(tr("Ind&ependent checkbox"));
        checkBox.setChecked(true);

//! [5] //! [6]

        auto vbox = cpp_new!QVBoxLayout();
        vbox.addWidget(radio1);
        vbox.addWidget(radio2);
        vbox.addWidget(radio3);
        vbox.addWidget(checkBox);
        vbox.addStretch(1);
        groupBox.setLayout(vbox);

//! [6]

        return groupBox;
    }

//! [7]

    QGroupBox createNonExclusiveGroup()
    {
        import core.stdcpp.new_;
        import qt.core.namespace;

        auto groupBox = cpp_new!QGroupBox(tr("Non-Exclusive Checkboxes"));
        groupBox.setFlat(true);

//! [7] //! [8]

        auto checkBox1 = cpp_new!QCheckBox(tr("&Checkbox 1"));
        auto checkBox2 = cpp_new!QCheckBox(tr("C&heckbox 2"));
        checkBox2.setChecked(true);
        auto tristateBox = cpp_new!QCheckBox(tr("Tri-&state button"));
        tristateBox.setTristate(true);
        tristateBox.setCheckState(CheckState.PartiallyChecked);

//! [8] //! [9]

        auto vbox = cpp_new!QVBoxLayout();
        vbox.addWidget(checkBox1);
        vbox.addWidget(checkBox2);
        vbox.addWidget(tristateBox);
        vbox.addStretch(1);
        groupBox.setLayout(vbox);

//! [9]

        return groupBox;
    }

//! [10]

    QGroupBox createPushButtonGroup()
    {
        import core.stdcpp.new_;

        auto groupBox = cpp_new!QGroupBox(tr("&Push Buttons"));
        groupBox.setCheckable(true);
        groupBox.setChecked(true);

//! [10] //! [11]

        auto pushButton = cpp_new!QPushButton(tr("&Normal Button"));
        auto toggleButton = cpp_new!QPushButton(tr("&Toggle Button"));
        toggleButton.setCheckable(true);
        toggleButton.setChecked(true);
        auto flatButton = cpp_new!QPushButton(tr("&Flat Button"));
        flatButton.setFlat(true);

//! [11] //! [12]

        auto popupButton = cpp_new!QPushButton(tr("Pop&up Button"));
        auto menu = cpp_new!QMenu(this);
        menu.addAction(tr("&First Item"));
        menu.addAction(tr("&Second Item"));
        menu.addAction(tr("&Third Item"));
        menu.addAction(tr("F&ourth Item"));
        popupButton.setMenu(menu);

        auto subMenu = menu.addMenu(tr("Submenu"));
        subMenu.addAction(tr("Item 1"));
        subMenu.addAction(tr("Item 2"));
        subMenu.addAction(tr("Item 3"));

//! [12] //! [13]

        auto vbox = cpp_new!QVBoxLayout();
        vbox.addWidget(pushButton);
        vbox.addWidget(toggleButton);
        vbox.addWidget(flatButton);
        vbox.addWidget(popupButton);
        vbox.addStretch(1);
        groupBox.setLayout(vbox);

//! [13]

        return groupBox;
    }
}
//! [0]