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




--- Whose similarity to Ukraine fluctuates the most over the years?
WITH clean_votes AS (
    SELECT
        decision_id,
        meeting_year,
        decision_topic,
        current_seat_name,
        amended_vote
    FROM public.all_votes_rs077
    WHERE amended_vote IN ('in favor', 'against', 'abstaining')
      AND decision_topic IS NOT NULL
),
ukraine_votes AS (
    SELECT
        decision_id,
        amended_vote AS ua_vote
    FROM clean_votes
    WHERE current_seat_name = 'Ukraine'
),
yearly_similarity AS (
    SELECT
        v.current_seat_name AS country,
        v.decision_topic,
        v.meeting_year,
        COUNT(*) AS shared_decisions,
        AVG(CASE WHEN v.amended_vote = u.ua_vote THEN 1.0 ELSE 0.0 END) AS similarity_rate
    FROM clean_votes v
    JOIN ukraine_votes u
        ON v.decision_id = u.decision_id
    WHERE v.current_seat_name <> 'Ukraine'
    GROUP BY
        v.current_seat_name,
        v.decision_topic,
        v.meeting_year
    HAVING COUNT(*) >= 3
),
volatility_stats AS (
    SELECT
        country,
        decision_topic,
        COUNT(*) AS active_years,
        ROUND(AVG(similarity_rate)::numeric, 4) AS avg_similarity,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY similarity_rate)::numeric, 4) AS median_similarity,
        ROUND(STDDEV_SAMP(similarity_rate)::numeric, 4) AS volatility_stddev,
        ROUND((MAX(similarity_rate) - MIN(similarity_rate))::numeric, 4) AS min_max_spread
    FROM yearly_similarity
    GROUP BY
        country,
        decision_topic
    HAVING COUNT(*) >= 5
)
SELECT
    decision_topic,
    country,
    active_years,
    avg_similarity,
    median_similarity,
    volatility_stddev,
    min_max_spread,
    RANK() OVER (
        PARTITION BY decision_topic
        ORDER BY volatility_stddev DESC
    ) AS volatility_rank,
    NTILE(4) OVER (
        PARTITION BY decision_topic
        ORDER BY volatility_stddev DESC
    ) AS volatility_quartile
FROM volatility_stats
ORDER BY
    decision_topic,
    volatility_rank;



--- Is the similarity on "important" votes different from the rest?
WITH unique_votes AS (
    SELECT DISTINCT
        decision_id,
        COALESCE(NULLIF(TRIM(important), ''), 'not important') AS vote_importance,
        count_member_states,
        count_in_favor,
        count_against,
        count_abstaining,
        count_not_voting
    FROM public.all_votes_rs077
    WHERE count_member_states > 0
)
SELECT 
    vote_importance,
    COUNT(*) AS total_decisions,
    ROUND(AVG(count_in_favor::numeric / count_member_states * 100), 2) AS avg_pct_in_favor,
    ROUND(AVG(count_against::numeric / count_member_states * 100), 2) AS avg_pct_against,
    ROUND(AVG(count_abstaining::numeric / count_member_states * 100), 2) AS avg_pct_abstaining,
    ROUND(AVG(
        GREATEST(count_in_favor, count_against, count_abstaining)::numeric 
        / NULLIF(count_in_favor + count_against + count_abstaining, 0) * 100
    ), 2) AS avg_consensus_pct
FROM unique_votes
GROUP BY vote_importance
ORDER BY total_decisions DESC;