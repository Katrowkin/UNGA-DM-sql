--- How many meetings there are a year and how many of them are "important"?
SELECT
    meeting_year,
    COUNT(DISTINCT meeting_record_id) AS meetings_a_year,
    COUNT(DISTINCT CASE WHEN important = 'important' THEN meeting_record_id END) AS number_important
FROM all_votes_rs077
GROUP BY meeting_year;

--- How many meetings on average there are a year and how many of them are "important"?
WITH yearly_stats AS (
    SELECT
        meeting_year,
        COUNT(DISTINCT meeting_record_id) AS meetings_in_year,
        COUNT(DISTINCT CASE WHEN important = 'important' THEN meeting_record_id END) AS important_meetings_in_year
    FROM all_votes_rs077
    GROUP BY meeting_year
)
SELECT
    ROUND(AVG(meetings_in_year), 2) AS avg_meetings_per_year,
    ROUND(AVG(important_meetings_in_year), 2) AS avg_important_meetings_per_year
FROM yearly_stats;

--- When do the most meetings happen?
SELECT
	meeting_year,
	meeting_month,
	COUNT(DISTINCT session_id) AS meetings
FROM public.all_votes_rs077
GROUP BY meeting_year, meeting_month