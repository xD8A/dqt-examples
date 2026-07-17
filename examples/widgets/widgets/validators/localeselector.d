module localeselector;

import qt.config;
import qt.helpers;
import qt.core.global : qsizetype;
import qt.core.locale : QLocale;
import qt.core.variant : QVariant, qvariant_cast;
import qt.widgets.combobox : QComboBox;
import qt.widgets.widget : QWidget;

class LocaleSelector : QComboBox
{
    mixin(Q_OBJECT_D);
public:
    this(QWidget parent = null)
    {
        super(parent);

        int curIndex = -1;
        int index = 0;
        for (auto lang = QLocale.Language.C; lang <= QLocale.Language.LastLanguage;
            ++lang)
        {
            auto countries = QLocale.countriesForLanguage(lang);
            /+
            TODO:
            * QLocale.matchingLocales(QLocale.Language, QLocale.Script, QLocale.Territory)

            const auto locales = QLocale.matchingLocales(lang, QLocale.Script.AnyScript, QLocale.Country.AnyTerritory);
            foreach (const l; locales) {
                QString label = QLocale.languageToString(l.language());
                label ~= QLatin1Char('/');
                label ~= QLocale.territoryToString(l.territory());
                // distinguish locales by script, if there are more than one script for a language/territory pair
                if (QLocale.matchingLocales(l.language(), QLocale.Script.AnyScript, l.territory()).size() > 1)
                    label ~= QLatin1String(" (") + QLocale.scriptToString(l.script()) + QLatin1Char(')');

                addItem(label, QVariant.fromValue(l));

                if (l.language() == locale().language() && l.territory() == locale().territory()
                    && (locale().script() == QLocale.Script.AnyScript || l.script() == locale().script())) {
                    curIndex = index;
                }
                ++index;
            }
            +/
            immutable qsizetype n = countries.size();
            for (qsizetype j = 0; j < n; ++j)
            {
                auto country = countries[j];
                auto l = QLocale(lang, country);
                auto label = QLocale.languageToString(l.language());
                label ~= "/";
                label ~= QLocale.territoryToString(l.territory());

                auto v = QVariant.fromValue!QLocale(l);
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

    @QSignal void localeSelected(const(QLocale) _)
    {
        mixin(Q_SIGNAL_IMPL_D);
    }

    @QSlot void emitLocaleSelected(int index)
    {
        auto v = itemData(index);
        if (!v.isValid())
            return;
        auto l = qvariant_cast!QLocale(v);
        localeSelected(l);
    }
}
