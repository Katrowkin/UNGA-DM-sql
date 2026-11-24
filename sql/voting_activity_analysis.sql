--- How many votes there are a year?
SELECT 
	meeting_year,
	COUNT(*) AS yearly_count
FROM all_votes_rs077
GROUP BY meeting_year

--- Which coutries vote in favor the most often?
SELECT 
    current_seat_name,
    COUNT(CASE WHEN amended_vote = 'in favor' THEN 1 END) AS number_of_votes
FROM all_votes_rs077
GROUP BY current_seat_name
ORDER BY number_of_votes DESC
LIMIT 10;

--- Which countries vote against the most often?
SELECT 
    current_seat_name,
    COUNT(CASE WHEN amended_vote = 'against' THEN 1 END) AS number_of_votes
FROM all_votes_rs077
GROUP BY current_seat_name
ORDER BY number_of_votes DESC
LIMIT 10;

--- Which countries abstain from the vote the most often?
SELECT 
    current_seat_name,
    COUNT(CASE WHEN amended_vote = 'abstaining' THEN 1 END) AS number_of_votes
FROM all_votes_rs077
GROUP BY current_seat_name
ORDER BY number_of_votes DESC
LIMIT 10;

--- Which countries do not vote the most often?
SELECT 
    current_seat_name,
    COUNT(CASE WHEN amended_vote = 'not voting' THEN 1 END) AS number_of_votes
FROM all_votes_rs077
GROUP BY current_seat_name
ORDER BY number_of_votes DESC
LIMIT 10;

--- How many votes AND meetings there are a year and how many of meetings are "important"?
WITH yearly_stats AS (
    SELECT
        meeting_year,
        COUNT(*) AS yearly_count,
        COUNT(DISTINCT meeting_record_id) AS meetings_a_year,
        COUNT(DISTINCT CASE WHEN important = 'important' THEN meeting_record_id END) AS number_important
    FROM all_votes_rs077
    GROUP BY meeting_year
)
SELECT
    meeting_year,
    yearly_count,
    meetings_a_year,
    number_important,
    ROUND(CORR(meetings_a_year, yearly_count) OVER ()::numeric, 4) AS corr_meetings_votes
FROM yearly_stats
ORDER BY meeting_year;

--- How did voting activity change after 2014 and 2022?
WITH avg_2000_2013 AS (
    SELECT ROUND(AVG(yearly_count), 2) AS val
    FROM (
        SELECT meeting_year, COUNT(*) AS yearly_count
        FROM all_votes_rs077
        WHERE meeting_year BETWEEN 2000 AND 2013
        GROUP BY meeting_year
    ) AS sub
),
avg_2014_2015 AS (
    SELECT ROUND(AVG(yearly_count), 2) AS val
    FROM (
        SELECT meeting_year, COUNT(*) AS yearly_count
        FROM all_votes_rs077
        WHERE meeting_year BETWEEN 2014 AND 2015
        GROUP BY meeting_year
    ) AS sub
),
avg_2016_2021 AS (
    SELECT ROUND(AVG(yearly_count), 2) AS val
    FROM (
        SELECT meeting_year, COUNT(*) AS yearly_count
        FROM all_votes_rs077
        WHERE meeting_year BETWEEN 2016 AND 2021
        GROUP BY meeting_year
    ) AS sub
),
votes_2022 AS (
    SELECT ROUND(AVG(yearly_count), 2) AS val
    FROM (
        SELECT meeting_year, COUNT(*) AS yearly_count
        FROM all_votes_rs077
        WHERE meeting_year = 2022
        GROUP BY meeting_year
    ) AS sub
)
SELECT 
    (SELECT val FROM avg_2000_2013) AS avg_votes_2000_2013,
    (SELECT val FROM avg_2014_2015) AS avg_votes_2014_2015,
	(SELECT val FROM avg_2016_2021) AS avg_votes_2016_2021,
	(SELECT val FROM votes_2022) AS votes_2022;
