--Table creation--
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix(
	show_id	VARCHAR(6),
	type VARCHAR(10),
	title	VARCHAR(150),
	director	VARCHAR(280),
	castS	VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year	INT,
	rating	VARCHAR(10),
	duration	VARCHAR(15),
	listed_in	VARCHAR(150),
	description VARCHAR(250)

)

SELECT * FROM netflix;


--Business problems--

--Count movies and tv shows---

SELECT type, COUNT(show_id)
FROM netflix
GROUP BY type;

--Most common rating for movie and tv shows---
--here we cannot use max or min on the rating column because it is not a number--
WITH ratingCounts as(
SELECT type,
       rating, 
	   COUNT(show_id), 
	   RANK() OVER(PARTITION BY type ORDER BY COUNT(show_id)DESC) as ranking
FROM netflix
GROUP by type,rating
ORDER BY COUNT(show_id) DESC)

SELECT type,
       rating
FROM ratingCounts
WHERE ranking=1;


--List all the movies released in 2020--

SELECT *
FROM netflix
WHERE release_year='2020'
      and
	  type='Movie'


--TOP 5 countries with the most content on Netflix---
--We need to first seperate the countries by ','--

SELECT TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS countries,
       COUNT(show_id)
FROM netflix
GROUP BY countries
ORDER BY COUNT(show_id) DESC
LIMIT 5;
	   
--Longest movie--
SELECT 
    title, 
    duration
FROM 
    netflix
WHERE duration IS NOT NULL 
      AND
	  type='Movie'
ORDER BY 
    CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) DESC 
LIMIT 1;


--Content that has been added in the last 5 years--

SELECT date_added
FROM netflix
WHERE TO_DATE(date_added, 'DD-Mon-YY') IS NULL;


--All movies directed by 'Rajiv Chilaka'--

SELECT * FROM netflix WHERE director like '%Rajiv Chilaka%' 

--All shows with more than 5 seasons--

SELECT *, CAST(SPLIT_PART(duration,' ',1) AS INTEGER) AS seasons
FROM netflix
WHERE CAST(SPLIT_PART(duration,' ',1) AS INTEGER) >= 5 and type = 'TV Show'

--Number of content items in each genre--

SELECT COUNT(show_id), TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) as genre 
FROM netflix
GROUP BY genre
ORDER BY COUNT(show_id) DESC

--Average number of content released in United States--
SELECT 
    COUNT(show_id) * 100/ 
    (SELECT COUNT(*) FROM netflix) AS average_content_released_in_us
FROM netflix
WHERE country LIKE '%United States%'

--Movies that are documetries--

SELECT * FROM netflix
WHERE type='Movie' and listed_in like '%Documentaries%'

--Content without a director--

SELECT * FROM netflix 
WHERE director is NULL

--Top 10 actors with the higgest appereance from INDIA--
SELECT COUNT(*), TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) as actor
FROM netflix
WHERE country LIKE '%United States%' AND type = 'Movie'
GROUP BY actor 
ORDER BY COUNT(*) DESC
LIMIT 10

--Rate the content as 'bad' or 'good' based on 'kill' and 'violence' present in the description and count the number of good and bad content--
WITH table3 AS (
SELECT title,
CASE 
WHEN description ILIKE '%kill%' OR 
     description ILIKE '%violence%'
     THEN 'BAD'
	 ELSE 'GOOD'
END category
FROM netflix
)

SELECT COUNT(*), category 
FROM table3
GROUP BY category