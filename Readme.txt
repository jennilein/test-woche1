TTTTTTTT    OOOO    LL        LL        ZZZZZZZZ  EEEEEEEE  IIIIIIII  TTTTTTTT   
   TT      OO  OO   LL        LL             ZZ   EE           II        TT      
   TT     OO    OO  LL        LL            ZZ    EE           II        TT      
   TT     OO    OO  LL        LL           ZZ     EEEEEEE      II        TT      
   TT     OO    OO  LL        LL          ZZ      EE           II        TT      
   TT      OO  OO   LL        LL         ZZ       EE           II        TT      
   TT       OOOO    LLLLLLLL  LLLLLLLL  ZZZZZZZZ  EEEEEEEE  IIIIIIII     TT      

TOLLZEIT                                               (c) ALFWARE Bernd Schubert
========                                                Version 1.80 Februar 2016

1. Einleitende Übersicht
========================

Mit dem Programm TOLLZEIT kann man Zeitpunkte und Zeitdifferenzen berechnen.
Es gibt sicher Hunderte solcher Programme und Funktionen eingebaut in z.B. Excel
oder andere Programmpakete, wo man eben mit Zeiten rechnen muß.
Motivation war für mich das Testen einer Pascal UNIT, mit der ich eben die
Grundprinzipien der Kalender-Arithmetik für mich ein wenig nachvollziehen kann.
Wer sich ein bißchen damit beschäftigt hat, weiß daß die Grundidee mit einem
künstlichen Nullpunkt und dann regelmäßigen Vielfachen von Sekunden, Minuten,
Tagen, Stunden, Tagen, Monaten, Jahren... im Prinzip trivial ist - daß aber
wie immer der Teufel im Detail liegt, denkt man an die vielen Ausnahmen zu
den Monatslängen, Schalttagen, Schaltjahren usw.
Auch einen Algorithmus zur Bestimmung des Osterfestes (und damit aller 
verschieblichen Feiertage im Jahr) habe ich noch eingebaut - dies ist aber
mit diesem TOLLZEIT Programm nicht abrufbar. Vielmehr wollte ich einmal genau
bestimmen, wann ich denn 1.111.111.111 Sekunden alt wäre und siehe da es war
ziemlich genau nach dem 11.September und ich befand mich auf einem Kreuzfahrschiff 
auf dem Nil :-) 


2. Zu den Einzelfunktionen
==========================

Man kann (gesteuert über das Auswahl-Menü)

a) JETZT als Anfangszeitpunkt setzen

b) einen Anfangszeitpunkt eingeben (Datum und Uhrzeit werden abgefragt)

c) eine absolute (ms) Zahl für den Anfangszeitpunkt eingeben 
   (Datum und Uhrzeit werden berechnet)
   
d) einen Endezeitpunkt berechnen (die dazwischen liegenden Sekunden, Minuten,
   Tage, Wochen, Monate und/oder Jahre werden abgefragt)
   ENDE = ANFANG + DIFFERENZ

e) einen Vorherzeitpunkt berechnen (wie b nur ist DIFFERENZ negativ gedacht)
   VORHER = ANFANG - DIFFERENZ

f) die Zeitdifferenz berechnen (dazu wird der Endezeitpunkt abgefragt)   
   DIFFERENZ = ENDE - ANFANG

g) bis k) Anfangs- und Endezeitpunkt tauschen
   oder zuweisen bzw. mit dem heutigen/jetzigem Zeitpunkt belegen
   
   g) ENDE <-> ANFANG
   h) ENDE   -> ANFANG
   i) ANFANG -> ENDE
   j) HEUTE  -> ANFANG   (wie a)
   k) HEUTE  -> ENDE
   
l) nichts tun / warten ;-)

m) das Programm beenden
   
  
3. Technische Hinweise
======================

Alle Berechnungen habe ich mit größter Sorgfalt und nach bestem Wissen
und Gewissen programmiert. Dennoch kann und möchte ich nicht ausschließen,
daß sich beim Hantieren mit ganz großen Integer oder Float Zahlen nicht 
einmal ein Denkfehlerchen eingeschlichen haben könnte. 
Wer glaubt, etwas gefunden zu haben, wo TOLLZEIT falsch rechnet, 
kann es mir schicken.
Auch mit Blick auf das Baujahr des Programmes selbst (erstellt 1994, 
zuletzt durchgesehen 2011**) wie des Compilers (Turbo-Pascal 7.0, mittlerweile 
über 20 Jahre alt) möchte ich ein allzu unkritisches Ausprobieren gleich mit 
'brute force' nicht als ersten Test empfehlen. Man hat eben damals nicht 
ahnen können, was heute die Computer scheinbar selbstverständlich können.

