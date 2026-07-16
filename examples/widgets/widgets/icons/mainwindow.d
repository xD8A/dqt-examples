module mainwindow;

import qt.config;
import qt.helpers;
import qt.core.dir;
import qt.core.fileinfo;
import qt.core.list;
import qt.core.namespace;
import qt.core.qchar;
import qt.core.size;
import qt.core.string;
import qt.core.stringlist;
import qt.core.object;
import qt.gui.action;
import qt.gui.actiongroup;
import qt.gui.icon;
import qt.gui.keysequence;
import qt.gui.screen;
import qt.widgets.style;
import qt.gui.icon;
import qt.gui.image;
import qt.gui.pixmap;
import qt.widgets.abstractbutton;
import qt.widgets.buttongroup;
import qt.widgets.boxlayout;
import qt.widgets.checkbox;
import qt.widgets.filedialog;
import qt.widgets.formlayout;
import qt.widgets.layoutitem;
import qt.widgets.gridlayout;
import qt.widgets.groupbox;
import qt.widgets.headerview;
import qt.widgets.label;
import qt.widgets.mainwindow;
import qt.widgets.menubar;
import qt.widgets.messagebox;
import qt.widgets.radiobutton;
import qt.widgets.style;
import qt.widgets.spinbox;
import qt.widgets.splitter;
import qt.widgets.tablewidget;
import qt.widgets.widget;

import iconpreviewarea;
import iconsizespinbox;
import imagedelegate;

//! [0]

enum { OtherSize = cast(int)(QStyle.PixelMetric.PM_CustomBase) }

class MainWindow : QMainWindow
{
    mixin(Q_OBJECT_D);

    IconPreviewArea previewArea;
    QTableWidget imagesTable;
    QButtonGroup sizeButtonGroup;
    IconSizeSpinBox otherSpinBox;
    QLabel devicePixelRatioLabel;
    QLabel screenNameLabel;
    QAction addOtherImagesAct;
    QAction addSampleImagesAct;
    QAction removeAllImagesAct;
    QAction guessModeStateAct;
    QAction nativeFileDialogAct;
    QActionGroup styleActionGroup;

    this(QWidget parent = null)
    {
        import core.stdcpp.new_;

        super(parent);

        auto centralWidget = cpp_new!QWidget(this);
        setCentralWidget(centralWidget);

        createActions();

        auto mainLayout = cpp_new!QGridLayout(centralWidget);

        auto previewGroupBox = cpp_new!QGroupBox(tr("Preview"));
        previewArea = cpp_new!IconPreviewArea(previewGroupBox);
        auto previewLayout = cpp_new!QVBoxLayout(previewGroupBox);
        previewLayout.addWidget(previewArea);

        mainLayout.addWidget(previewGroupBox, 0, 0, 1, 2);
        mainLayout.addWidget(createImagesGroupBox(), 1, 0);
        auto vBox = cpp_new!QVBoxLayout();
        vBox.addWidget(createIconSizeGroupBox());
        vBox.addWidget(createHighDpiIconSizeGroupBox());
        vBox.addItem(cpp_new!QSpacerItem(0, 0, QSizePolicy.Policy.Ignored, QSizePolicy.Policy.MinimumExpanding));
        mainLayout.addLayout(vBox, 1, 1);
        createContextMenu();

        setWindowTitle(tr("Icons"));
        checkCurrentStyle();
        sizeButtonGroup.button(OtherSize).click();
    }

    extern(C++)     void setupScreen()
    {
        connect(windowHandle().signal!"screenChanged", this.slot!"screenChanged");
        screenChanged();
    }

