--library management system

---create branch table

Create table branch
(
       branch_id VARCHAR(10) PRIMARY KEY,
	   manager_id VARCHAR(10),
	   branch_address VARCHAR(60),
	   contact_no VARCHAR(10)
);

alter table branch
alter column contact_no TYPE VARCHAR(20);

CREATE TABLE employees 
(
  emp_id varchar(10) Primary Key,
  emp_name VARCHAR(20), 
  position VARCHAR(15),
  salary INT,
  branch_id VARCHAR(20)
);
alter table employees
alter column salary TYPE FLOAT;

Create Table books 
(
 isbn VARCHAR(20) PRIMARY KEY,
 book_title VARCHAR(100),
 category VARCHAR(25),
 rental_price INT,
 status VARCHAR(10),
 author VARCHAR(40),
 publisher VARCHAR(40)
);

alter table books
alter column rental_price TYPE FLOAT;

Create table members 
(
     member_id VARCHAR(10) PRIMARY KEY,
	 member_name VARCHAR(20),
	 member_address VARCHAR(20),
	 reg_date DATE
);

DROP TABLE IF EXISTS issued_status;
Create table issued_status 
(
issued_id VARCHAR(10) PRIMARY KEY,
issued_member_id VARCHAR(10),
issued_book_name VARCHAR(70),
issued_date DATE,
issued_book_isbn VARCHAR(20),
issued_emp_id VARCHAR(10)
);

Create table return_status
(
return_id VARCHAR(10) PRIMARY KEY,
issued_id VARCHAR(10),
return_book_name VARCHAR(75),
return_date DATE,
return_book_isbn VARCHAR(20)
);

--FOREIGN KEY
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);