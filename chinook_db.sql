-- Q1- Rock Music Sales over Time
SELECT STRFTIME('%Y',i.InvoiceDate) as Year, g.name, COUNT(i.InvoiceId) as Sales
FROM Invoice i
JOIN InvoiceLine il
ON i.InvoiceId = il.InvoiceId
JOIN track t
ON t.TrackId = il.TrackId
JOIN Genre g
ON t.GenreId = g.GenreId
WHERE g.Name = 'Rock'
GROUP BY 1,2
-- Q2- Most commonly purchased media form
SELECT Name as MediaType, Count(InvoiceId)
FROM(SELECT i.InvoiceId, m.Name
	FROM MediaType m 
	JOIN Track t
	ON t.MediaTypeId = m.MediaTypeId
	JOIN InvoiceLine il
	ON il.TrackId = t.TrackId
	JOIN Invoice i
	ON i.InvoiceId = il.InvoiceId
	GROUP BY i.InvoiceId)
GROUP BY 1
-- Q3- Most Popular Artist in each genre
WITH T1 AS (SELECT g.name as Genre, a.Name as Artist_Name, i.InvoiceId
FROM invoice i
JOIN InvoiceLine il
ON i.InvoiceId = il.InvoiceId
JOIN track t
ON t.TrackId = il.TrackId
JOIN Album aa
ON t.AlbumId = aa.AlbumId
JOIN Artist a
ON aa.ArtistId = a.ArtistId
JOIN Genre g
ON t.GenreId = g.GenreId
GROUP BY i.InvoiceId),

t2 AS (SELECT Genre, Artist_Name, COUNT(InvoiceID) AS Purchases
FROM t1
GROUP BY 1,2)

SELECT Genre, Artist_Name, max(Purchases) as Purchases
FROM t2
GROUP BY 1
ORDER BY 3 DESC
LIMIT 12;
-- Q4- Most Popular Genre in Each Country 
WITH t1 AS (SELECT g.*,c.Country, COUNT(i.InvoiceId) as Purchases
	FROM Invoice i
	JOIN InvoiceLine il
	ON i.InvoiceId = il.InvoiceId
	JOIN track t
	ON t.TrackId = il.TrackId
	JOIN Genre g
	ON t.GenreId=g.GenreId
	JOIN customer c
	ON c.CustomerId = i.CustomerId
	GROUP BY 1,2,3
	ORDER BY 4 DESC)
SELECT t1.* 
FROM t1
JOIN (SELECT max(Purchases) as Purchases, GenreId,Name,Country
	  FROM t1
	  GROUP BY Country) t2
on t1.Country = t2.Country	
WHERE t1.Purchases = t2.Purchases  

/* Rock Music Fans */
SELECT c.Email, c.FirstName, c.LastName, g.Name
FROM Customer c
JOIN Invoice i
ON i.CustomerId = c.CustomerId
JOIN InvoiceLine il
ON i.InvoiceId = il.InvoiceId
JOIN Track t
ON il.TrackId = t.TrackId
JOIN Genre g
ON t.GenreId = g.GenreId
WHERE g.name = 'Rock'
GROUP BY c.Email
ORDER BY c.Email;

/* Who is writing the rock music? */
SELECT a.Name as Artist_Name, COUNT(t.TrackId)
FROM Artist a
JOIN Album aa
ON a.ArtistId = aa.ArtistId
JOIN Track t
ON t.AlbumId = aa.AlbumId
JOIN Genre g
ON t.GenreId = g.GenreId
WHERE g.name = 'Rock'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- artist who has earned the most--
SELECT Artist_Name, tot_unitprice * tot_qty
FROM (SELECT a.Name as Artist_Name, SUM(il.UnitPrice) as tot_unitprice , SUM(il.Quantity) as tot_qty
		FROM Artist a
		JOIN Album aa
		ON a.ArtistId = aa.ArtistId
		JOIN Track t
		ON t.AlbumId = aa.AlbumId
		JOIN InvoiceLine il
		ON il.TrackId = t.TrackId
		GROUP BY 1)
ORDER BY 2 DESC
LIMIT 5;
-- Top Purchaser--
SELECT CustomerId,FirstName,LastName,Name as artist_name, SUM(total) as amt_spent
FROM(SELECT c.CustomerId,c.FirstName, c.LastName,aa.name, i.total
	FROM Customer c
	JOIN Invoice i
	ON c.CustomerId = i.CustomerId
	JOIN InvoiceLine il
	ON il.InvoiceId = i.InvoiceId
	JOIN Track t
	ON il.TrackId = t.TrackId
	JOIN Album a
	ON t.AlbumId = a.AlbumId
	JOIN artist aa
	ON a.ArtistId = aa.ArtistId
	GROUP BY i.InvoiceId
	ORDER BY 5 DESC) t1
JOIN(SELECT Artist_name 
						FROM(SELECT Artist_Name, tot_unitprice * tot_qty
							FROM (SELECT a.Name as Artist_Name, SUM(il.UnitPrice) as tot_unitprice , SUM(il.Quantity) as tot_qty
									FROM Artist a
									JOIN Album aa
									ON a.ArtistId = aa.ArtistId
									JOIN Track t
									ON t.AlbumId = aa.AlbumId
									JOIN InvoiceLine il
									ON il.TrackId = t.TrackId
									GROUP BY 1)t2
							ORDER BY 2 DESC
							LIMIT 1)t3) t4
ON t1.Name = t4.Artist_Name
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-- most popular music Genre for each country--
WITH t1 AS (SELECT g.*,c.Country, COUNT(i.InvoiceId) as Purchases
	FROM Invoice i
	JOIN InvoiceLine il
	ON i.InvoiceId = il.InvoiceId
	JOIN track t
	ON t.TrackId = il.TrackId
	JOIN Genre g
	ON t.GenreId=g.GenreId
	JOIN customer c
	ON c.CustomerId = i.CustomerId
	GROUP BY 1,2,3
	ORDER BY 4 DESC)
SELECT t1.* 
FROM t1
JOIN (SELECT GenreId,Name,Country,max(Purchases) as Purchases
	  FROM t1
	  GROUP BY Country) t2
on t1.Country = t2.Country	
WHERE t1.Purchases = t2.Purchases  

--track names that have a song length longer than the average song length.--
SELECT t.Name, t.Milliseconds
FROM track t
WHERE t.Milliseconds > (SELECT AVG(Milliseconds)
						FROM track)
ORDER BY 2 DESC						

-- customer that spent the most on music in each country--
WITH t1 AS(SELECT c.Country,c.FirstName, c.LastName,c.CustomerId, i.total
		FROM Invoice i
		JOIN InvoiceLine il
		ON i.InvoiceId = il.InvoiceId
		JOIN track t
		ON t.TrackId = il.TrackId
		JOIN Genre g
		ON t.GenreId=g.GenreId
		JOIN customer c
		ON c.CustomerId = i.CustomerId
		GROUP BY i.InvoiceId
		ORDER BY 2),
t2 AS(SELECT Country,FirstName, LastName,CustomerId,SUM(TOTAL) as TotalSpent
		FROM t1
		GROUP BY CustomerId)

SELECT *
FROM t2
JOIN(SELECT Country,FirstName, LastName,CustomerId, max(TotalSpent) as TotalSpent
	  FROM t2
	  GROUP BY Country)t3
ON t2.Country= t3.Country
WHERE t2.TotalSpent= t3.TotalSpent
ORDER BY Country, FirstName,LastName

