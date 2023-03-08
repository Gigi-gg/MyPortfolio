### Book Tracker Data
##### Analyzing data from the book tracker app I use. For this practice, I only want books finished in 2022. I exported a csv file from the app and used BigQuery for the analysis.

```sql
/* COUNT, EXTRACT, ALIASING - Looking at some summaries from the 2022_books table. */

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


/* SUBQUERY - Using a subquery to filter out books not finished in 2022*/

SELECT 
    type, 
    COUNT(title) AS title_count
FROM 
    (SELECT title, type
    FROM `mythic-beanbag-363223.Books.2022_books`
    WHERE finishedReading BETWEEN '2022-01-01' AND '2022-12-31')
GROUP BY type;


| type         | title_count |
|--------------|-------------|
| EBOOK        | 30          |
| AUDIOBOOK    | 57          |
| PHYSICALBOOK | 12          |


/* Counting books and summing pages finished each month */

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


/* AGGREGATE FUNCTIONS SUM - Display running page count for books read in 2022 */

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


/* CAST - Casting average rating as string to count and group books by star rating */

WITH book_ratings AS (
    SELECT CAST(averageRating AS STRING) AS rating, title, pagecount, finishedReading,
    FROM `mythic-beanbag-363223.Books.2022_books`
    WHERE finishedReading BETWEEN '2022-01-01' AND '2022-12-31')

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


/* COUNT, GROUP BY, ORDER BY -counting the number of books by genre. */

WITH books_2022 AS (
    SELECT *
    FROM `mythic-beanbag-363223.Books.2022_books`
    WHERE finishedReading BETWEEN '2022-01-01' AND '2022-12-31')

SELECT 
  categories AS genre,
  count(title) AS book_count
FROM books_2022
GROUP BY genre
ORDER BY book_count DESC
LIMIT 6

| genre                | book_count |
|----------------------|------------|
| Fantasy Ficiton      | 32         |
| Memoir Non-Ficiton   | 8          |
| Historical Fiction   | 8          |
| Horror Ficition      | 7          |
| Science Fiction      | 6          |
| Contemporary Fiction | 6          |



/* CASE WHEN, LIKE OPERATOR, WILDCARDS - Categorizing books as fiction and non-fiction using CASE on the category. The previous query revealed spelling errors in some categories so I'll use wildcards to case properly */

WITH books_2022 AS (
    SELECT *
    FROM `mythic-beanbag-363223.Books.2022_books`
    WHERE finishedReading BETWEEN '2022-01-01' AND '2022-12-31')


SELECT count(*) AS book_count,
  (CASE WHEN categories LIKE '%Non-%' THEN 'Non-Fiction'
  ELSE 'Fiction'
  end) AS genre
FROM books_2022
GROUP BY genre

| book_count | genre       |
|------------|-------------|
| 77         | Fiction     |
| 22         | Non-Fiction |


##### Advanced SQL functions

/* WINDOW FUNCTIONS DENSE_RANK - Rank Top 5 genres by average rating from books list */

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
  
| categories              | avg_rating | genre_rank |
|-------------------------|------------|------------|
| Bio/AutoBio Non-Fiction | 5.0        | 1          |
| Science Fiction         | 4.42       | 2          |
| Essays Non-Fiction      | 4.38       | 3          |
| Mythic Fiction          | 4.2        | 4          |
| Fantasy Ficiton         | 4.19       | 5          |

 
/* LAG & PARTITION WINDOW FUNCTIONS -  See previous title and finished date by genre for books finished in 2022 */

WITH finished_books AS... (Shortened repetitive query to save space)

SELECT
  title,
  genre,
  finishedReading,
  LAG(title) OVER (PARTITION BY genre
                        ORDER BY finishedReading) AS previous_book,
  LAG(finishedReading) OVER (PARTITION BY genre
                        ORDER BY finishedReading) AS last_genre_read
FROM finished_books
ORDER BY genre DESC, finishedReading
LIMIT 6

| title                      | genre                      | finishedReading | previous_book              | last_genre_read |
|----------------------------|----------------------------|-----------------|----------------------------|-----------------|
| Other People's Clothes     | Thriller Fiction           | 2022-05-13      |                            |                 |
| Bunny                      | Thriller Fiction           | 2022-05-19      | Other People's Clothes     | 2022-05-13      |
| Come With Me               | Thriller Fiction           | 2022-08-28      | Bunny                      | 2022-05-19      |
| Cultish                    | Social Science Non-Fiction | 2022-03-31      |                            |                 |
| The Undocumented Americans | Social Science Non-Fiction | 2022-05-10      | Cultish                    | 2022-03-31      |
| Kids These Days            | Social Science Non-Fiction | 2022-11-30      | The Undocumented Americans | 2022-05-10      |


/*WINDOW FUNCTIONS NTILE - Find average total pages by series quarter */

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

| Quarter | avg_total_pages |
|---------|-----------------|
| 1       | 1656.0          |
| 2       | 1101.33         |
| 3       | 944.0           |
| 4       | 568.0           |



/* COALESCE, ROLLUP - Count books by genre, roll up to format level and replace nulls*/

SELECT
  COALESCE(type, "All Formats") AS format,
  COALESCE(categories, "All books") AS genre,
  COUNT(*) AS book_count
FROM `mythic-beanbag-363223.Books.2022_books`
GROUP BY ROLLUP(type, categories)
LIMIT 20

| format      | genre                      | book_count |
|-------------|----------------------------|------------|
| All Formats | All books                  | 103        |
| EBOOK       | All books                  | 33         |
| EBOOK       | LGBT Fiction               | 1          |
| EBOOK       | Fantasy Ficiton            | 15         |
| EBOOK       | Horror Ficition            | 3          |
| EBOOK       | Mystery Fiction            | 2          |
| EBOOK       | Science Fiction            | 1          |
| EBOOK       | Romantic Fiction           | 1          |
| EBOOK       | Essays Non-Fiction         | 2          |
| EBOOK       | Historical Fiction         | 2          |
| EBOOK       | Memoir Non-Ficiton         | 1          |
| EBOOK       | Science Non-Fiction        | 1          |
| EBOOK       | Contemporary Fiction       | 1          |
| EBOOK       | Historical Non-Fiction     | 1          |
| EBOOK       | Historical Fantasy Fiction | 1          |
| EBOOK       | Social Science Non-Fiction | 1          |
| AUDIOBOOK   | All books                  | 58         |
| AUDIOBOOK   | Mythic Fiction             | 4          |
| AUDIOBOOK   | Fantasy Ficiton            | 14         |
| AUDIOBOOK   | Horror Ficition            | 2          |



```




