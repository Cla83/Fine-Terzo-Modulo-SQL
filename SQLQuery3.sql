CREATE DATABASE Toys

USE Toys

CREATE TABLE ProductCategory (
CategoryID INT,
CategoryName VARCHAR (25)
CONSTRAINT PK_CategoryID PRIMARY KEY (CategoryID)
);

INSERT INTO ProductCategory (CategoryID, CategoryName)
VALUES (1, 'Toys'), (2, 'Video Games'), (3, 'Puzzle'), (4, 'Accessories')

CREATE TABLE Stato (
StateID INT,
StateName VARCHAR (25),
RegionID INT,
CONSTRAINT PK_StateID PRIMARY KEY (StateID),
CONSTRAINT Fk_RegionID FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
);

INSERT INTO Stato (StateID, StateName, RegionID)
VALUES
(1, 'Italy', 2),
(2, 'Alabama', 4),
(3, 'France', 1),
(4, 'Sweden', 1),
(5, 'Brasil', 6),
(6, 'China', 7),
(7, 'Denmark', 1),
(8, 'Mexico', 5),
(9, 'India', 8),
(10, 'Chile', 6),
(11, 'Venezuela', 6);


CREATE TABLE Product (
ProductID INT,
ProductName VARCHAR (25),
CategoryID INT,
Listprice DECIMAL (10,2),
CONSTRAINT PK_ProductID PRIMARY KEY (ProductID),
CONSTRAINT FK_CategoryID FOREIGN KEY (CategoryID) REFERENCES ProductCategory(CategoryID)
);

INSERT INTO Product (ProductID, ProductName, CategoryID, Listprice)
VALUES
(1, 'Barbie', 1, 100.00),
(2, 'Nintendo', 2, 250.00),
(3, 'Playstation', 2, 300.00),
(4, 'Toy Story', 1, 22.00),
(5, 'Lego', 3, 90.00),
(6, 'Cable', 4, 15.00);

CREATE TABLE Region (
RegionID INT,
RegionName VARCHAR (25),
CONSTRAINT Pk_RegionID PRIMARY KEY (RegionID),
);

INSERT INTO Region (RegionID, RegionName)
VALUES
(1, 'NorthEurope'), 
(2, 'SouthEurope'),
(3, 'WestEurope'),
(4, 'NorthAmerica'),
(5, 'CentralAmerica'),
(6, 'SouthAmerica'),
(7, 'EastAsia'),
(8, 'SouthAsia');

CREATE TABLE Categoria (
CategoriaID INT,
CategoriaName VARCHAR (25),
CONSTRAINT Pk_CategoriaID PRIMARY KEY (CategoriaID),
);

INSERT INTO Categoria (CategoriaID, CategoriaName)
VALUES
(1, 'Bambole'), 
(2, 'Video Games'),
(3, 'Puzzle'),
(4, 'Accessories'),
(5, 'Macchine');

CREATE TABLE Sales (
SalesID INT,
SalesLine INT,
Quantity INT,
OrderDate DATE,
SalesAmount DECIMAL (10,2),
ProductID INT,
StateID INT,
CONSTRAINT PK_SalesID PRIMARY KEY (SalesID),
CONSTRAINT FK_ProductID FOREIGN KEY (ProductID) REFERENCES Product (ProductID),
CONSTRAINT FK_StatesID_Sales FOREIGN KEY (StateId) REFERENCES Stato(StateID)
);

INSERT INTO Sales (SalesID, SalesLine, Quantity, OrderDate, SalesAmount, ProductID, StateID)
VALUES
(2, 4, 30, '2023-07-18', 7500.00, 2, 3),
(3, 5, 15, '2023-02-14', 4500.00, 3, 8),
(4, 6, 80, '2023-04-21', 1760.00, 4, 5),
(5, 7, 50, '2022-10-18', 4500.00, 5, 11),
(6, 8, 92, '2022-09-08', 1380.00, 6, 7),
(7, 7, 50, '2021-05-07', 4500.00, 5, 3);


--1)	Verificare che i campi definiti come PK siano univoci....


SELECT COUNT (*), ProductID
FROM Product
GROUP BY ProductID
HAVING COUNT(*) > 1

SELECT COUNT (*), StateID
FROM Stato
GROUP BY StateID
HAVING COUNT (*) > 1

SELECT COUNT (*), SalesID
FROM Sales
GROUP BY SalesID
HAVING COUNT (*) > 1

ALTER TABLE Sales ADD RegionID INT CONSTRAINT FK_Sales FOREIGN KEY (RegionID) REFERENCES Region (RegionID)

