module window;

import core.stdcpp.new_ : cpp_new;
import qt.config;
import qt.core.list : QList;
import qt.core.namespace : FillRule;
import qt.core.point : QPointF;
import qt.core.rect : QRectF;
import qt.gui.font : QFont;
import qt.gui.fontmetrics : QFontMetrics;
import qt.gui.painterpath : QPainterPath;
import qt.helpers;
import qt.widgets.combobox : QComboBox;
import qt.widgets.gridlayout : QGridLayout;
import qt.widgets.widget : QWidget;

import renderarea : Operation, RenderArea;

//! [h0 0]
class Window : QWidget
{
//! [h0 0]
//! [h1 0]
    mixin(Q_OBJECT_D);

public:
//! [c0 0]
    this()
    {
//! [h1 0]
//! [c0 0]
//! [c0 1]
        originalRenderArea = cpp_new!RenderArea();

        shapeComboBox = cpp_new!QComboBox();
        shapeComboBox.addItem(tr("Clock"));
        shapeComboBox.addItem(tr("House"));
        shapeComboBox.addItem(tr("Text"));
        shapeComboBox.addItem(tr("Truck"));

        auto layout = cpp_new!QGridLayout();
        layout.addWidget(originalRenderArea, 0, 0);
        layout.addWidget(shapeComboBox, 1, 0);
//! [c0 1]

//! [c1]
        for (int i = 0; i < NumTransformedAreas; ++i) {
            transformedRenderAreas[i] = cpp_new!RenderArea();

            operationComboBoxes[i] = cpp_new!QComboBox();
            operationComboBoxes[i].addItem(tr("No transformation"));
            operationComboBoxes[i].addItem(tr("Rotate by 60\xC2\xB0"));
            operationComboBoxes[i].addItem(tr("Scale to 75%"));
            operationComboBoxes[i].addItem(tr("Translate by (50, 50)"));

            connect(operationComboBoxes[i].signal!"activated",
                    this.slot!"operationChanged");

            layout.addWidget(transformedRenderAreas[i], 0, i + 1);
            layout.addWidget(operationComboBoxes[i], 1, i + 1);
        }
//! [c1]

//! [c2 0]
        setLayout(layout);
        setupShapes();
        shapeSelected(0);

        setWindowTitle(tr("Transformations"));
//! [c2 0]
//! [h1 1]
//! [c2 1]
    }
//! [c2 1]

//! [c8]
    @QSlot final void operationChanged()
    {
//! [h1 1]
        static immutable Operation[] operationTable = [
            Operation.NoTransformation, Operation.Rotate, Operation.Scale, Operation.Translate
        ];

        Operation[] operations;
        for (int i = 0; i < NumTransformedAreas; ++i) {
            immutable int index = operationComboBoxes[i].currentIndex();
            operations ~= operationTable[index];
            transformedRenderAreas[i].setOperations(operations);
        }
//! [h1 2]
    }
//! [c8]

//! [c9]
    @QSlot final void shapeSelected(int index)
    {
//! [h1 2]
        auto shape = shapes[index];
        originalRenderArea.setShape(shape);
        for (int i = 0; i < NumTransformedAreas; ++i)
            transformedRenderAreas[i].setShape(shape);
//! [h1 3]
    }
//! [c9]
//! [h1 3]

//! [h2 0]
private:
//! [c3 0]
    void setupShapes()
    {
//! [h2 0]
//! [c3 0]
//! [c3 1]
        auto truck = QPainterPath.create();
//! [c3 1]
        truck.setFillRule(FillRule.WindingFill);
        truck.moveTo(0.0, 87.0);
        truck.lineTo(0.0, 60.0);
        truck.lineTo(10.0, 60.0);
        truck.lineTo(35.0, 35.0);
        truck.lineTo(100.0, 35.0);
        truck.lineTo(100.0, 87.0);
        truck.lineTo(0.0, 87.0);
        truck.moveTo(17.0, 60.0);
        truck.lineTo(55.0, 60.0);
        truck.lineTo(55.0, 40.0);
        truck.lineTo(37.0, 40.0);
        truck.lineTo(17.0, 60.0);
        truck.addEllipse(QRectF(17.0, 75.0, 25.0, 25.0));
        truck.addEllipse(QRectF(63.0, 75.0, 25.0, 25.0));

//! [c4]
        auto clock = QPainterPath.create();
//! [c4]
        clock.addEllipse(QRectF(-50.0, -50.0, 100.0, 100.0));
        clock.addEllipse(QRectF(-48.0, -48.0, 96.0, 96.0));
        clock.moveTo(0.0, 0.0);
        clock.lineTo(-2.0, -2.0);
        clock.lineTo(0.0, -42.0);
        clock.lineTo(2.0, -2.0);
        clock.lineTo(0.0, 0.0);
        clock.moveTo(0.0, 0.0);
        clock.lineTo(2.732, -0.732);
        clock.lineTo(24.495, 14.142);
        clock.lineTo(0.732, 2.732);
        clock.lineTo(0.0, 0.0);

//! [c5]
        auto house = QPainterPath.create();
//! [c5]
        house.moveTo(-45.0, -20.0);
        house.lineTo(0.0, -45.0);
        house.lineTo(45.0, -20.0);
        house.lineTo(45.0, 45.0);
        house.lineTo(-45.0, 45.0);
        house.lineTo(-45.0, -20.0);
        house.addRect(15.0, 5.0, 20.0, 35.0);
        house.addRect(-35.0, -15.0, 25.0, 25.0);

//! [c6]
        auto text = QPainterPath.create();
//! [c6]
        auto font = QFont.create();
        font.setPixelSize(50);
        auto fontBoundingRect = QFontMetrics(font).boundingRect(tr("Qt"));
        /+
        TODO:
        * QPointF.opUnary!("-")()

        text.addText(-QPointF(fontBoundingRect.center()), font, tr("Qt"));
        +/
        auto fontBoundingCenter = fontBoundingRect.center();
        text.addText(QPointF(-fontBoundingCenter.x(), -fontBoundingCenter.y()), font, tr("Qt"));

//! [c7 0]
        shapes.append(clock);
        shapes.append(house);
        shapes.append(text);
        shapes.append(truck);

        connect(shapeComboBox.signal!"activated",
                this.slot!"shapeSelected");
//! [c7 0]
//! [c7 1]
//! [h2 1]
    }
//! [c7 1]

    enum { NumTransformedAreas = 3 }
    RenderArea originalRenderArea;
    RenderArea[NumTransformedAreas] transformedRenderAreas;
    QComboBox shapeComboBox;
    QComboBox[NumTransformedAreas] operationComboBoxes;
    QList!QPainterPath shapes;
//! [h2 1]
//! [h0 1]
}
//! [h0 1]
