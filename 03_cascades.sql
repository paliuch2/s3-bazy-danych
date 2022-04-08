
UPDATE ZAWODY SET id = 123456 WHERE Nazwa = 'Zakopane FIS Ski Jumping World Cup 2020' AND DataZawodow = '2020-01-19';
UPDATE ZAWODY SET id = 144000 WHERE id = 143842
UPDATE KRAJE SET TrzyLiterowySkrot = 'NED' WHERE Nazwa = 'Holandia';
UPDATE KRAJE SET TrzyLiterowySkrot = 'SVN' WHERE Nazwa = 'S³owenia'; /*aktualizacja skrótu pañstwa*/
UPDATE KLUBY_SPORTOWE SET Nazwa = 'Heming Holmenkollen' WHERE Nazwa = 'Heming'
UPDATE KLUBY_SPORTOWE SET Nazwa = 'NEC Andorra' WHERE Nazwa = 'NEC'
UPDATE KLUBY_SPORTOWE SET Nazwa = 'TSV Garmisch-Partenkirchen' WHERE Nazwa = 'TSV Garmisch'
UPDATE MIASTA SET Nazwa = 'Ruka' WHERE Nazwa = 'Kuusamo' 
UPDATE MIASTA SET Nazwa = 'PyeongChang' WHERE Nazwa = 'Pyeongchang' 
UPDATE OBIEKTY_SPORTOWE SET NazwaObiektu = 'Letalnica' WHERE NazwaObiektu = 'Velikanka'
UPDATE OBIEKTY_SPORTOWE SET NazwaObiektu = 'Bergisel Ski Jump' WHERE NazwaObiektu = 'Bergisel'

DELETE FROM OSOBY WHERE Nazwisko = 'Geiger' AND Imie = 'Karl';
DELETE FROM OSOBY WHERE Nazwisko = 'Boe';
DELETE FROM ZAWODY WHERE id=119310;
DELETE FROM ZAWODY WHERE Obiekt = 'Oslo-Holmenkollen';
DELETE FROM KLUBY_SPORTOWE WHERE Miasto = 'Sapporo' /* tutaj nie bêdzie kaskady, ale bedzie SET NULL zamiast klubu u trenera/zawodnika */
DELETE FROM KLUBY_SPORTOWE WHERE Nazwa = 'Ostersunds BK' /* jak wy¿ej */
DELETE FROM MIASTA WHERE Nazwa = 'Engelberg';
DELETE FROM DYSCYPLINY WHERE Nazwa = '£y¿wiarstwo figurowe' /*usuwa kaskadowo zawody, ustawia null zawodnikom jako dyscpline */
DELETE FROM ZAWODNICY WHERE id = (SELECT id FROM OSOBY WHERE Nazwisko = 'Kalinichenko' AND Imie = 'Vitaliy') /* usuwa zawodnika i kaskadowo jego wyniki, ale osoba zostaje w bazie */
DELETE FROM TRENERZY WHERE id = (SELECT id FROM OSOBY WHERE Nazwisko = 'Felder' AND Imie = 'Andreas') /* usuwa trenera, ale osoba zostaje w bazie */
DELETE FROM OBIEKTY_SPORTOWE WHERE NazwaObiektu = 'Oberstdorf Biathlon Centre'

