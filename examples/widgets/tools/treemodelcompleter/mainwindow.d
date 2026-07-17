module mainwindow;

import core.stdcpp.new_ : cpp_delete, cpp_new;
import qt.config;
import qt.core.abstractitemmodel : QAbstractItemModel, QModelIndex;
import qt.core.abstractproxymodel : QAbstractProxyModel;
import qt.core.file : QFile;
import qt.core.iodevice : QIODevice;
import qt.core.itemselectionmodel : QItemSelectionModel;
import qt.core.list : QList;
import qt.core.namespace : CaseSensitivity, CursorShape;
import qt.core.object : qobject_cast;
import qt.core.regularexpression : QRegularExpression;
import qt.core.string : QLatin1String, QString;
import qt.core.stringlistmodel : QStringListModel;
import qt.gui.guiapplication : QGuiApplication;
import qt.gui.cursor : QCursor;
import qt.gui.standarditemmodel : QStandardItem, QStandardItemModel;
import qt.helpers;
import qt.widgets.action : QAction;
import qt.widgets.application : QApplication;
import qt.widgets.checkbox : QCheckBox;
import qt.widgets.combobox : QComboBox;
import qt.widgets.completer : QCompleter;
import qt.widgets.gridlayout : QGridLayout;
import qt.widgets.label : QLabel;
import qt.widgets.lineedit : QLineEdit;
import qt.widgets.mainwindow : QMainWindow;
import qt.widgets.messagebox : QMessageBox;
import qt.widgets.sizepolicy : QSizePolicy;
import qt.widgets.treeview : QTreeView;
import qt.widgets.widget : QWidget;


import treemodelcompleter : TreeModelCompleter;

//! [h0 0]
class MainWindow : QMainWindow
{
    mixin(Q_OBJECT_D);

public:
//! [c0]
    this(QWidget *parent = null)
    {
//! [h0 0]
        createMenu();

        completer = cpp_new!TreeModelCompleter(this);
        completer.setModel(modelFromFile(QString(":/resources/treemodel.txt")));
        completer.setSeparator(QString("."));

        connect(completer.signal!("highlighted", const(QModelIndex)), this.slot!"highlight");

        auto centralWidget = cpp_new!QWidget();

        auto modelLabel = cpp_new!QLabel();
        modelLabel.setText(tr("Tree Model<br>(Double click items to edit)"));

        auto modeLabel = cpp_new!QLabel();
        modeLabel.setText(tr("Completion Mode"));
        modeCombo = cpp_new!QComboBox();
        modeCombo.addItem(tr("Inline"));
        modeCombo.addItem(tr("Filtered Popup"));
        modeCombo.addItem(tr("Unfiltered Popup"));
        modeCombo.setCurrentIndex(1);

        auto caseLabel = cpp_new!QLabel();
        caseLabel.setText(tr("Case Sensitivity"));
        caseCombo = cpp_new!QComboBox();
        caseCombo.addItem(tr("Case Insensitive"));
        caseCombo.addItem(tr("Case Sensitive"));
        caseCombo.setCurrentIndex(0);
//! [c0]

//! [c1]
        auto separatorLabel = cpp_new!QLabel();
        separatorLabel.setText(tr("Tree Separator"));

        auto separatorLineEdit = cpp_new!QLineEdit();
        separatorLineEdit.setText(completer.separator());
        connect(separatorLineEdit.signal!"textChanged",
                completer.slot!"setSeparator");

        auto wrapCheckBox = cpp_new!QCheckBox();
        wrapCheckBox.setText(tr("Wrap around completions"));
        wrapCheckBox.setChecked(completer.wrapAround());
        connect(wrapCheckBox.signal!"clicked", completer.slot!"setWrapAround");

        contentsLabel = cpp_new!QLabel();
        contentsLabel.setSizePolicy(QSizePolicy(QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Fixed));
        connect(separatorLineEdit.signal!"textChanged",
                this.slot!"updateContentsLabel");

        treeView = cpp_new!QTreeView();
        treeView.setModel(completer.model());
        treeView.header().hide();
        treeView.expandAll();
//! [c1]

//! [c2]
        connect(modeCombo.signal!"activated",
                this.slot!"changeMode");
        connect(caseCombo.signal!"activated",
                this.slot!"changeMode");

        lineEdit = cpp_new!QLineEdit();
        lineEdit.setCompleter(completer);
//! [c2]

//! [c3]
        auto layout = cpp_new!QGridLayout();
        layout.addWidget(modelLabel, 0, 0); layout.addWidget(treeView, 0, 1);
        layout.addWidget(modeLabel, 1, 0);  layout.addWidget(modeCombo, 1, 1);
        layout.addWidget(caseLabel, 2, 0);  layout.addWidget(caseCombo, 2, 1);
        layout.addWidget(separatorLabel, 3, 0); layout.addWidget(separatorLineEdit, 3, 1);
        layout.addWidget(wrapCheckBox, 4, 0);
        layout.addWidget(contentsLabel, 5, 0, 1, 2);
        layout.addWidget(lineEdit, 6, 0, 1, 2);
        centralWidget.setLayout(layout);
        setCentralWidget(centralWidget);

        changeCase(caseCombo.currentIndex());
        changeMode(modeCombo.currentIndex());

        setWindowTitle(tr("Tree Model Completer"));
        lineEdit.setFocus();
//! [h0 1]
    }
//! [c3]

private:
//! [c6]
    @QSlot void about()
    {
//! [h0 1]
        QMessageBox.about(this, tr("About"), tr("This example demonstrates how "
                ~ "to use a QCompleter with a custom tree model."));
//! [h0 2]
    }
//! [c6]

//! [c7]
    @QSlot void changeCase(int cs)
    {
//! [h0 2]
        completer.setCaseSensitivity(cs ? CaseSensitivity.CaseSensitive : CaseSensitivity.CaseInsensitive);
//! [h0 3]
    }
//! [c7]

//! [c5]
    @QSlot void changeMode(int index)
    {
//! [h0 3]
        QCompleter.CompletionMode mode;
        if (index == 0)
            mode = QCompleter.CompletionMode.InlineCompletion;
        else if (index == 1)
            mode = QCompleter.CompletionMode.PopupCompletion;
        else
            mode = QCompleter.CompletionMode.UnfilteredPopupCompletion;

        completer.setCompletionMode(mode);
//! [h0 4]
    }
//! [c5]

