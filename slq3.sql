CREATE OR REPLACE VIEW v_wysokie_pensje AS
SELECT *
  FROM employees
 WHERE salary > 6000;

SELECT * FROM v_wysokie_pensje;


CREATE OR REPLACE VIEW v_wysokie_pensje AS
SELECT *
  FROM employees
 WHERE salary > 12000;

SELECT * FROM v_wysokie_pensje;


DROP VIEW v_wysokie_pensje;


CREATE OR REPLACE VIEW v_finance AS
SELECT employee_id, last_name, first_name
  FROM employees
 WHERE department_id = (SELECT department_id
                          FROM departments
                         WHERE department_name = 'Finance');

SELECT * FROM v_finance;


CREATE OR REPLACE VIEW v_zarobki_5000_12000 AS
SELECT employee_id, last_name, first_name, salary, job_id, email, hire_date
  FROM employees
 WHERE salary BETWEEN 5000 AND 12000;

SELECT * FROM v_zarobki_5000_12000;


INSERT INTO v_finance (employee_id, last_name, first_name)
VALUES (300, 'Testowy', 'Jan');

UPDATE v_finance
   SET first_name = 'Zmienione'
 WHERE employee_id = 108;

SELECT * FROM v_finance WHERE employee_id = 108;

DELETE FROM v_finance
 WHERE employee_id = 108;

SELECT * FROM v_finance;

ROLLBACK;


INSERT INTO v_zarobki_5000_12000 (employee_id, last_name, first_name, salary, job_id, email, hire_date)
VALUES (300, 'Testowy', 'Jan', 8000, 'IT_PROG', 'JTESTOWY', DATE '2024-01-01');

SELECT * FROM v_zarobki_5000_12000 WHERE employee_id = 300;

UPDATE v_zarobki_5000_12000
   SET salary = 9000
 WHERE employee_id = 300;

SELECT * FROM v_zarobki_5000_12000 WHERE employee_id = 300;

DELETE FROM v_zarobki_5000_12000
 WHERE employee_id = 300;

SELECT * FROM v_zarobki_5000_12000 WHERE employee_id = 300;

ROLLBACK;


CREATE OR REPLACE VIEW v_dzialy_min4 AS
SELECT d.department_id,
       d.department_name,
       COUNT(e.employee_id) AS liczba_pracownikow,
       ROUND(AVG(e.salary), 2) AS srednia_pensja,
       MAX(e.salary)        AS najwyzsza_pensja
  FROM departments d
  JOIN employees e ON d.department_id = e.department_id
 GROUP BY d.department_id, d.department_name
HAVING COUNT(e.employee_id) >= 4;

SELECT * FROM v_dzialy_min4;

INSERT INTO v_dzialy_min4 (department_id, department_name, liczba_pracownikow, srednia_pensja, najwyzsza_pensja)
VALUES (999, 'Testowy', 5, 5000, 6000);


CREATE OR REPLACE VIEW v_zarobki_check AS
SELECT employee_id, last_name, first_name, salary, job_id, email, hire_date
  FROM employees
 WHERE salary BETWEEN 5000 AND 12000
  WITH CHECK OPTION CONSTRAINT v_zarobki_check_ck;

INSERT INTO v_zarobki_check (employee_id, last_name, first_name, salary, job_id, email, hire_date)
VALUES (301, 'Poprawny', 'Anna', 8000, 'IT_PROG', 'APOPRAWNY', DATE '2024-01-01');

INSERT INTO v_zarobki_check (employee_id, last_name, first_name, salary, job_id, email, hire_date)
VALUES (302, 'Zbytwysoki', 'Ewa', 15000, 'IT_PROG', 'EZBYTWYSOKI', DATE '2024-01-01');

SELECT * FROM v_zarobki_check WHERE employee_id IN (301, 302);

ROLLBACK;


CREATE MATERIALIZED VIEW v_managerowie
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT DISTINCT e.employee_id, e.first_name, e.last_name, d.department_name
  FROM employees e
  LEFT JOIN departments d ON e.department_id = d.department_id
 WHERE e.employee_id IN (SELECT manager_id
                           FROM employees
                          WHERE manager_id IS NOT NULL);

SELECT * FROM v_managerowie ORDER BY last_name;


CREATE OR REPLACE VIEW v_najlepiej_oplacani AS
SELECT employee_id, first_name, last_name, salary
  FROM employees
 ORDER BY salary DESC
 FETCH FIRST 10 ROWS ONLY;

SELECT * FROM v_najlepiej_oplacani;