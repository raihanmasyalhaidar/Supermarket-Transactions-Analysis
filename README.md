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
* Exploring the Data
* Do more people make transactions by card or by cash?
* Do people spend more per transaction when using cash or card?
* Exploring Sunday Trading
* Analysis of daily trends
* Should the supermarket open on sundays?
* How much does labor cost?
