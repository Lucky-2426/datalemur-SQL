-- Data Science Skills [LinkedIn SQL Interview Question]
/* Given a table of candidates and their skills, you're tasked with finding the candidates best suited for an open Data Science job.
   You want to find candidates who are proficient in Python, Tableau, and PostgreSQL.
   Write a query to list the candidates who possess all of the required skills for the job. Sort the output by candidate ID in ascending order.
 */
    SELECT candidate_id
    FROM candidates
    WHERE skill IN ('Python', 'Tableau', 'PostgreSQL')
    GROUP BY candidate_id
    HAVING COUNT(skill) = 3
    ORDER BY candidate_id;

-- Page With No Likes [Facebook SQL Interview Question]
/* Assume you're given the tables below about Facebook Page and Page likes (as in "Like a Facebook Page").
   Write a query to return the IDs of the Facebook pages which do not possess any likes. The output should be sorted in ascending order.
 */
    SELECT page_id
    FROM pages
    EXCEPT
    SELECT page_id
    FROM page_likes
    ORDER BY page_id;

-- Unfinished Parts [Tesla SQL Interview Question]
/* Tesla is investigating production bottlenecks and they need your help to extract the relevant data.
   Write a query that determines which parts with the assembly steps have initiated the assembly process but remain unfinished.
   Assumptions:
    - parts_assembly table contains all parts currently in production, each at varying stages of the assembly process.
    - An unfinished part is one that lacks a finish_date.
 */
    SELECT DISTINCT (part) FROM parts_assembly WHERE finish_date IS NULL;

-- Histogram of Tweets [Twitter SQL Interview Question]
/* Assume you're given a table Twitter tweet data, write a query to obtain a histogram of tweets posted per user in 2022.
   Output the tweet count per user as the bucket and the number of Twitter users who fall into that bucket.
   In other words, group the users by the number of tweets they posted in 2022 and count the number of users in each group.
 */
    WITH buckets AS
    (
    SELECT user_id, COUNT(tweet_id) as tweets_num
    FROM tweets
    WHERE tweet_date BETWEEN '2022-01-01' AND '2022-12-31'
    GROUP BY user_id
    )

    SELECT DISTINCT(tweets_num) as tweet_bucket, COUNT(tweets_num)
    FROM buckets
    GROUP BY tweets_num;

-- Laptop vs. Mobile Viewership [New York Times SQL Interview Question]
/* Assume you're given the table on user viewership categorised by device type where the three types are laptop, tablet, and phone.
   Write a query that calculates the total viewership for laptops and mobile devices where mobile is defined as the sum of tablet and phone viewership.
   Output the total viewership for laptops as laptop_reviews and the total viewership for mobile devices as mobile_views.
 */
    SELECT
    COUNT(CASE WHEN device_type = 'laptop' THEN 1 ELSE NULL END) AS laptop_views,
    COUNT(CASE WHEN device_type IN ('tablet', 'phone') THEN 1 ELSE NULL END) AS mobile_views
    FROM viewership;

-- Duplicate Job Listings [Linkedin SQL Interview Question]
/* Assume you are given the table below that shows job postings for all companies on the LinkedIn platform.
   Write a query to get the number of companies that have posted duplicate job listings.
   Clarification: Duplicate job listings refer to two jobs at the same company with the same title and description.
 */
    WITH jobs_grouped AS
    (
    SELECT company_id, title, description, COUNT(job_id) as job_count
    FROM job_listings
    GROUP BY company_id, title, description
    )

    SELECT COUNT(DISTINCT company_id) AS co_w_duplicate_jobs
    FROM jobs_grouped
    WHERE job_count > 1;

-- Average Post Hiatus (Part 1) [Facebook SQL Interview Question]
/* Given a table of Facebook posts, for each user who posted at least twice in 2021, write a query to find the number of days between each user’s first post of the year and last post of the year in the year 2021.
   Output the user and number of the days between each user's first and last post.
 */
    SELECT user_id,
    MAX(post_date::DATE)-MIN(post_date::DATE) as date_between
    FROM posts
    WHERE DATE_PART('year',post_date::DATE) = 2021
    GROUP BY user_id
    HAVING COUNT(post_id)>1;