32bit: 
------

Hier kommen wir jedoch zu einem Punkt, was die Computer heutzutage nicht
mehr können. Das Programm TOLLZEIT läuft leider nicht mehr unter 64bit-Systemen
wie Windows Vista und Win 7. Da Microsoft schlicht den 16bit-Emulator abgeschaltet
hat, der vielen Anwendern und auch Programmierern immer noch die Benutzung und
auch Wartung(!) der liebgewordenen Altprogramme ermöglicht hat. 
Ich habe viel Zeit investiert und meine ersten goldenen Haare bekommen bei dem
Versuch, dieses Programm TOLLZEIT auch unter 32/64bit zum Laufen zu bewegen. 
Leider gibt es Meinungsdifferenzen zwischen den entsprechenden 32bit-Compilern 
(Free Pascal) und mir und ich sehe letztlich ein, daß es den Aufwand nicht
wert wäre, das 100%ig zu portieren. 

Denn das Ergebnis würde auch nicht viel anders aussehen als wenn man es z.B. 
emuliert mit dem genialen DOSBOX* Programm, welches ich Euch hier heiß 
empfehlen kann! Hier ein Link zum Download:

http://www.dosbox.com/download.php?main=1

Da findet man die aktuelle Version und auch ein deutsches Sprachpaket.
Die Installation gestaltete sich aus meiner Sicht erstaunlich einfach. 
Wer doch Probleme hat, dem kann ich gern helfen z.B. mit der CONF Datei.

Im Weiteren gehe ich hier davon aus, daß DOSBOX installiert ist in einem
Ordner C:\BERND\DOSBOX und TOLLZEIT in C:\BERND\TOLLZEIT
Die Windows-Ordner C:\PROGRAMME etc. kann ich speziell unter Window7 und
Vista nicht empfehlen, da Windows einen letztlich immer irgendwie austrickst,
sei es mit Rechten oder gar Umleitungen. Darum habe ich alle meine Programme,
die ich weitergebe, unter C:\BERND angesiedelt.

Also wenn das auch bei Euch so ist, muß man nur noch eine Verknüpfung bauen,
die als Inhalt 
"C:\BERND\DOSBOX\DOSBOX.EXE C:\BERND\TOLLZEIT\TOLLZEIT.EXE -EXIT"
hat und als Ausführungsordner C:\BERND\TOLLZEIT
In dem Ordner VERSION\32bit findet Ihr so einen Link, der eigentlich nur noch
auf das Desktop gesetzt bzw. kopiert werden müßte.

Wer die automatische Installationsroutine (SETUP_TOLLZEIT...) probiert hat,
für den habe ich diese Aufgabe schon versucht zu erledigen (schaut mal nach,
ob die Verknüpfung TOLLZEIT(16) da ist).

Ein Doppelklick auf diese Verknüpfung und dann sollte das Programm normal
starten, und das Fenster sieht ähnlich aus wie das des Windows (z.B. XP),
man merkt also kaum einen Unterschied :-)

MD5:
----

cbf136003df9c0fa06db8622a62d84eb *Version\32bit\Tollzeit(16).lnk
5183bfb40de420518bf903feb46d3e84 *Version\Source\source.zip
6070ce856cd8d0647ffa492967039b7f *Tollzeit.exe


4. Rechtliche Hinweise*
======================

Die von mir beschriebene Fremdsoftware 
DOSBOX (DOSBOX Team)
ist Eigentum ihrer Entwickler. 
Ich benutze und empfehle sie hier mit großer Dankbarkeit.

Das Programm TOLLZEIT habe ich selbst entwickelt. 
Quellen findet man unter VERSION\SOURCE 
(auch mit einem kleinen Test zu den Feiertagen :-) 

Das Compile erledigte Borlands Turbo Pascal 7.0 für 16bit - 
auch hier besten Dank an die Hersteller.
Alles kann frei benutzt und weitergegeben werden, solange es nicht verändert 
oder von jemandem adoptiert und kommerziell ausgebeutet wird.

**Update Version 1.80, Februar 2016:
Anpassen der Source-Bibliothek "zeit.pas" wegen Free Pascal und Funktionen c) und e)

ENDE der Dokumentation
----------------------

Kontakt: info@alfware.de oder www.alfware.de