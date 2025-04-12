# Walmart Sales MYSQL Project
<p align="center">
  <img src="https://raw.githubusercontent.com/SHIVANIENUGANDULA/WALMART_DATA_ANALYSIS/main/walmart_logo.jpg" alt="Walmart Logo" width="180">
</p>



## 📊 Overview

This project explores transactional sales data from three Walmart branches using SQL. The main goal is to extract insights on sales trends, customer behavior, and product performance to inform strategic decision-making. This end-to-end analysis is inspired by a hands-on walkthrough and extended with custom SQL-driven feature engineering and visual insights.

---

## 🧠 Objectives

- Identify the most profitable product lines
- Analyze customer trends by type, gender, and location
- Understand time-based sales patterns (daily, monthly, hourly)
- Classify product performance based on revenue contribution
- Explore VAT contributions, gross income, and margins
- Engineer features like time of day, weekday, and monthly breakdowns

---

## 🧾 Dataset

The dataset represents POS (point-of-sale) transactions from three cities: **Mandalay, Yangon**, and **Naypyitaw**. Each row logs a unique invoice, including product details, COGS, VAT, payment type, timestamps, and ratings.

### Key Columns:

| Column         | Description                                |
|----------------|--------------------------------------------|
| invoice_id     | Unique transaction ID                      |
| branch         | Store identifier (A, B, C)                 |
| city           | Location of the branch                     |
| customer_type  | Member or Normal                          |
| gender         | Gender of the customer                     |
| product_line   | Category of the product                    |
| unit_price     | Price per unit                             |
| quantity       | Quantity purchased                         |
| VAT            | 5% Value Added Tax                         |
| total          | Total bill amount (COGS + VAT)            |
| date           | Date of purchase                           |
| time           | Time of purchase                           |
| payment        | Payment method (Cash, Card, etc.)         |
| cogs           | Cost of goods sold                         |
| gross_income   | Profit (Total - COGS)                      |
| rating         | Customer rating for the service/product    |

---

## 🛠️ Feature Engineering

Several new features were derived to deepen analysis:

- **time_of_day**: Bucketed into Morning, Afternoon, or Evening
- **day_name**: Weekday of the purchase (e.g., Mon, Tue)
- **month_name**: Purchase month (e.g., Jan, Feb)
- **performance_flag**: Labeled each product line as `Good` or `Bad` based on sales vs. average

---

## 🔍 Key Analysis

### 🏬 Sales & Products
- Top-performing branches by revenue
- Best-selling product lines
- Months and weekdays with peak sales

### 👥 Customer Insights
- Gender distribution across branches
- Customer types contributing the most revenue
- Average ratings by time and day

### 💰 Revenue Insights
- Product lines with highest VAT contributions
- Monthly COGS and total sales
- Gross income and margin percentages

---

## 📌 Sample Business Questions Answered

- What is the most common product line by gender?
- Which branch outperforms the average in product sales?
- What is the customer type distribution?
- When do customers give the highest ratings?
- Which day of the week has the best overall performance?

---

## 🧮 Revenue & Margin Formulas

```text
COGS = unit_price × quantity
VAT = 5% × COGS
Total = COGS + VAT
Gross Income = Total - COGS
Gross Margin % = Gross Income / Total

