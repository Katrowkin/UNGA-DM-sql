--- Which countries amend their votes most often?
SELECT
    member_state,
    COUNT(*) FILTER (WHERE vote_was_amended = 1) AS num_of_amnd_votes,
	COUNT(*) FILTER (WHERE vote_was_amended = 1 AND amended_vote = 'in favor') AS amnd_in_favor,
	COUNT(*) FILTER (WHERE vote_was_amended = 1 AND amended_vote = 'against') AS amnd_against,
	COUNT(*) FILTER (WHERE vote_was_amended = 1 AND amended_vote = 'abstaining') AS amnd_abstaining,
	COUNT(*) FILTER (WHERE vote_was_amended = 1 AND amended_vote = 'not voting') AS amnd_not_voting,
	COUNT(*) AS all_votes,
    ROUND(COUNT(*) FILTER (WHERE vote_was_amended = 1) * 100.0 / NULLIF(COUNT(*), 0), 2) AS amnd_share_pct
FROM public.all_votes_rs077
GROUP BY member_state
ORDER BY num_of_amnd_votes DESC, amnd_share_pct DESC;

--- When were the most votes amended?
SELECT
	meeting_year,
	COUNT(*) FILTER (WHERE vote_was_amended = 1) AS number_of_amended_votes,
    COUNT(*) AS all_votes,
    ROUND(COUNT(*) FILTER (WHERE vote_was_amended = 1) * 100.0 / NULLIF(COUNT(*), 0), 2) AS amended_share_pct
FROM public.all_votes_rs077
GROUP BY meeting_year
ORDER BY number_of_amended_votes DESC, amended_share_pct DESC;

	
	--- On which topics were the votes most amended?
SELECT
	decision_topic,
	COUNT(*) FILTER (WHERE vote_was_amended = 1) AS number_of_amended_votes,
    COUNT(*) AS all_votes,
    ROUND(COUNT(*) FILTER (WHERE vote_was_amended = 1) * 100.0 / NULLIF(COUNT(*), 0), 2) AS amended_share_pct
FROM public.all_votes_rs077
GROUP BY decision_topic
ORDER BY number_of_amended_votes DESC, amended_share_pct DESC;

