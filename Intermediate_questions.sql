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


-- Tweet's rolling average
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

/*Assume there are three Spotify tables containing information about the artists, songs, and music charts. Write a query to determine the top 5 artists whose songs appear in the Top 10 of the global_song_rank table the highest number of times. From now on, we'll refer to this ranking number as "song appearances".
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