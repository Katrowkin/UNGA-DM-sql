# UNGA-DM-sql
United Nations General Assembly Decision-Making dataset (PostgreSQL)

An ongoing personal data analytics project exploring United Nations General Assembly voting records (`All_Votes_RS-077`) using PostgreSQL. This repository contains SQL scripts designed to perform descriptive voting analysis and compute international voting alignment (similarity indices) between specific countries and the European Union.

# Repository Structure
`All_Votes_RS-077.csv`: The starter dataset containing UN General Assembly voting records (including resolutions, meeting records, years, countries/seats, and amended vote outcomes).
`descriptive_analysis_on_voting_statistics.sql`: Queries focusing on high-level trends, yearly meeting frequencies, important resolution counts, and breakdown of voting positions (in favor, against, abstaining, not voting) by country, alongside historical breakpoint comparisons (pre-2014, 2014–2015, 2016–2021, and 2022–2023).
`similarity-index.sql`: Advanced analytical queries utilizing self-joins and Common Table Expressions (CTEs) to calculate voting alignment percentages and coincidence proportions (e.g., Germany vs. Ukraine, and EU consensus vs. Ukraine).

# Key Analyses Included

1. Descriptive Voting Statistics (`descriptive_analysis_on_voting_statistics.sql`)
Yearly Volume & Importance, National Voting Tendencies
Structural changes in voting activity across key historical windows

2. Voting Similarity & Alignment Indices (`similarity-index.sql`)

Computes exact match percentages and joint voting behaviors between specific countries on resolutions where both actively participated.
Generates an EU consensus baseline (filtering for resolutions where all 27 EU member states share a unified vote) and measures other nations' alignment

# Tech Stack

Database: PostgreSQL.
Techniques: Aggregate functions, Window functions, CTEs (Common Table Expressions), Conditional Filtering (`FILTER (WHERE ...)`), Self-Joins.

---

*Note: This is an ongoing project; further analytical modules and visualizations are planned.*
