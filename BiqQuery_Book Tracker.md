
```sql
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
 
/* Display running page count for books read in 2022 */

SELECT 
  title,
  pageCount,
  finishedReading,
  SUM(pageCount) OVER(ORDER BY finishedReading,title 
   ROWS BETWEEN UNBOUNDED PRECEDING AND Current Row) AS running_total
 FROM `mythic-beanbag-363223.Books.2022_books` 
 WHERE readingStatus = "read" AND
 finishedReading BETWEEN '2022-01-01' AND '2022-12-31'
 ORDER BY finishedReading, title;
 
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




