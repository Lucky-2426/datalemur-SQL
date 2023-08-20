/* User's Third Transaction [Uber SQL Interview Question]
   Assume you are given the table below on Uber transactions made by users.
   Write a query to obtain the third transaction of every user. Output the user id, spend and transaction date.
 */

SELECT user_id, spend, transaction_date
FROM (
  SELECT
    user_id,
    spend,
    transaction_date,
    RANK() OVER (
      PARTITION BY user_id
      ORDER BY transaction_date) AS rank_num
  FROM transactions
) AS trans_num
WHERE rank_num = 3;


/* Sending vs. Opening Snaps [Snapchat SQL Interview Question]
Assume you're given tables with information on Snapchat users, including their ages and time spent sending and opening snaps.

Write a query to obtain a breakdown of the time spent sending vs. opening snaps as a percentage of total time spent on these activities grouped by age group. Round the percentage to 2 decimal places in the output.

Notes:

Calculate the following percentages:
time spent sending / (Time spent sending + Time spent opening)
Time spent opening / (Time spent sending + Time spent opening)
To avoid integer division in percentages, multiply by 100.0 and not 100.

 */

 WITH snap_statistics AS (
  SELECT
  age.age_bucket, 
    SUM(CASE WHEN activities.activity_type = 'send' 
        THEN activities.time_spent ELSE 0 END) AS send_timespent, 
    SUM(CASE WHEN activities.activity_type = 'open' 
        THEN activities.time_spent ELSE 0 END) AS open_timespent, 
    SUM(activities.time_spent) AS total_timespent 
  FROM activities
  INNER JOIN age_breakdown AS age 
    ON activities.user_id = age.user_id 
  WHERE activities.activity_type IN ('send', 'open') 
  GROUP BY age.age_bucket
)

SELECT 
  age_bucket, 
  ROUND(100.0 * send_timespent / total_timespent, 2) AS send_perc, 
  ROUND(100.0 * open_timespent / total_timespent, 2) AS open_perc 
FROM snap_statistics;


/* Tweets' Rolling Averages [Twitter SQL Interview Question]
Given a table of tweet data over a specified time period, calculate the 3-day rolling average of tweets for each user. Output the user ID, tweet date, and rolling averages rounded to 2 decimal places.
Notes:
A rolling average, also known as a moving average or running mean is a time-series technique that examines trends in data over a specified period of time.
In this case, we want to determine how the tweet count for each user changes over a 3-day period.
 */

WITH tweet_count
AS (
  SELECT
    user_id,
    tweet_date,
    COUNT(DISTINCT tweet_id) AS tweet_num
  FROM tweets
  GROUP BY user_id,tweet_date
)

