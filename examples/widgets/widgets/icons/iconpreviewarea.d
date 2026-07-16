module iconpreviewarea;

import qt.config;
import qt.helpers;
import qt.core.list;
import qt.core.namespace;
import qt.core.size;
import qt.core.string;
import qt.core.stringlist;
import qt.gui.icon;
import qt.gui.pixmap;
import qt.widgets.frame;
import qt.widgets.gridlayout;
import qt.widgets.label;
import qt.widgets.sizepolicy;
import qt.widgets.widget;

//! [0]
class IconPreviewArea : QWidget
{
    mixin(Q_OBJECT_D);

    enum { NumModes = 4, NumStates = 2 }

    QIcon icon;
    QSize size;
    QLabel[NumStates] stateLabels;
    QLabel[NumModes] modeLabels;
    QLabel[NumModes][NumStates] pixmapLabels;

    this(QWidget parent = null)
    {
        import core.stdcpp.new_;

        super(parent);

        auto mainLayout = cpp_new!QGridLayout(this);
        mainLayout.setContentsMargins(0, 0, 0, 0);

        for (int row; row < NumStates; ++row) {
            stateLabels[row] = createHeaderLabel(iconStateNames().at(row));
            mainLayout.addWidget(stateLabels[row], row + 1, 0);
        }

        for (int column; column < NumModes; ++column) {
            modeLabels[column] = createHeaderLabel(iconModeNames().at(column));
            mainLayout.addWidget(modeLabels[column], 0, column + 1);
        }

        for (int column; column < NumModes; ++column) {
            for (int row; row < NumStates; ++row) {
                pixmapLabels[column][row] = createPixmapLabel();
                mainLayout.addWidget(pixmapLabels[column][row], row + 1, column + 1);
            }
        }
    }

    static QList!(QIcon.Mode) iconModes()
    {
        auto result = QList!(QIcon.Mode).create();
        result.append(QIcon.Mode.Normal);
        result.append(QIcon.Mode.Active);
        result.append(QIcon.Mode.Disabled);
        result.append(QIcon.Mode.Selected);
        return result;
    }

    static QList!(QIcon.State) iconStates()
    {
        auto result = QList!(QIcon.State).create();
        result.append(QIcon.State.Off);
        result.append(QIcon.State.On);
        return result;
    }

    static QStringList iconModeNames()
    {
        auto result = QStringList();
        result.append(tr("Normal"));
        result.append(tr("Active"));
        result.append(tr("Disabled"));
        result.append(tr("Selected"));
        return result;
    }

    static QStringList iconStateNames()
    {
        auto result = QStringList();
        result.append(tr("Off"));
        result.append(tr("On"));
        return result;
    }

    void setIcon(const(QIcon) newIcon)
    {
        icon = newIcon;
        updatePixmapLabels();
    }

    void setSize(const(QSize) newSize)
    {
        if (newSize != size) {
            size = newSize;
            updatePixmapLabels();
        }
    }

    QLabel createHeaderLabel(const(QString) text)
    {
        import core.stdcpp.new_;

        auto label = cpp_new!QLabel(tr("<b>%1</b>").arg(text));
        label.setAlignment(Alignment(AlignmentFlag.AlignCenter));
        return label;
    }

    QLabel createPixmapLabel()
    {
        import core.stdcpp.new_;

        auto label = cpp_new!QLabel();
        label.setEnabled(false);
        label.setAlignment(Alignment(AlignmentFlag.AlignCenter));
        label.setFrameShape(QFrame.Shape.Box);
        label.setSizePolicy(QSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Expanding));
        label.setBackgroundRole(QPalette.ColorRole.Base);
        label.setAutoFillBackground(true);
        label.setMinimumSize(132, 132);
        return label;
    }

    void updatePixmapLabels()
    {
        import qt.gui.palette;

        for (int column; column < NumModes; ++column) {
            for (int row; row < NumStates; ++row) {
                auto modes = iconModes();
                auto states = iconStates();
                auto pixmap = icon.pixmap(size, devicePixelRatio(),
                                          modes.at(column), states.at(row));
                auto pixmapLabel = pixmapLabels[column][row];
                pixmapLabel.setPixmap(pixmap);
                pixmapLabel.setEnabled(!pixmap.isNull());
                QString toolTip;
                if (!pixmap.isNull()) {
                    auto actualSize = icon.actualSize(size);
                    toolTip = tr("Size: %1x%2\nActual size: %3x%4\nDevice pixel ratio: %5")
                        .arg(size.width()).arg(size.height())
                        .arg(actualSize.width()).arg(actualSize.height())
                        .arg(pixmap.devicePixelRatio());
                }
                pixmapLabel.setToolTip(toolTip);
            }
        }
    }
}
//! [0]