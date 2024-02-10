select top 1 *from Customer
select top 1  *from prod_cat_info
select top 1 *from Transactions

--DATA PREPARATION AND UNDERSTANDING
--Q1--BEGIN 

-- 1.	What is the total number of rows in each of the 3 tables in the database?

select count(*) as cnt from Customer
union
select count(*) as cnt from prod_cat_info
union
select count(*) as cnt from Transactions

--Q1--END

--Q2--BEGIN
--2.	What is the total number of transactions that have a return?

select count(distinct(transaction_id)) as tot_trans from[dbo].[Transactions]
where Qty<0

--Q2--END

--Q3--BEGIN
--3.	As you would have noticed, the dates provided across the datasets are not in a correct format. As first steps, pls
--convert the date variables into valid date formats before proceeding ahead.

SELECT CONVERT (DATE,tran_date,105) as tran_dates FROM Transactions

--Q3--END

--Q4--BEGIN
-- 4.	What is the time range of the transaction data available for analysis? Show the output in number of days, months and years simultaneously in different columns.

SELECT DATEDIFF(YEAR,MIN(CONVERT(DATE,TRAN_DATE,105)),MAX(CONVERT(DATE,TRAN_DATE,105))) AS DIFF_YEARS,
DATEDIFF(MONTH,MIN(CONVERT(DATE,TRAN_DATE,105)),MAX(CONVERT(DATE,TRAN_DATE,105))) AS DIFF_MONTHS,
DATEDIFF(DAY,MIN(CONVERT(DATE,TRAN_DATE,105)),MAX(CONVERT(DATE,TRAN_DATE,105))) AS DIFF_DAYS
FROM[dbo].[Transactions]
 
 --Q4--END

--Q5--BEGIN
-- 5.	Which product category does the sub-category “DIY” belong to?

 SELECT prod_cat,PROD_SUBCAT FROM [dbo].[prod_cat_info]
 WHERE PROD_SUBCAT= 'DIY'

--Q5--END

-- DATA ANALYSIS
--Q1--BEGIN
-- 1.	Which channel is most frequently used for transactions?

SELECT TOP 1 STORE_TYPE , COUNT(*) AS CNT FROM Transactions
GROUP BY Store_type
ORDER BY CNT DESC

--Q1--END

--Q2--START
-- 2.	What is the count of Male and Female customers in the database?

SELECT GENDER,COUNT(*) AS CNT FROM Customer
WHERE GENDER IS NOT NULL
GROUP BY Gender
--Q2--END

--Q3--START
-- 3.	From which city do we have the maximum number of customers and how many?

SELECT TOP 1 CITY_CODE ,COUNT(*) AS CNT FROM Customer
GROUP BY city_code
ORDER BY CNT DESC

--Q3--END

--Q4--START
-- 4.How many sub-categories are there under the Books category?

SELECT PROD_CAT,PROD_SUBCAT FROM prod_cat_info
WHERE prod_cat='BOOKS'

--Q4--END

--Q5--START
-- 5.What is the maximum quantity of products ever ordered?

SELECT PROD_CAT_CODE, MAX(QTY) AS MAX_PROD FROM Transactions
GROUP BY prod_cat_code

--Q5--END

--Q6--START
-- 6.	What is the net total revenue generated in categories Electronics and Books?

SELECT SUM(CAST(TOTAL_AMT AS FLOAT)) AS  NET_REVENUE  FROM prod_cat_info  AS T1
JOIN Transactions AS T2
ON T1.prod_cat_code=T2.prod_cat_code AND T1.prod_sub_cat_code=T2.prod_subcat_code
WHERE prod_cat='BOOKS' OR prod_cat='ELECTRONICS'

--Q6--END

--Q7--START
-- 7.How many customers have >10 transactions with us, excluding returns?

SELECT COUNT(*) AS TOT_CUST  FROM(
SELECT CUST_ID, COUNT(DISTINCT(TRANSACTION_ID)) AS CNT_TRANS FROM Transactions
WHERE QTY>0
GROUP BY CUST_ID
HAVING COUNT (DISTINCT(TRANSACTION_ID))>10
) AS T5

--Q7--END

--Q8--START
-- 8.What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?

SELECT SUM(CAST(TOTAL_AMT AS FLOAT)) AS  COMBINED_REVENUE  FROM prod_cat_info AS T1
JOIN Transactions AS T2
ON T1.prod_cat_code=T2.prod_cat_code AND T1.prod_sub_cat_code=T2.prod_subcat_code
WHERE prod_cat IN ('CLOTHING','ELECTRONICS') AND Store_type = 'FLAGSHIP STORE' AND QTY>0

--Q8--END

--Q9--START
-- 9.What is the total revenue generated from “Male” customers in “Electronics” category? Output should display total revenue by prod sub-cat.

