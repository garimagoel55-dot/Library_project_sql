SELECT * FROM branch;
SELECT * FROM members;
SELECT * FROM employees;
SELECT * FROM books;
SELECT * FROM issued_status;
SELECT * FROM return_status;

-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books (isbn,book_title,	category,rental_price,status,author,publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co')
SELECT * FROM books

-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Main St'
WHERE member_id ='C101';
SELECT *FROM members

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.

SELECT * FROM issued_status
DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
     issued_emp_id,
	 COUNT (issued_id) as total_books_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT (issued_id) > 1

-- ### 3. CTAS (Create Table As Select)

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt

CREATE TABLE book_cnts
AS
SELECT 
     b.isbn,
	 b.book_title,
	 COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1,2;

-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category ='Classic'

-- Task 8: Find Total Rental Income by Category:

SELECT
     b.category,
	 SUM(b.rental_price),
     COUNT(*)
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1

-- Task 9. **List Members Who Registered in the Last 180 Days**:

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'


-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:

SELECT 
     e1.*,
	 b.branch_id,
	 e2.emp_name as manager
FROM employees as e1
JOIN
branch as b
ON e1.emp_id = b.branch_id
JOIN
employees as e2
ON b.manager_id = e2.emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:

CREATE TABLE expensive_books
AS
SELECT * FROM books
WHERE rental_price > 7;

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT * 
FROM issued_status as ist
LEFT JOIN 
return_status as rs
ON ist.issued_id= rs.issued_id
WHERE rs.return_id IS NULL

/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

SELECT 
     m.member_id,
	 m.member_name,
	 bk.book_title,
	 ist.issued_date,
	 rs.return_date,
	 CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN
members as m
on m.member_id = ist.issued_member_id
JOIN
books as bk
ON bk.isbn = ist.issued_book_name
LEFT JOIN
return_status as rs
ON rs.return_id = ist.issued_id
WHERE
    rs.return_id IS NULL
    AND
	(CURRENT_DATE - ist.issued_date) >30
ORDER BY 1

/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" 
when they are returned (based on entries in the return_status table)
*/

-- stored Procedures
CREATE OR REPLACE PROCEDURE add_return_data(p_return_id VARCHAR(10),p_issued_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
      v_isbn VARCHAR(20);
	  v_book_name VARCHAR (100);
	 
BEGIN
  INSERT INTO return_status(return_id,issued_id,return_date)
  VALUES
  (p_return_id,p_issued_id,CURRENT_DATE);

 SELECT 
       issued_book_isbn
	   issued_book_name
       INTO
	   v_isbn,
	   v_book_name
 FROM issued_status
 WHERE issued_id = p_issued_id;

UPDATE books
SET staus = 'yes'
WHERE isbn = v_isbn;

   RAISE NOTICE 'Thank you for returning the book %', v_book_name;
  
 END;
 $$

-- Testing FUNCTION add_return_data

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_data('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_data('RS148', 'IS140', 'Good');

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/

SELECT * FROM branch;

SELECT * FROM employees;

SELECT * FROM books;

SELECT * FROM return_status;

CREATE TABLE branch_report
AS
SELECT 
     b.branch_id,
	 b.manager_id,
	 COUNT(ist.issued_id) as number_book_issued,
	 COUNT(rs.return_id) as number_of_books_return,
	 SUM(bk.rental_price) as Total_revenue
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.return_id = ist.issued_id
JOIN
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1,2;

/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members
containing members who have issued at least one book in the last 24 months.
*/

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT  
                     DISTINCT issued_member_id
                     FROM issued_status
                     WHERE issued_date >= CURRENT_DATE - INTERVAL '24 months'
					 )
;

SELECT * FROM active_members;

/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most 
book issues. Display the employee name, number of books processed, and their branch.
*/

SELECT 
     e.emp_name,
	 b.*,
	 COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON b.branch_id = e.branch_id
GROUP BY 1,2

/*
Task 18: Stored Procedure Objective: 
Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its 
issuance. The procedure should function as follows: The stored procedure should 
take the book_id as an input parameter. The procedure should first check 
if the book is available (status = 'yes'). If the book is available, it should be issued, 
and the status in the books table should be updated to 'no'. If the book is not 
available (status = 'no'), the procedure should return an error message 
indicating that the book is currently not available.
*/

SELECT * FROM issued_status

CREATE OR REPLACE PROCEDURE books_status((p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10)))
LANGUAGE plpgsql
AS
$$

DECLARE
     v_status VARCHAR(10)

BEGIN
   SELECT 
        status
		INTO
		v_status
	FROM books
	WHERE isbn = p_issued_book_isbn
   IF v_status = 'yes' THEN

    INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;

END;
$$

-- Testing The function
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'