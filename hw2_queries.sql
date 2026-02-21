-- Homework 2: EN.601.415
-- Joanne Li (jli460)

-- QUERIES --

-- Question 1: Recent movies
SELECT Title, Director
FROM Movies
WHERE Year = 2023
ORDER BY Title DESC;

-- Question 2: Movies by James
SELECT *
FROM Movies
WHERE (Year > 2022 OR Year < 2000)
  AND Director LIKE '%James%';

-- Question 3: Good years for movies
SELECT DISTINCT Year
FROM Movies
WHERE MovieID IN (
    SELECT MovieID
    FROM Ratings
    WHERE Stars IN (4, 5)
)
ORDER BY Year ASC;

-- Question 4: Easier to read Ratings
SELECT R.Name AS ReviewerName, M.Title AS MovieTitle, Ra.Stars, Ra.RatingDate
FROM Ratings Ra
JOIN Reviewers R ON Ra.ReviewerID = R.ReviewerID
JOIN Movies M ON Ra.MovieID = M.MovieID
ORDER BY R.Name, M.Title, Ra.Stars;

-- Question 5: Movies with poor coverage
SELECT Title
FROM Movies
WHERE MovieID NOT IN (
    SELECT MovieID
    FROM Ratings
);

-- Question 6: Harshest ratings
SELECT Ra.ReviewerID, R.Name, Ra.MovieID, M.Title, Ra.Stars
FROM Ratings Ra
JOIN Reviewers R ON Ra.ReviewerID = R.ReviewerID
JOIN Movies M ON Ra.MovieID = M.MovieID
WHERE Ra.Stars = (SELECT MIN(Stars) FROM Ratings);

-- Question 7: Best ratings per movie
SELECT MovieID, MAX(Stars) AS HighestStars
FROM Ratings
GROUP BY MovieID;

-- Question 8: Keep the best, ignore the rest
SELECT M.Title, MAX(Ra.Stars) AS HighestStars
FROM Movies M
JOIN Ratings Ra ON M.MovieID = Ra.MovieID
GROUP BY M.MovieID, M.Title
ORDER BY M.Title ASC;

-- Question 9: Power users
SELECT R.Name, COUNT(*) AS TotalReviews
FROM Ratings Ra
JOIN Reviewers R ON Ra.ReviewerID = R.ReviewerID
GROUP BY Ra.ReviewerID, R.Name
HAVING COUNT(*) >= 3;

-- Question 10: Real power users
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

-- Question 11: What to watch
SELECT M.Title
FROM Movies M
WHERE M.MovieID NOT IN (
    SELECT Ra.MovieID
    FROM Ratings Ra
    JOIN Reviewers R ON Ra.ReviewerID = R.ReviewerID
    WHERE R.Name = 'Chris Jackson'
);

-- Question 12: Actor directors
SELECT DISTINCT P.Name
FROM People P
JOIN Actors_Movies AM ON P.PersonID = AM.ActorID
JOIN Movies M ON AM.MovieID = M.MovieID
WHERE M.Director = P.Name;

-- Question 13: Actor, director, reviewer
SELECT DISTINCT R.ReviewerID, R.Name
FROM Reviewers R
JOIN People P ON R.Name = P.Name
JOIN Actors_Movies AM ON P.PersonID = AM.ActorID
JOIN Movies M ON M.Director = P.Name;

-- Question 14: Conflicts of interest
SELECT DISTINCT R.ReviewerID, R.Name
FROM Reviewers R
JOIN People P ON R.Name = P.Name
JOIN Actors_Movies AM ON P.PersonID = AM.ActorID
JOIN Ratings Ra ON R.ReviewerID = Ra.ReviewerID
  AND AM.MovieID = Ra.MovieID;

-- Question 15: Only good directors
SELECT DISTINCT Director
FROM Movies
WHERE Director NOT IN (
    SELECT DISTINCT M.Director
    FROM Movies M
    JOIN Ratings Ra ON M.MovieID = Ra.MovieID
    WHERE Ra.Stars < 4
);

-- Question 16: No rating actors and movies
SELECT DISTINCT P.Name, AM.Role, M.Title
FROM Actors_Movies AM
JOIN People P ON AM.ActorID = P.PersonID
JOIN Movies M ON AM.MovieID = M.MovieID
WHERE M.MovieID NOT IN (
    SELECT MovieID FROM Ratings
);

-- Question 17: Movie with highest average rating
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

