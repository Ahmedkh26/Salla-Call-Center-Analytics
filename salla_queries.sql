-- ====================================================================
-- Salla Call Center Operations Analytics
-- End-to-End Data Pipeline & Operational KPIs
-- Developed by: Ahmed Khaled
-- ====================================================================

-- 1. Switch to Project Database
USE salla_project;
GO

-- 2. Data Consolidation: Merging monthly tables into a single view
CREATE VIEW All_Salla_Sales AS
SELECT * FROM Sallah_Feb
UNION ALL
SELECT * FROM Sallah_Mar
UNION ALL
UNION ALL
SELECT * FROM Sallah_Apr;
GO

-- Quick Data Exploration
SELECT * FROM All_Salla_Sales;
SELECT COUNT(*) AS total_rows FROM All_Salla_Sales;
SELECT TOP 10 * FROM All_Salla_Sales;

-- 3. Data Cleaning: Handling NULL values and rounding metrics
CREATE VIEW clean_all_salla AS
SELECT 
    Project, 
    Date, 
    Month,
    ISNULL(Forecasted_Calls, 0) AS forecasted_calls,
    ISNULL(Calls_Offered, 0) AS calls_offered,
    ISNULL(Calls_Handled_with_in_THreshold, 0) AS Calls_Handled_with_in_THreshold,
    ISNULL(Calls_Abandon, 0) AS calls_abandon,
    ROUND(ISNULL(ASA, 0), 2) AS ASA,
    ISNULL(Answer_Time, 0) AS answer_time,
    Agent_Name
FROM All_Salla_Sales;
GO

-- Verify Cleaned Data View
SELECT * FROM clean_all_salla;

-- 4. Operational KPIs & Business Metrics Analysis

-- KPI A: Total Calls Offered
SELECT SUM(calls_offered) AS total_calls_offered 
FROM clean_all_salla;

-- KPI B: Total Abandon Rate Percentage
SELECT 
    ROUND((SUM(calls_abandon) * 100.0) / SUM(calls_offered), 2) AS abandon_rate_percentage
FROM clean_all_salla;

-- KPI C: Overall Service Level Percentage
SELECT 
    ROUND((SUM(Calls_Handled_with_in_THreshold) * 100.0) / SUM(calls_offered), 2) AS service_level_percentage
FROM clean_all_salla;

-- 5. Monthly Performance Trends (Managerial Insights)
SELECT
    Month,
    SUM(calls_offered) AS Total_Calls,
    ROUND((SUM(calls_abandon) * 100.0) / SUM(calls_offered), 2) AS Abandon_Rate,
    ROUND((SUM(Calls_Handled_with_in_THreshold) * 100.0) / SUM(calls_offered), 2) AS Service_Level
FROM clean_all_salla
GROUP BY Month;

-- 6. Agent Performance Benchmarking (Speed of Answer Ranking)
SELECT 
    Agent_Name,
    SUM(calls_offered) AS Total_Calls,
    ROUND(AVG(ASA), 2) AS avg_ASA
FROM clean_all_salla
GROUP BY Agent_Name
ORDER BY avg_ASA ASC;
