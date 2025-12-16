SELECT * FROM data;

SELECT
	SUM(CASE WHEN State is NULL THEN 1 ELSE 0 END) as null_state,
	SUM(CASE WHEN City is NULL THEN 1 ELSE 0 END) as null_city,
	SUM(CASE WHEN Order_Date is NULL THEN 1 ELSE 0 END) as null_order,
	SUM(CASE WHEN Restaurant_Name is NULL THEN 1 ELSE 0 END) as null_restaurant,
	SUM(CASE WHEN Location is NULL THEN 1 ELSE 0 END) as null_location,
	SUM(CASE WHEN Category is NULL THEN 1 ELSE 0 END) as null_category,
	SUM(CASE WHEN Dish_Name is NULL THEN 1 ELSE 0 END) as null_dish,
	SUM(CASE WHEN Price is NULL THEN 1 ELSE 0 END) as null_price,
	SUM(CASE WHEN Rating is NULL THEN 1 ELSE 0 END) as null_rating,
	SUM(CASE WHEN Rating_Count is NULL THEN 1 ELSE 0 END) as null_rating_count
from data;

-- 0) Disable safe update mode just for this session
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE `practice`.`swiggy_data`
ADD COLUMN `Order_Date_new` DATE NULL;

UPDATE `practice`.`swiggy_data`
SET `Order_Date_new` = STR_TO_DATE(`Order_Date`, '%d-%m-%Y');

ALTER TABLE `practice`.`swiggy_data`
DROP COLUMN `Order_Date`;

ALTER TABLE `practice`.`swiggy_data`
CHANGE COLUMN `Order_Date_new` `Order_Date` DATE NULL DEFAULT NULL;

-- 5) (Optional) Re-enable safe updates
SET SQL_SAFE_UPDATES = 1;


-- SELECT * FROM data
-- WHERE State = ' ' ,OR City =' ' , or Restaurant_Name = ' ' , or Location = ' ' , OR Dish_Name = ' ' ;
SELECT 
    State,
    City,
    Order_Date,
    Restaurant_Name,
    Location,
    Category,
    Dish_Name,
    Price,
    Rating,
    Rating_Count,
    COUNT(*) AS CNT
FROM data
GROUP BY 
    State,
    City,
    Order_Date,
    Restaurant_Name,
    Location,
    Category,
    Dish_Name,
    Price,
    Rating,
    Rating_Count
HAVING COUNT(*) > 1;


CREATE TABLE dim_date(
	date_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Full_Date DATE,
    YEAR INT,
    MONTH INT,
    Month_Name varchar(20),
    Quarter INT,
    DAY INT,
    WEEK INT
    ); 

CREATE TABLE dim_location(
	location_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    State varchar(100),
    City varchar(100),
    Location varchar(200)
    );
    
CREATE TABLE dim_restuarant(
	restaurant_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Restaurant_Name varchar (200)
    );
    
CREATE TABLE dim_category(
	category_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Category varchar(200)
    );
    
CREATE TABLE dim_dish(
	dish_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Dish_Name varchar(200)
    );
    
CREATE TABLE fact_swiggy_orders(
	order_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    date_id int,
    Price DECIMAL(10,2),
    Rating DECIMAL (4,2),
    Rating_Count int,
    location_id int,
    restaurant_id int,
    category_id int,
    dish_id int,
    
    foreign key(date_id) REFERENCES dim_date(date_id),
    foreign key(location_id) REFERENCES dim_location(location_id),
    foreign key(restaurant_id) REFERENCES dim_restuarant(restaurant_id),
    foreign key(category_id) REFERENCES dim_category(category_id),
    foreign key(dish_id) REFERENCES dim_dish(dish_id)
    );
    
    INSERT INTO dim_date (
    Full_Date,
    Year,
    Month,
    Month_Name,
    Quarter,
    Day,
    Week
)
SELECT DISTINCT
    Order_Date,
    YEAR(Order_Date),
    MONTH(Order_Date),
    MONTHNAME(Order_Date),     
    QUARTER(Order_Date),        
    DAY(Order_Date),
    WEEK(Order_Date)         
FROM swiggy_data
WHERE Order_Date IS NOT NULL;

SELECT * from dim_date;


INSERT INTO dim_location (
    State,
    City,
    Location
)
SELECT DISTINCT 
    State,
    City,
    Location
FROM swiggy_data;
 select * from dim_location;
 
 
 INSERT INTO dim_restuarant(
	Restaurant_Name 
    )
SELECT DISTINCT
	Restaurant_Name 
    FROM swiggy_data;

INSERT INTO dim_category(
	Category
    )
SELECT DISTINCT 
	Category
 FROM swiggy_data;
 
 INSERT INTO dim_dish(
	 Dish_Name
     )
