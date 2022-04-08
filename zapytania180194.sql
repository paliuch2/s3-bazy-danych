-- 1) Lista wszystkich trenerów trenuj¹cych w rodzimych klubach, wraz z podaniem ich daty urodzenia, nazwy klubu, pochodzenia i typu licencji.

CREATE VIEW TrenerzyWRodzimychKlubach
	AS SELECT O.Imie, O.Nazwisko, O.DataUrodzenia, K.Nazwa AS Pañstwo, T.Klub, T.TypLicencji
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

-- 2) Zsumowanie liczby obiektów danego typu, bêd¹cych w u¿ytku i znajduj¹cych siê w Niemczech sortowanie wg malej¹cej iloœci obiektów).

SELECT TypObiektu, COUNT (*) AS LiczbaObiektow
	FROM OBIEKTY_SPORTOWE		
		WHERE Miasto IN
			(SELECT Nazwa FROM MIASTA
				WHERE Kraj = 'GER')
		AND CzyWUzytku = 1
	GROUP BY TypObiektu
	ORDER BY LiczbaObiektow DESC

--	3) Zestawienie wszystkich aktywnych zawodników (imie, nazwisko, kraj klub) z niemieckich klubów sportowych, 
--	którzy w 2020 roku osi¹gnêli jakikolwiek zarobek za uzyskane wyniki.

SELECT DISTINCT O.Imie, O.Nazwisko, O.Kraj, Z.Klub -- select distinct, aby zawodnicy nie powtarzali siê.
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
	

--  4) Zestawienie liczby zdobytych punktów przez zawodników danego klubu w Pucharach Œwiata w danej dyscyplinie w latach 2018-2020.
--  Wyniki nale¿y u³o¿yæ wg dyscypliny, a nastêpnie wg malej¹cej liczby punktów.

SELECT Z.Klub, ZA.Dyscyplina AS Dyscyplina, SUM (W.ZdobytePunkty) AS Punkty
	FROM ZAWODNICY Z
		JOIN WYNIKI W
			ON Z.id = W.FK_id_Zawodnika
		JOIN ZAWODY ZA
			ON W.FK_id_Zawodow = ZA.id
	WHERE ZA.DataZawodow >= '2018-01-01' 
		AND ZA.DataZawodow <= '2020-12-31'
		AND ZA.RangaZawodow = 'Puchar Œwiata'
	GROUP BY Z.Klub, ZA.Dyscyplina
	ORDER BY ZA.Dyscyplina, Punkty DESC

-- 5) Podaj wyniki norweskich biathlonistów na zawodach w Szwecji. Zawarta ma byæ informacja o dyscyplinie i mieœcie rozgrywania zawodów.
--	Pouk³adaæ wyniki wg chronologicznej kolejnoœci odbywania siê zawodów.

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

-- 6) Sporz¹dzenie tabeli z wynikami zawodów "FIS Ski Jumping Planica 2019" z dnia 20.03.2019 dla gazety 
--   (podaæ miejsce, nazwiska i imiona zawodnikow, kraj i rezultat).

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
	

-- 7) Podliczenie, ilu zawodników z danego kraju wyst¹pi³o w zawodach pod egid¹ FIS-u w 2019 roku.

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

-- 8) Podanie listy zawodów odbytych w 2019 roku w Norwegii (Data, Godzina, Nazwa, Miasto). Podsumowanie wydatki poniesione na nagrody dla ka¿dych zawodów z osobna.


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

	
-- 9) Zestawienie czo³owej szóstki klasyfikacji generalnej Pucharu Œwiata w skokach narciarskich mê¿czyzn w sezonie 2018/19 (przedzia³ dat: listopad '18 - marzec '19)


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
				AND RangaZawodow = 'Puchar Œwiata'
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