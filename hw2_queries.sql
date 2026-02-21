-- Homework 2: EN.601.415 Databases
-- Joanne Li (jli460)

SELECT '--- Question 1: Recent Movies ---';
SELECT Title, Director
FROM Movies
WHERE Year = 2023
ORDER BY Title DESC;

SELECT '--- Question 2: Movies by James ---';
SELECT *
FROM Movies
WHERE (Year > 2022 OR Year < 2000)
  AND Director LIKE '%James%';

SELECT '--- Question 3: Good Years for Movies ---';
SELECT DISTINCT Year
FROM Movies
WHERE MovieID IN (
    SELECT MovieID
    FROM Ratings
    WHERE Stars IN (4, 5)
)
ORDER BY Year ASC;

SELECT '--- Question 4: Easier to Read Ratings ---';
SELECT R.Name AS ReviewerName, M.Title AS MovieTitle, Ra.Stars, Ra.RatingDate
FROM Ratings Ra
JOIN Reviewers R ON Ra.ReviewerID = R.ReviewerID
JOIN Movies M ON Ra.MovieID = M.MovieID
ORDER BY R.Name, M.Title, Ra.Stars;

SELECT '--- Question 5: Movies with Poor Coverage ---';
SELECT Title
FROM Movies
WHERE MovieID NOT IN (
    SELECT MovieID
    FROM Ratings
);

SELECT '--- Question 6: Harshest Ratings ---';
SELECT Ra.ReviewerID, R.Name, Ra.MovieID, M.Title, Ra.Stars
FROM Ratings Ra
JOIN Reviewers R ON Ra.ReviewerID = R.ReviewerID
JOIN Movies M ON Ra.MovieID = M.MovieID
WHERE Ra.Stars = (SELECT MIN(Stars) FROM Ratings);

SELECT '--- Question 7: Best Ratings per Movie ---';
SELECT MovieID, MAX(Stars) AS HighestStars
FROM Ratings
GROUP BY MovieID;

SELECT '--- Question 8: Keep the Best, Ignore the Rest ---';
SELECT M.Title, MAX(Ra.Stars) AS HighestStars
FROM Movies M
JOIN Ratings Ra ON M.MovieID = Ra.MovieID
GROUP BY M.MovieID, M.Title
ORDER BY M.Title ASC;

SELECT '--- Question 9: Power Users ---';
SELECT R.Name, COUNT(*) AS TotalReviews
FROM Ratings Ra
JOIN Reviewers R ON Ra.ReviewerID = R.ReviewerID
GROUP BY Ra.ReviewerID, R.Name
HAVING COUNT(*) >= 3;

SELECT '--- Question 10: Real Power Users ---';
SELECT R.ReviewerID, R.Name
FROM Reviewers R
WHERE NOT EXISTS (
    SELECT M.MovieID
    FROM Movies M
    WHERE NOT EXISTS (
        SELECT 1
        FROM Ratings Ra
        WHERE Ra.ReviewerID = R.ReviewerID
          AND Ra.MovieID = M.MovieID
    )
);

SELECT '--- Question 11: What to Watch ---';
SELECT M.Title
FROM Movies M
WHERE M.MovieID NOT IN (
    SELECT Ra.MovieID
    FROM Ratings Ra
    JOIN Reviewers R ON Ra.ReviewerID = R.ReviewerID
    WHERE R.Name = 'Chris Jackson'
);

SELECT '--- Question 12: Actor Directors ---';
SELECT DISTINCT P.Name
FROM People P
JOIN Actors_Movies AM ON P.PersonID = AM.ActorID
JOIN Movies M ON AM.MovieID = M.MovieID
WHERE M.Director = P.Name;

SELECT '--- Question 13: Actor, Director, Reviewer ---';
SELECT DISTINCT R.ReviewerID, R.Name
FROM Reviewers R
JOIN People P ON R.Name = P.Name
JOIN Actors_Movies AM ON P.PersonID = AM.ActorID
JOIN Movies M ON M.Director = P.Name;

SELECT '--- Question 14: Conflicts of Interest ---';
SELECT DISTINCT R.ReviewerID, R.Name
FROM Reviewers R
JOIN People P ON R.Name = P.Name
JOIN Actors_Movies AM ON P.PersonID = AM.ActorID
JOIN Ratings Ra ON R.ReviewerID = Ra.ReviewerID
  AND AM.MovieID = Ra.MovieID;

SELECT '--- Question 15: Only Good Directors ---';
SELECT DISTINCT Director
FROM Movies
WHERE Director NOT IN (
    SELECT DISTINCT M.Director
    FROM Movies M
    JOIN Ratings Ra ON M.MovieID = Ra.MovieID
    WHERE Ra.Stars < 4
);

