--SQL Advance Case Study
select top 1 * from [dbo].[DIM_CUSTOMER]
select top 1 * from [dbo].[DIM_DATE]
select top 1 * from [dbo].[DIM_LOCATION]
select top 1 * from [dbo].[DIM_MANUFACTURER]
select top 1 * from [dbo].[DIM_MODEL]
select top 1 * from [dbo].[DIM_CUSTOMER]
select top 1 * from [dbo].[FACT_TRANSACTIONS]



--Q1--BEGIN 
 --List all the states in which we have customers who have bought cellphones from 2005 till today.

select distinct state from 
(select t1.state, SUM(quantity)as qnt ,year(t2.date)as year from [dbo].[DIM_LOCATION] as t1
join [dbo].[FACT_TRANSACTIONS] as t2
on t1.IDLocation = t2.IDLocation
where YEAR (t2.date)>=2005
group by t1.state,year(t2.date))
as A
--Q1--END

--Q2--BEGIN
--What state in the US is buying the most 'Samsung' cell phones? 


SELECT top 1 STATE,COUNT(*) AS CNT  FROM [dbo].[DIM_LOCATION] AS T1
JOIN [dbo].[FACT_TRANSACTIONS] AS T2
ON T1.IDLocation =T2.IDLocation
JOIN [dbo].[DIM_MODEL] AS T3
ON T2.IDModel = T3.IDModel
JOIN DIM_MANUFACTURER AS T4
ON T3.IDManufacturer=T4.IDManufacturer
WHERE COUNTRY='US' AND Manufacturer_Name='SAMSUNG'
GROUP BY STATE
ORDER BY CNT DESC

--END

--Q3--BEGIN
-- Show the number of transactions for each model per zip code per state.

SELECT IDModel,STATE,ZIPCODE,COUNT(*) AS TOT_TRANS
FROM [dbo].[FACT_TRANSACTIONS] AS T1
JOIN [dbo].[DIM_LOCATION] AS T2
ON T1.IDLocation = T2.IDLocation
GROUP BY IDModel,STATE,ZIPCODE

--Q3--END

--Q4--BEGIN
 --Show the cheapest cellphone (Output should contain the price also)


SELECT TOP 1 Model_Name, MIN(UNIT_PRICE) AS MIN_PRICE FROM [dbo].[DIM_MODEL]
GROUP BY Model_Name
ORDER BY MIN_PRICE ASC

--Q4--END

--Q5--BEGIN
--Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price. 

SELECT   T1.IDMODEL,AVG(TOTALPRICE) AS AVG_PRICE,SUM(QUANTITY) AS  TOT_QTY FROM[dbo].[FACT_TRANSACTIONS] AS T1
JOIN[dbo].[DIM_MODEL] AS T2
ON T1.IDModel = T2.IDModel
JOIN DIM_MANUFACTURER AS T3 
ON T2.IDManufacturer = T3.IDManufacturer
WHERE Manufacturer_Name IN (SELECT TOP 5 Manufacturer_Name FROM [dbo].[FACT_TRANSACTIONS] AS T1
                            JOIN [dbo].[DIM_MODEL] AS T2
							ON T1.IDModel =T2.IDModel
							JOIN DIM_MANUFACTURER AS T3
							ON T2.IDManufacturer = T3.IDManufacturer
							GROUP BY Manufacturer_Name
							ORDER BY SUM(TOTALPRICE)DESC)
	GROUP BY T1.IDMODEL,MANUFACTURER_NAME
	ORDER BY AVG_PRICE DESC

--Q5--END

--Q6--BEGIN
-- List the names of the customers and the average amount spent in 2009, where the average is higher than 500

SELECT CUSTOMER_NAME, AVG(TOTALPRICE) AS AVG_PRICE  FROM[dbo].[DIM_CUSTOMER] AS T1
JOIN [dbo].[FACT_TRANSACTIONS] AS T2
ON T1.IDCustomer = T2.IDCustomer
WHERE YEAR(DATE)=2009
GROUP BY CUSTOMER_NAME
HAVING AVG(TOTALPRICE)>500

--Q6--END
	
--Q7--BEGIN 
--List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010

