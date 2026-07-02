module calculator;

import qt.config;
import qt.helpers;
import qt.core.string;
import qt.core.object;
import qt.core.qchar;
import qt.widgets.widget;
import qt.widgets.lineedit;

import std.math;

import button;

//! [h0]
class Calculator : QWidget
{
    mixin(Q_OBJECT_D);

public:
    this(QWidget parent = null)
//! [h0]

//! [c0]
    {
        import core.stdcpp.new_;
        import qt.core.namespace;
        import qt.gui.font;
        import qt.widgets.gridlayout;
        import qt.widgets.layout;

        super(parent);
//! [c0]

//! [c1]
        display = cpp_new!QLineEdit(QString("0"));
//! [c1] //! [c2]
        display.setReadOnly(true);
        display.setAlignment(Alignment(AlignmentFlag.AlignRight));
        display.setMaxLength(15);

        QFont font = QFont(display.font());
        font.setPointSize(font.pointSize() + 8);
        display.setFont(font);
//! [c2]

//! [c4]
        for (int i = 0; i < NumDigitButtons; ++i)
            digitButtons[i] = createButton(QString.number(i), &digitClicked);

        auto pointButton = createButton(tr("."), &pointClicked);
        auto changeSignButton = createButton(tr("\302\261"), &changeSignClicked);

        auto backspaceButton = createButton(tr("Backspace"), &backspaceClicked);
        auto clearButton = createButton(tr("Clear"), &clear);
        auto clearAllButton = createButton(tr("Clear All"), &clearAll);

        auto clearMemoryButton = createButton(tr("MC"), &clearMemory);
        auto readMemoryButton = createButton(tr("MR"), &readMemory);
        auto setMemoryButton = createButton(tr("MS"), &setMemory);
        auto addToMemoryButton = createButton(tr("M+"), &addToMemory);

        auto divisionButton = createButton(tr("\303\267"), &multiplicativeOperatorClicked);
        auto timesButton = createButton(tr("\303\227"), &multiplicativeOperatorClicked);
        auto minusButton = createButton(tr("-"), &additiveOperatorClicked);
        auto plusButton = createButton(tr("+"), &additiveOperatorClicked);

        auto squareRootButton = createButton(tr("Sqrt"), &unaryOperatorClicked);
        auto powerButton = createButton(tr("x\302\262"), &unaryOperatorClicked);
        auto reciprocalButton = createButton(tr("1/x"), &unaryOperatorClicked);
        auto equalButton = createButton(tr("="), &equalClicked);
//! [c4]

//! [c5]
        auto mainLayout = cpp_new!QGridLayout();
//! [c5] //! [c6]
        mainLayout.setSizeConstraint(QLayout.SizeConstraint.SetFixedSize);
        mainLayout.addWidget(display, 0, 0, 1, 6);
        mainLayout.addWidget(backspaceButton, 1, 0, 1, 2);
        mainLayout.addWidget(clearButton, 1, 2, 1, 2);
        mainLayout.addWidget(clearAllButton, 1, 4, 1, 2);

        mainLayout.addWidget(clearMemoryButton, 2, 0);
        mainLayout.addWidget(readMemoryButton, 3, 0);
        mainLayout.addWidget(setMemoryButton, 4, 0);
        mainLayout.addWidget(addToMemoryButton, 5, 0);

        for (int i = 1; i < NumDigitButtons; ++i) {
            int row = ((9 - i) / 3) + 2;
            int column = ((i - 1) % 3) + 1;
            mainLayout.addWidget(digitButtons[i], row, column);
        }

        mainLayout.addWidget(digitButtons[0], 5, 1);
        mainLayout.addWidget(pointButton, 5, 2);
        mainLayout.addWidget(changeSignButton, 5, 3);

        mainLayout.addWidget(divisionButton, 2, 4);
        mainLayout.addWidget(timesButton, 3, 4);
        mainLayout.addWidget(minusButton, 4, 4);
        mainLayout.addWidget(plusButton, 5, 4);

        mainLayout.addWidget(squareRootButton, 2, 5);
        mainLayout.addWidget(powerButton, 3, 5);
        mainLayout.addWidget(reciprocalButton, 4, 5);
        mainLayout.addWidget(equalButton, 5, 5);

        setLayout(mainLayout);
        setWindowTitle(tr("Calculator"));
    }
//! [c6]

//! [h1]
private:
//! [h1]

//! [c7]
    @QSlot final void digitClicked()
    {
        auto clickedButton = qobject_cast!Button(QObject.sender());
        int digitValue = clickedButton.text().toInt();
        if (display.text() == "0" && digitValue == 0)
            return;

        if (waitingForOperand) {
            display.clear();
            waitingForOperand = false;
        }
        display.setText(display.text() ~ QString.number(digitValue));
    }
//! [c7]

//! [c8]
    @QSlot final void unaryOperatorClicked()
//! [c8] //! [c9]
    {
        auto clickedButton = qobject_cast!Button(QObject.sender());
        auto clickedOperator = clickedButton.text();
        double operand = display.text().toDouble();
        double result = 0.0;

        if (clickedOperator == tr("Sqrt")) {
            if (operand < 0.0) {
                abortOperation();
                return;
            }
            result = sqrt(operand);
        } else if (clickedOperator == tr("x\302\262")) {
            result = operand * operand;
        } else if (clickedOperator == tr("1/x")) {
            if (operand == 0.0) {
                abortOperation();
                return;
            }
            result = 1.0 / operand;
        }
        display.setText(QString.number(result));
        waitingForOperand = true;
    }
//! [c9]

//! [c10]
    @QSlot final void additiveOperatorClicked()
//! [c10] //! [c11]
    {
        auto clickedButton = qobject_cast!Button(QObject.sender());
        if (!clickedButton)
            return;
        auto clickedOperator = clickedButton.text();
        double operand = display.text().toDouble();

//! [c11] //! [c12]
        if (!pendingMultiplicativeOperator.isEmpty()) {
//! [c12] //! [c13]
            if (!calculate(operand, pendingMultiplicativeOperator)) {
                abortOperation();
                return;
            }
            display.setText(QString.number(factorSoFar));
            operand = factorSoFar;
            factorSoFar = 0.0;
            pendingMultiplicativeOperator.clear();
        }
//! [c13]

//! [c14]
        if (!pendingAdditiveOperator.isEmpty()) {
//! [c14] //! [c15]
            if (!calculate(operand, pendingAdditiveOperator)) {
                abortOperation();
                return;
            }
            display.setText(QString.number(sumSoFar));
        } else {
            sumSoFar = operand;
        }
//! [c15]

//! [c16]
        pendingAdditiveOperator = clickedOperator;
//! [c16] //! [c17]
        waitingForOperand = true;
    }
//! [c17]

//! [c18]
    @QSlot final void multiplicativeOperatorClicked()
    {
        auto clickedButton = qobject_cast!Button(QObject.sender());
        if (!clickedButton)
            return;
        auto clickedOperator = clickedButton.text();
        double operand = display.text().toDouble();

        if (!pendingMultiplicativeOperator.isEmpty()) {
            if (!calculate(operand, pendingMultiplicativeOperator)) {
                abortOperation();
                return;
            }
            display.setText(QString.number(factorSoFar));
        } else {
            factorSoFar = operand;
        }

        pendingMultiplicativeOperator = clickedOperator;
        waitingForOperand = true;
    }
//! [c18]

//! [c20]
    @QSlot final void equalClicked()
    {
        double operand = display.text().toDouble();

        if (!pendingMultiplicativeOperator.isEmpty()) {
            if (!calculate(operand, pendingMultiplicativeOperator)) {
                abortOperation();
                return;
            }
            operand = factorSoFar;
            factorSoFar = 0.0;
            pendingMultiplicativeOperator.clear();
        }
        if (!pendingAdditiveOperator.isEmpty()) {
            if (!calculate(operand, pendingAdditiveOperator)) {
                abortOperation();
                return;
            }
            pendingAdditiveOperator.clear();
        } else {
            sumSoFar = operand;
        }

        display.setText(QString.number(sumSoFar));
        sumSoFar = 0.0;
        waitingForOperand = true;
    }
//! [c20]

//! [c22]
    @QSlot final void pointClicked()
    {
        if (waitingForOperand)
            display.setText("0");
        if (!display.text().contains(QChar('.')))
            display.setText(display.text() ~ ".");
        waitingForOperand = false;
    }
//! [c22]

//! [c24]
    @QSlot final void changeSignClicked()
    {
        auto text = display.text();
        double value = text.toDouble();

        if (value > 0.0) {
            text = QString("-") ~ text;
        } else if (value < 0.0) {
            text.remove(0, 1);
        }
        display.setText(text);
    }
//! [c24]

//! [c26]
    @QSlot final void backspaceClicked()
    {
        if (waitingForOperand)
            return;

        auto text = display.text();
        text.chop(1);
        if (text.isEmpty()) {
            text = QString("0");
            waitingForOperand = true;
        }
        display.setText(text);
    }
//! [c26]

//! [c28]
    @QSlot final void clear()
    {
        if (waitingForOperand)
            return;

        display.setText("0");
        waitingForOperand = true;
    }
//! [c28]

//! [c30]
    @QSlot final void clearAll()
    {
        sumSoFar = 0.0;
        factorSoFar = 0.0;
        pendingAdditiveOperator.clear();
        pendingMultiplicativeOperator.clear();
        display.setText("0");
        waitingForOperand = true;
    }
//! [c30]

//! [c32]
    @QSlot final void clearMemory()
    {
        sumInMemory = 0.0;
    }

