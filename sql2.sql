BEGIN
    FOR t IN (SELECT table_name FROM user_tables) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE "' || t.table_name || '" CASCADE CONSTRAINTS PURGE';
    END LOOP;
END;
/

CREATE TABLE regions AS SELECT * FROM hr.regions;
CREATE TABLE countries AS SELECT * FROM hr.countries;
CREATE TABLE locations AS SELECT * FROM hr.locations;
CREATE TABLE departments AS SELECT * FROM hr.departments;
CREATE TABLE jobs AS SELECT * FROM hr.jobs;
CREATE TABLE employees AS SELECT * FROM hr.employees;
CREATE TABLE job_history AS SELECT * FROM hr.job_history;

SELECT last_name || ' ' || salary AS wynagrodzenie
  FROM employees
 WHERE department_id IN (20, 50)
   AND salary BETWEEN 2000 AND 7000
 ORDER BY last_name;


SELECT hire_date, last_name, &&kolumna
  FROM employees
 WHERE manager_id IS NOT NULL
   AND EXTRACT(YEAR FROM hire_date) = 2005
 ORDER BY &&kolumna;


SELECT first_name || ' ' || last_name AS imie_nazwisko, salary, phone_number
  FROM employees
 WHERE SUBSTR(last_name, 3, 1) = 'e'
   AND LOWER(first_name) LIKE '%' || LOWER('&czesc_imienia') || '%'
 ORDER BY 1 DESC, 2 ASC;


SELECT first_name, last_name, miesiace,
       CASE
           WHEN miesiace < 150 THEN salary * 0.1
           WHEN miesiace <= 200 THEN salary * 0.2
           ELSE salary * 0.3
       END AS wysokosc_dodatku
  FROM (SELECT first_name, last_name, salary,
               ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) AS miesiace
          FROM employees)
 ORDER BY miesiace;


SELECT department_id,
       SUM(salary)        AS suma_zarobkow,
       ROUND(AVG(salary)) AS srednia_zarobkow
  FROM employees
 GROUP BY department_id
HAVING MIN(salary) > 5000;


SELECT e.last_name, d.department_id, d.department_name, e.job_id
  FROM employees e
  JOIN departments d ON e.department_id = d.department_id
  JOIN locations l   ON d.location_id = l.location_id
 WHERE l.city = 'Toronto';


SELECT j.first_name, j.last_name, c.first_name AS wspolpracownik_imie, c.last_name AS wspolpracownik_nazwisko
  FROM employees j
  JOIN employees c ON j.department_id = c.department_id
                  AND j.employee_id <> c.employee_id
 WHERE j.first_name = 'Jennifer';


SELECT d.*
  FROM departments d
 WHERE NOT EXISTS (SELECT 1
                     FROM employees e
                    WHERE e.department_id = d.department_id);


SELECT e.first_name, e.last_name, e.job_id, d.department_name, e.salary, g.grade_level
  FROM employees e
  LEFT JOIN departments d ON e.department_id = d.department_id
  JOIN job_grades g       ON e.salary BETWEEN g.lowest_sal AND g.highest_sal;


SELECT first_name, last_name, salary
  FROM employees
 WHERE salary > (SELECT AVG(salary) FROM employees)
 ORDER BY salary DESC;


SELECT employee_id, first_name, last_name
  FROM employees
 WHERE department_id IN (SELECT department_id
                           FROM employees
                          WHERE LOWER(last_name) LIKE '%u%');


SELECT employee_id, first_name, last_name, hire_date
  FROM employees
 WHERE SYSDATE - hire_date > (SELECT AVG(SYSDATE - hire_date) FROM employees);


SELECT d.department_name,
       COUNT(e.employee_id)    AS liczba_pracownikow,
       ROUND(AVG(e.salary), 2) AS srednie_wynagrodzenie
  FROM departments d
  LEFT JOIN employees e ON d.department_id = e.department_id
 GROUP BY d.department_name
 ORDER BY liczba_pracownikow DESC;


SELECT first_name, last_name
  FROM employees
 WHERE salary < ANY (SELECT e.salary
                       FROM employees e
                       JOIN departments d ON e.department_id = d.department_id
                      WHERE d.department_name = 'IT');


SELECT d.department_id, d.department_name
  FROM departments d
 WHERE EXISTS (SELECT 1
                 FROM employees e
                WHERE e.department_id = d.department_id
                  AND e.salary > (SELECT AVG(salary) FROM employees));


SELECT job_title, srednie_zarobki
  FROM (SELECT j.job_title, ROUND(AVG(e.salary), 2) AS srednie_zarobki
          FROM jobs j
          JOIN employees e ON j.job_id = e.job_id
         GROUP BY j.job_title
         ORDER BY AVG(e.salary) DESC)
 FETCH FIRST 5 ROWS ONLY;


SELECT r.region_name,
       COUNT(DISTINCT c.country_id) AS liczba_krajow,
       COUNT(e.employee_id)         AS liczba_pracownikow
  FROM regions r
  LEFT JOIN countries c   ON r.region_id = c.region_id
  LEFT JOIN locations l   ON c.country_id = l.country_id
  LEFT JOIN departments d ON l.location_id = d.location_id
  LEFT JOIN employees e   ON d.department_id = e.department_id
 GROUP BY r.region_name;


SELECT e.first_name, e.last_name
  FROM employees e
  JOIN employees m ON e.manager_id = m.employee_id
 WHERE e.salary > m.salary;


SELECT TO_CHAR(hire_date, 'MM') AS miesiac, COUNT(*) AS liczba_pracownikow
  FROM employees
 GROUP BY TO_CHAR(hire_date, 'MM')
 ORDER BY miesiac;


SELECT department_name, srednie_wynagrodzenie
  FROM (SELECT d.department_name, ROUND(AVG(e.salary), 2) AS srednie_wynagrodzenie
          FROM departments d
          JOIN employees e ON d.department_id = e.department_id
         GROUP BY d.department_name
         ORDER BY AVG(e.salary) DESC)
 FETCH FIRST 3 ROWS ONLY;