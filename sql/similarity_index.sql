--- The proportion of coincidences of votes between two countries among decisions where both voted
SELECT 
    COUNT(*) FILTER (WHERE a.amended_vote = 'in favor' AND u.amended_vote = 'in favor') AS in_favor_together,
    COUNT(*) FILTER (WHERE a.amended_vote = 'against' AND u.amended_vote = 'against') AS against_together,
    COUNT(*) FILTER (WHERE a.amended_vote = 'abstaining' AND u.amended_vote = 'abstaining') AS abstaining_together,
    COUNT(*) FILTER (WHERE a.amended_vote = u.amended_vote) AS total_same_votes,
    COUNT(*) AS total_joint_votes,
    ROUND(COUNT(*) FILTER (WHERE a.amended_vote = u.amended_vote) * 100.0 / COUNT(*), 2) AS match_percentage
FROM public.all_votes_rs077 a
JOIN public.all_votes_rs077 u 
  ON a.resolution_id = u.resolution_id
WHERE a.current_seat_name = 'Germany' 
  AND u.current_seat_name = 'Ukraine'
  AND a.amended_vote NOT IN ('absent', 'not voting')
  AND u.amended_vote NOT IN ('absent', 'not voting');



--- The proportion of coincidences of votes between the EU and other country among decisions where both voted
WITH EU_Consensus_Votes AS (
    SELECT 
        resolution_id,
        MAX(amended_vote) AS eu_vote
    FROM public.all_votes_rs077
    WHERE current_seat_name IN (
        'Austria', 'Belgium', 'Bulgaria', 'Croatia', 'Cyprus', 'Czechia', 
        'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece', 
        'Hungary', 'Ireland', 'Italy', 'Latvia', 'Lithuania', 'Luxembourg', 
        'Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania', 'Slovakia', 
        'Slovenia', 'Spain', 'Sweden'
    )
    AND amended_vote NOT IN ('absent', 'not voting')
    GROUP BY resolution_id
    HAVING COUNT(DISTINCT amended_vote) = 1
)
SELECT 
    COUNT(*) FILTER (WHERE eu.eu_vote = 'in favor' AND us.amended_vote = 'in favor') AS in_favor_together,
    COUNT(*) FILTER (WHERE eu.eu_vote = 'against' AND us.amended_vote = 'against') AS against_together,
    COUNT(*) FILTER (WHERE eu.eu_vote = 'abstaining' AND us.amended_vote = 'abstaining') AS abstaining_together,
    COUNT(*) FILTER (WHERE eu.eu_vote = us.amended_vote) AS total_same_votes,
    COUNT(*) AS total_joint_votes,
    ROUND(COUNT(*) FILTER (WHERE eu.eu_vote = us.amended_vote) * 100.0 / COUNT(*), 2) AS match_percentage
FROM EU_Consensus_Votes eu
JOIN public.all_votes_rs077 us 
  ON eu.resolution_id = us.resolution_id
WHERE us.current_seat_name = 'Ukraine'
  AND us.amended_vote NOT IN ('absent', 'not voting');
