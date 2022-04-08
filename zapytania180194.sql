-- 1) Lista wszystkich trener�w trenuj�cych w rodzimych klubach, wraz z podaniem ich daty urodzenia, nazwy klubu, pochodzenia i typu licencji.

CREATE VIEW TrenerzyWRodzimychKlubach
	AS SELECT O.Imie, O.Nazwisko, O.DataUrodzenia, K.Nazwa AS Pa�stwo, T.Klub, T.TypLicencji
		FROM TRENERZY T
			JOIN OSOBY O
				ON T.id = O.id 
			JOIN KRAJE K
				ON O.Kraj = K.TrzyLiterowySkrot
		WHERE Klub IN 
			(SELECT Nazwa FROM KLUBY_SPORTOWE
				WHERE KLUBY_SPORTOWE.Miasto IN
					(SELECT Nazwa FROM MIASTA 
						WHERE MIASTA.Kraj = O.Kraj
			))
		WITH CHECK OPTION
			
SELECT *
	FROM TrenerzyWRodzimychKlubach
		
DROP VIEW TrenerzyWRodzimychKlubach

-- 2) Zsumowanie liczby obiekt�w danego typu, b�d�cych w u�ytku i znajduj�cych si� w Niemczech sortowanie wg malej�cej ilo�ci obiekt�w).

SELECT TypObiektu, COUNT (*) AS LiczbaObiektow
	FROM OBIEKTY_SPORTOWE		
		WHERE Miasto IN
			(SELECT Nazwa FROM MIASTA
				WHERE Kraj = 'GER')
		AND CzyWUzytku = 1
	GROUP BY TypObiektu
	ORDER BY LiczbaObiektow DESC

--	3) Zestawienie wszystkich aktywnych zawodnik�w (imie, nazwisko, kraj klub) z niemieckich klub�w sportowych, 
--	kt�rzy w 2020 roku osi�gn�li jakikolwiek zarobek za uzyskane wyniki.

SELECT DISTINCT O.Imie, O.Nazwisko, O.Kraj, Z.Klub -- select distinct, aby zawodnicy nie powtarzali si�.
	FROM OSOBY O
		JOIN ZAWODNICY Z
			ON O.id = Z.id 
		JOIN KLUBY_SPORTOWE KS
			ON Z.Klub = KS.Nazwa
		JOIN MIASTA M
			ON KS.Miasto = M.Nazwa
		JOIN WYNIKI W
			ON Z.id = W.FK_id_Zawodnika
		JOIN ZAWODY ZA
			ON ZA.id = W.FK_id_Zawodow
	WHERE M.Kraj = 'GER'
		AND ZA.DataZawodow > '2020-01-01' 
		AND ZA.DataZawodow < '2020-12-31'
		AND W.ZarobekZaZajeteMiejsce > 0.00
		AND Z.CzyAktywny = 1
	ORDER BY O.Nazwisko, O.Imie	
	

--  4) Zestawienie liczby zdobytych punkt�w przez zawodnik�w danego klubu w Pucharach �wiata w danej dyscyplinie w latach 2018-2020.
--  Wyniki nale�y u�o�y� wg dyscypliny, a nast�pnie wg malej�cej liczby punkt�w.

SELECT Z.Klub, ZA.Dyscyplina AS Dyscyplina, SUM (W.ZdobytePunkty) AS Punkty
	FROM ZAWODNICY Z
		JOIN WYNIKI W
			ON Z.id = W.FK_id_Zawodnika
		JOIN ZAWODY ZA
			ON W.FK_id_Zawodow = ZA.id
	WHERE ZA.DataZawodow >= '2018-01-01' 
		AND ZA.DataZawodow <= '2020-12-31'
		AND ZA.RangaZawodow = 'Puchar �wiata'
	GROUP BY Z.Klub, ZA.Dyscyplina
	ORDER BY ZA.Dyscyplina, Punkty DESC

-- 5) Podaj wyniki norweskich biathlonist�w na zawodach w Szwecji. Zawarta ma by� informacja o dyscyplinie i mie�cie rozgrywania zawod�w.
--	Pouk�ada� wyniki wg chronologicznej kolejno�ci odbywania si� zawod�w.

SELECT O.Imie, O.Nazwisko, Z.Klub, ZA.Dyscyplina, OB.Miasto AS MiastoZawodow, ZA.Nazwa AS NazwaZawodow, ZA.DataZawodow, W.Miejsce, W.Rezultat
	FROM OSOBY O
		JOIN ZAWODNICY Z
			ON O.id = Z.id 
		JOIN WYNIKI W
			ON Z.id = W.FK_id_Zawodnika
		JOIN ZAWODY ZA
			ON W.FK_id_Zawodow = ZA.id
		JOIN OBIEKTY_SPORTOWE OB
			ON OB.NazwaObiektu = ZA.Obiekt
		JOIN MIASTA M
			ON OB.Miasto = M.Nazwa
	WHERE O.Kraj = 'NOR' AND M.Kraj = 'SWE'
		AND ZA.Dyscyplina = 'Biathlon'
	ORDER BY DataZawodow

