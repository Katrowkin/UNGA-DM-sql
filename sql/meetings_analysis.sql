--- How many meetings there are a year and how many of them are "important"?
SELECT
    meeting_year,
    COUNT(DISTINCT meeting_record_id) AS meetings_a_year,
    COUNT(DISTINCT CASE WHEN important = 'important' THEN meeting_record_id END) AS number_important
FROM all_votes_rs077
GROUP BY meeting_year;

--- How many meetings there are a year and how many of them are "important" on average?
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
	COUNT(DISTINCT session_id) AS n_meetings
FROM all_votes_rs077
GROUP BY meeting_year, meeting_month
ORDER BY n_meetings DESC;

--- When do the most meetings happen by month?
SELECT
	meeting_month,
	COUNT(DISTINCT session_id) AS n_meetings
FROM all_votes_rs077
GROUP BY meeting_month

--- How long do different session types last?
WITH unique_sessions AS (
    SELECT DISTINCT
        session_id,
        session_type,
        (TO_DATE(end_date, 'DD.MM.YYYY') - TO_DATE(start_date, 'DD.MM.YYYY')) AS duration_days
    FROM all_votes_rs077
    WHERE start_date IS NOT NULL
      AND end_date IS NOT NULL
)
SELECT
    session_type,
    COUNT(*) AS n_sessions,
    ROUND(AVG(duration_days), 1) AS avg_duration_days,
    MIN(duration_days) AS min_duration_days,
    MAX(duration_days) AS max_duration_days
FROM unique_sessions
GROUP BY session_type
ORDER BY avg_duration_days DESC;

--- How long do different session types last? (broadened)
WITH unique_sessions AS (
    SELECT DISTINCT
        session_id,
        session_type,
        start_date,
        end_date,
        (TO_DATE(end_date, 'DD.MM.YYYY') - TO_DATE(start_date, 'DD.MM.YYYY')) AS duration_days
    FROM all_votes_rs077
    WHERE start_date IS NOT NULL
      AND end_date IS NOT NULL
)
SELECT
    session_id,
    session_type,
    start_date,
    end_date,
    duration_days
FROM unique_sessions
ORDER BY duration_days DESC;