SELECT '--- Question 16: No Rating Actors and Movies ---';
SELECT DISTINCT P.Name, AM.Role, M.Title
FROM Actors_Movies AM
JOIN People P ON AM.ActorID = P.PersonID
JOIN Movies M ON AM.MovieID = M.MovieID
WHERE M.MovieID NOT IN (
    SELECT MovieID FROM Ratings
);

SELECT '--- Question 17: Movie with Highest Average Rating ---';
SELECT M.Title, AVG(Ra.Stars) AS AvgRating
FROM Movies M
JOIN Ratings Ra ON M.MovieID = Ra.MovieID
GROUP BY M.MovieID, M.Title
HAVING AVG(Ra.Stars) = (
    SELECT MAX(AvgStars)
    FROM (
        SELECT AVG(Stars) AS AvgStars
        FROM Ratings
        GROUP BY MovieID
    ) AS Averages
);

SELECT '--- Question 18: Chris Reviews ---';
SELECT M.MovieID, M.Title, COUNT(*) AS NumReviews
FROM Movies M
JOIN Ratings Ra ON M.MovieID = Ra.MovieID
JOIN Reviewers R ON Ra.ReviewerID = R.ReviewerID
WHERE R.Name LIKE '%Chris%'
GROUP BY M.MovieID, M.Title;

SELECT '--- Question 19: Top Rated Movies ---';
SELECT M.Title, M.Year, M.Director
FROM Movies M
JOIN Ratings Ra ON M.MovieID = Ra.MovieID
GROUP BY M.MovieID, M.Title, M.Year, M.Director
HAVING AVG(Ra.Stars) = (
    SELECT MAX(AvgStars)
    FROM (
        SELECT AVG(Stars) AS AvgStars
        FROM Ratings
        GROUP BY MovieID
    ) AS Averages
);

SELECT '--- Question 20: Frequent Collaborations ---';
SELECT AM.ActorID, P.Name AS ActorName, M.Director, COUNT(*) AS NumMovies
FROM Actors_Movies AM
JOIN Movies M ON AM.MovieID = M.MovieID
JOIN People P ON AM.ActorID = P.PersonID
GROUP BY AM.ActorID, P.Name, M.Director
ORDER BY NumMovies DESC
LIMIT 1;

SELECT '--- Question 21: Director Averages ---';
SELECT M.Director, AVG(Ra.Stars) AS AvgRating
FROM Movies M
JOIN Ratings Ra ON M.MovieID = Ra.MovieID
GROUP BY M.Director
HAVING COUNT(DISTINCT M.MovieID) >= 2
ORDER BY AvgRating DESC;

SELECT '--- Question 22: Versatile Actors ---';
SELECT P.Name, COUNT(DISTINCT AM.MovieID) AS NumMovies, COUNT(DISTINCT AM.Role) AS NumRoles
FROM Actors_Movies AM
JOIN People P ON AM.ActorID = P.PersonID
GROUP BY AM.ActorID, P.Name
HAVING COUNT(DISTINCT AM.MovieID) >= 3
   AND COUNT(DISTINCT AM.Role) >= 2;

SELECT '--- Question 23: John Directors 2022 ---';
SELECT Title, Director
FROM Movies
WHERE Year = 2022
  AND Director LIKE 'John %';

SELECT '--- Question 24: Prolific Actors ---';
SELECT P.Name, COUNT(DISTINCT AM.MovieID) AS NumMovies
FROM Actors_Movies AM
JOIN People P ON AM.ActorID = P.PersonID
GROUP BY AM.ActorID, P.Name
HAVING COUNT(DISTINCT AM.MovieID) >= 10;

SELECT '--- Question 26 (L2): Acting Only in Good Movies ---';
SELECT DISTINCT P.Name
FROM People P
JOIN Actors_Movies AM ON P.PersonID = AM.ActorID
WHERE EXISTS (
    SELECT 1
    FROM Ratings Ra
    WHERE Ra.MovieID = AM.MovieID
      AND Ra.Stars = 5
)
AND P.PersonID NOT IN (
    SELECT AM2.ActorID
    FROM Actors_Movies AM2
    JOIN Ratings Ra2 ON AM2.MovieID = Ra2.MovieID
    WHERE Ra2.Stars < 3
);

SELECT '--- Question 27 (L2): Co-star Actors ---';
SELECT A1.ActorID AS Actor1ID, P1.Name AS Actor1Name,
       A2.ActorID AS Actor2ID, P2.Name AS Actor2Name,
       COUNT(*) AS NumMovies
FROM Actors_Movies A1
JOIN Actors_Movies A2 ON A1.MovieID = A2.MovieID AND A1.ActorID < A2.ActorID
JOIN People P1 ON A1.ActorID = P1.PersonID
JOIN People P2 ON A2.ActorID = P2.PersonID
GROUP BY A1.ActorID, P1.Name, A2.ActorID, P2.Name
HAVING COUNT(*) >= 3;