-- 6) Sporz�dzenie tabeli z wynikami zawod�w "FIS Ski Jumping Planica 2019" z dnia 20.03.2019 dla gazety 
--   (poda� miejsce, nazwiska i imiona zawodnikow, kraj i rezultat).

SELECT W.Miejsce, O.Imie, O.Nazwisko, K.Nazwa AS Panstwo, W.Rezultat
	FROM WYNIKI W
		JOIN OSOBY O
			ON W.FK_id_Zawodnika = O.id
		JOIN KRAJE K
			ON O.Kraj = K.TrzyLiterowySkrot
	WHERE W.FK_id_Zawodow IN
		(SELECT id FROM ZAWODY
			WHERE Nazwa = 'FIS Ski Jumping Planica 2019'
				AND DataZawodow = '2019-03-20')
	ORDER BY W.Miejsce
	

-- 7) Podliczenie, ilu zawodnik�w z danego kraju wyst�pi�o w zawodach pod egid� FIS-u w 2019 roku.

SELECT K.Nazwa, COUNT (*) AS LiczbaZawodnikow
	FROM OSOBY O 
		JOIN KRAJE K
			ON O.Kraj = K.TrzyLiterowySkrot
	WHERE id IN
		( SELECT FK_id_Zawodnika FROM WYNIKI W
			WHERE W.FK_id_Zawodnika = O.id
				AND FK_id_Zawodow IN
					(SELECT id FROM ZAWODY
						WHERE Dyscyplina IN
							(SELECT Nazwa FROM DYSCYPLINY
								WHERE OrganZarzadzajacy = 'FIS'
							)
						AND DataZawodow >= '2019-01-01' 
						AND DataZawodow <= '2019-12-31'
					)
			)
		GROUP BY K.Nazwa
		ORDER BY LiczbaZawodnikow DESC

-- 8) Podanie listy zawod�w odbytych w 2019 roku w Norwegii (Data, Godzina, Nazwa, Miasto). Podsumowanie wydatki poniesione na nagrody dla ka�dych zawod�w z osobna.


SELECT ZA.DataZawodow, ZA.GodzinaRozpoczecia, ZA.Nazwa, ZA.Dyscyplina, OB.Miasto, ROUND (SUM (W.ZarobekZaZajeteMiejsce),2) AS WydatkiNaNagrody
	FROM ZAWODY ZA
		JOIN WYNIKI W
			ON ZA.id = W.FK_id_Zawodow
		JOIN OBIEKTY_SPORTOWE OB
			ON ZA.Obiekt = OB.NazwaObiektu
				WHERE OB.Miasto IN
					(SELECT Nazwa FROM MIASTA M
						WHERE OB.Miasto = M.Nazwa
							AND M.Kraj IN
							(SELECT TrzyLiterowySkrot FROM KRAJE K
								WHERE K.Nazwa = 'Norwegia')
				)	
		AND CzyOdbyte = 1
		AND DataZawodow >= '2019-01-01' 
		AND DataZawodow <= '2019-12-31'
	GROUP BY ZA.Nazwa, ZA.DataZawodow, ZA.GodzinaRozpoczecia, ZA.Dyscyplina, OB.Miasto
	ORDER BY ZA.DataZawodow, ZA.GodzinaRozpoczecia

	
-- 9) Zestawienie czo�owej sz�stki klasyfikacji generalnej Pucharu �wiata w skokach narciarskich m�czyzn w sezonie 2018/19 (przedzia� dat: listopad '18 - marzec '19)


CREATE VIEW KlasyfikacjaSkokiPS AS
	SELECT TOP 6 O.Imie, O.Nazwisko, O.Kraj, SUM (W.ZdobytePunkty) AS Punkty 
		FROM OSOBY O
		JOIN WYNIKI W
			ON O.id = W.FK_id_Zawodnika
		WHERE W.FK_id_Zawodow IN
		 (SELECT id FROM ZAWODY
			 WHERE  DataZawodow >= '2018-11-01' 
				AND DataZawodow <= '2019-03-31'
				AND Dyscyplina = 'Skoki narciarskie'
				AND RangaZawodow = 'Puchar �wiata'
		 )
		 AND O.Plec = 'M'
	GROUP BY O.Imie, O.Nazwisko, O.Kraj
	ORDER BY Punkty DESC
	WITH CHECK OPTION

	SELECT *
	FROM KlasyfikacjaSkokiPS

	DROP VIEW KlasyfikacjaSkokiPS

	
-- 2x VIEW
-- 20x JOIN
-- 10x podzapytania
-- 5x GROUP BY
-- 8x ORDER BY
-- 5x AGREGUJACE