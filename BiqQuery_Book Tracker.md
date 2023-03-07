
```sql
/* Let's look at some summary statistics from the 2022_books table */

SELECT 
    EXTRACT(YEAR FROM finishedReading) AS year,
    COUNT (DISTINCT title) AS book_count,
    sum(pageCount) AS total_pages,
    COUNT (DISTINCT authors) AS total_authors,
    COUNT (DISTINCT categories) as total_genres,
    readingStatus AS read_status,
FROM `mythic-beanbag-363223.Books.2022_books` 
GROUP BY readingStatus, year;

| year | book_count | total_pages | total_authors | total_genres | read_status |
|------|------------|-------------|---------------|--------------|-------------|
| 2022 | 99         | 35832       | 80            | 18           | read        |
| 2021 | 3          | 1552        | 2             | 1            | read        |
| null | 1          | 320         | 1             | 1            | dnf         |


/* Total books by format */

SELECT 
    type, 
    COUNT(title) AS title_count
FROM 
    (SELECT title, type
    FROM `mythic-beanbag-363223.Books.2022_books`
    WHERE finishedReading BETWEEN '2022-01-01' AND '2022-12-31') AS subquery
GROUP BY type;


| type         | title_count |
|--------------|-------------|
| EBOOK        | 30          |
| AUDIOBOOK    | 57          |
| PHYSICALBOOK | 12          |


/* COUNT books and pages finished each month */

WITH books_2022 AS (
    SELECT title, pagecount, finishedReading,
    FROM `mythic-beanbag-363223.Books.2022_books`
    WHERE finishedReading BETWEEN '2022-01-01' AND '2022-12-31')

SELECT
 EXTRACT(MONTH from finishedReading) AS month,
 COUNT(title) AS books_count,
  sum(pageCount) AS page_count,
FROM books_2022
GROUP BY month
ORDER BY month

| month | books_count | page_count |
|-------|-------------|------------|
| 1     | 1           | 352        |
| 2     | 6           | 2064       |
| 3     | 11          | 3776       |
| 4     | 8           | 3280       |
| 5     | 9           | 3272       |
| 6     | 9           | 3216       |
| 7     | 11          | 3616       |
| 8     | 12          | 5135       |
| 9     | 10          | 2901       |
| 10    | 5           | 1650       |
| 11    | 8           | 2956       |
| 12    | 9           | 3614       |


/* Display running page count for books read in 2022 */

SELECT 
    finishedReading AS finish_date,
    title,
    pageCount AS pages,
  SUM(pageCount) OVER(ORDER BY finishedReading,title 
   ROWS BETWEEN UNBOUNDED PRECEDING AND Current Row) AS running_page_count
 FROM `mythic-beanbag-363223.Books.2022_books` 
 WHERE readingStatus = "read" AND
 finishedReading BETWEEN '2022-01-01' AND '2022-12-31'
 ORDER BY finishedReading, title
 LIMIT 6;
 
 | finish_date | title                     | pages | running_page_count |
|-------------|---------------------------|-------|--------------------|
| 2022-01-11  | The Vanishing Half        | 352   | 352                |
| 2022-02-01  | Moonwalking with Einstein | 320   | 672                |
| 2022-02-06  | Apples Never Fall         | 480   | 1152               |
| 2022-02-11  | The Last Thing He Told Me | 320   | 1472               |
| 2022-02-18  | The Nickel Boys           | 224   | 1696               |
| 2022-02-24  | Six of Crows              | 320   | 2016               |


/* COUNT books by rating */

WITH book_ratings AS (
    SELECT CAST(averageRating AS STRING) AS rating, title, pagecount, finishedReading,
    FROM `mythic-beanbag-363223.Books.2022_books`
    WHERE finishedReading BETWEEN '2022-01-01' AND '2022-12-31'
)

SELECT rating AS rating_of_5, COUNT(*) AS book_count
FROM book_ratings
GROUP BY rating
ORDER BY rating

| rating_of_5 | book_count |
|-------------|------------|
| 2           | 1          |
| 3           | 25         |
| 3.5         | 8          |
| 4           | 27         |
| 4.5         | 4          |
| 5           | 34         |






/* Rank Top 5 genres by average rating from books list */

WITH book_ratings AS (SELECT 
  categories,
  ROUND(AVG(averageRating),2) AS avg_rating
 FROM `mythic-beanbag-363223.Books.2022_books` 
 GROUP BY categories
 ORDER BY avg_rating DESC)

 SELECT
  categories,
  book_ratings.avg_rating,
  DENSE_RANK() OVER(ORDER BY book_ratings.avg_rating DESC) AS top_genres
  FROM book_ratings
  ORDER BY book_ratings.avg_rating DESC
  LIMIT 5
  
  /* Rank genres based on count of books read */

WITH book_genres AS (SELECT 
  categories,
  COUNT(*) AS book_count
 FROM `mythic-beanbag-363223.Books.2022_books` 
 GROUP BY categories
 ORDER BY book_count DESC)

 SELECT
  categories,
  book_count,
  DENSE_RANK() OVER(ORDER BY book_genres.book_count DESC) AS rank_categories
  FROM book_genres
  ORDER BY book_genres.book_count DESC
  LIMIT 5
 

 /* Display previous title and genre read from books finished in 2022 */

WITH finished_books AS (SELECT 
  title, 
  categories AS genre,
  finishedReading
FROM `mythic-beanbag-363223.Books.2022_books` 
WHERE read = 'read'
 AND finishedReading BETWEEN '2022-01-01' AND '2022-12-31'
ORDER BY finishedReading)

SELECT
  title,
  genre,
  finishedReading,
  LAG(title) OVER (ORDER BY finishedReading) AS previous_book,
  LAG(genre) OVER (ORDER BY finishedReading) AS previous_genre
FROM finished_books
ORDER BY finishedReading

/* See previous title and finished date by genre for books finished in 2022 */

WITH finished_books AS (SELECT 
  title, 
  categories AS genre,
  finishedReading
FROM `mythic-beanbag-363223.Books.2022_books` 
WHERE read = 'read'
 AND finishedReading BETWEEN '2022-01-01' AND '2022-12-31'
ORDER BY finishedReading)

SELECT
  title,
  genre,
  finishedReading,
  LAG(title) OVER (PARTITION BY genre
                        ORDER BY finishedReading) AS previous_book,
  LAG(finishedReading) OVER (PARTITION BY genre
                        ORDER BY finishedReading) AS last_genre_read
FROM finished_books
ORDER BY genre, finishedReading


 
 /* Select series and page count from book list*/
SELECT 
  series,
  SUM(pageCount) as total_pages
FROM `mythic-beanbag-363223.Books.2022_books`
WHERE series IS NOT NULL
GROUP BY series
ORDER BY total_pages DESC;

/* Split series into quarters using NTILE() function */

WITH book_series AS (SELECT 
  series,
  SUM(pageCount) as total_pages
FROM `mythic-beanbag-363223.Books.2022_books`
WHERE series IS NOT NULL
GROUP BY series
ORDER BY total_pages DESC)

SELECT 
  series,
  book_series.total_pages,
  NTILE(4) OVER (ORDER BY book_series.total_pages DESC) AS Quarter
FROM book_series
ORDER BY book_series.total_pages DESC;

/*Find average total pages by series quarter */

WITH book_series AS (SELECT 
  series,
  SUM(pageCount) as total_pages
FROM `mythic-beanbag-363223.Books.2022_books`
WHERE series IS NOT NULL
GROUP BY series
ORDER BY total_pages DESC),

Quarters AS (SELECT 
  series,
  book_series.total_pages,
  NTILE(4) OVER (ORDER BY book_series.total_pages DESC) AS Quarter
FROM book_series
ORDER BY book_series.total_pages DESC)

SELECT
  Quarter,
  ROUND(AVG(Quarters.total_pages),2) AS avg_total_pages
FROM Quarters
GROUP BY quarter
ORDER BY avg_total_pages DESC

/* SELECT title count for each genre of book in each book format*/

SELECT 
  type AS format,
  categories AS genre,
  COUNT(*) AS book_count,
FROM `mythic-beanbag-363223.Books.2022_books`
GROUP BY type, genre
ORDER BY format, genre;


/* ROLLUP totals by format */

SELECT 
  type AS format,
  categories AS genre,
  COUNT(*) AS book_count,
FROM `mythic-beanbag-363223.Books.2022_books`
GROUP BY ROLLUP(format,genre)
ORDER BY format;

/* COALESCE format and genre columns to replace nulls*/

SELECT
  COALESCE(type, "All Formats") AS format,
  COALESCE(categories, "All books") AS genre,
  COUNT(*) AS book_count
FROM `mythic-beanbag-363223.Books.2022_books`
GROUP BY ROLLUP(type, categories)

```




