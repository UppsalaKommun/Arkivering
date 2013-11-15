############################################################
## Arkivering av webbplats med NTLM-baserad autentisering
############################################################



Det h�r dokumentet beskriver en l�sning som g�r det m�jligt att arkivera en webbplats som kr�ver
inloggning (NTLM-baserad autentisering) genom att spara ner en �gonblicksbild med hj�lp av programmet HTTrack.



L�sningen best�r av 3 delar:
- Ett script (HTMLarchiver) som hanterar vilka webbplatser som ska sparas ner, och till viss del hur detta ska g�ras.
- En NTLM-proxy (cntlm), som m�jligg�r autentisering.
- Programmet HTTrack, som anv�nds f�r att g�ra HTML-dumpar.


Upphosvman till scriptet HTMLarchiver �r Bj�rn Rengerstam (bjorn.rengerstam@akademiska.se)
Detta dokument �r skapat av Gustav Malmstr�m (gustav.malmstrom@uppsala.se)




HTMLarchiver
-------------

HTMLarchiver �r ett script (BAT-fil) som startar en arkivering med givna parametrar. HTMLarchiver har en konfigurationsfil med relativt mycket kommentarer kring konfigurationsalternativen som finns. 
Scriptet skapades f�r att kunna anv�ndas med standardv�rden. Det som beh�ver anges i konfigurationsfilen �r lagringsplatsen f�r dumparna, enligt exemplet nedan:

storage=C:\Temp\Webbarkivering


Ytterligare information om scriptet finns i README.txt i samma katalog.




cntlm (NTLM-proxy)
-------------------
Programmet cntlm (http://sourceforge.net/projects/cntlm/) anv�nds f�r att komma �t resurser som kr�ver NTLM-inloggning med mjukvara som inte har st�d f�r detta. 
I grundutf�randet �r det t�nkt att ansluta till en proxy som kr�ver NTLM, men man kan �ven konfigurera det som en stand-alone proxy, 
och p� s� s�tt kan man ansluta direkt till en site som kr�ver NTLM-inloggning.

OBS! cntlm m�ste konfigureras s� att det lyssnar p� port 3128 eftersom HTML-archiver idag anv�nder en proxy som f�rv�ntas finnas p� 127.0.0.1:3128. 
Om den porten av n�gon anledning inte kan anv�ndas, kom ih�g att �ndra �ven i HTMLarchiver.

Konfigurationsfilen f�r cntlm (cntlm.ini) b�r se ut s� h�r:

Username *****
Domain   *****
Password *****
Proxy 127.0.0.1:12345
NoProxy *
Listen 3128

Det anv�ndarkonto som anges f�r Username, Domain och Password �r det som arkiveringen kommer att k�ras under s� det kontot m�ste ha tillr�ckliga l�sr�ttigheter f�r det 
inneh�ll som beh�ver arkiveras.

Av s�kerhetssk�l kan det vara l�mpligt att inte spara l�senordet i klartext i konfigurationsfilen. 
Det finns st�d i cntlm f�r att anv�nda en hashad version av l�senordet ist�llet enligt exemplet nedan:

Username	*******
Domain		*******
#Password	...
# NOTE: Use plaintext password only at your own risk
# Use hashes instead. You can use a "cntlm -M" and "cntlm -H"
# command sequence to get the right config for your environment.
# See cntlm man page
# Example secure config shown below.
PassLM          406983BDD903209AE4591916CE0987DB
PassNT          610C690CBAA98CCB93C937773E7A54BA
### Only for user 'testuser', domain 'corp-uk'
PassNTLMv2      8B539ADEF22D89BAD522048F2F8B5586

Se manualen till cntlm f�r mer information.




HTTrack
--------
HTTrack (eller WinHTTrack om det k�rs i Windowsmilj�) �r programmet som skapar sj�lva html-kopian av webbplatsen. Ladda ner fr�n http://www.httrack.com/.
N�gon speciell konfiguration av HTTrack beh�vs egentligen inte. Ett antal filter f�r vad som ska ing� i html-kopian av webbplatsen anges i HTMLarchiver. Se
http://httrack.kauler.com/help/Filters f�r mer information om m�jligheter med filter.


Det som �r viktigt att t�nka p� �r att den katalog HTTrack installeras i ska anges i konfigurationsfilen f�r HTMLarchiver.



Snabbguide
------------
1. Ladda hem och l�gg mappen HTMLarchiver p� l�mpligt st�lle. F�rslagsvis p� en server om arkiveringen ska automatiseras.
2. �ppna HTMLarchiver.conf och ange lagringsplats f�r de arkiverade webbplatserna.
3. �ppna sites.txt och l�gg till de webbplatser som ska arkiveras.
4. Ladda hem cntlm (http://sourceforge.net/projects/cntlm/).
5. Installera cntlm och �ndra i konfigurationsfilen (cntlm.ini) s� att r�tt anv�ndarkonto anv�nds.
6. Ladda hem HTTrack (http://www.httrack.com/).
7. Installera HTTrack och kontrollera att mappen som HTTrack installerats i �r densamma som angetts i HTMLarchiver.conf.
8. Starta cntlm-proxyn (via Startmenyn i Windows eller via kommando-prompt)
9. K�r skriptet HTMLarchiver.
10. Stoppa cntlm-proxyn n�r arkiveringen �r f�rdig.


Fels�kning
------------
HTMLarchiver skapar en loggfil (HTMLarchiver.txt) d�r det loggas var filerna sparas, n�r arkiveringen av respektive webbplats startats och n�r den blev klar. 

F�r fels�kning av cntlm �r det enklast att anv�nda Windows h�ndelselogg eftersom alla fel- och informationsmeddelanden loggas d�r.

HTTrack skapar loggfiler som ligger i den mapp som angetts f�r parametern "temp" i HTMLarchiver.conf. Loggfilerna heter "hts-err.txt" och "hts-log.txt".