UPDATE Sales SET RegionID = 1 WHERE SalesID = 1 
UPDATE Sales SET RegionID = 1 WHERE SalesID = 3 
UPDATE Sales SET RegionID = 1 WHERE SalesID = 7 
UPDATE Sales SET RegionID = 1 WHERE SalesID = 9 
UPDATE Sales SET RegionID = 6 WHERE SalesID = 5 
UPDATE Sales SET RegionID = 3 WHERE SalesID = 6



--2)	Esporre l’elenco delle transazioni indicando nel result set il codice documento, la data,.... 

SELECT s.SalesID, s.OrderDate, p.ProductName, s.StateID, r.RegionName, 
CASE WHEN DATEDIFF(day, s.OrderDate, GETDATE()) >180 THEN 'true' 
     WHEN DATEDIFF(day, s.OrderDate, GETDATE()) <=180 THEN 'false'
END  
FROM Sales as s
INNER JOIN Product as p
ON s.ProductID = p.ProductID
INNER JOIN Region as r
ON s.RegionID = r.RegionID

--3)	Esporre l’elenco dei soli prodotti venduti e per ognuno di questi il fatturato totale per anno

SELECT p.ProductName, YEAR(s.OrderDate), SUM(s.SalesAmount) 
FROM Sales as s
INNER JOIN Product as p
ON s.ProductID = p.ProductID
GROUP BY p.ProductName, s.OrderDate



--	4)	Esporre il fatturato totale per stato per anno. Ordina il risultato per data e per fatturato decrescente

SELECT p.ProductName, st.StateName, YEAR(s.OrderDate) AS Anno, SUM(s.SalesAmount) AS Totale
FROM Sales as s
INNER JOIN Product as p 
ON s.ProductID = p.ProductID
INNER JOIN Stato as st 
ON s.RegionID = st.RegionID
GROUP BY p.ProductName, st.StateName, s.OrderDate
ORDER BY YEAR(s.OrderDate) ASC, SUM(s.SalesAmount) DESC;


--5)	Rispondere alla seguente domanda: qual è la categoria di articoli maggiormente richiesta dal mercato?

SELECT *
FROM Sales

SELECT *
FROM Categoria

  
SELECT c.CategoriaName AS categoria, SUM(v.SalesAmount) AS vendite
FROM Categoria AS c
INNER JOIN Product AS p
ON p.CategoryID = c.CategoriaID
INNER JOIN Sales AS v
ON p.ProductID = v.ProductID
GROUP BY c.CategoriaName, v.SalesAmount
ORDER BY vendite DESC

  
SELECT c.CategoriaName AS categoria, SUM(v.SalesAmount) AS vendite
FROM Categoria AS c
INNER JOIN Product AS p
ON p.CategoryID = c.CategoriaID
INNER JOIN Sales AS v
ON p.ProductID = v.ProductID
GROUP BY c.CategoriaName
ORDER BY SUM(v.SalesAmount) DESC


--6)	Rispondere alla seguente domanda: quali sono, se ci sono, i prodotti invenduti? Proponi due approcci 

SELECT *
FROM Product

SELECT p.ProductID, p.ProductName
FROM Product AS p
LEFT JOIN Sales AS v
ON p.ProductID = v.ProductID
WHERE v.ProductID IS NULL

-- Oppure

SELECT ProductID, ProductName
FROM Product
WHERE ProductID NOT IN (SELECT DISTINCT ProductID FROM Sales);


--7)	Esporre l’elenco dei prodotti cona la rispettiva ultima data di vendita (la data di vendita più recente).

SELECT TOP 6 p.ProductName, v.OrderDate
FROM Product AS p
INNER JOIN Sales AS v
ON p.ProductID = v.ProductID
ORDER BY v.OrderDate DESC


--8)	Creare una vista sui prodotti in modo tale da esporre una “versione denormalizzata” delle informazioni utili (cod. prodotto,nome prod, nome categoria)

SELECT *
FROM Product


CREATE VIEW VProduct AS (
SELECT p.ProductID AS ProductID, p.ProductName AS ProductName, c.CategoriaID AS CategoryName 
FROM Product AS p
INNER JOIN Categoria AS c
ON p.CategoryID = c.CategoriaID
);



--9)	Creare una vista per restituire una versione “denormalizzata” delle informazioni geografiche

SELECT *
FROM Region

SELECT *
FROM Stato
     
CREATE VIEW VRegion AS (
SELECT r.RegionID AS RegionID, r.RegionName AS Region, s.StateName AS Stato
FROM Region as r
INNER JOIN Stato as s
ON r.RegionID = s.RegionID
);





