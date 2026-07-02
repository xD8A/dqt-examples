module movieplayer;

import qt.config;
import qt.helpers;
import qt.core.fileinfo;
import qt.core.namespace;
import qt.core.size;
import qt.core.string;
import qt.gui.movie;
import qt.gui.palette;
import qt.widgets.boxlayout;
import qt.widgets.checkbox;
import qt.widgets.filedialog;
import qt.widgets.gridlayout;
import qt.widgets.label;
import qt.widgets.sizepolicy;
import qt.widgets.slider;
import qt.widgets.spinbox;
import qt.widgets.style;
import qt.widgets.toolbutton;
import qt.widgets.widget;

class MoviePlayer : QWidget
{
    mixin(Q_OBJECT_D);

public:
    this(QWidget parent = null)
    {
        import core.stdcpp.new_;

        super(parent);

        movie = cpp_new!QMovie(this);
        movie.setCacheMode(QMovie.CacheMode.CacheAll);

        movieLabel = cpp_new!QLabel(tr("No movie loaded"));
        movieLabel.setAlignment(Alignment(AlignmentFlag.AlignCenter));
        movieLabel.setSizePolicy(QSizePolicy(QSizePolicy.Policy.Ignored, QSizePolicy.Policy.Ignored));
        movieLabel.setBackgroundRole(QPalette.ColorRole.Dark);
        movieLabel.setAutoFillBackground(true);

        currentMovieDirectory = "movies";

        createControls();
        createButtons();

        connect(movie.signal!"frameChanged", this.slot!"updateFrameSlider");
        connect(movie.signal!"stateChanged", this.slot!"updateButtons");
        connect(fitCheckBox.signal!"clicked", this.slot!"fitToWindow");
        connect(frameSlider.signal!"valueChanged", this.slot!"goToFrame");
        connect(speedSpinBox.signal!"valueChanged", movie.slot!"setSpeed");

        mainLayout = cpp_new!QVBoxLayout();
        mainLayout.addWidget(movieLabel);
        mainLayout.addLayout(controlsLayout);
        mainLayout.addLayout(buttonsLayout);
        setLayout(mainLayout);

        updateFrameSlider();
        updateButtons();

        setWindowTitle(tr("Movie Player"));
        resize(400, 400);
    }

    void openFile(const(QString) fileName)
    {
        currentMovieDirectory = QFileInfo(fileName).path();

        movie.stop();
        movieLabel.setMovie(movie);
        movie.setFileName(fileName);
        movie.start();

        updateFrameSlider();
        updateButtons();
    }

    @QSlot final void open()
    {
        auto fileName = QFileDialog.getOpenFileName(this, tr("Open a Movie"),
                               currentMovieDirectory);
        if (!fileName.isEmpty())
            openFile(fileName);
    }

    @QSlot final void goToFrame(int frame)
    {
        movie.jumpToFrame(frame);
    }

    @QSlot final void fitToWindow()
    {
        movieLabel.setScaledContents(fitCheckBox.isChecked());
    }

    @QSlot final void updateFrameSlider()
    {
        bool hasFrames = (movie.currentFrameNumber() >= 0);

        if (hasFrames) {
            if (movie.frameCount() > 0) {
                frameSlider.setMaximum(movie.frameCount() - 1);
            } else {
                if (movie.currentFrameNumber() > frameSlider.maximum())
                    frameSlider.setMaximum(movie.currentFrameNumber());
            }
            frameSlider.setValue(movie.currentFrameNumber());
        } else {
            frameSlider.setMaximum(0);
        }
        frameLabel.setEnabled(hasFrames);
        frameSlider.setEnabled(hasFrames);
    }

