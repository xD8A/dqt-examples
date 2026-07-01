module main;

int main()
{
    import core.runtime;
    import core.stdcpp.new_;
    import qt.core.string;
    import qt.core.stringlist;
    import qt.gui.standarditemmodel;
    import qt.widgets.application;
    import qt.widgets.boxlayout;
    import qt.widgets.label;
    import qt.widgets.lineedit;
    import qt.widgets.tableview;
    import qt.widgets.widget;

    scope app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv);

    auto window = cpp_new!QWidget();
    scope(exit) cpp_delete(window);

    auto queryLabel = cpp_new!QLabel(
        QApplication.translate("nestedlayouts", "Query:"));
    auto queryEdit = cpp_new!QLineEdit();
    auto resultView = cpp_new!QTableView();

    auto queryLayout = cpp_new!QHBoxLayout();
    queryLayout.addWidget(queryLabel);
    queryLayout.addWidget(queryEdit);

    auto mainLayout = cpp_new!QVBoxLayout();
    mainLayout.addLayout(queryLayout);
    mainLayout.addWidget(resultView);
    window.setLayout(mainLayout);

    auto model = cpp_new!QStandardItemModel();
    {
        QStringList headers;
        headers.append(QString("Name"));
        headers.append(QString("Office"));
        model.setHorizontalHeaderLabels(headers);
    }

    string[][] rows =
    [
        ["Verne Nilsen", "123"],
        ["Carlos Tang", "77"],
        ["Bronwyn Hawcroft", "119"],
        ["Alessandro Hanssen", "32"],
        ["Andrew John Bakken", "54"],
        ["Vanessa Weatherley", "85"],
        ["Rebecca Dickens", "17"],
        ["David Bradley", "42"],
        ["Knut Walters", "25"],
        ["Andrea Jones", "34"]
    ];

    foreach (i, row; rows)
    {
        model.setItem(cast(int)i, 0, cpp_new!QStandardItem(QString(row[0])));
        model.setItem(cast(int)i, 1, cpp_new!QStandardItem(QString(row[1])));
    }

    resultView.setModel(model);
    resultView.verticalHeader().hide();
    resultView.horizontalHeader().setStretchLastSection(true);

    window.setWindowTitle(
        QApplication.translate("nestedlayouts", "Nested layouts"));
    window.show();

    return app.exec();
}