SELECT
  user_id,
  tweet_date,
  ROUND(
    AVG(tweet_num) OVER (
      PARTITION BY user_id
      ORDER BY user_id, tweet_date
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2)
  AS rolling_avg_3d
FROM tweet_count;

/* Top 5 Artists [Spotify SQL Interview Question]

Assume there are three Spotify tables containing information about the artists, songs, and music charts. Write a query to determine the top 5 artists whose songs appear in the Top 10 of the global_song_rank table the highest number of times. From now on, we'll refer to this ranking number as "song appearances".
Output the top 5 artist names in ascending order along with their song appearances ranking (not the number of song appearances, but the rank of who has the most appearances). The order of the rank should take precedence.
For example, Ed Sheeran's songs appeared 5 times in Top 10 list of the global song rank table; this is the highest number of appearances, so he is ranked 1st. Bad Bunny's songs appeared in the list 4, so he comes in at a close 2nd.

Assumptions:
If two artists' songs have the same number of appearances, the artists should have the same rank.
The rank number should be continuous (1, 2, 2, 3, 4, 5) and not skipped (1, 2, 2, 4, 5).*/

WITH top_artists
AS (
  SELECT 
    artist_id,
    DENSE_RANK() OVER (
      ORDER BY song_count DESC) AS artist_rank
  FROM (    
    SELECT songs.artist_id, COUNT(songs.song_id) AS song_count
    FROM songs
    INNER JOIN global_song_rank AS ranking
      ON songs.song_id = ranking.song_id
    WHERE ranking.rank <= 10
    GROUP BY songs.artist_id) 
AS top_songs)

SELECT 
  artists.artist_name, top_artists.artist_rank
FROM top_artists
INNER JOIN artists
  ON top_artists.artist_id = artists.artist_id
WHERE top_artists.artist_rank <= 5
ORDER BY top_artists.artist_rank, artists.artist_name;

SELECT p1.page_id
FROM pages as p1
FULL JOIN page_likes as p2
ON p1.page_id = p2.page_id
WHERE p2.liked_date IS NULL
ORDER BY p1.page_id ASC;

/* Signup Activation Rate [TikTok SQL Interview Question]

New TikTok users sign up with their emails. They confirmed their signup by replying to the text confirmation to activate their accounts. Users may receive multiple text messages for account confirmation until they have confirmed their new account.

A senior analyst is interested to know the activation rate of specified users in the emails table. Write a query to find the activation rate. Round the percentage to 2 decimal places.

Definitions:

emails table contain the information of user signup details.
texts table contains the users' activation information.
Assumptions:

The analyst is interested in the activation rate of specific users in the emails table, which may not include all users that could potentially be found in the texts table.
For example, user 123 in the emails table may not be in the texts table and vice versa.*/

SELECT
 ROUND(COUNT(t.email_id)::DECIMAL
    /COUNT(e.email_id),2) AS activation_rate
FROM emails as e
LEFT JOIN texts as t
  ON e.email_id = t.email_id
  AND t.signup_action = 'Confirmed';

/* Supercloud Customer [Microsoft SQL Interview Question]

A Microsoft Azure Supercloud customer is a company which buys at least 1 product from each product category.

Write a query to report the company ID which is a Supercloud customer. */

WITH supercloud AS (
    SELECT c.customer_id, COUNT(DISTINCT p.product_category) as Count_categories
    FROM customer_contracts as c
    LEFT JOIN  products as p
    ON c.product_id = p.product_id
    GROUP BY c.customer_id
)

SELECT customer_id AS supercloud_customers
FROM supercloud
WHERE Count_categories = (
  SELECT COUNT(DISTINCT product_category)
  FROM products)
ORDER BY customer_id;

/* Odd and Even Measurements [Google SQL Interview Question]

Assume you're given a table with measurement values obtained from a Google sensor over multiple days with measurements taken multiple times within each day.

Write a query to calculate the sum of odd-numbered and even-numbered measurements separately for a particular day and display the results in two different columns. Refer to the Example Output below for the desired format.

Definition: Within a day, measurements taken at 1st, 3rd, and 5th times are considered odd-numbered measurements, and measurements taken at 2nd, 4th, and 6th times are considered even-numbered measurements.

 */

WITH ranked_measurements AS (
  SELECT
    CAST(measurement_time AS DATE) AS measurement_day, --CAST transform the measurement_time column in date
    measurement_value,
    ROW_NUMBER() OVER (
      PARTITION BY CAST(measurement_time AS DATE)
      ORDER BY measurement_time) AS measurement_num --ROW_NUMBER is a window function that assign a unique number to a row based on the condition specified in the PARTITION BY and ORDER BY clauses
  FROM measurements
)

SELECT
  measurement_day,
  SUM(measurement_value) FILTER (WHERE measurement_num % 2 != 0) AS odd_sum, --FILTER is a function that will sum over the specified condition
  SUM(measurement_value) FILTER (WHERE measurement_num % 2 = 0) AS even_sum --The modulus operator (%) returns the remainder of a division. When we divide an even number by 2, the remainder is always 0, whereas dividing an odd number will result in a non-zero value
FROM ranked_measurements
GROUP BY measurement_day;

/* Histogram of Users and Purchases [Walmart SQL Interview Question]
   Assume you're given a table on Walmart user transactions.
   Based on their most recent transaction date, write a query that retrieve the users along with the number of products they bought.
   Output the user's most recent transaction date, user ID, and the number of products, sorted in chronological order by the transaction date.
*/

WITH latest_transactions_cte AS (
  SELECT
    transaction_date,
    user_id,
    product_id,
    RANK() OVER (
      PARTITION BY user_id
      ORDER BY transaction_date DESC) AS transaction_rank
  FROM user_transactions)

SELECT
  transaction_date,
  user_id,
  COUNT(product_id) AS purchase_count
FROM latest_transactions_cte
WHERE transaction_rank = 1
GROUP BY transaction_date, user_id
ORDER BY transaction_date;

/* You're given a table containing the item count for each order on Alibaba, along with the frequency of orders that have the same item count. Write a query to retrieve the mode of the order occurrences. Additionally, if there are multiple item counts with the same mode, the results should be sorted in ascending order.

Clarifications:

item_count: Represents the number of items sold in each order.
order_occurrences: Represents the frequency of orders with the corresponding number of items sold per order.
For example, if there are 800 orders with 3 items sold in each order, the record would have an item_count of 3 and an order_occurrences of 800.

 */

-- Solution A
WITH ranked_table AS
(SELECT *, RANK()OVER(ORDER BY order_occurrences DESC) occurrence_rank
FROM items_per_order
ORDER BY order_occurrences DESC)

SELECT item_count from ranked_table
WHERE occurrence_rank = 1
ORDER BY item_count;

-- Solution B (using max() function)
SELECT item_count AS mode
FROM items_per_order
WHERE order_occurrences = (
  SELECT MAX(order_occurrences)
  FROM items_per_order
)
ORDER BY item_count;

-- Solution C
SELECT item_count AS mode
FROM items_per_order
WHERE order_occurrences = (
  SELECT MODE() WITHIN GROUP (ORDER BY order_occurrences DESC)
  FROM items_per_order
)
ORDER BY item_count;

/*
Your team at JPMorgan Chase is soon launching a new credit card. You are asked to estimate how many cards you'll issue in the first month.
Before you can answer this question, you want to first get some perspective on how well new credit card launches typically do in their first month.
Write a query that outputs the name of the credit card, and how many cards were issued in its launch month.
The launch month is the earliest record in the monthly_cards_issued table for a given card. Order the results starting from the biggest issued amount.
 */

 -- My solution
WITH ranked_table AS
(
SELECT card_name, issue_year, issue_month,
RANK() OVER(PARTITION BY card_name ORDER BY issue_year, issue_month) launch_date, issued_amount
FROM monthly_cards_issued
)

SELECT card_name, issued_amount
FROM ranked_table
WHERE launch_date = 1
ORDER BY issue_year, issue_month;

-- Solution B
WITH card_launch AS (
SELECT
  card_name,
  issued_amount,
  MAKE_DATE(issue_year, issue_month, 1) AS issue_date,
  MIN(MAKE_DATE(issue_year, issue_month, 1)) OVER (
    PARTITION BY card_name) AS launch_date
FROM monthly_cards_issued
)

SELECT card_name, issued_amount
FROM card_launch
WHERE issue_date = launch_date
ORDER BY issued_amount DESC;

/* Tutorial Lesson: Manipulating with SQL Case Statement [Marvel's Avengers SQL Interview Question]

Delve into the Marvel Avengers dataset and write a query to categorize the superheroes based on their average likes as follows:

    - Super Likes: Superheroes with an average likes count greater than or equal to 15,000.
    - Good Likes: Superheroes with an average likes count between 5,000 and 14,999 (inclusive).
    - Low Likes: Superheroes with an average likes count less than 5,000.

Display the superhero's character name, platform, average likes, and the corresponding likes category.
 */

-- My solution
SELECT actor, character,platform, avg_likes,
  CASE WHEN avg_likes < 5000 THEN 'Low Likes'
  WHEN (avg_likes BETWEEN 5000 AND 14999) THEN 'Good Likes'
  ELSE 'Super Likes' END
  AS like_category
FROM marvel_avengers
ORDER BY avg_likes DESC;

/* International Call Percentage [Verizon SQL Interview Question]
 A phone call is considered an international call when the person calling is in a different country than the person receiving the call.
 What percentage of phone calls are international? Round the result to 1 decimal.
 */

 -- Solution A
SELECT
  ROUND(
    100.0 * SUM(CASE
      WHEN caller.country_id <> receiver.country_id THEN 1 ELSE NULL END)
    /COUNT(*) ,1) AS international_call_pct
FROM phone_calls AS calls
LEFT JOIN phone_info AS caller
  ON calls.caller_id = caller.caller_id
LEFT JOIN phone_info AS receiver
  ON calls.receiver_id = receiver.caller_id;

-- Solution B (using FILTER)
SELECT
  ROUND(
    100.0 * COUNT(*) FILTER (
      WHERE caller.country_id <> receiver.country_id)
  / COUNT(*), 1) AS international_calls_pct
FROM phone_calls AS calls
LEFT JOIN phone_info AS caller
  ON calls.caller_id = caller.caller_id
LEFT JOIN phone_info AS receiver
  ON calls.receiver_id = receiver.caller_id;

-- Solution C (using CTE)
WITH international_calls AS (
SELECT
  caller.caller_id,
  caller.country_id,
  receiver.caller_id,
  receiver.country_id
FROM phone_calls AS calls
LEFT JOIN phone_info AS caller
  ON calls.caller_id = caller.caller_id
LEFT JOIN phone_info AS receiver
  ON calls.receiver_id = receiver.caller_id
WHERE caller.country_id <> receiver.country_id
)

SELECT
  ROUND(
    100.0 * COUNT(*)
  / (SELECT COUNT(*) FROM phone_calls),1) AS international_call_pct
FROM international_calls;

/* Tutorial Lesson: Pivoting using SQL CASE Statement [Concert SQL Interview Question]
    As the lead data analyst for a prominent music event management company, you have been entrusted with a dataset containing concert revenue and detailed information about various artists.

Write a query that categorizes the artists based on their album release count. Display the output of the artist name, and album categort, sorted in ascending order of the artist's name.

The album category will be based on the number of albums released by the artists or bands:

If an artist has released 7 or more albums, they fall under the "Platinum" category.
If an artist has released between 3 and 6 albums (inclusive), they fall under the "Gold" category.
If an artist has released 2 or fewer albums, they fall under the "Silver" category.
 */

 SELECT artist_name,
CASE
  WHEN SUM(album_released) >= 7 THEN 'Platinum'
  WHEN SUM(album_released) BETWEEN 3 AND  7 THEN 'Gold'
  ELSE 'Silver'
END album_category
FROM concerts
GROUP BY artist_name
ORDER BY artist_name;

/* Tutorial Lesson: CTE vs. Subquery [Concert Revenue SQL Interview Question]

 */

-- My solution
WITH revenues as
(SELECT *, ROUND(concert_revenue/number_of_members, 0) as revenue_per_member,
RANK()OVER(PARTITION BY genre ORDER BY ROUND(concert_revenue/number_of_members, 0) DESC) ranking
FROM concerts
ORDER BY genre)

SELECT artist_name, genre, concert_revenue, number_of_members, revenue_per_member
FROM revenues
WHERE ranking = 1
ORDER BY revenue_per_member DESC;

-- Solution B (using CTE)
WITH ranked_concerts_cte AS (
  SELECT
    artist_name,
    concert_revenue,
    genre,
    number_of_members,
    concert_revenue / number_of_members AS revenue_per_member,
    RANK() OVER (
      PARTITION BY genre
      ORDER BY concert_revenue / number_of_members DESC) AS ranked_concerts
  FROM concerts
)

SELECT *
FROM ranked_concerts_cte;

-- Solution C (using subquery)
SELECT
  artist_name,
  concert_revenue,
  genre,
  number_of_members,
  concert_revenue / number_of_members AS revenue_per_member,
  RANK() OVER (
    PARTITION BY genre
    ORDER BY concert_revenue / number_of_members DESC) AS ranked_concerts
FROM concerts;