-- Teams Power Users [Microsoft SQL Interview Question]
/* Write a query to identify the top 2 Power Users who sent the highest number of messages on Microsoft Teams in August 2022.
   Display the IDs of these 2 users along with the total number of messages they sent.
   Output the results in descending order based on the count of the messages.
   Assumption: No two users have sent the same number of messages in August 2022.
 */

    SELECT sender_id, COUNT(message_id) as Messages_sent
    FROM messages
    WHERE EXTRACT(MONTH FROM sent_date) = '8'
    AND EXTRACT(YEAR FROM sent_date) = '2022'
    GROUP BY sender_id
    ORDER BY Messages_sent DESC
    LIMIT 2;

-- Cities With Completed Trades [Robinhood SQL Interview Question]
/* Assume you're given the tables containing completed trade orders and user details in a Robinhood trading system.
   Write a query to retrieve the top three cities that have the highest number of completed trade orders listed in descending order.
   Output the city name and the corresponding number of completed trade orders.
 */

    SELECT  u.city, COUNT(t.order_id) as total_orders
    FROM trades as t
    JOIN users as u
    ON t.user_id = u.user_id
    WHERE t.status = 'Completed'
    GROUP BY u.city
    ORDER BY COUNT(t.order_id) DESC
    LIMIT 3;

-- Average Review Ratings [Amazon SQL Interview Question]
/* Given the reviews table, write a query to retrieve the average star rating for each product, grouped by month.
   The output should display the month as a numerical value, product ID, and average star rating rounded to two decimal places.
   Sort the output first by month and then by product ID.
 */

    SELECT EXTRACT(MONTH FROM submit_date) as mth,
    product_id as product, ROUND(AVG(stars),2) as avg_stars
    FROM reviews
    GROUP BY mth, product
    ORDER BY mth, product;

-- App Click-through Rate (CTR) [Facebook SQL Interview Question]
/* Assume you have an events table on Facebook app analytics.
   Write a query to calculate the click-through rate (CTR) for the app in 2022 and round the results to 2 decimal places.
   Definition and note:
   - Percentage of click-through rate (CTR) = 100.0 * Number of clicks / Number of impressions
   - To avoid integer division, multiply the CTR by 100.0, not 100.
 */

    SELECT
      app_id,
      ROUND(100.0 *
        COUNT(CASE WHEN event_type = 'click' THEN 1 ELSE NULL END) /
        COUNT(CASE WHEN event_type = 'impression' THEN 1 ELSE NULL END), 2)  AS ctr_rate
    FROM events
    WHERE timestamp >= '2022-01-01'
      AND timestamp < '2023-01-01'
    GROUP BY app_id;

-- Second Day Confirmation [TikTok SQL Interview Question]
/* Assume you're given tables with information about TikTok user sign-ups and confirmations through email and text.
   New users on TikTok sign up using their email addresses, and upon sign-up, each user receives a text message confirmation to activate their account.
   Write a query to display the user IDs of those who did not confirm their sign-up on the first day, but confirmed on the second day.
   Definition: action_date refers to the date when users activated their accounts and confirmed their sign-up through text messages.
 */

    SELECT user_id FROM emails as e
    JOIN texts as t on t.email_id = e.email_id
    WHERE t.signup_action = 'Confirmed'
    AND t.action_date = e.signup_date + interval '1 day';

-- Cards Issued Difference [JPMorgan Chase SQL Interview Question]
/* Your team at JPMorgan Chase is soon launching a new credit card, and to gain some context, you are analyzing how many credit cards were issued each month.
   Write a query that outputs the name of each credit card and the difference in issued amount between the month with the most cards issued, and the least cards issued.
   Order the results according to the biggest difference.
 */

    SELECT DISTINCT card_name, MAX(issued_amount)-MIN(issued_amount) as difference
    FROM monthly_cards_issued
    GROUP BY card_name
    ORDER BY card_name DESC;