    void loadImages(const(QStringList) fileNames)
    {
        import core.stdcpp.new_;
        //import qt.gui.imageio;
        import qt.core.qchar;

        for (int i = 0; i < fileNames.size(); ++i) {
            auto fileName = fileNames.at(i);
            int row = imagesTable.rowCount();
            imagesTable.setRowCount(row + 1);

            auto fileInfo = QFileInfo(fileName);
            auto imageName = fileInfo.baseName();
            auto fileName2x = fileInfo.absolutePath()
                ~ QChar('/') ~ imageName ~ QString("@2x.") ~ fileInfo.suffix();
            auto fileInfo2x = QFileInfo(fileName2x);
            auto image2 = QImage(fileName);
            auto toolTip = tr("Directory: %1\nFile: %2\nFile@2x: %3\nSize: %4x%5")
               .arg(QDir.toNativeSeparators(fileInfo.absolutePath()), fileInfo.fileName())
               .arg(fileInfo2x.exists() ? fileInfo2x.fileName() : tr("<None>"))
               .arg(image2.width()).arg(image2.height());

            auto fileItem = cpp_new!QTableWidgetItem(imageName);
            fileItem.setData(ItemDataRole.UserRole, fileName);
            fileItem.setIcon(QPixmap.fromImage(image2));
            {
                auto flags = fileItem.flags();
                flags |= ItemFlag.ItemIsUserCheckable;
                flags &= ~ItemFlag.ItemIsEditable;
                fileItem.setFlags(flags);
            }
            fileItem.setToolTip(toolTip);

            auto mode = QIcon.Mode.Normal;
            auto state = QIcon.State.Off;
            if (guessModeStateAct.isChecked()) {
                if (imageName.contains("_act", CaseSensitivity.CaseInsensitive))
                    mode = QIcon.Mode.Active;
                else if (imageName.contains("_dis", CaseSensitivity.CaseInsensitive))
                    mode = QIcon.Mode.Disabled;
                else if (imageName.contains("_sel", CaseSensitivity.CaseInsensitive))
                    mode = QIcon.Mode.Selected;

                if (imageName.contains("_on", CaseSensitivity.CaseInsensitive))
                    state = QIcon.State.On;
            }

            imagesTable.setItem(row, 0, fileItem);
            auto modes = IconPreviewArea.iconModes();
            auto modeItem = cpp_new!QTableWidgetItem(
                IconPreviewArea.iconModeNames().at(modes.indexOf(mode)));
            modeItem.setToolTip(toolTip);
            imagesTable.setItem(row, 1, modeItem);
            auto states = IconPreviewArea.iconStates();
            auto stateItem = cpp_new!QTableWidgetItem(
                IconPreviewArea.iconStateNames().at(states.indexOf(state)));
            stateItem.setToolTip(toolTip);
            imagesTable.setItem(row, 2, stateItem);
            imagesTable.openPersistentEditor(modeItem);
            imagesTable.openPersistentEditor(stateItem);

            fileItem.setCheckState(CheckState.Checked);
        }
    }

    @QSlot final void about()
    {
        QMessageBox.about(this, tr("About Icons"),
            tr("The <b>Icons</b> example illustrates how Qt renders an icon in "
               ~ "different modes (active, normal, disabled, and selected) and "
               ~ "states (on and off) based on a set of images."));
    }

    @QSlot final void changeStyle(bool checked)
    {
        if (!checked) return;

        auto action = qobject_cast!QAction(QObject.sender());
        auto style = QStyleFactory.create(action.data().toString());
        QApplication.setStyle(style);

        auto buttons = sizeButtonGroup.buttons();
        for (int i = 0; i < buttons.size(); ++i) {
            auto button = buttons.at(i);
            auto metric = cast(QStyle.PixelMetric)(sizeButtonGroup.id(button));
            int value = style.pixelMetric(metric);
            final switch (metric) {
            case QStyle.PixelMetric.PM_SmallIconSize:
                button.setText(tr("Small (%1 x %1)").arg(value));
                break;
            case QStyle.PixelMetric.PM_LargeIconSize:
                button.setText(tr("Large (%1 x %1)").arg(value));
                break;
            case QStyle.PixelMetric.PM_ToolBarIconSize:
                button.setText(tr("Toolbars (%1 x %1)").arg(value));
                break;
            case QStyle.PixelMetric.PM_ListViewIconSize:
                button.setText(tr("List views (%1 x %1)").arg(value));
                break;
            case QStyle.PixelMetric.PM_IconViewIconSize:
                button.setText(tr("Icon views (%1 x %1)").arg(value));
                break;
            case QStyle.PixelMetric.PM_TabBarIconSize:
                button.setText(tr("Tab bars (%1 x %1)").arg(value));
                break;
            default:
                break;
            }
        }

        triggerChangeSize();
    }