SELECT * FROM (
SELECT  TOP 5  IDMODEL FROM [dbo].[FACT_TRANSACTIONS]
WHERE YEAR(DATE) = 2008
GROUP BY IDMODEL, YEAR(DATE)
ORDER BY  SUM(QUANTITY) DESC
) AS A
INTERSECT
SELECT * FROM (
SELECT  TOP 5  IDMODEL FROM [dbo].[FACT_TRANSACTIONS]
WHERE YEAR(DATE) = 2009
GROUP BY IDMODEL, YEAR(DATE)
ORDER BY  SUM(QUANTITY) DESC
) AS B
INTERSECT
SELECT * FROM (
SELECT  TOP 5  IDMODEL FROM [dbo].[FACT_TRANSACTIONS]
WHERE YEAR(DATE) = 2010
GROUP BY IDMODEL, YEAR(DATE)
ORDER BY  SUM(QUANTITY) DESC
) AS C

--Q7--END	

--Q8--BEGIN
--Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.

SELECT* FROM(
SELECT TOP 1  * FROM(
SELECT TOP 2  MANUFACTURER_NAME, YEAR(DATE) AS YEAR ,SUM(TOTALPRICE) AS SALES FROM [dbo].[FACT_TRANSACTIONS] AS T1
JOIN DIM_MODEL AS T2
ON T1.IDMODEL = T2.IDMODEL
JOIN DIM_MANUFACTURER AS T3
ON T2.IDManufacturer = T3.IDManufacturer
WHERE YEAR(DATE)= 2009
GROUP BY MANUFACTURER_NAME, YEAR(DATE)
ORDER BY SALES DESC)AS A
ORDER BY SALES  ASC
) AS C
UNION
SELECT * FROM(
SELECT TOP 1  * FROM(
SELECT TOP 2  MANUFACTURER_NAME, YEAR(DATE) AS YEAR ,SUM(TOTALPRICE) AS SALES FROM [dbo].[FACT_TRANSACTIONS] AS T1
JOIN DIM_MODEL AS T2
ON T1.IDMODEL = T2.IDMODEL
JOIN DIM_MANUFACTURER AS T3
ON T2.IDManufacturer = T3.IDManufacturer
WHERE YEAR(DATE)= 2010
GROUP BY MANUFACTURER_NAME, YEAR(DATE)
ORDER BY SALES DESC)AS A
ORDER BY SALES  ASC
) AS D
--Q8--END

--Q9--BEGIN
-- Show the manufacturers that sold cellphones in 2010 but did not in 2009.

SELECT MANUFACTURER_NAME FROM [dbo].[FACT_TRANSACTIONS] AS T1
JOIN [dbo].[DIM_MODEL] AS T2
ON T1.IDModel = T2.IDModel
JOIN [dbo].[DIM_MANUFACTURER] AS T3
ON T2.IDManufacturer = T3.IDManufacturer
WHERE YEAR(DATE) = 2010
GROUP BY Manufacturer_Name
EXCEPT
SELECT MANUFACTURER_NAME FROM [dbo].[FACT_TRANSACTIONS] AS T1
JOIN [dbo].[DIM_MODEL] AS T2
ON T1.IDModel = T2.IDModel
JOIN [dbo].[DIM_MANUFACTURER] AS T3
ON T2.IDManufacturer = T3.IDManufacturer
WHERE YEAR(DATE) = 2009
GROUP BY Manufacturer_Name

--Q9--END

--Q10--BEGIN
-- Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.

SELECT *, ((AVG_PRICE - LAG_PRICE)/LAG_PRICE) AS PERCENTAGE_CHANGE FROM(
SELECT*, LAG(AVG_PRICE ,1) OVER (PARTITION BY  IDCUSTOMER  ORDER BY YEAR) AS LAG_PRICE FROM(

SELECT IDCustomer , YEAR(DATE) as year , AVG(totalprice) as avg_price , sum(quantity) as qty from[dbo].[FACT_TRANSACTIONS]
where IDCustomer  in (select top 10 idcustomer  from[dbo].[FACT_TRANSACTIONS]
                      group by IDCustomer
					  order by  sum(totalprice)desc)
Group by IDCustomer,YEAR(DATE)
) AS A
) AS B

--Q10--END
	