SELECT DISTINCT 
	Dish_Name
 FROM swiggy_data;
 
 INSERT INTO fact_swiggy_orders(
	date_id,
    Price,
    Rating,
    Rating_Count,
    location_id,
    restaurant_id,
    category_id,
    dish_id
    )
    SELECT dd.date_id,
    s.Price,
    s.Rating,
    s.Rating_Count,
    dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    dsh.dish_id
From swiggy_data

Join dim_date dd
	on dd.FULL_DATE = s.Order_Date
Join dim_location dl
	on dl.State = s.State
    and dl.City= s.City
    and dl.location = s.Location
    
JOIN dim_restuarant dr
on dr.restaurant_name = s.Restaurant_Name

JOIN dim_category dc
on dc.Category = s.Category

Join dim_dish dsh
on dsh.DISH_NAME = s.Dish_Name;

SELECT * from fact_swiggy_orders;

SELECT * FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_location l on f.location_id = l.location_id
JOIN dim_restuarant r on f.restaurant_id = r.restaurant_id
JOIN dim_category c on f.category_id = c.category_id
JOIN dim_dish di on f.dish_id = di.dish_id;


-- Total Orders
SELECT COUNT(*) AS Total_Orders
FROM fact_swiggy_orders;

-- Total_Revenue
SELECT 
    FORMAT(SUM(CAST(REPLACE(Price, 'INR', '') AS DECIMAL(10,2))), 2) AS Total_Revenue
FROM fact_swiggy_orders;

-- AVG dish Price 
SELECT 
    FORMAT(avg(CAST(REPLACE(Price, 'INR', '') AS DECIMAL(10,2))), 2) AS Total_Revenue
FROM fact_swiggy_orders;

-- AVG Rating
SELECT 
AVG(Rating) as avg_rating from fact_swiggy_orders;

-- MONTHKY ORDERS 
SELECT 
    d.Year,
    d.Month,
    d.Month_Name,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d 
    ON f.date_id = d.date_id
GROUP BY 
    d.Year,
    d.Month,
    d.Month_Name
ORDER BY 
    d.Year,
    d.Month;
    
    -- Quarterly Trend
SELECT 
    d.Year,
    d.Quarter,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d 
    ON f.date_id = d.date_id
GROUP BY 
    d.Year,
    d.Quarter
ORDER BY 
    d.Year,
    d.Quarter;
    
-- Yearly Trend 
SELECT 
    d.Year,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d 
    ON f.date_id = d.date_id
GROUP BY 
    d.Year
ORDER BY 
    d.Year;
    
    -- Orders of the day of week
    
SELECT
    DAYNAME(Order_Date) AS Day_Name,
    COUNT(*) AS total_orders
FROM swiggy_data
WHERE Order_Date IS NOT NULL
GROUP BY
    DAYNAME(Order_Date)
ORDER BY
    total_orders DESC;

-- top 10 cities by order volume 
SELECT 
    l.City,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_location l 
    ON f.location_id = l.location_id
GROUP BY 
    l.City
ORDER BY 
    total_orders DESC
LIMIT 10;


-- Revenue contirbution by state 
SELECT 
    l.State,
    SUM(f.Price) AS total_revenue,
    ROUND(
        100 * SUM(f.Price) / SUM(SUM(f.Price)) OVER (), 
        2
    ) AS revenue_pct
FROM fact_swiggy_orders f
JOIN dim_location l 
    ON f.location_id = l.location_id
GROUP BY 
    l.State
ORDER BY 
    total_revenue DESC;
    
-- Top 10 restaurants by number of orders
SELECT 
    r.Restaurant_Name,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_restuarant r 
    ON f.restaurant_id = r.restaurant_id
GROUP BY 
    r.Restaurant_Name
ORDER BY 
    total_orders DESC
LIMIT 10;

-- Most ordered dish
SELECT 
    d.dish_name,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_dish d on f.dish_id = d.dish_id
GROUP BY 
    d.dish_name
ORDER BY 
    total_orders DESC
LIMIT 10;

-- Cuisine Performnace

SELECT 
    c.category,
    COUNT(*) AS total_orders,
    CAST(AVG(CAST(f.rating AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS avg_rating
FROM fact_swiggy_orders f
JOIN dim_category c 
    ON f.category_id = c.category_id
GROUP BY 
    c.category
ORDER BY 
    total_orders DESC;


SELECT 
    CASE
        WHEN CAST(Price AS DECIMAL(10,2)) < 100 THEN 'Under 100'
        WHEN CAST(Price AS DECIMAL(10,2)) BETWEEN 100 AND 199 THEN '100-199'
        WHEN CAST(Price AS DECIMAL(10,2)) BETWEEN 200 AND 299 THEN '200-299'
        WHEN CAST(Price AS DECIMAL(10,2)) BETWEEN 300 AND 499 THEN '300-499'
        ELSE '500+'
    END AS price_range,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders
GROUP BY 
    price_range
ORDER BY 
    total_orders DESC;
    
    -- Rating count distribution 
    SELECT Rating, count(*) as rating_count
    from fact_swiggy_orders 
    group by Rating order by count(*) desc;


















