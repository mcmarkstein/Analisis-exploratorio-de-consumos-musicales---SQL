--TOP 3 DE NOMBRES DE ARTISTAS POR GENERO CON MAS PLAYLISTS
WITH RankedArtists AS (
    SELECT
        G.name AS Genre,
        A.name AS Artist,
        ROW_NUMBER() OVER (PARTITION BY G.genreid ORDER BY PlaylistCount DESC) AS Position,
        PlaylistCount
    FROM (
        SELECT
            G.genreid,
            A.artistid,
            COUNT(DISTINCT PT.playlistid) AS PlaylistCount
        FROM Genre AS G
        JOIN Track AS T 
      		ON G.genreid = T.genreid
        JOIN Album AS AL 
      		ON T.albumid = AL.albumid
        JOIN Artist AS A 
      		ON AL.artistid = A.artistid
        JOIN Playlisttrack AS PT 
      		ON T.trackid = PT.trackid
        GROUP BY G.genreid, A.artistid
    ) AS GenreArtistPlaylistCounts
    JOIN Genre AS G 
  		ON GenreArtistPlaylistCounts.genreid = G.genreid
    JOIN Artist AS A 
  		ON GenreArtistPlaylistCounts.artistid = A.artistid
)
SELECT
    Genre,
    Artist,
    Position,
    PlaylistCount
FROM RankedArtists
WHERE Position <= 3
ORDER BY Genre, Position;

-- Mostrar el top 10 de clientes que han comprado al menos una canción en cinco géneros de música diferentes 
SELECT
    C.customerid AS CustomerID,
    C.firstname || ' ' || C.lastname AS CustomerName,
    COUNT(DISTINCT G.genreid) AS DistinctGenresBought
FROM Customer as C
JOIN Invoice as I 
	ON C.customerid = I.customerid
JOIN InvoiceLine IL 
	ON I.invoiceid = IL.invoiceid
JOIN Track as T 
	ON IL.trackid = T.trackid
JOIN Genre as G 
	ON T.genreid = G.genreid
GROUP BY C.customerid, CustomerName
HAVING COUNT(DISTINCT G.genreid) >= 5
ORDER BY DistinctGenresBought DESC
LIMIT 10;

--  Los géneros musicales que generaron más ingresos, clasificando a aquellos con 
-- ingresos superiores a la media general como "Rentables" y los demás como "No Tan Rentables".
SELECT
    G.name AS Genre,
    ROUND(SUM(IL.unitprice * IL.quantity), 2) AS TotalRevenue,
    CASE WHEN SUM(IL.unitprice * IL.quantity) > AVG(SUM(IL.unitprice * IL.quantity)) OVER () THEN 'Rentable' 
    	ELSE 'No Tan Rentable' END AS GenreStatus
FROM Genre as G
JOIN Track as T 
	ON G.genreid = T.genreid
JOIN InvoiceLine IL 
	ON T.trackid = IL.trackid
GROUP BY G.name
ORDER BY TotalRevenue DESC;






