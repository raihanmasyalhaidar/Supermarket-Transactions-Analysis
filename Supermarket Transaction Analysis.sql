CREATE TABLE pos_operator_logs (
	id INT PRIMARY KEY,
	Workstation_Group_ID INT NOT NULL,
	Workstation_ID INT NOT NULL,
	begin_date_time TIMESTAMP NOT NULL,
	operator_id INT NOT NULL
);

CREATE TABLE pos_transactions (
	id INT PRIMARY KEY,
	WorkstationGroupID INT NOT NULL,
	begin_date_time TIMESTAMP NOT NULL,
	end_date_time TIMESTAMP NOT NULL,
	OperatorID INT NOT NULL,
	basket_size INT NOT NULL,
	t_cash BOOLEAN NOT NULL,
	t_card BOOLEAN NOT NULL,
	amount NUMERIC (15, 2) NOT NULL
);

-- Exploring the Data from pos_operator_logs
SELECT * FROM pos_operator_logs LIMIT 10;

-- Exploring the Data from pos_transactions
SELECT * FROM pos_transactions LIMIT 10;

-- Do people spend more per transaction when using cash or card
SELECT
	AVG(CASE WHEN t_cash AND NOT t_card THEN amount END) AS cash_transactions,
	AVG(CASE WHEN t_card AND NOT t_cash THEN amount END) AS card_transactions
FROM pos_transactions;

SELECT ROUND(AVG(amount), 2)
FROM pos_transactions
WHERE t_cash AND NOT t_card;

SELECT ROUND(AVG(amount), 2)
FROM pos_transactions
WHERE t_card AND NOT t_cash;

-- Exploring Sunday Trading
SELECT
	DATE_PART('week', end_date_time:: DATE) as week_num,
	end_date_time::DATE AS end_date
FROM pos_transactions
WHERE EXTRACT(YEAR FROM end_date_time) >= '2019'
	AND end_date_time::DATE IN ('2019-02-24','2019-03-31','2019-02-17','2019-04-07')
GROUP BY end_date;

-- Analysis of Daily Trends
SELECT
	DATE_PART('week', end_date_time::DATE) AS week_num,
	end_date_time::DATE AS end_date,
	COUNT(DISTINCT(id)) AS total_transactions,
	SUM(amount) AS total_sales,
	ROUND(AVG(amount), 2) AS avg_sale_amount
FROM pos_transactions
WHERE EXTRACT(YEAR FROM (end_date_time)) >= '2019'
GROUP BY end_date
ORDER BY week_num, total_transactions;

-- Add Average and median basket_size per day in 2019
SELECT
	DATE_PART('week', end_date_time::DATE) as week_num,
	end_date_time::DATE AS end_date,
	COUNT(id) AS total_transactions,
	SUM(amount) AS total_sales,
	AVG(amount) AS avg_sale_amount,
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY amount) AS median_sale_amount,
	AVG(basket_size) AS avg_basket_size,
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY basket_size) AS median_basket_size
FROM pos_transactions
WHERE EXTRACT(YEAR FROM end_date_time) >= '2019'
GROUP BY (end_date) ORDER BY week_num;

-- Should the supermarket open on Sundays?
SELECT
	DATE_PART('week', end_date_time::DATE) AS week_num,
	SUM(amount)
FROM pos_transactions
WHERE EXTRACT(YEAR FROM end_date_time) >= '2019' AND 
	DATE_PART('week', end_date_time::DATE) IN (8, 14)
GROUP BY DATE_PART('week', end_date_time::DATE);

-- How much does labor cost?
SELECT
	(begin_date_time::DATE) AS working_day,
	COUNT(DISTINCT(operator_id)),
	DATE_PART('week', (begin_date_time::DATE)) AS week_num
FROM pos_operator_logs
WHERE EXTRACT(YEAR FROM begin_date_time) >= '2019'
GROUP BY working_day;

-- Operator Performance and Revenue Analysis (Which operator generates the highest revenue in a specific month?)
SELECT
	OperatorID,
	COUNT(id) AS total_transactions,
	SUM(amount) AS total_revenue,
	ROUND(AVG(amount),2) AS avg_transaction_value
FROM pos_transactions
GROUP BY OperatorID
ORDER BY total_revenue DESC
LIMIT 5;

-- Workstation Utilization (Which workstation is most frequently used by the operator for transactions?)
SELECT
	Workstation_ID,
	COUNT(id) AS usage_count
FROM pos_operator_logs
GROUP BY Workstation_ID
ORDER BY usage_count DESC
LIMIT 5;

-- Peak Transaction Times (At what time do the most transactions occur?)
SELECT
	DATE_PART('hour', begin_date_time) AS transaction_hour,
	COUNT(id) AS total_transactions
FROM pos_transactions
GROUP BY DATE_PART('hour', begin_date_time)
ORDER BY total_transactions DESC
LIMIT 5;

-- Is there a relationship between basket size and transaction value (amount)?
SELECT
	basket_size,
	AVG(amount) AS avg_transaction_value,
	COUNT(id) AS total_transactions
FROM pos_transactions
GROUP BY basket_size
ORDER BY avg_transaction_value DESC
LIMIT 10;

-- Which transaction took the longest time from begin_date_time to end_date_time?
SELECT
	id,
	EXTRACT(EPOCH FROM end_date_time - begin_date_time)/60 AS transaction_duration_minutes,
	amount
FROM pos_transactions
ORDER BY transaction_duration_minutes DESC
LIMIT 10;

-- How many transactions were performed by each operator during their login?
SELECT
	o.operator_id,
	COUNT(t.id) AS total_transactions
FROM pos_operator_logs o
LEFT JOIN pos_transactions t
ON o.operator_id = t.OperatorID
 AND t.begin_date_time BETWEEN o.begin_date_time AND o.begin_date_time + INTERVAL '8 hours'
    o.operator_id,
    COUNT(t.id) AS total_transactions
FROM pos_operator_logs o
LEFT JOIN pos_transactions t
    ON o.operator_id = t.OperatorID
    AND t.begin_date_time BETWEEN o.begin_date_time AND o.begin_date_time + INTERVAL '8 hours'
GROUP BY o.operator_id
ORDER BY total_transactions DESC;