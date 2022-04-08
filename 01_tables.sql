create function czy_poprawne_znaki(@string varchar(50))
returns bit as
begin
	declare @result bit = 0
	if @string LIKE REPLICATE ('[A-Z -]', LEN(@string))
		set @result = 1
	return @result
end
go

create function czy_poprawne_nazwisko(@string varchar(50))
returns bit as
begin
	declare @result bit = 0
	if @string LIKE REPLICATE('[A-Z-]', LEN(@string))
		set @result = 1
	return @result
end
go


CREATE TABLE KRAJE (

		Nazwa VARCHAR(32) UNIQUE NOT NULL,
		TrzyLiterowySkrot VARCHAR(3) CHECK (TrzyLiterowySkrot LIKE '[A-Z][A-Z][A-Z]') PRIMARY KEY NOT NULL,

);

CREATE TABLE MIASTA (

		Nazwa VARCHAR(30) PRIMARY KEY CHECK (dbo.czy_poprawne_znaki(Nazwa) = 1) NOT NULL,
		Kraj VARCHAR(3) REFERENCES KRAJE ON UPDATE CASCADE NOT NULL,
		
);

CREATE TABLE OSOBY (

		id INT IDENTITY(1,1) CHECK (id >0 AND id < 1000000) PRIMARY KEY NOT NULL, 
		Nazwisko VARCHAR(35) NOT NULL CHECK (dbo.czy_poprawne_nazwisko(Nazwisko) = 1) ,
		Imie VARCHAR(30) NOT NULL CHECK (dbo.czy_poprawne_znaki(Imie) = 1),
		Plec CHAR CHECK (Plec = 'K' OR Plec = 'M') NOT NULL,
		DataUrodzenia  DATE NOT NULL,
		Kraj VARCHAR(3) REFERENCES KRAJE ON UPDATE CASCADE NOT NULL,

);


CREATE TABLE KLUBY_SPORTOWE (

		Nazwa VARCHAR(40) PRIMARY KEY NOT NULL,
		RokZalozenia INT CHECK (RokZalozenia > 1800 AND RokZalozenia < 2100),
		Miasto VARCHAR(30) REFERENCES MIASTA ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,

);

CREATE TABLE DYSCYPLINY (

		Nazwa VARCHAR(30) PRIMARY KEY NOT NULL,
		OrganZarzadzajacy VARCHAR(20),

);

CREATE TABLE ZAWODNICY (

		id INT REFERENCES OSOBY ON DELETE CASCADE PRIMARY KEY,
		Kadra CHAR CHECK (Kadra LIKE '[A-Z]') NOT NULL,
		CzyAktywny BIT NOT NULL,
		RokDebiutu INT,
		Klub VARCHAR(40) REFERENCES KLUBY_SPORTOWE ON UPDATE CASCADE ON DELETE SET NULL,
		Dyscyplina VARCHAR(30) REFERENCES DYSCYPLINY ON DELETE SET NULL,

);

CREATE TABLE TRENERZY (
		
		id INT REFERENCES OSOBY  ON DELETE CASCADE PRIMARY KEY,
		RokUzyskaniaLicencji INT NOT NULL,
		TypLicencji CHAR CHECK (TypLicencji LIKE '[A-Z]') NOT NULL,
		DataWaznosciLicencji DATE,
		Klub VARCHAR(40) REFERENCES KLUBY_SPORTOWE ON UPDATE CASCADE ON DELETE SET NULL,

);


CREATE TABLE OBIEKTY_SPORTOWE (

	NazwaObiektu VARCHAR(35) NOT NULL PRIMARY KEY ,
	TypObiektu VARCHAR(25) NOT NULL,
	CzyWUzytku BIT DEFAULT 1 NOT NULL,
	WymiarObiektu VARCHAR(20), 
	Miasto VARCHAR(30) REFERENCES MIASTA ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,

);


CREATE TABLE ZAWODY (

		id INT CHECK (id > 0 AND id < 500000) PRIMARY KEY NOT NULL,
		Nazwa VARCHAR(50) NOT NULL,
		DataZawodow DATE CHECK (DataZawodow >= '1900-01-01' AND DataZawodow <= '2099-12-31') NOT NULL,
		GodzinaRozpoczecia TIME DEFAULT '12:00' NOT NULL,
		RangaZawodow VARCHAR(30),
		CzyOdbyte BIT DEFAULT 0 NOT NULL,
		Dyscyplina VARCHAR(30) REFERENCES DYSCYPLINY ON DELETE CASCADE NOT NULL,
		Obiekt VARCHAR(35) REFERENCES OBIEKTY_SPORTOWE ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,

);

CREATE TABLE WYNIKI (

		FK_id_Zawodnika INT REFERENCES  ZAWODNICY ON DELETE CASCADE NOT NULL ,
		FK_id_Zawodow INT REFERENCES ZAWODY ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
		Miejsce INT CHECK (Miejsce >= 1 AND Miejsce <= 1000),
		Rezultat VARCHAR(200),
		ZarobekZaZajeteMiejsce FLOAT(2) CHECK (ZarobekZaZajeteMiejsce >= 0.00) DEFAULT 0.00,
		ZdobytePunkty INT CHECK (ZdobytePunkty >= 0) DEFAULT 0,
		PRIMARY KEY (FK_id_Zawodnika, FK_id_Zawodow),
);

go
CREATE TRIGGER uppercase_osoba
ON dbo.OSOBY
AFTER INSERT 
AS 
BEGIN
    UPDATE j
    SET imie = UPPER(SUBSTRING(i.imie, 1, 1)) + SUBSTRING(i.imie, 2, 50),
        nazwisko = UPPER(SUBSTRING(i.nazwisko, 1, 1)) + SUBSTRING(i.nazwisko, 2, 50)
    FROM dbo.OSOBY j
    INNER JOIN Inserted i ON j.id = i.id;
END
GO

CREATE TRIGGER uppercase_kraj
ON dbo.KRAJE
AFTER INSERT 
AS 
BEGIN
    UPDATE j
    SET nazwa = UPPER(SUBSTRING(i.nazwa, 1, 1)) + SUBSTRING(i.nazwa, 2, 50)
    FROM dbo.KRAJE j
    INNER JOIN Inserted i ON j.nazwa = i.nazwa;
END
GO

CREATE TRIGGER uppercase_skrot
ON dbo.KRAJE
AFTER INSERT 
AS 
BEGIN
    UPDATE j
    SET TrzyLiterowySkrot = UPPER(SUBSTRING(i.TrzyLiterowySkrot, 1, 3))
    FROM dbo.KRAJE j
    INNER JOIN Inserted i ON j.TrzyLiterowySkrot = i.TrzyLiterowySkrot;
END
GO