    @QSlot final void changeSize(QAbstractButton button, bool checked)
    {
        if (!checked) return;

        int index = sizeButtonGroup.id(button);
        bool other = index == OtherSize;
        int extent = other
            ? otherSpinBox.value()
            : QApplication.style().pixelMetric(cast(QStyle.PixelMetric)(index));

        previewArea.setSize(QSize(extent, extent));
        otherSpinBox.setEnabled(other);
    }

    @QSlot final void triggerChangeSize()
    {
        changeSize(sizeButtonGroup.checkedButton(), true);
    }

    @QSlot final void changeIcon()
    {
        import qt.gui.pixmap;

        auto icon = QIcon();

        for (int row = 0; row < imagesTable.rowCount(); ++row) {
            auto fileItem = imagesTable.item(row, 0);
            auto modeItem = imagesTable.item(row, 1);
            auto stateItem = imagesTable.item(row, 2);

            if (fileItem.checkState() == CheckState.Checked) {
                int modeIndex = IconPreviewArea.iconModeNames().indexOf(modeItem.text());
                int stateIndex = IconPreviewArea.iconStateNames().indexOf(stateItem.text());
                auto mode = IconPreviewArea.iconModes().at(modeIndex);
                auto state = IconPreviewArea.iconStates().at(stateIndex);

                auto fileName = fileItem.data(ItemDataRole.UserRole).toString();
                auto image3 = QImage(fileName);
                if (!image3.isNull())
                    icon.addPixmap(QPixmap.fromImage(image3), mode, state);
            }
        }
        previewArea.setIcon(icon);
    }

    @QSlot final void addSampleImages()
    {
        addImages("images");
    }

    @QSlot final void addOtherImages()
    {
        import qt.core.standardpaths;

        static bool firstInvocation = true;
        auto directory = QString();
        if (firstInvocation) {
            firstInvocation = false;
            auto locations = QStandardPaths.standardLocations(QStandardPaths.StandardLocation.PicturesLocation);
            if (locations.size() > 0)
                directory = locations.at(0);
        }
        addImages(directory);
    }

    @QSlot final void removeAllImages()
    {
        imagesTable.setRowCount(0);
        changeIcon();
    }

    @QSlot final void screenChanged()
    {
        devicePixelRatioLabel.setText(QString.number(devicePixelRatio()));
        auto window = windowHandle();
        if (window) {
            auto screen = window.screen();
            auto screenDescription = tr("\"%1\" (%2x%3)").arg(screen.name())
               .arg(screen.geometry().width()).arg(screen.geometry().height());
            screenNameLabel.setText(screenDescription);
        }
        changeIcon();
    }

private:
    void addImages(const(QString) directory)
    {
        auto fileDialog = cpp_new!QFileDialog(this, tr("Open Images"), directory);
        auto mimeTypeFilters = QStringList();
        auto mimeTypes = QImageReader.supportedMimeTypes();
        for (int i = 0; i < mimeTypes.size(); ++i)
            mimeTypeFilters.append(QString(mimeTypes.at(i)));
        mimeTypeFilters.sort();
        fileDialog.setMimeTypeFilters(mimeTypeFilters);
        fileDialog.selectMimeTypeFilter("image/png");
        fileDialog.setAcceptMode(QFileDialog.AcceptMode.AcceptOpen);
        fileDialog.setFileMode(QFileDialog.FileMode.ExistingFiles);
        if (!nativeFileDialogAct.isChecked())
            fileDialog.setOption(QFileDialog.Option.DontUseNativeDialog);
        if (fileDialog.exec() == QDialog.DialogCode.Accepted)
            loadImages(fileDialog.selectedFiles());
    }

