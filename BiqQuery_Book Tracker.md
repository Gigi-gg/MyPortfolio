
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




