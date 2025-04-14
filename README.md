# SQL Window Functions Analysis Project

## Team Information
## Members:

### 1. MUSHIMIYUMUKIZA Blaise 
### Eunice

### Instructor: Eric Maniraquha

### Course: Database Development with PL/SQL (INSY 8311)

### Institution: Adventist University of Central Africa

## Project Overview
This project demonstrates the practical application of SQL window functions in Oracle PL/SQL. We've created a comprehensive database solution that includes table creation, sample data insertion, and several analytical procedures that leverage window functions to solve common business problems related to employee salary analysis.



# Database Schema
Our database consists of two main tables:

1. employees Table
Stores employee information including:

Employee ID, name, contact details

Hire date, job ID, salary

Department and manager relationships

2. departments Table
Contains department details:

Department ID and name

Manager and location information

Procedures Implemented
1. generate_salary_comparison_report
Purpose: Compares each employee's salary with their department peers
Window Functions Used:

LAG() - Accesses previous row's salary

LEAD() - Accesses next row's salary

Business Value: Helps identify salary progression patterns within departments

2. generate_department_ranking_report
Purpose: Ranks departments by average salary
Window Functions Used:

RANK() - Standard ranking with gaps

DENSE_RANK() - Ranking without gaps

Business Value: Provides insights into which departments are most/least compensated

3. generate_top_earners_report
Purpose: Identifies top N earners in each department
Window Function Used:

DENSE_RANK() - For ranking within partitions

Business Value: Helps with retention strategies for high performers

4. generate_salary_distribution
Purpose: Analyzes salary distribution across the organization
Window Functions Used:

MAX() OVER (PARTITION BY) - Department-level maximums

MAX() OVER () - Organization-wide maximum

Business Value: Reveals compensation equity across the company

# How to Run the Project
Database Setup:

sql
Copy
-- Execute the database creation script first
@create_database.sql
Load Sample Data:

sql
Copy
-- Run the data insertion script
@insert_data.sql
Create Procedures:

sql
Copy
-- Execute the procedure creation script
@create_procedures.sql
Generate Reports:

sql
Copy
-- Enable output display
SET SERVEROUTPUT ON SIZE 1000000;

-- Run the procedures
EXEC generate_salary_comparison_report;
EXEC generate_department_ranking_report;
EXEC generate_top_earners_report(3);
EXEC generate_salary_distribution;
Real-World Applications
HR Analytics: These procedures provide valuable insights for human resources departments to:

Identify compensation trends

Spot potential salary inequities

Make data-driven decisions about raises and promotions

Financial Planning: The reports help finance teams:

Forecast payroll expenses

Allocate budgets by department

Plan for merit increases

Employee Development: Managers can use this data to:

Understand their team's compensation relative to others

Develop retention strategies for top performers

Create career progression plans

# Key Learnings
Through this project, we've gained practical experience with:

Window Function Concepts:

Partitioning data with PARTITION BY

Ordering within windows with ORDER BY

Frame specification for sliding windows

Specific Functions:

Ranking functions (RANK, DENSE_RANK, ROW_NUMBER)

Offset functions (LAG, LEAD)

Aggregate functions in window context

Performance Considerations:

The efficiency benefits of window functions over self-joins

The impact of partitioning on query performance

Memory usage with large window frames

## Contribution Summary
### Eunice
Designed and implemented the database schema

Created the salary comparison and department ranking procedures

Wrote the initial documentation

### Blaise
Developed the top earners and salary distribution procedures

Created sample data and test cases

Refined the documentation and added real-world application examples

## Future Enhancements
Add more comprehensive error handling

Incorporate additional window functions like FIRST_VALUE and LAST_VALUE

Create visualization procedures to generate HTML reports

Add historical tracking for salary changes over time

## Resources
Oracle Window Functions Documentation
YouTube Tutorial on Window Functions.

# screenshoots
https://github.com/ReponseBlaise/THE_FOREIGNERS/blob/a1056205a88206af4faa21bb4001a572f1d30753/pic%201.jpg
https://github.com/ReponseBlaise/THE_FOREIGNERS/blob/82259deac0d6f468ad6ebcaf7005d8b96d6943d5/pic%202.jpg