SELECT PROD_SUBCAT, SUM(CAST(TOTAL_AMT AS FLOAT)) AS  TOT_REVENUE  FROM Customer AS T1
JOIN  Transactions AS T2
ON T1.CUSTOMER_ID = T2.cust_id
JOIN prod_cat_info AS T3
ON  T2.prod_cat_code = T3.prod_cat_code AND T2.prod_subcat_code = T3.prod_sub_cat_code
WHERE GENDER ='M' AND PROD_CAT = 'ELECTRONICS'
GROUP BY prod_subcat

--Q9--END

--Q10--START
-- 10.What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales? 

select*from(SELECT Top 5  prod_subcat,(SUM(CAST(TOTAL_AMT AS FLOAT))/(SELECT SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOT_SALES from Transactions  WHERE QTY>0))  as PercenTage_sales FROM prod_cat_info  AS T1
JOIN Transactions AS T2
ON T1.prod_cat_code=T2.prod_cat_code AND T1.prod_sub_cat_code=T2.prod_subcat_code
where qty>0
group by prod_subcat	
order by  PercenTage_sales desc) as t5
join
--percentage returns
(select  prod_subcat,(SUM(CAST(TOTAL_AMT AS FLOAT))/(SELECT SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOT_SALES from[dbo].[Transactions]  WHERE QTY<0))  as PercenTage_returns FROM [dbo].[prod_cat_info] AS T1
JOIN [dbo].[Transactions] AS T2
ON T1.prod_cat_code=T2.prod_cat_code AND T1.prod_sub_cat_code=T2.prod_subcat_code
where qty<0
group by prod_subcat)  t6
on t5.prod_subcat=t6.prod_subcat

-- end

--Q11--START
-- 11.For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers in last 30 days of transactions
-- from max transaction date available in the data?

SELECT * FROM (
SELECT * FROM (
SELECT CUST_ID, DATEDIFF(year ,DOB,MAX_DATE) AS AGE,REVENUE FROM (
SELECT CUST_ID,DOB,MAX(CONVERT(DATE,TRAN_DATE,105)) AS MAX_DATE,SUM(CAST(TOTAL_AMT AS float)) AS REVENUE FROM Customer AS T1
JOIN Transactions AS T2
ON T1.customer_Id=T2.cust_id
WHERE Qty>0
GROUP BY CUST_ID ,DOB
) AS A 
     ) AS B
  
WHERE AGE BETWEEN 25 AND 35 
           ) as C
JOIN (
SELECT CUST_ID, CONVERT (DATE,TRAN_DATE,105) AS TRAN_DATE
FROM Transactions
GROUP BY CUST_ID, CONVERT (DATE,TRAN_DATE,105)
HAVING CONVERT (DATE,TRAN_DATE,105)>=(SELECT DATEADD(DAY,-30,MAX(CONVERT(DATE,TRAN_DATE,105))) AS CUTOFF_DATE FROM Transactions)
 ) As D
 ON C.cust_id =D.cust_id
 
 --Q11--END


 --Q12--start
-- 12.	Which product category has seen the max value of returns in the last 3 months of transactions?

 SELECT top 1 prod_cat_code,Sum(returns) as tot_returns from										
( SELECT prod_cat_code, CONVERT (DATE,TRAN_DATE,105) AS TRAN_DATE,SUM(QTY) AS RETURNS
FROM Transactions
where Qty<0
GROUP BY prod_cat_code, CONVERT (DATE,TRAN_DATE,105)
HAVING CONVERT (DATE,TRAN_DATE,105)>=(SELECT DATEADD(MONTH,-3,MAX(CONVERT(DATE,TRAN_DATE,105))) AS CUTOFF_DATE FROM Transactions)
 ) AS A	
 group by prod_cat_code
 order by tot_returns

--Q12-END

--Q13--start
-- 13.	Which store-type sells the maximum products; by value of sales amount and by quantity sold?

 select store_type, SUM(CAST(TOTAL_AMT AS FLOAT)) as revenue , sum(qty) as quantity
 from Transactions
 where  qty>0
 group by Store_type
 order by revenue desc, quantity desc

 --Q13--end

--Q14--start
--  14.	What are the categories for which average revenue is above the overall average

 select prod_cat_code, avg(cast(total_amt as float)) as avg_revenue  from Transactions
 where qty>0
 group by prod_cat_code
 having avg(cast(total_amt as float)) >=(select avg(cast(total_amt as float)) from Transactions where qty>0)

 --Q14--end

--Q15-start
-- 15.Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold.

  select prod_subcat_code, SUM(CAST(TOTAL_AMT AS FLOAT)) as revenue , avg(cast(total_amt as float))as avg from Transactions
  where qty>0 and prod_cat_code in (select top 5 prod_cat_code from[dbo].[Transactions]
                                     where Qty>0
									 group  by prod_cat_code
									 order by sum(qty)desc)
group by prod_subcat_code

--Q15-end


