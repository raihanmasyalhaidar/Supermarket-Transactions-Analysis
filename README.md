<div align="center">

# Supermarket Transactions Analysis in PostgreSQL

</div>

<div align="justify">

![image](https://github.com/user-attachments/assets/f1810c63-9443-433c-8bb5-2cede3fff19b)

## Overview
Supermarkets are complex retail operations that handle a massive volume of transactions and operational data daily. These transactions include purchases made by customers using various payment methods (cash, card, or digital wallets) and involve multiple employees (operators) managing checkout counters or self-service kiosks. Effective management and analysis of this data are crucial for optimizing performance, improving customer experience, and identifying potential inefficiencies or fraudulent activities.

In this project, we analyze transactional and operational data from a supermarket using two datasets:
1. pos_transactions: Contains information on all transactions, including amounts, payment methods, and basket sizes.
2. pos_operator_logs: Records login details of operators, including timestamps and workstation IDs.

The aim is to derive actionable insights about operator performance, revenue generation patterns, and potential inefficiencies or anomalies in operations. The project employs SQL for data exploration and visualization to drive decisions that improve productivity, identify fraud, and optimize supermarket operations.

## Objectives
1. Analyze Operator Performance:
   * Measure operator efficiency by evaluating transactions handled during their login shifts
   * Identify operators with high or low productivity levels
2. Evaluate Revenue Patterns:
   * Analyze revenue trends by time, workstation, and operator
   * Identify high-performing and underperforming workstation groups
3. Detect Anomalies or Fraud:
   * Detect transactions made without a valid operator login
   * Find operators with suspicious transaction patterns (e.g., unusually high-value transactions)
4. Optimize Operations:
   * Discover peak revenue hours to improve staffing schedules
   * Evaluate workstation and operator group performance for resource optimization

## Datasets
The data used comes from https://www.mdpi.com/2306-5729/4/2/67, consisting of two tables: pos_transactions and pos_operator_logs, with the following descriptions:

### 1. `pos_transactions`
This table contains detailed information about every transaction conducted in the supermarket.

| Column Name         | Data Type   | Description                                                   |
|---------------------|-------------|---------------------------------------------------------------|
| `id`                | INT         | Unique identifier for each transaction.                      |
| `WorkstationGroupID`| INT         | ID of the workstation group where the transaction occurred.   |
| `begin_date_time`   | TIMESTAMP   | Start time of the transaction.                               |
| `end_date_time`     | TIMESTAMP   | End time of the transaction.                                 |
| `OperatorID`        | INT         | ID of the operator who processed the transaction.            |
| `basket_size`       | INT         | Number of items in the basket.                               |
| `t_cash`            | BOOLEAN     | True if the transaction was paid in cash, False otherwise.   |
| `t_card`            | BOOLEAN     | True if the transaction was paid by card, False otherwise.   |
| `amount`            | NUMERIC     | Total value of the transaction in currency format (15, 2).   |

---

### 2. `pos_operator_logs`
This table records operator login sessions at the supermarket's Point-of-Sale (POS) system.

| Column Name           | Data Type   | Description                                          |
|-----------------------|-------------|------------------------------------------------------|
| `id`                  | INT         | Unique identifier for each log entry.               |
| `Workstation_Group_ID`| INT         | ID of the workstation group where the operator logged in. |
| `Workstation_ID`      | INT         | ID of the specific workstation where the operator logged in. |
| `begin_date_time`     | TIMESTAMP   | Time when the operator logged in.                   |
| `operator_id`         | INT         | ID of the operator who logged in.                   |

---

## Technologies Used
* Database : PostgreSQL, Microsoft Excel
* Query Language : SQL

## Analysis
Here are some analysis I used in this repository
* Do more people make transactions by card or by cash?
```SQL
SELECT
	AVG(CASE WHEN t_cash AND NOT t_card THEN amount END) AS cash_transactions,
	AVG(CASE WHEN t_card AND NOT t_cash THEN amount END) AS card_transactions
FROM pos_transactions;
```
![image](https://github.com/user-attachments/assets/22b1ab47-7ddb-4ffc-ab99-a9e6594e6942)

From the results obtained, it is known that people tend to spend more money on shopping when using a card.

* Analysis of daily trends
```SQL
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
```
![image](https://github.com/user-attachments/assets/ff3c79d0-8104-4653-b4e5-2a5e544aeb46)

From the data, it is evident that weekends, especially Saturdays, recorded the highest transactions and sales, such as on April 6, 2019, with total sales of 430,575.40. Week 14 was the best-performing week with total sales of 1,690,989.87, while Week 9 had the lowest performance. The average sales per transaction tend to be higher on weekends compared to weekdays. Promotional strategies can be focused on weekends, while additional incentives can be applied on low-performing days to boost sales.

* Should the supermarket open on sundays?
```SQL
SELECT
	DATE_PART('week', end_date_time::DATE) AS week_num,
	SUM(amount)
FROM pos_transactions
WHERE EXTRACT(YEAR FROM end_date_time) >= '2019' AND 
	DATE_PART('week', end_date_time::DATE) IN (8, 14)
GROUP BY DATE_PART('week', end_date_time::DATE);
```
![image](https://github.com/user-attachments/assets/5c1f886b-4f03-467b-9cbd-2ed46e1aab8f)

From the results shown in the table, Week 8 recorded total sales of 1,686,485.72, while Week 14 recorded total sales of 1,690,989.87. The difference between the two is very small, indicating that sales during both weeks were quite consistent and high. In general, considering the stable weekly sales performance, there is potential that opening the store on Sundays could further increase total sales. This is especially relevant if customers tend to shop more during weekends.

* Operator Performance and Revenue Analysis
```SQL
SELECT
	OperatorID,
	COUNT(id) AS total_transactions,
	SUM(amount) AS total_revenue,
	ROUND(AVG(amount),2) AS avg_transaction_value
FROM pos_transactions
GROUP BY OperatorID
ORDER BY total_revenue DESC
LIMIT 5;
```
![image](https://github.com/user-attachments/assets/7b54faa6-eb45-4d54-91fa-66a69abee699)

From the provided data, the operator with the highest revenue in a given month is Operator ID 119, with total revenue of 587,517.53. This operator recorded a total of 6,944 transactions, with an average transaction value of 84.61. The high revenue is attributed to the combination of a large transaction volume and a relatively high average transaction value compared to other operators.

Although Operator ID 114 has the highest average transaction value of 90.02, their total revenue is lower because they handled fewer transactions, totaling 5,882. This indicates that the main factor contributing to the highest revenue is the high volume of transactions processed by Operator ID 119.

* Workstation Utilization
```SQL
SELECT
	Workstation_ID,
	COUNT(id) AS usage_count
FROM pos_operator_logs
GROUP BY Workstation_ID
ORDER BY usage_count DESC
LIMIT 5;
```

![image](https://github.com/user-attachments/assets/3fa733d3-58dd-4609-a284-2cdf3bc286a1)

Based on the analysis, Workstation 4 is the most frequently used workstation by operators for transactions, with a total of 1,764 logged transactions. Workstation 5 ranks second with 902 transactions, followed by Workstations 6, 7, and 8 with 864, 830, and 720 transactions, respectively. This indicates a significant disparity in workstation usage, with Workstation 4 being utilized far more frequently than the others. This information can be used to evaluate workload distribution and ensure operational efficiency, such as by optimizing the use of underutilized workstations or enhancing the capacity of heavily used ones.

* Peak Transaction Times
```SQL
SELECT
	DATE_PART('hour', begin_date_time) AS transaction_hour,
	COUNT(id) AS total_transactions
FROM pos_transactions
GROUP BY DATE_PART('hour', begin_date_time)
ORDER BY total_transactions DESC
LIMIT 5;
```
![image](https://github.com/user-attachments/assets/452b7dae-c7e7-469c-a200-bef9291b1c5c)

Based on the data, it can be concluded that the peak transaction times occur at 11:00 AM with a total of 14,153 transactions, followed by 12:00 PM with 14,146 transactions. After that, the number of transactions gradually decreased at 1:00 PM (13,625 transactions), 2:00 PM (12,849 transactions), and 10:00 AM (12,842 transactions).

Therefore, the peak transaction period occurs between 10:00 AM and 12:00 PM, with the highest peak at 11:00 AM, indicating that midday is the busiest time for transactions. Operational strategies, such as increasing staff or enhancing services, could be focused on these hours to improve efficiency and customer experience.

* Basket Size and Revenue Correlation
```SQL
SELECT
	basket_size,
	AVG(amount) AS avg_transaction_value,
	COUNT(id) AS total_transactions
FROM pos_transactions
GROUP BY basket_size
ORDER BY avg_transaction_value DESC
LIMIT 10;
```
![image](https://github.com/user-attachments/assets/29ff06a3-a6f4-475d-b002-ed9781c5bee7)

Based on the results, there is generally a positive relationship between basket size and average transaction value. When the basket size is larger, the transaction value tends to be higher. For example, larger basket sizes like 240 and 236 have higher transaction values compared to smaller basket sizes. Although there are some variations, this pattern suggests that customers who buy more items usually spend more money. However, other factors such as the types of items or promotions can also influence the transaction value, so this relationship is not entirely consistent.

* Longest Transaction
```SQL
SELECT
	id,
	ROUND(EXTRACT(EPOCH FROM end_date_time - begin_date_time)/60, 2) AS transaction_duration_minutes,
	amount
FROM pos_transactions
ORDER BY transaction_duration_minutes DESC
LIMIT 10;
```
![image](https://github.com/user-attachments/assets/699ce251-7c12-4aa2-84c3-99b5632685fc)

The analysis reveals that the transaction with ID 98366 took the longest time to complete, with a duration of 18.95 minutes and an associated amount of 346.80. Following this, transactions with IDs 152416 and 62820 had durations of 16.57 and 16.38 minutes, respectively, with amounts of 291.96 and 399.21. The durations of the remaining transactions in the top 10 ranged from 12.68 minutes to 15.72 minutes, with varying transaction amounts. This information highlights that some transactions take considerably longer than others, which may be due to complex processes or other factors. Identifying the causes of these delays can help optimize transaction efficiency and improve overall system performance.
