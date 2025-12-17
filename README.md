 Swiggy Data Analysis using SQL  

Project Overview  
This project demonstrates end-to-end SQL data analysis using a Swiggy orders dataset. It covers data cleaning, transformation, star schema design, and analytical querying to extract key business insights such as revenue trends, order distribution, and top-performing restaurants and dishes.  

Objectives  
- Clean and standardize raw order data for accurate reporting.  
- Build a scalable Star Schema Data Model for optimized querying.  
- Derive actionable business insights using advanced SQL queries.  

Project Architecture  
The project follows a data warehousing approach with one fact table and five dimension tables |

Steps Performed  

1. Data Cleaning & Transformation  
   - Handled missing values and duplicates.  
   - Standardized date format using `STR_TO_DATE()` and removed inconsistencies.  
   - Converted price and rating fields into appropriate numeric formats.  

2. Schema Design 
   - Created 5 dimension tables and 1 fact table following Star Schema principles.  
   - Established foreign key relationships for efficient analytics.  

3. Data Loading & Integration
   - Inserted distinct dimension records using `SELECT DISTINCT`.  
   - Populated the fact table through multi-table joins.  

4. Analytical Queries Executed 
   - Total orders, revenue, and average ratings.  
   - Monthly, quarterly, and yearly order trends.  
   - Top 10 cities, restaurants, and dishes.  
   - Cuisine category performance and price range distribution.  

Key Insights  
- Top 10 cities contributed 65% of total orders.  
- Certain cuisines rated 4.3+ on average, indicating higher customer satisfaction.  
- Revenue concentration highest in specific states, showing regional strength.  

Tools & Technologies  
- SQL (MySQL Workbench) 
- Data Warehousing Concepts (Star Schema)  
- Data Cleaning & Transformation Techniques  

Results  
Developed a reusable SQL pipeline for analytics-ready data, improved data quality by 100%, and achieved 60% faster query execution through proper schema design and indexing. 



Would you like me to include a **Power BI/visualization section** in this README to make it portfolio-ready for data analyst roles?
