USE Retail_CaseStudy_CN;

/* 
Problem statement
Write a query to identify the number of duplicates in "sales_transaction" table. 
Also, create a separate table containing the unique values and remove the the original table from the databases 
and replace the name of the new table with the original name.

Query description:

Use the “Sales_transaction” table.
There will be two resulting tables in the output. First, 
the table where the count of duplicates will be identified and in the second table
 we can check if the duplicates were removed or not by selecting the whole table.
*/

SELECT TransactionID, COUNT(*)
from sales_transaction
GROUP BY TransactionID
HAVING COUNT(*) >1;


CREATE TABLE no_dupt as
SELECT DISTINCT *
FROM sales_transaction;

DROP TABLE sales_transaction;

ALTER TABLE no_dupt
RENAME TO sales_transaction;

SELECT * FROM sales_transaction;

/*
Problem statement
Write a query to identify the discrepancies in the price of the same product in 
"sales_transaction" and "product_inventory" tables. Also, update those discrepancies to match the price in both the tables.

Query description:
Use the "sales_transaction" and the "product_inventory" tables.
There will be two resulting tables in the output. 
First, the table where the discrepancies will be identified and in the second table 
we can check if the discrepancies were updated or not.
*/

SET SQL_SAFE_UPDATES = 0;

SELECT st.TransactionID, st.price as TransactionPrice, pin.price as InventoryPrice
FROM sales_transaction as st
LEFT JOIN product_inventory as pin ON st.productID = pin.productID
WHERE st.price <> pin.price;

UPDATE sales_transaction as st
INNER JOIN product_inventory as pin ON st.productID = pin.productID
SET st.price = pin.price 
WHERE st.price <> pin.price;

SELECT * FROM sales_transaction;

/* 
Problem statement
Write a SQL query to identify the null values in the dataset and replace those by “Unknown”.

Query description:
Use the customer_profiles table.
Identify the columns which contains null values and count the number of cells containing null values. 
Update those values with “unknown” and showcase the changes that the query has created.
*/

SET SQL_SAFE_UPDATES = 0;
SELECT * FROM customer_profiles;

select COUNT(*)
from customer_profiles
WHERE Location = '' ;


UPDATE customer_profiles
SET Location = "unknown"
WHERE Location = '';

select * 
FROM customer_profiles;


/*
Problem statement
Write a SQL query to clean the DATE column in the dataset.

Steps:
Create a separate table and change the data type of the date column and name it as you wish to.
Remove the original table from the database.
Change the name of the new table and replace it with the original name of the table.

Query description:
Use the “Customer_profiles” and the “Sales_transaction” tables.
The resulting table will display a column named TransactionDate_updated.
*/

SELECT * FROM Customer_profiles;
DESC Customer_profiles;

CREATE TABLE temp as
SELECT * FROM Customer_profiles;

SELECT * FROM temp;

ALTER TABLE temp
ADD column date_updated date;

UPDATE  temp 
SET date_updated = JoinDate;

SELECT * FROM temp;
Desc temp;


/*
Problem statement
Write a SQL query to summarize the total sales and quantities sold per product by the company.

(Here, the data has been already cleaned in the previous steps and from 
here we will be understanding the different types of data analysis from the given dataset.)
Query description:
Use the “Sales_transaction” table.
The resulting table will display the total quantity purchased by the customers and the total sales done by the company to evaluate the product performance.
Return the result table in descending order corresponding to Total Sales Column. */

SELECT * FROM Sales_transaction;

SELECT ProductID, SUM(QuantityPurchased) as totalunits_sold, ROUND(SUM(Price* QuantityPurchased),2) as Total_Sales
FROM Sales_transaction
GROUP BY ProductID
ORDER BY Total_Sales DESC;

/*Problem statement
Write a SQL query to count the number of transactions per customer to understand purchase frequency.

Query description:
Use the “Sales_transaction” table.
The resulting table will be counting the number of transactions corresponding to each customerID.
Return the result table ordered by NumberOfTransactions in descending order.
*/

SELECT * from Sales_transaction;

SELECT  CustomerID, COUNT(TransactionID) as NumberOfTransactions
FROM Sales_transaction
GROUP BY CustomerID
ORDER BY NumberOfTransactions DESC;


/*
Problem statement
Write a SQL query to evaluate the performance of the product categories based 
on the total sales which help us understand the product categories which needs to be promoted in the marketing campaigns.

Query description:
Use the “Sales_transaction” and "product_inventory" table.
The resulting table must display product categories, the aggregated count of units sold for each category, and the total sales value per category.
Return the result table ordering by TotalSales in descending order.
*/

SELECT Category,SUM(QuantityPurchased) as TotalUnits_Sold, ROUND(SUM(sl.Price * QuantityPurchased),2)  as Totalsales 
FROM Sales_transaction sl
LEFT JOIN  product_inventory pin
ON sl.ProductID = pin.ProductID
GROUP BY Category
ORDER BY Totalsales DESC;


/*
Problem statement
Write a SQL query to find the top 10 products with the highest total sales revenue from the sales transactions. 
This will help the company to identify the High sales products which needs to be focused to increase the revenue of the company.

Query description:
Use the “Sales_transaction” table.
The resulting table should be limited to 10 productIDs whose TotalRevenue (Product of Price and QuantityPurchased) is the highest.
Return the result table ordering by TotalRevenue in descending order.
*/

SELECT ProductID, ROUND(SUM(Price * QuantityPurchased),2)  as TotalRevenue
FROM Sales_transaction 
GROUP BY ProductID
ORDER BY TotalRevenue DESC
limit 10;

