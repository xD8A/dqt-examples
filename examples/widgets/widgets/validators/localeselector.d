module localeselector;

import qt.config;
import qt.helpers;
import qt.core.locale : QLocale;
import qt.widgets.combobox : QComboBox;
import qt.widgets.widget : QWidget;

class LocaleSelector : QComboBox
{
    mixin(Q_OBJECT_D);
public:
    this(QWidget parent = null)
    {
        super(parent);

        import qt.core.global : qsizetype;

        import qt.core.variant : QVariant;

        int curIndex = -1;
        int index = 0;
        for (auto lang = QLocale.Language.C; lang <= QLocale.Language.LastLanguage;
            ++lang)
        {
            auto countries = QLocale.countriesForLanguage(lang);
            qsizetype n = countries.size();
            for (qsizetype j = 0; j < n; ++j)
            {
                auto country = countries[j];
                auto l = QLocale(lang, country);
                auto label = QLocale.languageToString(l.language());
                label ~= "/";
                label ~= QLocale.territoryToString(l.territory());

                auto v = QVariant.fromValue!QLocale(l);
                auto t = v.type();
                auto b = v.isValid();
                addItem(label, v);

                if (l.language() == locale().language() && l.territory() == locale()
                    .territory())
                {
                    curIndex = index;
                }
                ++index;
            }
        }
        if (curIndex != -1)
            setCurrentIndex(curIndex);

        connect(this.signal!("activated", int), this.slot!"emitLocaleSelected");
    }

private:

    @QSignal void localeSelected(const(QLocale) locale)
    {
        mixin(Q_SIGNAL_IMPL_D);
    }

    @QSlot void emitLocaleSelected(int index)
    {
        import qt.core.variant : qvariant_cast;

        auto v = itemData(index);
        auto l = qvariant_cast!QLocale(v);
        localeSelected(l);
    }
}
