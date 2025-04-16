

-- Create employees table
CREATE TABLE employees (
    employee_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    email VARCHAR2(100),
    phone_number VARCHAR2(20),
    hire_date DATE,
    job_id VARCHAR2(10),
    salary NUMBER(8,2),
    commission_pct NUMBER(2,2),
    manager_id NUMBER,
    department_id NUMBER
);

-- Create departments table
CREATE TABLE departments (
    department_id NUMBER PRIMARY KEY,
    department_name VARCHAR2(50),
    manager_id NUMBER,
    location_id NUMBER
);

-- Using LAG() and LEAD() to compare salary changes
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    LAG(salary, 1) OVER (ORDER BY salary) AS prev_salary,
    LEAD(salary, 1) OVER (ORDER BY salary) AS next_salary,
    CASE 
        WHEN salary > LAG(salary, 1) OVER (ORDER BY salary) THEN 'HIGHER'
        WHEN salary < LAG(salary, 1) OVER (ORDER BY salary) THEN 'LOWER'
        WHEN salary = LAG(salary, 1) OVER (ORDER BY salary) THEN 'EQUAL'
        ELSE 'FIRST RECORD' 
    END AS comparison_to_previous
FROM employees;

-- Using RANK() and DENSE_RANK() by department
SELECT 
    employee_id,
    first_name,
    last_name,
    department_id,
    salary,
    RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rank_in_dept,
    DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dense_rank_in_dept
FROM employees;

-- Top 3 salaries per department
WITH ranked_employees AS (
    SELECT 
        employee_id,
        first_name,
        last_name,
        department_id,
        salary,
        DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dept_rank
    FROM employees
)
SELECT * FROM ranked_employees
WHERE dept_rank <= 3;

-- First 2 employees hired in each department
WITH hire_order AS (
    SELECT 
        employee_id,
        first_name,
        last_name,
        department_id,
        hire_date,
        ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY hire_date) AS hire_seq
    FROM employees
)
SELECT * FROM hire_order
WHERE hire_seq <= 2;

-- Category-level and overall maximums
SELECT 
    employee_id,
    first_name,
    last_name,
    department_id,
    salary,
    MAX(salary) OVER (PARTITION BY department_id) AS dept_max_salary,
    MAX(salary) OVER () AS overall_max_salary
FROM employees;

-- Procedure 1: Employee Salary Comparison Report
CREATE OR REPLACE PROCEDURE generate_salary_comparison_report AS
  CURSOR emp_cur IS
    SELECT 
      e.employee_id,
      e.first_name || ' ' || e.last_name AS full_name,
      e.salary,
      d.department_name,
      LAG(e.salary, 1) OVER (PARTITION BY e.department_id ORDER BY e.salary) AS prev_salary,
      LEAD(e.salary, 1) OVER (PARTITION BY e.department_id ORDER BY e.salary) AS next_salary
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id;
  
  v_report CLOB := 'Employee Salary Comparison Report' || CHR(10) || CHR(10);
  v_line VARCHAR2(200);
BEGIN
  v_report := v_report || 'ID  Name                Salary  Department        Comparison' || CHR(10);
  v_report := v_report || '-----------------------------------------------------------' || CHR(10);
  
  FOR emp_rec IN emp_cur LOOP
    v_line := RPAD(emp_rec.employee_id, 4) || ' ' ||
               RPAD(emp_rec.full_name, 19) || ' ' ||
               LPAD(TO_CHAR(emp_rec.salary, '99999'), 7) || ' ' ||
               RPAD(emp_rec.department_name, 16) || ' ';
               
    IF emp_rec.prev_salary IS NULL THEN
      v_line := v_line || 'First in department';
    ELSIF emp_rec.salary > emp_rec.prev_salary THEN
      v_line := v_line || 'Higher than previous by ' || (emp_rec.salary - emp_rec.prev_salary);
    ELSIF emp_rec.salary < emp_rec.prev_salary THEN
      v_line := v_line || 'Lower than previous by ' || (emp_rec.prev_salary - emp_rec.salary);
    ELSE
      v_line := v_line || 'Same as previous';
    END IF;
    
    v_report := v_report || v_line || CHR(10);
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE(v_report);
END;
/