    @QSlot final void updateButtons()
    {
        playButton.setEnabled(movie.isValid() && movie.frameCount() != 1
                            && movie.state() == QMovie.MovieState.NotRunning);
        pauseButton.setEnabled(movie.state() != QMovie.MovieState.NotRunning);
        pauseButton.setChecked(movie.state() == QMovie.MovieState.Paused);
        stopButton.setEnabled(movie.state() != QMovie.MovieState.NotRunning);
    }

private:
    void createControls()
    {
        import core.stdcpp.new_;

        fitCheckBox = cpp_new!QCheckBox(tr("Fit to Window"));

        frameLabel = cpp_new!QLabel(tr("Current frame:"));

        frameSlider = cpp_new!QSlider(Orientation.Horizontal);
        frameSlider.setTickPosition(QSlider.TickPosition.TicksBelow);
        frameSlider.setTickInterval(10);

        speedLabel = cpp_new!QLabel(tr("Speed:"));

        speedSpinBox = cpp_new!QSpinBox();
        speedSpinBox.setRange(1, 9999);
        speedSpinBox.setValue(100);
        speedSpinBox.setSuffix(tr("%"));

        controlsLayout = cpp_new!QGridLayout();
        controlsLayout.addWidget(fitCheckBox, 0, 0, 1, 2);
        controlsLayout.addWidget(frameLabel, 1, 0);
        controlsLayout.addWidget(frameSlider, 1, 1, 1, 2);
        controlsLayout.addWidget(speedLabel, 2, 0);
        controlsLayout.addWidget(speedSpinBox, 2, 1);
    }

    void createButtons()
    {
        import core.stdcpp.new_;

        auto iconSize = QSize(36, 36);

        openButton = cpp_new!QToolButton();
        openButton.setIcon(style().standardIcon(QStyle.StandardPixmap.SP_DialogOpenButton));
        openButton.setIconSize(iconSize);
        openButton.setToolTip(tr("Open File"));
        connect(openButton.signal!"clicked", this.slot!"open");

        playButton = cpp_new!QToolButton();
        playButton.setIcon(style().standardIcon(QStyle.StandardPixmap.SP_MediaPlay));
        playButton.setIconSize(iconSize);
        playButton.setToolTip(tr("Play"));
        connect(playButton.signal!"clicked", movie.slot!"start");

        pauseButton = cpp_new!QToolButton();
        pauseButton.setCheckable(true);
        pauseButton.setIcon(style().standardIcon(QStyle.StandardPixmap.SP_MediaPause));
        pauseButton.setIconSize(iconSize);
        pauseButton.setToolTip(tr("Pause"));
        connect(pauseButton.signal!"clicked", movie.slot!"setPaused");

        stopButton = cpp_new!QToolButton();
        stopButton.setIcon(style().standardIcon(QStyle.StandardPixmap.SP_MediaStop));
        stopButton.setIconSize(iconSize);
        stopButton.setToolTip(tr("Stop"));
        connect(stopButton.signal!"clicked", movie.slot!"stop");

        quitButton = cpp_new!QToolButton();
        quitButton.setIcon(style().standardIcon(QStyle.StandardPixmap.SP_DialogCloseButton));
        quitButton.setIconSize(iconSize);
        quitButton.setToolTip(tr("Quit"));
        connect(quitButton.signal!"clicked", this.slot!"close");

        buttonsLayout = cpp_new!QHBoxLayout();
        buttonsLayout.addStretch();
        buttonsLayout.addWidget(openButton);
        buttonsLayout.addWidget(playButton);
        buttonsLayout.addWidget(pauseButton);
        buttonsLayout.addWidget(stopButton);
        buttonsLayout.addWidget(quitButton);
        buttonsLayout.addStretch();
    }

    QString currentMovieDirectory;
    QLabel movieLabel;
    QMovie movie;
    QToolButton openButton;
    QToolButton playButton;
    QToolButton pauseButton;
    QToolButton stopButton;
    QToolButton quitButton;
    QCheckBox fitCheckBox;
    QSlider frameSlider;
    QSpinBox speedSpinBox;
    QLabel frameLabel;
    QLabel speedLabel;

    QGridLayout controlsLayout;
    QHBoxLayout buttonsLayout;
    QVBoxLayout mainLayout;
}
