import Foundation

struct Quelle {
    let autor: String
    let jahr: String
    let titel: String
    let zeitschrift: String
}

struct ExperimentAnalyse {
    let mechanismus: String
    let wennErfolgreich: String
    let wennNichtErfolgreich: String
    let tipp: String
    let quellen: [Quelle]
}

func wissenschaftlicheAnalyse(fuer titel: String) -> ExperimentAnalyse {
    switch titel {

    case "Kein Koffein nach 14 Uhr":
        return ExperimentAnalyse(
            mechanismus: "Koffein blockiert die Adenosinrezeptoren im Gehirn. Adenosin ist ein Botenstoff, der sich tagsüber ansammelt und Schläfrigkeit auslöst – Koffein verhindert dieses Signal. Mit einer Halbwertszeit von 5–7 Stunden kann ein Kaffee um 15 Uhr noch um 21 Uhr halb so stark wirken und die Einschlafzeit sowie die Tiefschlafmenge deutlich reduzieren.",
            wennErfolgreich: "Deine Daten zeigen eine Verbesserung – das passt zur Wissenschaft: Ohne Koffein am Abend kann Adenosin ungehindert wirken, du wirst natürlich müder und dein Tiefschlafanteil steigt. Studien zeigen, dass Koffeinverzicht ab dem frühen Nachmittag den Tiefschlaf um bis zu 15 % erhöhen kann.",
            wennNichtErfolgreich: "Koffein allein reicht manchmal nicht aus. Mögliche Gründe: Du schläfst zu einer unregelmäßigen Zeit, dein Stresslevel ist hoch, oder andere Faktoren wie helles Licht am Abend überlagern den Effekt. Auch genetische Unterschiede im Koffeinabbau (CYP1A2-Gen) beeinflussen, wie stark Koffein wirkt.",
            tipp: "Kombiniere den Koffeinverzicht mit einer festen Schlafzeit – diese Kombination zeigt in Studien die stärksten Effekte.",
            quellen: [
                Quelle(autor: "Drake C. et al.", jahr: "2013", titel: "Caffeine Effects on Sleep Taken 0, 3, or 6 Hours before Going to Bed", zeitschrift: "Journal of Clinical Sleep Medicine, 9(11), 1195–1200"),
                Quelle(autor: "Roehrs T. & Roth T.", jahr: "2008", titel: "Caffeine: Sleep and daytime sleepiness", zeitschrift: "Sleep Medicine Reviews, 12(2), 153–162")
            ]
        )

    case "Handy weg ab 21 Uhr":
        return ExperimentAnalyse(
            mechanismus: "Smartphone-Bildschirme emittieren kurzwelliges blaues Licht (450–490 nm), das die Melatoninproduktion in der Zirbeldrüse hemmt. Melatonin ist das Schlafhormon, das deinen Körper auf Nacht einstellt. Hinzu kommt die kognitive Stimulation durch soziale Medien und Nachrichten, die das Gehirn in einen wachen, alertigen Zustand versetzt.",
            wennErfolgreich: "Weniger Bildschirmzeit am Abend lässt deinen Melatoninspiegel früher ansteigen. Dein Körper schaltet schneller in den Schlafmodus – du schläfst schneller ein und der REM-Schlaf in der ersten Nachthälfte verbessert sich.",
            wennNichtErfolgreich: "Andere Lichtquellen (helle Deckenlampen, Fernseher), Stress oder eine unregelmäßige Schlafzeit können den Melatonineffekt überlagern. Außerdem: Wenn du das Handy weglegest, aber gedanklich noch aktiv bist (Grübeln, Planung), hilft das allein noch nicht.",
            tipp: "Dunkle auch den Rest der Wohnung ab 21 Uhr ab – Dimmlicht oder Kerzen signalisieren dem Körper zusätzlich, dass die Nacht beginnt.",
            quellen: [
                Quelle(autor: "Chang A.M. et al.", jahr: "2015", titel: "Evening use of light-emitting eReaders negatively affects sleep, circadian timing, and next-morning alertness", zeitschrift: "PNAS, 112(4), 1232–1237"),
                Quelle(autor: "Cajochen C. et al.", jahr: "2011", titel: "Evening exposure to a light-emitting diodes (LED)-backlit computer screen affects circadian physiology and cognitive performance", zeitschrift: "Journal of Applied Physiology, 110(5), 1432–1438")
            ]
        )

    case "Blaues Licht Filter ab 20 Uhr":
        return ExperimentAnalyse(
            mechanismus: "Blaulichtfilter reduzieren kurzwellige Lichtanteile und verschieben das Lichtspektrum in wärmere Töne. Das schränkt die Hemmung der Melatoninproduktion ein, ohne vollständig auf Bildschirme verzichten zu müssen. Studien zeigen, dass der Effekt schwächer ist als vollständiger Bildschirmverzicht, aber dennoch messbar.",
            wennErfolgreich: "Der Filter hat bei dir geholfen, den Melatoninabfall am Abend zu bremsen. Dein Körper konnte trotz Bildschirmnutzung früher in den Schlafmodus übergehen.",
            wennNichtErfolgreich: "Blaulichtfilter reduzieren nur einen Teil des Problems. Die kognitive Aktivierung durch Inhalte (Nachrichten, soziale Medien, anregende Videos) bleibt bestehen und kann den Schlaf genauso stören wie das Licht selbst.",
            tipp: "Kombiniere den Filter mit einer bewussten Wahl von Inhalten: Ruhige, wenig stimulierende Videos oder E-Books statt sozialer Medien.",
            quellen: [
                Quelle(autor: "Burkhart K. & Phelps J.R.", jahr: "2009", titel: "Amber lenses to block blue light and improve sleep: a randomized trial", zeitschrift: "Chronobiology International, 26(8), 1602–1612"),
                Quelle(autor: "van der Lely S. et al.", jahr: "2015", titel: "Blue blocker glasses as a countermeasure for alerting effects of evening light-emitting diode screen exposure", zeitschrift: "Journal of Adolescent Health, 56(1), 113–119")
            ]
        )

    case "10 Min Meditation vor Bett":
        return ExperimentAnalyse(
            mechanismus: "Meditation aktiviert das parasympathische Nervensystem (\"Rest & Digest\") und bremst das sympathische System (\"Fight or Flight\"). Das senkt Herzrate, Blutdruck und Cortisolspiegel. Gleichzeitig reduziert sie das präschlafliche kognitive Arousal – das Gedankenkarussell, das viele vom Einschlafen abhält.",
            wennErfolgreich: "Deine Schlafdaten verbesserten sich – das zeigt, dass dein Nervensystem auf die Meditation angesprochen hat. Mit regelmäßiger Praxis verstärkt sich dieser Effekt weiter, da das Gehirn lernt, den Übergang in den Entspannungszustand schneller zu vollziehen.",
            wennNichtErfolgreich: "Meditation braucht oft 3–4 Wochen, bis messbare Schlafeffekte eintreten – 14 Tage sind eine gute Basis, aber möglicherweise noch zu kurz für dich. Auch die Technik spielt eine Rolle: Bodyscan-Meditationen zeigen in Studien stärkere Schlafeffekte als konzentrative Methoden.",
            tipp: "Probiere geführte Bodyscan-Meditationen (z.B. MBSR-basiert) – sie sind speziell auf den Übergang zum Schlaf ausgelegt und zeigen in Studien sehr gute Ergebnisse.",
            quellen: [
                Quelle(autor: "Black D.S. et al.", jahr: "2015", titel: "Mindfulness Meditation and Improvement in Sleep Quality and Daytime Impairment Among Older Adults With Sleep Disturbances", zeitschrift: "JAMA Internal Medicine, 175(4), 494–501"),
                Quelle(autor: "Ong J.C. et al.", jahr: "2014", titel: "A randomized controlled trial of mindfulness meditation for chronic insomnia", zeitschrift: "Sleep, 37(9), 1553–1563")
            ]
        )

    case "5 Min Tagebuch schreiben":
        return ExperimentAnalyse(
            mechanismus: "Das Aufschreiben von Gedanken und Erledigtem aktiviert \"Cognitive Offloading\" – das Gehirn übergibt Verantwortung für offene Punkte ans Papier und muss sie nicht mehr aktiv im Arbeitsgedächtnis halten. Das reduziert nächtliches Grübeln. Eine Studie der Baylor University zeigte, dass 5 Minuten To-Do-Listen schreiben vor dem Schlafen die Einschlafzeit um 9 Minuten verkürzte.",
            wennErfolgreich: "Das Tagebuch hat dein Gehirn entlastet. Offene Gedanken, Sorgen und Planungen \"landen\" auf dem Papier – dein Kopf muss sie nicht die ganze Nacht festhalten. Das ist besonders effektiv bei Menschen, die zum Grübeln neigen.",
            wennNichtErfolgreich: "Manche Menschen aktivieren sich durch das Schreiben eher, als dass sie sich beruhigen – besonders wenn über belastende Ereignisse geschrieben wird. Wenn du über Positives oder Erledigtes schreibst (Dankbarkeits-Journal), ist der Effekt meist stärker als bei Problemfokus.",
            tipp: "Schreib morgen Abend konkrete To-Do-Listen für den nächsten Tag statt allgemeiner Gedanken – das zeigt laut Forschung die stärkste schlaffördernde Wirkung.",
            quellen: [
                Quelle(autor: "Scullin M.K. et al.", jahr: "2018", titel: "The Effects of Bedtime Writing on Difficulty Falling Asleep: A Polysomnographic Study Comparing To-Do Lists and Completed Activity Journals", zeitschrift: "Journal of Experimental Psychology: General, 147(1), 139–146")
            ]
        )

    case "Atemübung vor dem Schlafen":
        return ExperimentAnalyse(
            mechanismus: "Langsame, tiefe Atemübungen (z.B. 4-7-8 oder Box-Breathing) stimulieren den Vagusnerv, der direkt das parasympathische Nervensystem aktiviert. Das erhöht die Herzratenvariabilität (HRV), senkt Herzrate und Blutdruck und signalisiert dem Körper Sicherheit. Schon 5 Minuten langsamer Atmung können den Cortisolspiegel messbar senken.",
            wennErfolgreich: "Atemübungen haben deinen Körper in den Ruhemodus versetzt. Dein autonomes Nervensystem reagiert direkt auf Atemrhythmus – das ist einer der schnellsten Wege, Stress physiologisch abzubauen, und deine Daten bestätigen das.",
            wennNichtErfolgreich: "Atemübungen wirken stark auf den Körper, aber der Geist kann noch aktiv bleiben. Wenn du während der Atemübung über den Tag nachgrübelst, ist die Wirkung eingeschränkt. Versuche, die Aufmerksamkeit wirklich nur auf das Atemgefühl zu lenken.",
            tipp: "Die 4-7-8-Technik (4 Sekunden einatmen, 7 halten, 8 ausatmen) aktiviert besonders stark den Vagusnerv – probiere sie für die nächsten zwei Wochen.",
            quellen: [
                Quelle(autor: "Jerath R. et al.", jahr: "2006", titel: "Physiology of long pranayamic breathing: Neural respiratory elements may provide a mechanism that explains how slow deep breathing shifts the autonomic nervous system", zeitschrift: "Medical Hypotheses, 67(3), 566–571"),
                Quelle(autor: "Tsai H.J. et al.", jahr: "2015", titel: "Efficacy of paced breathing for insomnia: enhances vagal activity and improves sleep quality", zeitschrift: "Psychophysiology, 52(3), 388–396")
            ]
        )

    case "Kein Essen nach 18 Uhr":
        return ExperimentAnalyse(
            mechanismus: "Der Körper folgt einem circadianen Rhythmus, der auch Verdauung und Stoffwechsel steuert. Spätes Essen erhöht die Körperkerntemperatur und den Insulinspiegel – beides sind Signale für Wachheit. Außerdem konkurriert aktive Verdauung mit dem Schlaf: Der Magen-Darm-Trakt produziert Wärme und benötigt Blutfluss, der vom schlafbegünstigenden Abkühlen des Körpers ablenkt.",
            wennErfolgreich: "Dein Körper konnte zum Schlafenszeit bereits deutlich abkühlen – ein zentraler Mechanismus des Einschlafens. Ohne Verdauungsarbeit fiel dein Körper schneller in die für den Tiefschlaf nötige Kerntemperaturabsenkung.",
            wennNichtErfolgreich: "Der Effekt späten Essens hängt stark vom Mahlzeitinhalt ab. Kleine, leichte Mahlzeiten stören weniger als fett- oder zuckerreiche. Außerdem spielt der Gesamtkaloriengehalt des Tages eine Rolle – Hunger selbst kann den Schlaf stören.",
            tipp: "Falls du nach 18 Uhr hungrig bist: Kleine Proteinmahlzeiten (z.B. griechischer Joghurt) stören den Schlaf weniger als Kohlenhydrate und halten den Hunger im Zaum.",
            quellen: [
                Quelle(autor: "Crispim C.A. et al.", jahr: "2011", titel: "Relationship between Food Intake and Sleep Pattern in Healthy Individuals", zeitschrift: "Journal of Clinical Sleep Medicine, 7(6), 659–664"),
                Quelle(autor: "Kinsey A.W. & Ormsbee M.J.", jahr: "2015", titel: "The Health Impact of Nighttime Eating: Old and New Perspectives", zeitschrift: "Nutrients, 7(4), 2648–2662")
            ]
        )

    case "Kein Alkohol unter der Woche":
        return ExperimentAnalyse(
            mechanismus: "Alkohol hat einen zweiphasigen Effekt: Er erleichtert das Einschlafen (dämpft das ZNS), fragmentiert aber den Schlaf in der zweiten Nachthälfte stark. Alkohol unterdrückt den REM-Schlaf massiv – schon ein Glas Wein reduziert den REM-Anteil in der ersten Hälfte der Nacht um bis zu 24 %. Der Körper kompensiert mit einem REM-Rebound später, der durch lebhafte Träume und Aufwachen geprägt ist.",
            wennErfolgreich: "Ohne Alkohol blieb deine Schlafarchitektur intakt. Dein REM-Schlaf – entscheidend für Gedächtniskonsolidierung und emotionale Regulation – konnte sich ungestört entfalten. Das erklärt, warum du dich morgens erholter gefühlt hast.",
            wennNichtErfolgreich: "Andere Faktoren wie Stress, Koffein oder Bildschirmzeit können den Alkohol-Effekt überlagern. Außerdem: Wenn du nur gelegentlich Alkohol getrunken hast, ist der Unterschied zur alkoholfreien Woche möglicherweise zu klein für eine messbare Wirkung.",
            tipp: "Falls du abends ein Glas trinkst: Mindestens 3 Stunden vor dem Schlafen – in dieser Zeit kann der Körper Alkohol soweit abbauen, dass der REM-Schlaf weniger gestört wird.",
            quellen: [
                Quelle(autor: "Ebrahim I.O. et al.", jahr: "2013", titel: "Alcohol and Sleep I: Effects on Normal Sleep", zeitschrift: "Alcoholism: Clinical and Experimental Research, 37(4), 539–549"),
                Quelle(autor: "Colrain I.M. et al.", jahr: "2014", titel: "Alcohol and the sleeping brain", zeitschrift: "Handbook of Clinical Neurology, 125, 415–431")
            ]
        )

    case "Jeden Tag 8 Gläser Wasser":
        return ExperimentAnalyse(
            mechanismus: "Schon leichte Dehydration (1–2 % des Körpergewichts) erhöht den Cortisolspiegel und stört die Schlafkontinuität. Der Körper benötigt ausreichend Flüssigkeit für die Thermoregulation im Schlaf – ein zentraler Mechanismus des Tiefschlafs. Dehydration kann außerdem Muskelkrämpfe und trockene Atemwege verursachen, die zu Aufwachreaktionen führen.",
            wennErfolgreich: "Ausreichend Flüssigkeit hat deine Schlafarchitektur stabilisiert. Dein Körper konnte die Körpertemperatur optimal regulieren und das Stresshormon Cortisol blieb niedrig – beides fördert tiefen, ununterbrochenenen Schlaf.",
            wennNichtErfolgreich: "Wenn du nachts häufig zur Toilette musst, kann ausgerechnet mehr Wasser den Schlaf fragmentieren. Trink die meisten Gläser bis 17 Uhr und reduziere die Zufuhr ab dem Abend. Außerdem ist der Schlaf-Effekt von Wasser eher ein Hintergrundeffekt – andere Faktoren wiegen stärker.",
            tipp: "Verteile das Wasser auf den Morgen und Nachmittag. Kräutertees am Abend (Baldrian, Kamille) kombinieren Flüssigkeit mit schlaffördernden Pflanzenstoffen.",
            quellen: [
                Quelle(autor: "Rosinger A.Y. et al.", jahr: "2021", titel: "Short sleep duration is associated with inadequate hydration: cross-cultural evidence from US and Chinese adults", zeitschrift: "Sleep, 44(2), zsaa163")
            ]
        )

    case "30 Min Spaziergang täglich":
        return ExperimentAnalyse(
            mechanismus: "Moderate Bewegung am Tag erhöht den Adenosin-Aufbau im Gehirn – den natürlichen Schlaftrieb. Außerdem hebt Bewegung die Körperkerntemperatur an, die danach abfällt – dieser Abkühlprozess ist ein starkes Schlaf-Signal. Tageslichtexposition während des Spaziergangs synchronisiert zusätzlich den circadianen Rhythmus.",
            wennErfolgreich: "Dein Körper hat auf die erhöhte körperliche Aktivität reagiert: Mehr Adenosin, bessere Körpertemperaturregulation und ein gestärkter circadianer Rhythmus durch Tageslicht. Diese drei Faktoren zusammen erklären die Verbesserung deines Schlafs.",
            wennNichtErfolgreich: "Der Zeitpunkt des Spaziergangs kann eine Rolle spielen. Sport nach 19 Uhr hebt die Körpertemperatur und den Adrenalinspiegel zu spät an. Außerdem braucht der Körper manchmal 2–3 Wochen, um auf regelmäßige Bewegung mit besseren Schlafdaten zu reagieren.",
            tipp: "Gehe deinen Spaziergang idealerweise morgens oder am frühen Nachmittag und suche dabei direktes Tageslicht – das verstärkt die Wirkung auf den circadianen Rhythmus erheblich.",
            quellen: [
                Quelle(autor: "Youngstedt S.D.", jahr: "2005", titel: "Effects of exercise on sleep", zeitschrift: "Clinics in Sports Medicine, 24(2), 355–365"),
                Quelle(autor: "Reid K.J. et al.", jahr: "2010", titel: "Aerobic exercise improves self-reported sleep and quality of life in older adults with insomnia", zeitschrift: "Sleep Medicine, 11(9), 934–940")
            ]
        )

    case "Zimmer auf 18 Grad kühlen":
        return ExperimentAnalyse(
            mechanismus: "Der Einschlafprozess erfordert, dass die Körperkerntemperatur um 0,5–1 °C sinkt. Ein kühles Zimmer (16–19 °C) unterstützt diesen Prozess aktiv durch Wärmeabgabe über die Haut. Studien zeigen konsistent, dass Raumtemperaturen über 21 °C die Schlafdauer verkürzen und den Tiefschlafanteil reduzieren.",
            wennErfolgreich: "Das kühle Zimmer hat deinem Körper die Temperaturabsenkung erleichtert, die er für den Tiefschlaf braucht. Der Effekt ist besonders stark in der ersten Nachthälfte, wenn die meiste Tiefschlafphase stattfindet.",
            wennNichtErfolgreich: "Manche Menschen reagieren empfindlicher auf Kälte – wenn du dich unter einer Decke warm halten musst und dabei unruhig wirst, ist 18 °C möglicherweise zu kalt. Der optimale Wert variiert individuell zwischen 16 und 20 °C.",
            tipp: "Warme Füße helfen beim Einschlafen, auch wenn das Zimmer kühl ist – warme Socken oder ein Wärmkissen für die Füße erweitern die Hautgefäße und beschleunigen die Wärmeabgabe des Körperkerns.",
            quellen: [
                Quelle(autor: "Okamoto-Mizuno K. & Mizuno K.", jahr: "2012", titel: "Effects of thermal environment on sleep and circadian rhythm", zeitschrift: "Journal of Physiological Anthropology, 31(1), 14"),
                Quelle(autor: "Harding E.C. et al.", jahr: "2019", titel: "The Temperature Dependence of Sleep", zeitschrift: "Frontiers in Neuroscience, 13, 336")
            ]
        )

    case "Kein Sport nach 20 Uhr":
        return ExperimentAnalyse(
            mechanismus: "Intensive Bewegung setzt Adrenalin und Noradrenalin frei und erhöht die Körperkerntemperatur – beides sind Signale für Wachheit. Der Cortisol-Spiegel nach dem Sport kann 2–3 Stunden erhöht bleiben. Sport am Abend verzögert den Melatonin-Anstieg und verschiebt die innere Uhr nach hinten.",
            wennErfolgreich: "Ohne abendlichen Sport konnte dein Körper rechtzeitig abkühlen und die Stresshormone sanken bis zum Schlafenszeit auf ein schlafförderliches Niveau. Dein Melatonin-Anstieg blieb ungestört.",
            wennNichtErfolgreich: "Moderate Bewegung wie Yoga oder leichtes Dehnen am Abend stört den Schlaf kaum – der Zeitpunkt ist weniger kritisch als die Intensität. Wenn du trotz des Experiments spät intensiven Sport gemacht hast, kann das den Effekt neutralisiert haben.",
            tipp: "Sanftes Abend-Yoga oder Stretching nach 20 Uhr ist unproblematisch oder sogar schlafförderlich. Nur intensive Ausdauer- und Kraftsporteinheiten sollten früher am Tag stattfinden.",
            quellen: [
                Quelle(autor: "Stutz J. et al.", jahr: "2019", titel: "Effects of Evening Exercise on Sleep in Healthy Participants: A Systematic Review and Meta-Analysis", zeitschrift: "Sports Medicine, 49(2), 269–287")
            ]
        )

    case "Jeden Tag gleiche Schlafzeit":
        return ExperimentAnalyse(
            mechanismus: "Der menschliche Körper hat eine innere Uhr (Nucleus suprachiasmaticus) mit einem Rhythmus von knapp 24 Stunden. Regelmäßige Schlafzeiten synchronisieren diese Uhr präzise: Hormone wie Melatonin, Cortisol und Wachstumshormon werden auf einen festen Rhythmus getaktet. Unregelmäßige Schlafzeiten erzeugen einen \"sozialen Jetlag\" mit ähnlichen Effekten wie echter Zeitzonenwechsel.",
            wennErfolgreich: "Deine innere Uhr hat in 14 Tagen einen stabilen Rhythmus entwickelt. Melatonin steigt nun jeden Abend zur gleichen Zeit an, Cortisol morgens zur gleichen Zeit – dein Körper ist auf deinen Schlafrhythmus \"kalibriert\". Das ist eine der wirkungsvollsten Schlaf-Interventionen überhaupt.",
            wennNichtErfolgreich: "14 Tage können für manche Menschen zu kurz sein, um die innere Uhr vollständig zu synchronisieren – besonders bei ausgeprägten Schlafproblemen oder wenn du an Wochenenden stark von deiner Schlafzeit abgewichen bist. Konsequenz ist hier entscheidend.",
            tipp: "Behalte die gleiche Aufstehzeit auch am Wochenende bei – das ist wichtiger als die Einschlafzeit, weil der Wecker die innere Uhr aktiv setzt.",
            quellen: [
                Quelle(autor: "Wittmann M. et al.", jahr: "2006", titel: "Social Jetlag: Misalignment of Biological and Social Time", zeitschrift: "Chronobiology International, 23(1–2), 497–509"),
                Quelle(autor: "Phillips A.J.K. et al.", jahr: "2017", titel: "Irregular sleep/wake patterns are associated with poorer academic performance and delayed circadian and sleep/wake timing", zeitschrift: "Scientific Reports, 7, 3216")
            ]
        )

    case "10 Min Lesen statt Handy":
        return ExperimentAnalyse(
            mechanismus: "Lesen (physisches Buch oder E-Ink-Reader ohne Blaulicht) kombiniert zwei Vorteile: kein kurzwelliges Licht und geringe kognitive Erregung gegenüber sozialen Medien. Studien zeigen, dass bereits 6 Minuten Lesen den Stresspegel um 68 % senken können – mehr als Musik hören oder Tee trinken. Das Eintauchen in eine Geschichte lenkt vom Tagesgeschehen ab.",
            wennErfolgreich: "Das Lesen hat deinen Übergang zum Schlaf erleichtert: weniger Blaulicht, weniger Stressreize und ein natürlicher \"Ausstieg\" aus dem Tag. Dein Gehirn wechselt beim Lesen in einen weniger aktivierten Zustand als beim Scrollen.",
            wennNichtErfolgreich: "Die Art des Lesestoffs macht einen Unterschied. Spannende Thriller oder aufwühlende Sachbücher können genauso aktivierend wirken wie das Handy. Außerdem: Wenn du beim Lesen auf einem hellbeleuchteten Tablet liest, ist der Effekt deutlich geringer.",
            tipp: "Ein E-Ink-Reader (Kindle, Tolino) ohne eigenes Licht oder mit warmem Licht ist ideal – er kombiniert entspanntes Lesen mit minimalem Blaulicht.",
            quellen: [
                Quelle(autor: "Exelmans L. & Van den Bulck J.", jahr: "2017", titel: "Bedtime, shuteye time and electronic media: sleep displacement is a two-step process", zeitschrift: "Journal of Sleep Research, 26(3), 364–370")
            ]
        )

    case "Magnesium vor dem Schlafen":
        return ExperimentAnalyse(
            mechanismus: "Magnesium ist Cofaktor für über 300 enzymatische Reaktionen und spielt eine zentrale Rolle bei der GABA-Aktivierung – dem wichtigsten hemmenden Neurotransmitter im Gehirn. GABA \"bremst\" neuronale Aktivität und fördert Entspannung. Magnesium reguliert außerdem den NMDA-Rezeptor, der bei Überstimulation zu Schlaflosigkeit beitragen kann. Studien zeigen besonders gute Wirkung bei Magnesiummangelzuständen.",
            wennErfolgreich: "Magnesium hat bei dir angeschlagen – entweder weil du einen subklinischen Mangel hattest (sehr verbreitet, besonders bei hohem Stresslevel) oder weil dein GABA-System besonders gut auf die Unterstützung reagiert hat. Du schläfst wahrscheinlich schneller ein und tiefer.",
            wennNichtErfolgreich: "Wenn dein Magnesiumspiegel bereits ausreichend war, ist der Effekt geringer. Die Wirksamkeit hängt stark von der Form ab: Magnesiumglycinat und -malat zeigen in Studien bessere Schlafeffekte als Magnesiumoxid oder -citrat.",
            tipp: "Magnesiumglycinat gilt als die am besten verträgliche und schlafwirksamste Form. 200–400 mg ca. 30–60 Minuten vor dem Schlafen – nimm es mit einem Glas Wasser und ohne Kalzium-haltige Nahrung.",
            quellen: [
                Quelle(autor: "Abbasi B. et al.", jahr: "2012", titel: "The effect of magnesium supplementation on primary insomnia in elderly: A double-blind placebo-controlled clinical trial", zeitschrift: "Journal of Research in Medical Sciences, 17(12), 1161–1169"),
                Quelle(autor: "Nielsen F.H. et al.", jahr: "2010", titel: "Magnesium supplementation improves indicators of low magnesium status and inflammatory stress in adults older than 51 years with poor quality sleep", zeitschrift: "Magnesium Research, 23(4), 158–168")
            ]
        )

    default:
        return ExperimentAnalyse(
            mechanismus: "Du hast dein eigenes Experiment entwickelt – das ist echter Wissenschaftsgeist. Selbstgewählte Interventionen haben einen entscheidenden Vorteil: Du hast sie auf dein Leben zugeschnitten, was die Einhaltung und damit die Wirksamkeit erhöht.",
            wennErfolgreich: "Dein Experiment hat messbar geholfen. Das zeigt: Du hast einen Faktor identifiziert, der für deinen Schlaf relevant ist. Dieses Wissen ist personalisierter als jede allgemeine Studie, denn du bist dein eigenes Experiment.",
            wennNichtErfolgreich: "Nicht jede Intervention wirkt bei jedem Menschen gleich – das ist die Grundlage der Schlafforschung. Genetik, Lifestyle, Stress und Umgebung interagieren komplex. Dein Nicht-Ergebnis ist genauso wertvolles Wissen: Du weißt jetzt, was für dich nicht der entscheidende Faktor ist.",
            tipp: "Dokumentiere, was du während des Experiments verändert hast und was nicht – oft gibt es versteckte Variablen (besonderer Stress, Reisen, Erkältung), die das Ergebnis verzerren.",
            quellen: []
        )
    }
}