    @QSlot void highlight(ref const(QModelIndex) index)
    {
//! [h0 4]
        auto completionModel = completer.completionModel();
        auto proxy = qobject_cast!QAbstractProxyModel(completionModel);
        if (!proxy)
            return;
        auto sourceIndex = proxy.mapToSource(index);
        treeView.selectionModel().select(
            sourceIndex, QItemSelectionModel.SelectionFlags(
                QItemSelectionModel.SelectionFlag.ClearAndSelect 
                | QItemSelectionModel.SelectionFlag.Rows));
        treeView.scrollTo(sourceIndex);
//! [h0 5]
    }
    @QSlot void updateContentsLabel(const (QString) sep)
    {
//! [h0 5]
        contentsLabel.setText(tr("Type path from model above with items at each level separated by a '%1'").arg(sep));
//! [h0 6]
    }
//! [h0 6]

//! [c4]
//! [h1 0]
    void createMenu()
    {
//! [h1 0]
        auto exitAction = cpp_new!QAction(tr("Exit"), this);
        auto aboutAct = cpp_new!QAction(tr("About"), this);
        auto aboutQtAct = cpp_new!QAction(tr("About Qt"), this);

        connect(exitAction.signal!"triggered", QApplication.instance().slot!"quit");
        connect(aboutAct.signal!"triggered", this.slot!"about");
        connect(aboutQtAct.signal!"triggered", (){ QMessageBox.aboutQt(this); });

        auto fileMenu = menuBar().addMenu(tr("File"));
        fileMenu.addAction(exitAction);

        auto helpMenu = menuBar().addMenu(tr("About"));
        helpMenu.addAction(aboutAct);
        helpMenu.addAction(aboutQtAct);
//! [h1 1]
    }
//! [c4]

    QAbstractItemModel modelFromFile(const (QString) fileName)
    {
//! [h1 1]
        auto file = cpp_new!QFile(fileName);
        scope(exit)
            cpp_delete(file);
        if (!file.open(QIODevice.OpenMode.ReadOnly))
            return cpp_new!QStringListModel(completer);

        version (QT_NO_CURSOR) 
        {
            QGuiApplication.setOverrideCursor(QCursor(CursorShape.WaitCursor));
        }

        auto model = cpp_new!QStandardItemModel(completer);
        auto parents = QList!QStandardItem(10);
        parents[0] = model.invisibleRootItem();

        auto re = QRegularExpression("^\\s+");
        while (!file.atEnd()) {
            const auto line = QString.fromUtf8(file.readLine());
            const auto trimmedLine = line.trimmed();
            if (trimmedLine.isEmpty())
                continue;

            const auto match = re.match(line);
            int nonws = cast(int)match.capturedStart();
            int level = 0;
            if (nonws == -1) {
                level = 0;
            } else {
                const int capLen =cast(int)match.capturedLength();
                level = capLen / 4;
            }

            if (level + 1 >= parents.size())
                parents.resize(parents.size() * 2);

            auto item = cpp_new!QStandardItem();
            item.setText(trimmedLine);
            /+
            TODO:
            * QStandardItem.appendRow(QStandardItem)

            parents[level].appendRow(item);
            +/
            parents[level].appendRow(QList!QStandardItem(1, item));
            parents[level + 1] = item;
        }

        version (QT_NO_CURSOR) 
        {
            QGuiApplication.restoreOverrideCursor();
        }

        return model;
//! [h1 2]
    }

    QTreeView treeView = null;
    QComboBox caseCombo = null;
    QComboBox modeCombo = null;
    QLabel contentsLabel = null;
    TreeModelCompleter completer = null;
    QLineEdit lineEdit = null;
}
//! [h1 2]