-- Question 18: Chris reviews
SELECT M.MovieID, M.Title, COUNT(*) AS NumReviews
FROM Movies M
JOIN Ratings Ra ON M.MovieID = Ra.MovieID
JOIN Reviewers R ON Ra.ReviewerID = R.ReviewerID
WHERE R.Name LIKE '%Chris%'
GROUP BY M.MovieID, M.Title;

-- Question 19: Top rated movies
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

-- Question 20: Frequent collaborations
SELECT AM.ActorID, P.Name AS ActorName, M.Director, COUNT(*) AS NumMovies
FROM Actors_Movies AM
JOIN Movies M ON AM.MovieID = M.MovieID
JOIN People P ON AM.ActorID = P.PersonID
GROUP BY AM.ActorID, P.Name, M.Director
ORDER BY NumMovies DESC
LIMIT 1;

-- Question 21: Director averages
SELECT M.Director, AVG(Ra.Stars) AS AvgRating
FROM Movies M
JOIN Ratings Ra ON M.MovieID = Ra.MovieID
GROUP BY M.Director
HAVING COUNT(DISTINCT M.MovieID) >= 2
ORDER BY AvgRating DESC;

-- Question 22: Versatile actors
SELECT P.Name, COUNT(DISTINCT AM.MovieID) AS NumMovies, COUNT(DISTINCT AM.Role) AS NumRoles
FROM Actors_Movies AM
JOIN People P ON AM.ActorID = P.PersonID
GROUP BY AM.ActorID, P.Name
HAVING COUNT(DISTINCT AM.MovieID) >= 3
   AND COUNT(DISTINCT AM.Role) >= 2;

-- Question 23: John directors 2022
SELECT Title, Director
FROM Movies
WHERE Year = 2022
  AND Director LIKE 'John %';

-- Question 24: Prolific actors
SELECT P.Name, COUNT(DISTINCT AM.MovieID) AS NumMovies
FROM Actors_Movies AM
JOIN People P ON AM.ActorID = P.PersonID
GROUP BY AM.ActorID, P.Name
HAVING COUNT(DISTINCT AM.MovieID) >= 10;

-- Question 26 (L2): Acting only in good movies
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

-- Question 27 (L2): Co-star actors
SELECT A1.ActorID AS Actor1ID, P1.Name AS Actor1Name,
       A2.ActorID AS Actor2ID, P2.Name AS Actor2Name,
       COUNT(*) AS NumMovies
FROM Actors_Movies A1
JOIN Actors_Movies A2 ON A1.MovieID = A2.MovieID AND A1.ActorID < A2.ActorID
JOIN People P1 ON A1.ActorID = P1.PersonID
JOIN People P2 ON A2.ActorID = P2.PersonID
GROUP BY A1.ActorID, P1.Name, A2.ActorID, P2.Name
HAVING COUNT(*) >= 3;

-- Question 28 (L2): Co-lead movies
SELECT DISTINCT M.MovieID, M.Title
FROM Movies M
JOIN Actors_Movies AM ON M.MovieID = AM.MovieID
JOIN Ratings Ra ON M.MovieID = Ra.MovieID
WHERE LOWER(AM.Role) LIKE '%lead%'
GROUP BY M.MovieID, M.Title
HAVING COUNT(DISTINCT AM.ActorID) >= 2
   AND AVG(Ra.Stars) >= 4;

-- Question 29 (L2): Late Bloomers
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

-- Question 30 (L2): Complete Spielberg reviews
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

-- Question 31 (L2): No five-star reviewers
SELECT R.ReviewerID, R.Name
FROM Reviewers R
WHERE R.ReviewerID NOT IN (
    SELECT ReviewerID
    FROM Ratings
    WHERE Stars = 5
);

-- Question 32 (L2): One-hit directors
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

-- Question 33 (L2): Director statistics
SELECT M.Director, COUNT(DISTINCT M.MovieID) AS NumMovies, AVG(Ra.Stars) AS AvgRating
FROM Movies M
JOIN Ratings Ra ON M.MovieID = Ra.MovieID
GROUP BY M.Director
HAVING COUNT(DISTINCT M.MovieID) >= 2;

-- Question 34 (L2): Highly rated actors
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

-- Question 35 (L2): Most active actors
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

-- Question 36 (L2): Original question
-- (Reviewers who improved over time) Find reviewers whose average rating
-- in their second half of reviews (by date) is strictly higher than in
-- their first half. Uses window functions with aggregation and ordering.
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