-- Procedure 2: Department Ranking Report
CREATE OR REPLACE PROCEDURE generate_department_ranking_report AS
  CURSOR dept_cur IS
    SELECT 
      department_id,
      department_name,
      AVG(salary) AS avg_salary,
      RANK() OVER (ORDER BY AVG(salary) DESC) AS dept_rank,
      DENSE_RANK() OVER (ORDER BY AVG(salary) DESC) AS dept_dense_rank
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    GROUP BY department_id, department_name;
  
  v_report CLOB := 'Department Salary Ranking Report' || CHR(10) || CHR(10);
BEGIN
  v_report := v_report || 'Department          Avg Salary  Rank  Dense Rank' || CHR(10);
  v_report := v_report || '-----------------------------------------------' || CHR(10);
  
  FOR dept_rec IN dept_cur LOOP
    v_report := v_report || 
      RPAD(dept_rec.department_name, 19) || ' ' ||
      LPAD(TO_CHAR(dept_rec.avg_salary, '99999.99'), 10) || ' ' ||
      LPAD(dept_rec.dept_rank, 5) || ' ' ||
      LPAD(dept_rec.dept_dense_rank, 10) || CHR(10);
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE(v_report);
END;
/

-- Procedure 3: Top Earners Report
CREATE OR REPLACE PROCEDURE generate_top_earners_report(p_top_n NUMBER) AS
  CURSOR top_earners_cur IS
    SELECT * FROM (
      SELECT 
        e.employee_id,
        e.first_name || ' ' || e.last_name AS full_name,
        e.salary,
        d.department_name,
        DENSE_RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS dept_rank
      FROM employees e
      JOIN departments d ON e.department_id = d.department_id
    ) WHERE dept_rank <= p_top_n;
  
  v_report CLOB := 'Top ' || p_top_n || ' Earners by Department Report' || CHR(10) || CHR(10);
BEGIN
  v_report := v_report || 'ID  Name                Salary  Department        Rank' || CHR(10);
  v_report := v_report || '---------------------------------------------------' || CHR(10);
  
  FOR emp_rec IN top_earners_cur LOOP
    v_report := v_report || 
      RPAD(emp_rec.employee_id, 4) || ' ' ||
      RPAD(emp_rec.full_name, 19) || ' ' ||
      LPAD(TO_CHAR(emp_rec.salary, '99999'), 7) || ' ' ||
      RPAD(emp_rec.department_name, 16) || ' ' ||
      LPAD(emp_rec.dept_rank, 4) || CHR(10);
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE(v_report);
END;
/

-- Procedure 4: Salary Distribution Analysis
CREATE OR REPLACE PROCEDURE generate_salary_distribution AS
  v_report CLOB := 'Salary Distribution Analysis' || CHR(10) || CHR(10);
BEGIN
  -- Department-level and overall maximums
  FOR rec IN (
    SELECT 
      e.employee_id,
      e.first_name || ' ' || e.last_name AS full_name,
      d.department_name,
      e.salary,
      MAX(e.salary) OVER (PARTITION BY e.department_id) AS dept_max,
      MAX(e.salary) OVER () AS overall_max,
      ROUND(e.salary / MAX(e.salary) OVER (PARTITION BY e.department_id) * 100, 1) AS pct_of_dept_max,
      ROUND(e.salary / MAX(e.salary) OVER () * 100, 1) AS pct_of_overall_max
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    ORDER BY d.department_name, e.salary DESC
  ) LOOP
    v_report := v_report ||
      'Employee: ' || rec.full_name || CHR(10) ||
      'Department: ' || rec.department_name || CHR(10) ||
      'Salary: ' || rec.salary || CHR(10) ||
      'Department Max: ' || rec.dept_max || ' (' || rec.pct_of_dept_max || '%)' || CHR(10) ||
      'Overall Max: ' || rec.overall_max || ' (' || rec.pct_of_overall_max || '%)' || CHR(10) ||
      '----------------------------------------' || CHR(10);
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE(v_report);
END;
-- Enable server output to see the results
SET SERVEROUTPUT ON SIZE 1000000;

-- Execute the procedures
EXEC generate_salary_comparison_report;
EXEC generate_department_ranking_report;
EXEC generate_top_earners_report(3);
EXEC generate_salary_distribution;