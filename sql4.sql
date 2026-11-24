CREATE TABLE products AS SELECT * FROM hr.products;
CREATE TABLE sales AS SELECT * FROM hr.sales;


SELECT employee_id, first_name, last_name, salary,
       RANK() OVER (ORDER BY salary DESC) AS ranking_pensji
  FROM employees;


SELECT employee_id, first_name, last_name, salary,
       SUM(salary) OVER () AS suma_pensji
  FROM employees;


SELECT e.last_name,
       p.product_name,
       SUM(s.quantity * s.price) OVER (PARTITION BY e.employee_id
                                       ORDER BY s.sale_date
                                       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS skumulowana_sprzedaz,
       RANK() OVER (ORDER BY s.quantity * s.price DESC)                                  AS ranking_wartosci
  FROM sales s
  JOIN employees e ON s.employee_id = e.employee_id
  JOIN products p  ON s.product_id = p.product_id;


SELECT e.last_name,
       p.product_name,
       s.price,
       COUNT(*) OVER (PARTITION BY s.product_id, s.sale_date)                        AS liczba_transakcji,
       SUM(s.quantity * s.price) OVER (PARTITION BY s.product_id, s.sale_date)       AS suma_dnia,
       LAG(s.price)  OVER (PARTITION BY s.product_id ORDER BY s.sale_date)           AS poprzednia_cena,
       LEAD(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date)           AS kolejna_cena
  FROM sales s
  JOIN employees e ON s.employee_id = e.employee_id
  JOIN products p  ON s.product_id = p.product_id;


SELECT p.product_name,
       s.price,
       SUM(s.quantity * s.price) OVER (PARTITION BY TRUNC(s.sale_date, 'MM'))        AS suma_miesiaca,
       SUM(s.quantity * s.price) OVER (PARTITION BY s.product_id, TRUNC(s.sale_date, 'MM')
                                       ORDER BY s.sale_date
                                       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS suma_rosnaca_produktu
  FROM sales s
  JOIN products p ON s.product_id = p.product_id;


SELECT p.product_name,
       p.product_category,
       s22.sale_date  AS data_2022,
       s23.sale_date  AS data_2023,
       s22.price      AS cena_2022,
       s23.price      AS cena_2023,
       s23.price - s22.price AS roznica_cen
  FROM sales s22
  JOIN sales s23   ON s22.product_id = s23.product_id
                  AND TO_CHAR(s22.sale_date, 'MM-DD') = TO_CHAR(s23.sale_date, 'MM-DD')
  JOIN products p  ON s22.product_id = p.product_id
 WHERE EXTRACT(YEAR FROM s22.sale_date) = 2022
   AND EXTRACT(YEAR FROM s23.sale_date) = 2023;


SELECT p.product_category,
       p.product_name,
       s.price,
       MIN(s.price) OVER (PARTITION BY p.product_category)                              AS min_cena_kategorii,
       MAX(s.price) OVER (PARTITION BY p.product_category)                              AS max_cena_kategorii,
       MAX(s.price) OVER (PARTITION BY p.product_category)
         - MIN(s.price) OVER (PARTITION BY p.product_category)                          AS roznica_max_min
  FROM sales s
  JOIN products p ON s.product_id = p.product_id;


SELECT p.product_name,
       s.sale_date,
       s.price,
       ROUND(AVG(s.price) OVER (PARTITION BY s.product_id
                                ORDER BY s.sale_date
                                ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING), 2) AS srednia_kroczaca
  FROM sales s
  JOIN products p ON s.product_id = p.product_id;


SELECT p.product_name,
       p.product_category,
       s.price,
       RANK()       OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS ranking_cen,
       ROW_NUMBER() OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS numer_wiersza,
       DENSE_RANK() OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS ranking_gesty
  FROM sales s
  JOIN products p ON s.product_id = p.product_id;


SELECT e.last_name,
       p.product_name,
       s.sale_date,
       s.quantity * s.price AS wartosc_zamowienia,
       SUM(s.quantity * s.price) OVER (PARTITION BY e.employee_id
                                       ORDER BY s.sale_date
                                       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sprzedaz_rosnaca,
       RANK() OVER (ORDER BY s.quantity * s.price DESC)                                  AS ranking_globalny
  FROM sales s
  JOIN employees e ON s.employee_id = e.employee_id
  JOIN products p  ON s.product_id = p.product_id;


SELECT e.first_name, e.last_name, j.job_title
  FROM employees e
  JOIN jobs j ON e.job_id = j.job_id
 WHERE EXISTS (SELECT 1
                 FROM sales s
                WHERE s.employee_id = e.employee_id);