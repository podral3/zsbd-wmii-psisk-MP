
CREATE TABLE regions (
    region_id    NUMBER(4)     CONSTRAINT regions_pk PRIMARY KEY,
    region_name  VARCHAR2(64)
);

CREATE TABLE jobs (
    job_id      VARCHAR2(10)  CONSTRAINT jobs_pk PRIMARY KEY,
    job_title   VARCHAR2(64)  NOT NULL,
    min_salary  NUMBER(6),
    max_salary  NUMBER(6)
);

ALTER TABLE jobs
    ADD CONSTRAINT jobs_salary_chk CHECK (max_salary - min_salary >= 2000);

CREATE TABLE countries (
    country_id    CHAR(2)       CONSTRAINT countries_pk PRIMARY KEY,
    country_name  VARCHAR2(64)
);

ALTER TABLE countries ADD region_id NUMBER(4);
ALTER TABLE countries
    ADD CONSTRAINT countries_region_fk FOREIGN KEY (region_id)
        REFERENCES regions (region_id);

CREATE TABLE locations (
    location_id     NUMBER(4)     CONSTRAINT locations_pk PRIMARY KEY,
    street_address  VARCHAR2(64),
    postal_code     VARCHAR2(12),
    city            VARCHAR2(64)  NOT NULL,
    state_province  VARCHAR2(64)
);

ALTER TABLE locations ADD country_id CHAR(2);
ALTER TABLE locations
    ADD CONSTRAINT locations_country_fk FOREIGN KEY (country_id)
        REFERENCES countries (country_id);

CREATE TABLE departments (
    department_id    NUMBER(4)     CONSTRAINT departments_pk PRIMARY KEY,
    department_name  VARCHAR2(30)  NOT NULL,
    manager_id       NUMBER(6),
    location_id      NUMBER(4)
);

ALTER TABLE departments
    ADD CONSTRAINT dept_location_fk FOREIGN KEY (location_id)
        REFERENCES locations (location_id);

CREATE TABLE employees (
    employee_id  NUMBER(6)     CONSTRAINT employees_pk PRIMARY KEY,
    first_name   VARCHAR2(20),
    last_name    VARCHAR2(25)  NOT NULL,
    email        VARCHAR2(25)  NOT NULL CONSTRAINT employees_email_uk UNIQUE,
    hire_date    DATE          NOT NULL,
    job_id       VARCHAR2(10)  NOT NULL,
    salary       NUMBER(8,2)
);

ALTER TABLE employees ADD phone_number    VARCHAR2(20);
ALTER TABLE employees ADD commission_pct  NUMBER(2,2);
ALTER TABLE employees ADD manager_id      NUMBER(6);
ALTER TABLE employees ADD department_id   NUMBER(4);

ALTER TABLE employees
    ADD CONSTRAINT emp_job_fk FOREIGN KEY (job_id)
        REFERENCES jobs (job_id);
ALTER TABLE employees
    ADD CONSTRAINT emp_manager_fk FOREIGN KEY (manager_id)
        REFERENCES employees (employee_id);         
ALTER TABLE employees
    ADD CONSTRAINT emp_dept_fk FOREIGN KEY (department_id)
        REFERENCES departments (department_id);


ALTER TABLE departments
    ADD CONSTRAINT dept_manager_fk FOREIGN KEY (manager_id)
        REFERENCES employees (employee_id);

CREATE TABLE job_history (
    employee_id    NUMBER(6)     NOT NULL,
    start_date     DATE          NOT NULL,
    end_date       DATE          NOT NULL,
    job_id         VARCHAR2(10)  NOT NULL,
    department_id  NUMBER(4),
    CONSTRAINT job_history_pk PRIMARY KEY (employee_id, start_date),
    CONSTRAINT jhist_date_chk CHECK (end_date > start_date)
);

ALTER TABLE job_history
    ADD CONSTRAINT jhist_emp_fk  FOREIGN KEY (employee_id)
        REFERENCES employees (employee_id);
ALTER TABLE job_history
    ADD CONSTRAINT jhist_job_fk  FOREIGN KEY (job_id)
        REFERENCES jobs (job_id);
ALTER TABLE job_history
    ADD CONSTRAINT jhist_dept_fk FOREIGN KEY (department_id)
        REFERENCES departments (department_id);


INSERT INTO jobs VALUES ('IT_PROG',    'Programmer',           4000, 10000);
INSERT INTO jobs VALUES ('SA_REP',     'Sales Representative', 6000, 12000);
INSERT INTO jobs VALUES ('AC_ACCOUNT', 'Accountant',           4200,  9000);
INSERT INTO jobs VALUES ('BK_KEEP',    'Bookkeeper',           3000,  6000);
COMMIT;

SELECT * FROM jobs;


INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary, phone_number, commission_pct, manager_id, department_id)
VALUES (1, 'Jan',   'Kowalski',  'JKOWALSKI',  DATE '2020-01-15', 'AC_ACCOUNT', 8000, '515.123.4567', NULL, NULL, NULL);

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary, phone_number, commission_pct, manager_id, department_id)
VALUES (4, 'Piotr', 'Wiśniewski','PWISNIEWSKI',DATE '2021-09-01', 'AC_ACCOUNT', 6500, '515.123.7890', NULL, 1, NULL);

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary, phone_number, commission_pct, manager_id, department_id)
VALUES (2, 'Anna',  'Nowak',     'ANOWAK',     DATE '2021-03-10', 'BK_KEEP',    5000, '515.123.5678', NULL, 4, NULL);

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary, phone_number, commission_pct, manager_id, department_id)
VALUES (3, 'Ewa',   'Zielińska', 'EZIELINSKA', DATE '2022-06-20', 'BK_KEEP',    4500, '515.123.6789', NULL, 4, NULL);
COMMIT;

SELECT employee_id, last_name, job_id, manager_id FROM employees ORDER BY employee_id;

UPDATE employees
   SET manager_id = 1
 WHERE employee_id IN (2, 3);
COMMIT;

SELECT employee_id, last_name, manager_id FROM employees ORDER BY employee_id;

UPDATE jobs
   SET min_salary = min_salary + 500,
       max_salary = max_salary + 500
 WHERE LOWER(job_title) LIKE '%b%'
    OR LOWER(job_title) LIKE '%s%';
COMMIT;

SELECT * FROM jobs;

DELETE FROM jobs
 WHERE max_salary > 9000;
COMMIT;

SELECT * FROM jobs;

DROP TABLE job_history;


SELECT object_name, original_name, type, droptime
  FROM user_recyclebin;

FLASHBACK TABLE job_history TO BEFORE DROP;

SELECT * FROM job_history; 

SELECT constraint_name, constraint_type
  FROM user_constraints
 WHERE table_name = 'JOB_HISTORY';

ALTER TABLE job_history
    ADD CONSTRAINT jhist_emp_fk  FOREIGN KEY (employee_id)
        REFERENCES employees (employee_id);
ALTER TABLE job_history
    ADD CONSTRAINT jhist_job_fk  FOREIGN KEY (job_id)
        REFERENCES jobs (job_id);
ALTER TABLE job_history
    ADD CONSTRAINT jhist_dept_fk FOREIGN KEY (department_id)
        REFERENCES departments (department_id);