/*
Problem statement
Write a SQL query to find the ten products with the least amount of units sold from the sales transactions, 
provided that at least one unit was sold for those products.

Query description:
Use the “Sales_transaction” table.
The resulting table should be limited to 10 productIDs whose TotalUnitsSold (sum of QuantityPurchased) is the least. 
(The limit value can be adjusted accordingly)
Return the result table ordering by TotalUnitsSold in ascending order.
*/

SELECT ProductID, SUM(QuantityPurchased)  as TotalUnitsSold
FROM Sales_transaction 
GROUP BY ProductID
HAVING TotalUnitsSold > 0
ORDER BY TotalUnitsSold ASC
limit 10;

/*Problem statement
Write a SQL query to identify the sales trend to understand the revenue pattern of the company.

Query description:
Use the “sales_transaction” table.
The resulting table must have DATETRANS in date format, count the number of transaction on that particular date,
total units sold and the total sales took place.
Return the result table ordered by datetrans in descending order.
*/

SELECT DATE_FORMAT(TransactionDate, '%Y-%m-%d') as DATETRANS, COUNT(TransactionID) as Transaction_count, 
SUM(QuantityPurchased) as TotalUnitssold, ROUND(SUM(QuantityPurchased* Price),2) as TotalSales
FROM sales_transaction
GROUP BY DATETRANS
ORDER BY DATETRANS ;

/*
Problem statement
Write a SQL query to understand the month on month growth rate of sales of the company which 
will help understand the growth trend of the company.

Query description:
Use the “sales_transaction” table.
The resulting table must extract the month from the transactiondate
and then the Month on month growth percentange should be calculated. 
(Total sales present month - total sales previous month/ total sales previous month * 100)
Return the result table ordering by month.
*/

SELECT MONTH(TransactionDate), SUM(QuantityPurchased* Price) as total_sales,  
(SUM(QuantityPurchased* Price) - LAG(SUM(QuantityPurchased* Price) OVER (order by MONTH(TransactionDate))) ) * 100/LAG(SUM(QuantityPurchased* Price) OVER (order by MONTH(TransactionDate))) 
as PreviousMonthSales
FROM sales_transaction
GROUP BY MONTH(TransactionDate);



SELECT 
    MONTH(TransactionDate) AS Month, 
    SUM(QuantityPurchased * Price) AS total_sales,
    LAG(SUM(QuantityPurchased * Price)) OVER (ORDER BY MONTH(TransactionDate)) as PreviousMonthSales,
    (SUM(QuantityPurchased * Price) - 
        LAG(SUM(QuantityPurchased * Price)) OVER (ORDER BY MONTH(TransactionDate))) * 100.0 / 
        LAG(SUM(QuantityPurchased * Price)) OVER (ORDER BY MONTH(TransactionDate)) 
    AS MonthSalesPercentage
FROM 
    sales_transaction
GROUP BY 
    MONTH(TransactionDate);

/*
Problem statement
Write a SQL query that describes the number of transaction along with the total amount spent by 
each customer which are on the higher side and will help us understand the customers 
who are the high frequency purchase customers in the company.

Query description:
Use the “sales_transaction” table.
The resulting table must have number of transactions more than 10 and 
TotalSpent more than 1000 on those transactions by the corresponding customers. 
Return the result table on the “TotalSpent” in descending order.
*/

SELECT CustomerID, 
COUNT(*) as NumberOfTransactions, 
SUM(QuantityPurchased * price) as TotalSpent 
FROM sales_transaction
GROUP BY CustomerID
HAVING 
NumberOfTransactions > 10 AND TotalSpent > 1000 
ORDER BY TotalSpent DESC;

/*
Problem statement
Write a SQL query that describes the total number of purchases made by each customer against each productID
to understand the repeat customers in the company.
*/

SELECT CustomerID, ProductID, COUNT(ProductID) as TimesPurchased
FROM sales_transaction
GROUP BY CustomerID, ProductID
HAVING TimesPurchased >1
ORDER BY TimesPurchased DESC;


/*
Problem statement
Write a SQL query that describes the duration between the first and the last purchase of the
 customer in that particular company to understand the loyalty of the customer.

Query description:
Use the "Sales_transaction" table.
The resulting table must have the first date of purchase, the last date of purchase and 
the difference between the first and the last date of purchase.
The Difference between the first and the last date of purchase should be more than 0.
Return the table in descending order corresponding to DaysBetweenPurchases.
*/

SELECT CustomerID, MIN(TransactionDate) as Firstpurchase, MAX(TransactionDate) as LastPurchase, (MAX(TransactionDate) - MIN(TransactionDate)) as DaysBetweenPurchases
FROM Sales_transaction
GROUP BY CustomerID
ORDER BY DaysBetweenPurchases DESC;

/*
Problem statement
Write a SQL query that segments customers based on the total quantity of products they have purchased. 
Also, count the number of customers in each segment which will help us target a particular segment for marketing.
*/

CREATE TABLE cust_segment as 
SELECT sub.CustomerID, sub.totalquantity,
	CASE
		WHEN sub.totalquantity <=10 THEN 'LOW'
        WHEN sub.totalquantity <=30 THEN 'MID'
	ELSE  'HIGH'
    END AS CustomerSegment
FROM
(SELECT cp.customerID, SUM(st.QuantityPurchased) as totalquantity
FROM customer_profiles as cp
LEFT JOIN Sales_transaction as  st 
ON cp.customerID = st.customerID
GROUP BY cp.customerID) as sub ;

SELECT COUNT(*), CustomerSegment
FROM cust_segment
GROUP BY CustomerSegment;

