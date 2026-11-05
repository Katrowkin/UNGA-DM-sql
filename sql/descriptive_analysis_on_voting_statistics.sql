--- How many votings there are a year and how many of them are "important"?
SELECT 
    meeting_year,
    COUNT(DISTINCT meeting_record_id) AS meetings_a_year,
    COUNT(CASE WHEN important = 'important' THEN 1 END) AS number_important
FROM all_votes_rs077
GROUP BY meeting_year;

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
avg_2022_2023 AS (
    SELECT ROUND(AVG(yearly_count), 2) AS val
    FROM (
        SELECT meeting_year, COUNT(*) AS yearly_count
        FROM all_votes_rs077
        WHERE meeting_year BETWEEN 2022 AND 2023
        GROUP BY meeting_year
    ) AS sub
)
SELECT 
    (SELECT val FROM avg_2000_2013) AS avg_votes_2000_2013,
    (SELECT val FROM avg_2014_2015) AS avg_votes_2014_2015,
	(SELECT val FROM avg_2016_2021) AS avg_votes_2016_2021,
	(SELECT val FROM avg_2022_2023) AS avg_votes_2022_2023;