    @QSlot final void readMemory()
    {
        display.setText(QString.number(sumInMemory));
        waitingForOperand = true;
    }

    @QSlot final void setMemory()
    {
        equalClicked();
        sumInMemory = display.text().toDouble();
    }

    @QSlot final void addToMemory()
    {
        equalClicked();
        sumInMemory += display.text().toDouble();
    }
//! [c32]

//! [h2] //! [c34]
    Button createButton(const(QString) text, void delegate() slot)
    {
        import core.stdcpp.new_;
        auto button = cpp_new!Button(text);
        connect(button.signal!"clicked", this, slot);
        return button;
    }
//! [c34]

//! [c36]
    void abortOperation()
    {
        clearAll();
        display.setText(tr("####"));
    }
//! [c36]

//! [c38]
    bool calculate(double rightOperand, const(QString) pendingOperator)
    {
        if (pendingOperator == tr("+")) {
            sumSoFar += rightOperand;
        } else if (pendingOperator == tr("-")) {
            sumSoFar -= rightOperand;
        } else if (pendingOperator == tr("\303\227")) {
            factorSoFar *= rightOperand;
        } else if (pendingOperator == tr("\303\267")) {
            if (rightOperand == 0.0)
                return false;
            factorSoFar /= rightOperand;
        }
        return true;
    }
//! [c38]

//! [h3]
    double sumInMemory;
//! [h3] //! [h4]
    double sumSoFar;
//! [h4] //! [h5]
    double factorSoFar;
//! [h5] //! [h6]
    QString pendingAdditiveOperator;
//! [h6] //! [h7]
    QString pendingMultiplicativeOperator;
//! [h7] //! [h8]
    bool waitingForOperand;
//! [h8]

//! [h9]
    QLineEdit display;
//! [h9]

//! [h10]
    enum { NumDigitButtons = 10 }
    Button[NumDigitButtons] digitButtons;
//! [h10]
}
//! [h0]
