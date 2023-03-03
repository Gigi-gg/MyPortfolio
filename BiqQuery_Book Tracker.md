
```sql
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
``` 
| title                             | pageCount | finishedReading | running_total |
|-----------------------------------|-----------|-----------------|---------------|
| The Vanishing Half                | 352       | 2022-01-11      | 352           |
| Moonwalking with Einstein         | 320       | 2022-02-01      | 672           |
| Apples Never Fall                 | 480       | 2022-02-06      | 1152          |
| The Last Thing He Told Me         | 320       | 2022-02-11      | 1472          |
| The Nickel Boys                   | 224       | 2022-02-18      | 1696          |
| Six of Crows                      | 320       | 2022-02-24      | 2016          |
| The Seven Husbands of Evelyn Hugo | 400       | 2022-02-24      | 2416          |
| Confess                           | 320       | 2022-03-01      | 2736          |
| I'm Still Here                    | 192       | 2022-03-03      | 2928          |