    QWidget createImagesGroupBox()
    {
        import core.stdcpp.new_;

        auto imagesGroupBox = cpp_new!QGroupBox(tr("Images"));

        imagesTable = cpp_new!QTableWidget();
        imagesTable.setSelectionMode(QAbstractItemView.SelectionMode.NoSelection);
        imagesTable.setItemDelegate(cpp_new!ImageDelegate(this));

        auto labels = QStringList();
        labels.append(tr("Image"));
        labels.append(tr("Mode"));
        labels.append(tr("State"));

        imagesTable.horizontalHeader().setDefaultSectionSize(90);
        imagesTable.setColumnCount(3);
        imagesTable.setHorizontalHeaderLabels(labels);
        imagesTable.horizontalHeader().setSectionResizeMode(0, QHeaderView.ResizeMode.Stretch);
        imagesTable.horizontalHeader().setSectionResizeMode(1, QHeaderView.ResizeMode.Fixed);
        imagesTable.horizontalHeader().setSectionResizeMode(2, QHeaderView.ResizeMode.Fixed);
        imagesTable.verticalHeader().hide();

        connect(imagesTable.signal!"itemChanged", this.slot!"changeIcon");

        auto layout = cpp_new!QVBoxLayout(imagesGroupBox);
        layout.addWidget(imagesTable);
        return imagesGroupBox;
    }

    QWidget createIconSizeGroupBox()
    {
        import core.stdcpp.new_;
        import qt.widgets.splitter;

        auto iconSizeGroupBox = cpp_new!QGroupBox(tr("Icon Size"));

        sizeButtonGroup = cpp_new!QButtonGroup(this);
        sizeButtonGroup.setExclusive(true);

        connect(sizeButtonGroup.signal!"buttonToggled", this.slot!"changeSize");

        auto smallRadioButton = cpp_new!QRadioButton();
        sizeButtonGroup.addButton(smallRadioButton, QStyle.PixelMetric.PM_SmallIconSize);
        auto largeRadioButton = cpp_new!QRadioButton();
        sizeButtonGroup.addButton(largeRadioButton, QStyle.PixelMetric.PM_LargeIconSize);
        auto toolBarRadioButton = cpp_new!QRadioButton();
        sizeButtonGroup.addButton(toolBarRadioButton, QStyle.PixelMetric.PM_ToolBarIconSize);
        auto listViewRadioButton = cpp_new!QRadioButton();
        sizeButtonGroup.addButton(listViewRadioButton, QStyle.PixelMetric.PM_ListViewIconSize);
        auto iconViewRadioButton = cpp_new!QRadioButton();
        sizeButtonGroup.addButton(iconViewRadioButton, QStyle.PixelMetric.PM_IconViewIconSize);
        auto tabBarRadioButton = cpp_new!QRadioButton();
        sizeButtonGroup.addButton(tabBarRadioButton, QStyle.PixelMetric.PM_TabBarIconSize);
        auto otherRadioButton = cpp_new!QRadioButton(tr("Other:"));
        sizeButtonGroup.addButton(otherRadioButton, OtherSize);
        otherSpinBox = cpp_new!IconSizeSpinBox();
        otherSpinBox.setRange(8, 256);
        auto spinBoxToolTip = tr("Enter a custom size within %1..%2")
           .arg(otherSpinBox.minimum()).arg(otherSpinBox.maximum());
        otherSpinBox.setValue(64);
        otherSpinBox.setToolTip(spinBoxToolTip);
        otherRadioButton.setToolTip(spinBoxToolTip);

        connect(otherSpinBox.signal!"valueChanged", this.slot!"triggerChangeSize");

        auto otherSizeLayout = cpp_new!QHBoxLayout();
        otherSizeLayout.addWidget(otherRadioButton);
        otherSizeLayout.addWidget(otherSpinBox);
        otherSizeLayout.addStretch();

        auto layout = cpp_new!QGridLayout(iconSizeGroupBox);
        layout.addWidget(smallRadioButton, 0, 0);
        layout.addWidget(largeRadioButton, 1, 0);
        layout.addWidget(toolBarRadioButton, 2, 0);
        layout.addWidget(listViewRadioButton, 0, 1);
        layout.addWidget(iconViewRadioButton, 1, 1);
        layout.addWidget(tabBarRadioButton, 2, 1);
        layout.addLayout(otherSizeLayout, 3, 0, 1, 2);
        layout.setRowStretch(4, 1);
        return iconSizeGroupBox;
    }

