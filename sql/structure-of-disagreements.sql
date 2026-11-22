--- Solution type: where countries diverge the most
SELECT 
    decision_topic,
    COUNT(*) FILTER (WHERE original_vote = 'in favor') AS count_in_favor,
    COUNT(*) FILTER (WHERE original_vote = 'against') AS count_against,
    COUNT(*) FILTER (WHERE original_vote = 'abstaining') AS count_abstaining,
    COUNT(*) FILTER (WHERE original_vote = 'not voting') AS count_not_voting,
    COUNT(*) AS total_country_votes
FROM public.all_votes_rs077
GROUP BY decision_topic
ORDER BY total_country_votes DESC;


--- Group cohesion
WITH bloc_members AS (
    SELECT 'EU' AS bloc, unnest(ARRAY[
        'Austria', 'Belgium', 'Bulgaria', 'Croatia', 'Cyprus', 'Czechia',
        'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece',
        'Hungary', 'Ireland', 'Italy', 'Latvia', 'Lithuania', 'Luxembourg',
        'Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania', 'Slovakia',
        'Slovenia', 'Spain', 'Sweden'
    ]) AS country
    UNION ALL
    SELECT 'NATO', unnest(ARRAY[
        'Albania', 'Belgium', 'Bulgaria', 'Canada', 'Croatia', 'Czechia',
        'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece',
        'Hungary', 'Iceland', 'Italy', 'Latvia', 'Lithuania', 'Luxembourg',
        'Montenegro', 'Netherlands', 'North Macedonia', 'Norway', 'Poland',
        'Portugal', 'Romania', 'Slovakia', 'Slovenia', 'Spain', 'Sweden',
        'Türkiye', 'United Kingdom', 'United States'
    ])
    UNION ALL
    SELECT 'BRICS', unnest(ARRAY[
        'Brazil', 'Russia', 'India', 'China', 'South Africa',
        'Egypt', 'Ethiopia', 'Iran', 'United Arab Emirates', 'Indonesia'
    ])
),
decision_bloc_votes AS (
    SELECT
        v.decision_id,
        v.meeting_year,
        b.bloc,
        COUNT(*) FILTER (WHERE v.amended_vote = 'in favor') AS n_favor,
        COUNT(*) FILTER (WHERE v.amended_vote = 'against') AS n_against,
        COUNT(*) FILTER (WHERE v.amended_vote = 'abstaining') AS n_abstaining,
        COUNT(*) FILTER (WHERE v.amended_vote IN ('in favor', 'against', 'abstaining')) AS n_active_voters
    FROM public.all_votes_rs077 AS v
    JOIN bloc_members AS b
        ON v.current_seat_name = b.country
    WHERE v.amended_vote IN ('in favor', 'against', 'abstaining')
    GROUP BY
        v.decision_id,
        v.meeting_year,
        b.bloc
    HAVING COUNT(*) FILTER (WHERE v.amended_vote IN ('in favor', 'against', 'abstaining')) > 0
),
decision_metrics AS (
    SELECT
        bloc,
        meeting_year,
        GREATEST(n_favor, n_against, n_abstaining)::numeric / n_active_voters AS majority_share,
        CASE
            WHEN (n_favor + n_against) > 0
            THEN ABS(n_favor - n_against)::numeric / (n_favor + n_against)
        END AS rice_index
    FROM decision_bloc_votes
)
SELECT
    bloc,
    MIN(meeting_year) AS first_year,
    MAX(meeting_year) AS last_year,
    COUNT(*) AS decisions_all,
    COUNT(*) FILTER (WHERE meeting_year >= 2014) AS decisions_from_2014,
    COUNT(*) FILTER (WHERE meeting_year >= 2022) AS decisions_from_2022,

    ROUND(AVG(majority_share), 4) AS majority_all,
    ROUND(AVG(majority_share) FILTER (WHERE meeting_year >= 2014), 4) AS majority_from_2014,
    ROUND(AVG(majority_share) FILTER (WHERE meeting_year >= 2022), 4) AS majority_from_2022,

    ROUND(AVG(rice_index), 4) AS rice_all,
    ROUND(AVG(rice_index) FILTER (WHERE meeting_year >= 2014), 4) AS rice_from_2014,
    ROUND(AVG(rice_index) FILTER (WHERE meeting_year >= 2022), 4) AS rice_from_2022
FROM decision_metrics
GROUP BY bloc
ORDER BY rice_from_2022 DESC NULLS LAST;