--- Which world regions amend their votes most often?
WITH world_regions AS (
    SELECT 'Europe' AS region, unnest(ARRAY[
        'Albania', 'Andorra', 'Armenia', 'Austria', 'Azerbaijan', 'Belarus',
        'Belgium', 'Bosnia and Herzegovina', 'Bulgaria', 'Croatia', 'Cyprus',
        'Czech Republic', 'Czechia', 'Denmark', 'Estonia', 'Finland', 'France',
        'Georgia', 'Germany', 'Greece', 'Hungary', 'Iceland', 'Ireland',
        'Italy', 'Latvia', 'Liechtenstein', 'Lithuania', 'Luxembourg',
        'Malta', 'Moldova', 'Monaco', 'Montenegro', 'Netherlands',
        'North Macedonia', 'Norway', 'Poland', 'Portugal', 'Romania',
        'Russia', 'Russian Federation', 'San Marino', 'Serbia', 'Slovakia',
        'Slovenia', 'Spain', 'Sweden', 'Switzerland', 'Turkey', 'Türkiye',
        'Ukraine', 'United Kingdom'
    ]) AS country
    UNION ALL
    SELECT 'Middle East', unnest(ARRAY[
        'Bahrain', 'Iran', 'Iran (Islamic Republic of)', 'Iraq', 'Israel',
        'Jordan', 'Kuwait', 'Lebanon', 'Oman', 'Qatar', 'Saudi Arabia',
        'Syria', 'Syrian Arab Republic', 'United Arab Emirates', 'Yemen'
    ])
    UNION ALL
    SELECT 'Africa', unnest(ARRAY[
        'Algeria', 'Angola', 'Benin', 'Botswana', 'Burkina Faso', 'Burundi',
        'Cabo Verde', 'Cape Verde', 'Cameroon', 'Central African Republic',
        'Chad', 'Comoros', 'Congo', 'Côte d''Ivoire', 'Cote d''Ivoire',
        'CГґte dвЂ™Ivoire', 'Democratic Republic of the Congo', 'Djibouti',
        'Egypt', 'Equatorial Guinea', 'Eritrea', 'Estonia' /* remove if not needed */,
        'Eswatini', 'Swaziland', 'Ethiopia', 'Gabon', 'Gambia', 'Ghana',
        'Guinea', 'Guinea-Bissau', 'Kenya', 'Lesotho', 'Liberia', 'Libya',
        'Madagascar', 'Malawi', 'Mali', 'Mauritania', 'Mauritius', 'Morocco',
        'Mozambique', 'Namibia', 'Niger', 'Nigeria', 'Rwanda',
        'Sao Tome and Principe', 'São Tomé and Príncipe', 'Senegal',
        'Seychelles', 'Sierra Leone', 'Somalia', 'South Africa', 'South Sudan',
        'Sudan', 'Tanzania', 'United Republic of Tanzania', 'Togo', 'Tunisia',
        'Uganda', 'Zambia', 'Zimbabwe'
    ])
    UNION ALL
    SELECT 'Asia', unnest(ARRAY[
        'Afghanistan', 'Bangladesh', 'Bhutan', 'Brunei Darussalam', 'Cambodia',
        'China', 'India', 'Indonesia', 'Japan', 'Kazakhstan', 'Kyrgyzstan',
        'Laos', 'Lao People''s Democratic Republic', 'Malaysia', 'Maldives',
        'Mongolia', 'Myanmar', 'Burma', 'Nepal', 'North Korea',
        'Democratic People''s Republic of Korea', 'Pakistan', 'Philippines',
        'Singapore', 'South Korea', 'Republic of Korea', 'Sri Lanka',
        'Tajikistan', 'Thailand', 'Timor-Leste', 'Turkmenistan',
        'Uzbekistan', 'Viet Nam', 'Vietnam'
    ])
    UNION ALL
    SELECT 'Oceania', unnest(ARRAY[
        'Australia', 'Fiji', 'Federated States of Micronesia', 'Micronesia',
        'Kiribati', 'Marshall Islands', 'Nauru', 'New Zealand', 'Palau',
        'Papua New Guinea', 'Samoa', 'Solomon Islands', 'Tonga', 'Tuvalu',
        'Vanuatu'
    ])
    UNION ALL
    SELECT 'North America', unnest(ARRAY[
        'Canada', 'Mexico', 'United States', 'United States of America'
    ])
    UNION ALL
    SELECT 'Latin America and the Caribbean', unnest(ARRAY[
        'Antigua and Barbuda', 'Argentina', 'Bahamas', 'Barbados', 'Belize',
        'Bolivia', 'Bolivia (Plurinational State of)', 'Brazil', 'Chile',
        'Colombia', 'Costa Rica', 'Cuba', 'Dominica', 'Dominican Republic',
        'Ecuador', 'El Salvador', 'Grenada', 'Guatemala', 'Guyana', 'Haiti',
        'Honduras', 'Jamaica', 'Nicaragua', 'Panama', 'Paraguay', 'Peru',
        'Saint Kitts and Nevis', 'Saint Lucia',
        'Saint Vincent and the Grenadines', 'Suriname', 'Trinidad and Tobago',
        'Uruguay', 'Venezuela', 'Venezuela (Bolivarian Republic of)'
    ])
),
cleaned_regions AS (
    SELECT DISTINCT region, country
    FROM world_regions
    WHERE country <> 'Estonia'
),
votes_with_region AS (
    SELECT
        p.member_state,
        p.member_state_id,
        COALESCE(wr.region, 'Other / Unmapped') AS region,
        p.vote_was_amended
    FROM public.all_votes_rs077 AS p
    LEFT JOIN cleaned_regions AS wr
        ON p.member_state = wr.country
)
SELECT
    region,
    COUNT(DISTINCT member_state_id) AS countries_in_region,
    COUNT(*) FILTER (WHERE vote_was_amended = 1) AS number_of_amended_votes,
    COUNT(*) AS all_votes,
    ROUND(COUNT(*) FILTER (WHERE vote_was_amended = 1) * 100.0 / NULLIF(COUNT(*), 0), 2) AS amended_share_pct
FROM votes_with_region
GROUP BY region
ORDER BY number_of_amended_votes DESC, amended_share_pct DESC;