    QWidget createHighDpiIconSizeGroupBox()
    {
        import core.stdcpp.new_;

        auto highDpiGroupBox = cpp_new!QGroupBox(tr("High DPI Scaling"));
        auto layout = cpp_new!QFormLayout(highDpiGroupBox);
        devicePixelRatioLabel = cpp_new!QLabel(highDpiGroupBox);
        screenNameLabel = cpp_new!QLabel(highDpiGroupBox);
        layout.addRow(tr("Screen:"), screenNameLabel);
        layout.addRow(tr("Device pixel ratio:"), devicePixelRatioLabel);
        return highDpiGroupBox;
    }

    void createActions()
    {
        auto fileMenu = menuBar().addMenu(tr("&File"));

        addSampleImagesAct = cpp_new!QAction(tr("Add &Sample Images..."), this);
        addSampleImagesAct.setShortcut(tr("Ctrl+A"));
        connect(addSampleImagesAct.signal!"triggered", this.slot!"addSampleImages");
        fileMenu.addAction(addSampleImagesAct);

        addOtherImagesAct = cpp_new!QAction(tr("&Add Images..."), this);
        addOtherImagesAct.setShortcut(QKeySequence.StandardKey.Open);
        connect(addOtherImagesAct.signal!"triggered", this.slot!"addOtherImages");
        fileMenu.addAction(addOtherImagesAct);

        removeAllImagesAct = cpp_new!QAction(tr("&Remove All Images"), this);
        removeAllImagesAct.setShortcut(tr("Ctrl+R"));
        connect(removeAllImagesAct.signal!"triggered", this.slot!"removeAllImages");
        fileMenu.addAction(removeAllImagesAct);

        fileMenu.addSeparator();

        auto exitAct = fileMenu.addAction(tr("&Quit"), this, &QWidget.close);
        exitAct.setShortcuts(QKeySequence.StandardKey.Quit);

        auto viewMenu = menuBar().addMenu(tr("&View"));

        styleActionGroup = cpp_new!QActionGroup(this);
        auto styleKeys = QStyleFactory.keys();
        for (int i = 0; i < styleKeys.size(); ++i) {
            auto styleName = styleKeys.at(i);
            auto action = cpp_new!QAction(tr("%1 Style").arg(styleName), styleActionGroup);
            action.setData(styleName);
            action.setCheckable(true);
            connect(action.signal!"triggered", this.slot!"changeStyle");
            viewMenu.addAction(action);
        }

        auto settingsMenu = menuBar().addMenu(tr("&Settings"));

        guessModeStateAct = cpp_new!QAction(tr("&Guess Image Mode/State"), this);
        guessModeStateAct.setCheckable(true);
        guessModeStateAct.setChecked(true);
        settingsMenu.addAction(guessModeStateAct);

        nativeFileDialogAct = cpp_new!QAction(tr("&Use Native File Dialog"), this);
        nativeFileDialogAct.setCheckable(true);
        nativeFileDialogAct.setChecked(true);
        settingsMenu.addAction(nativeFileDialogAct);

        auto helpMenu = menuBar().addMenu(tr("&Help"));
        helpMenu.addAction(tr("&About"), this, &MainWindow.about);
        helpMenu.addAction(tr("About &Qt"), qApp, &QApplication.aboutQt);
    }

    void createContextMenu()
    {
        imagesTable.setContextMenuPolicy(ContextMenuPolicy.ActionsContextMenu);
        imagesTable.addAction(addSampleImagesAct);
        imagesTable.addAction(addOtherImagesAct);
        imagesTable.addAction(removeAllImagesAct);
    }

    void checkCurrentStyle()
    {
        auto actions = styleActionGroup.actions();
        for (int i = 0; i < actions.size(); ++i) {
            auto action = actions.at(i);
            auto styleName = action.data().toString();
            auto candidate = QStyleFactory.create(styleName);
            if (candidate.metaObject().className()
                    == QApplication.style().metaObject().className()) {
                action.trigger();
                return;
            }
        }
    }
}
//! [0]