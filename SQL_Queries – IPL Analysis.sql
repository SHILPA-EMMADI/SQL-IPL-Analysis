select * from iplplayers;
--  the total spending on players for each team:
select team ,sum(price_in_cr) as totalamount
from iplplayers
group by team;

-- higherst paid allrounders acreoss all teams 
select * from iplplayers
where role = "all-rounder"
order by price_in_cr desc
limit 3 ;

-- Highest priced player in each team

WITH high AS (
    SELECT 
        team,
        MAX(price_in_cr) AS max_price
    FROM iplplayers
    GROUP BY team
)
SELECT 
    p.team,
    p.player,
    p.price_in_cr
FROM iplplayers p
JOIN high h
ON p.team = h.team
AND p.price_in_cr = h.max_price;


-- rank players by their price within eachteam and list top two
SELECT *
FROM (
    SELECT *,
           RANK() OVER (
               PARTITION BY team
               ORDER BY price_in_cr DESC
           ) AS player_rank
    FROM iplplayers
) AS ranked_players
WHERE player_rank <= 2;

SELECT player, price_in_cr,type,acquisition,role,team
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY team
               ORDER BY price_in_cr DESC
           ) AS player_rank
    FROM iplplayers
) AS ranked
WHERE player_rank <= 2;

-- first most expensive and second most in every team 

WITH ranked AS (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY team
               ORDER BY price_in_cr DESC
           ) AS player_rank
    FROM iplplayers
)
SELECT
    team,
    MAX(CASE WHEN player_rank = 1 THEN player END) AS highest_player,
    MAX(CASE WHEN player_rank = 1 THEN price_in_cr END) AS highest_price,
    MAX(CASE WHEN player_rank = 2 THEN player END) AS second_player,
    MAX(CASE WHEN player_rank = 2 THEN price_in_cr END) AS second_price
FROM ranked
GROUP BY team;

-- player price contribution in their teams total price 

WITH team_summary AS (
    SELECT team, SUM(price_in_cr) AS team_total
    FROM iplplayers
    GROUP BY team
)
SELECT
    p.team,
    p.player,
    p.price_in_cr,
    s.team_total,
    ROUND(p.price_in_cr * 100.0 / s.team_total, 2)
        AS contribution_percentage
FROM iplplayers p
JOIN team_summary s
ON p.team = s.team;



WITH team_summary AS (
    SELECT team, SUM(price_in_cr) AS team_total
    FROM iplplayers
    GROUP BY team
)
SELECT
    p.team,
    p.player,
    p.price_in_cr,
    s.team_total,
    ROUND(p.price_in_cr * 100.0 / s.team_total, 2)
        AS contribution_percentage
FROM iplplayers p
JOIN team_summary s
ON p.team = s.team;


-- Categorize IPL players based on their price:
-- High: Price > 15 Crores
-- Medium: Price BETWEEN 5 and 15 Crores
-- Low: Price < 5 Crores
-- Find the number of players in each price category
-- within every team.


WITH player_category AS (
    SELECT *,
           CASE
               WHEN price_in_cr > 15 THEN 'High'
               WHEN price_in_cr < 5 THEN 'Low'
               ELSE 'Medium'
           END AS price_category
    FROM iplplayers
)
SELECT
    team,
    price_category,
    COUNT(*) AS player_count
FROM player_category
GROUP BY team, price_category
ORDER BY team, price_category;

-- Find the average price of Indian players
-- and compare it with the average price of overseas players.
-- Use a subquery to calculate and compare both averages.

SELECT
    (SELECT AVG(Price_in_cr)
     FROM IPLPlayers
     WHERE Type LIKE 'Indian%') AS Indian_Avg_Price,

    (SELECT AVG(Price_in_cr)
     FROM IPLPlayers
     WHERE Type like  'Overseas%') AS Overseas_Avg_Price;
 
 
 -- Find players who earn more than the average price
-- of players in their respective teams.
-- Display player name, team, and price.
     
     SELECT Player, Team, Price_in_cr
FROM IPLPlayers p
WHERE Price_in_cr > (
    SELECT AVG(Price_in_cr)
    FROM IPLPlayers
    WHERE Team = p.Team
);

-- Find players whose price is greater than the average price
-- of other players in their respective teams.
-- Exclude the current player while calculating the team average.
-- Display player name, team, and price.



SELECT Player, Team, Price_in_cr
FROM IPLPlayers p
WHERE Price_in_cr > (
    SELECT AVG(Price_in_cr)
    FROM IPLPlayers
    WHERE Team = p.Team
      AND Player <> p.Player
);


-- Find the highest-priced player in each role within every team.
-- Display player name, team, role, and price.
-- Use a correlated subquery.

SELECT
    Player,
    Team,
    Role,
    Price_in_cr
FROM IPLPlayers p
WHERE Price_in_cr = (
    SELECT MAX(Price_in_cr)
    FROM IPLPlayers
    WHERE Team = p.Team
      AND Role = p.Role
);