SELECT '--- Question 28 (L2): Co-lead Movies ---';
SELECT DISTINCT M.MovieID, M.Title
FROM Movies M
JOIN Actors_Movies AM ON M.MovieID = AM.MovieID
JOIN Ratings Ra ON M.MovieID = Ra.MovieID
WHERE LOWER(AM.Role) LIKE '%lead%'
GROUP BY M.MovieID, M.Title
HAVING COUNT(DISTINCT AM.ActorID) >= 2
   AND AVG(Ra.Stars) >= 4;

SELECT '--- Question 29 (L2): Late Bloomers ---';
SELECT R.Name
FROM Reviewers R
WHERE (
    SELECT Ra.Stars
    FROM Ratings Ra
    WHERE Ra.ReviewerID = R.ReviewerID
    ORDER BY Ra.RatingDate ASC
    LIMIT 1
) IN (1, 2)
AND (
    SELECT Ra.Stars
    FROM Ratings Ra
    WHERE Ra.ReviewerID = R.ReviewerID
    ORDER BY Ra.RatingDate DESC
    LIMIT 1
) IN (4, 5);

SELECT '--- Question 30 (L2): Complete Spielberg Reviews ---';
SELECT R.Name
FROM Reviewers R
WHERE NOT EXISTS (
    SELECT M.MovieID
    FROM Movies M
    WHERE M.Director = 'Steven Spielberg'
      AND NOT EXISTS (
          SELECT 1
          FROM Ratings Ra
          WHERE Ra.ReviewerID = R.ReviewerID
            AND Ra.MovieID = M.MovieID
      )
);

SELECT '--- Question 31 (L2): No Five-Star Reviewers ---';
SELECT R.ReviewerID, R.Name
FROM Reviewers R
WHERE R.ReviewerID NOT IN (
    SELECT ReviewerID
    FROM Ratings
    WHERE Stars = 5
);

SELECT '--- Question 32 (L2): One-hit Directors ---';
SELECT M.Director, M.Title
FROM Movies M
JOIN Ratings Ra ON M.MovieID = Ra.MovieID
WHERE Ra.Stars = 5
  AND M.Director IN (
      SELECT Director
      FROM Movies
      GROUP BY Director
      HAVING COUNT(*) = 1
  )
GROUP BY M.Director, M.Title;

SELECT '--- Question 33 (L2): Director Statistics ---';
SELECT M.Director, COUNT(DISTINCT M.MovieID) AS NumMovies, AVG(Ra.Stars) AS AvgRating
FROM Movies M
JOIN Ratings Ra ON M.MovieID = Ra.MovieID
GROUP BY M.Director
HAVING COUNT(DISTINCT M.MovieID) >= 2;

SELECT '--- Question 34 (L2): Highly Rated Actors ---';
SELECT P.Name, COUNT(DISTINCT AM.MovieID) AS HighlyRatedMovies
FROM People P
JOIN Actors_Movies AM ON P.PersonID = AM.ActorID
JOIN (
    SELECT MovieID
    FROM Ratings
    GROUP BY MovieID
    HAVING AVG(Stars) >= 4
) AS GoodMovies ON AM.MovieID = GoodMovies.MovieID
GROUP BY P.PersonID, P.Name
HAVING COUNT(DISTINCT AM.MovieID) >= 3;

SELECT '--- Question 35 (L2): Most Active Actors ---';
SELECT P.Name, COUNT(DISTINCT AM.MovieID) AS NumMovies
FROM Actors_Movies AM
JOIN People P ON AM.ActorID = P.PersonID
GROUP BY AM.ActorID, P.Name
HAVING COUNT(DISTINCT AM.MovieID) = (
    SELECT MAX(MovieCount)
    FROM (
        SELECT COUNT(DISTINCT MovieID) AS MovieCount
        FROM Actors_Movies
        GROUP BY ActorID
    ) AS Counts
);

SELECT '--- Question 36 (L2): Reviewers Who Improved Over Time ---';
SELECT R.Name
FROM Reviewers R
JOIN (
    SELECT ReviewerID,
           AVG(CASE WHEN rn <= total / 2 THEN CAST(Stars AS FLOAT) END) AS FirstHalfAvg,
           AVG(CASE WHEN rn > total / 2 THEN CAST(Stars AS FLOAT) END) AS SecondHalfAvg
    FROM (
        SELECT ReviewerID, Stars,
               ROW_NUMBER() OVER (PARTITION BY ReviewerID ORDER BY RatingDate) AS rn,
               COUNT(*) OVER (PARTITION BY ReviewerID) AS total
        FROM Ratings
    ) AS Ranked
    GROUP BY ReviewerID
) AS HalfAvgs ON R.ReviewerID = HalfAvgs.ReviewerID
WHERE HalfAvgs.SecondHalfAvg > HalfAvgs.FirstHalfAvg;