-- Compressed Mean [Alibaba SQL Interview Question]
/* You're trying to find the mean number of items per order on Alibaba,
   rounded to 1 decimal place using tables which includes information on the count of items in each order (item_count table)
   and the corresponding number of orders for each item count (order_occurrences table).
 */

    SELECT ROUND(
    (SUM (item_count * order_occurrences)
    /
    SUM(order_occurrences::DECIMAL)), 1)
    as mean
    FROM items_per_order;

-- Pharmacy Analytics (Part 1) [CVS Health SQL Interview Question]
/* CVS Health is trying to better understand its pharmacy sales, and how well different products are selling.
   Each drug can only be produced by one manufacturer.
   Write a query to find the top 3 most profitable drugs sold, and how much profit they made.
   Assume that there are no ties in the profits. Display the result from the highest to the lowest total profit.
   */

    SELECT drug, (total_sales-cogs) as total_profit
    FROM pharmacy_sales
    ORDER BY total_profit DESC
    LIMIT 3;

-- Pharmacy Analytics (Part 2) [CVS Health SQL Interview Question]
/* CVS Health is analyzing its pharmacy sales data, and how well different products are selling in the market.
   Each drug is exclusively manufactured by a single manufacturer.
   Write a query to identify the manufacturers associated with the drugs that resulted in losses for CVS Health and calculate the total amount of losses incurred.
   Output the manufacturer's name, the number of drugs associated with losses, and the total losses in absolute value.
   Display the results sorted in descending order with the highest losses displayed at the top.
   */

    WITH first_step AS
    (SELECT manufacturer, COUNT(drug) as drug_count,
    SUM(total_sales-cogs) as net_value
    FROM pharmacy_sales
    WHERE total_sales - cogs <= 0
    GROUP BY manufacturer)

    SELECT manufacturer, drug_count, (-1 * net_value) as total_loss
    FROM first_step
    ORDER BY total_loss DESC;

-- Pharmacy Analytics (Part 3) [CVS Health SQL Interview Question]
/* CVS Health is trying to better understand its pharmacy sales, and how well different products are selling.
   Write a query to find the total drug sales for each manufacturer.
   Round your answer to the closest million, and report your results in descending order of total sales.
   Because this data is being directly fed into a dashboard which is being seen by business stakeholders, format your result like this: "$36 million".
   */

    SELECT manufacturer,
    CONCAT('$', ROUND(SUM(total_sales) / 1000000), ' million') as sales
    FROM pharmacy_sales
    GROUP BY manufacturer
    ORDER BY SUM(total_sales) DESC;

-- Patient Support Analysis (Part 1) [UnitedHealth SQL Interview Question]
/* UnitedHealth has a program called Advocate4Me, which allows members to call an advocate and receive support for their health care needs –
   whether that's behavioural, clinical, well-being, health care financing, benefits, claims or pharmacy help.
   Write a query to find how many UHG members made 3 or more calls. case_id column uniquely identifies each call made.
 */
    WITH calls_per_member AS
    (SELECT policy_holder_id, COUNT(case_id) as nbr_calls
    FROM callers
    GROUP BY policy_holder_id)

    SELECT COUNT(policy_holder_id) as member_count
    FROM calls_per_member
    WHERE nbr_calls >= 3;

-- Patient Support Analysis (Part 2) [UnitedHealth SQL Interview Question]
/*
 UnitedHealth Group has a program called Advocate4Me, which allows members to call an advocate and receive support for their health care needs
 – whether that's behavioural, clinical, well-being, health care financing, benefits, claims or pharmacy help.
 Calls to the Advocate4Me call centre are categorised, but sometimes they can't fit neatly into a category.
 These uncategorized calls are labelled “n/a”, or are just empty (when a support agent enters nothing into the category field).

 Write a query to find the percentage of calls that cannot be categorised. Round your answer to 1 decimal place.
 */

    SELECT ROUND(100.0 *
                 COUNT (case_id) FILTER (WHERE call_category IS NULL OR call_category = 'n/a')
                /
                COUNT (case_id), 1) AS uncategorised_call_pct
    FROM callers;
