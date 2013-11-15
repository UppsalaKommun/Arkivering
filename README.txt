############################################################
## Arkivering av webbplats med NTLM-baserad autentisering
############################################################



Det här dokumentet beskriver en lösning som gör det möjligt att arkivera en webbplats som kräver
inloggning (NTLM-baserad autentisering) genom att spara ner en ögonblicksbild med hjälp av programmet HTTrack.



Lösningen består av 3 delar:
- Ett script (HTMLarchiver) som hanterar vilka webbplatser som ska sparas ner, och till viss del hur detta ska göras.
- En NTLM-proxy (cntlm), som möjliggör autentisering.
- Programmet HTTrack, som används för att göra HTML-dumpar.


Upphosvman till scriptet HTMLarchiver är Björn Rengerstam (bjorn.rengerstam@akademiska.se)
Detta dokument är skapat av Gustav Malmström (gustav.malmstrom@uppsala.se)




HTMLarchiver
-------------

HTMLarchiver är ett script (BAT-fil) som startar en arkivering med givna parametrar. HTMLarchiver har en konfigurationsfil med relativt mycket kommentarer kring konfigurationsalternativen som finns. 
Scriptet skapades för att kunna användas med standardvärden. Det som behöver anges i konfigurationsfilen är lagringsplatsen för dumparna, enligt exemplet nedan:

storage=C:\Temp\Webbarkivering


Ytterligare information om scriptet finns i README.txt i samma katalog.




cntlm (NTLM-proxy)
-------------------
Programmet cntlm (http://sourceforge.net/projects/cntlm/) används för att komma åt resurser som kräver NTLM-inloggning med mjukvara som inte har stöd för detta. 
I grundutförandet är det tänkt att ansluta till en proxy som kräver NTLM, men man kan även konfigurera det som en stand-alone proxy, 
och på så sätt kan man ansluta direkt till en site som kräver NTLM-inloggning.

OBS! cntlm måste konfigureras så att det lyssnar på port 3128 eftersom HTML-archiver idag använder en proxy som förväntas finnas på 127.0.0.1:3128. 
Om den porten av någon anledning inte kan användas, kom ihåg att ändra även i HTMLarchiver.

Konfigurationsfilen för cntlm (cntlm.ini) bör se ut så här:

Username *****
Domain   *****
Password *****
Proxy 127.0.0.1:12345
NoProxy *
Listen 3128

Det användarkonto som anges för Username, Domain och Password är det som arkiveringen kommer att köras under så det kontot måste ha tillräckliga läsrättigheter för det 
innehåll som behöver arkiveras.

Av säkerhetsskäl kan det vara lämpligt att inte spara lösenordet i klartext i konfigurationsfilen. 
Det finns stöd i cntlm för att använda en hashad version av lösenordet istället enligt exemplet nedan:

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

Se manualen till cntlm för mer information.




HTTrack
--------
HTTrack (eller WinHTTrack om det körs i Windowsmiljö) är programmet som skapar själva html-kopian av webbplatsen. Ladda ner från http://www.httrack.com/.
Någon speciell konfiguration av HTTrack behövs egentligen inte. Ett antal filter för vad som ska ingå i html-kopian av webbplatsen anges i HTMLarchiver. Se
http://httrack.kauler.com/help/Filters för mer information om möjligheter med filter.


Det som är viktigt att tänka på är att den katalog HTTrack installeras i ska anges i konfigurationsfilen för HTMLarchiver.



Snabbguide
------------
1. Ladda hem och lägg mappen HTMLarchiver på lämpligt ställe. Förslagsvis på en server om arkiveringen ska automatiseras.
2. Öppna HTMLarchiver.conf och ange lagringsplats för de arkiverade webbplatserna.
3. Öppna sites.txt och lägg till de webbplatser som ska arkiveras.
4. Ladda hem cntlm (http://sourceforge.net/projects/cntlm/).
5. Installera cntlm och ändra i konfigurationsfilen (cntlm.ini) så att rätt användarkonto används.
6. Ladda hem HTTrack (http://www.httrack.com/).
7. Installera HTTrack och kontrollera att mappen som HTTrack installerats i är densamma som angetts i HTMLarchiver.conf.
8. Starta cntlm-proxyn (via Startmenyn i Windows eller via kommando-prompt)
9. Kör skriptet HTMLarchiver.
10. Stoppa cntlm-proxyn när arkiveringen är färdig.


Felsökning
------------
HTMLarchiver skapar en loggfil (HTMLarchiver.txt) där det loggas var filerna sparas, när arkiveringen av respektive webbplats startats och när den blev klar. 

För felsökning av cntlm är det enklast att använda Windows händelselogg eftersom alla fel- och informationsmeddelanden loggas där.

HTTrack skapar loggfiler som ligger i den mapp som angetts för parametern "temp" i HTMLarchiver.conf. Loggfilerna heter "hts-err.txt" och "hts-log.txt".




