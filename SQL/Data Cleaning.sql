-- Capstone Project--

-- 1) --> Creating Database Capstone Project --
Create Database Capstone_Project;
use Capstone_Project;
-- 2) --> Importing file in SQL and stored as tables in database  --

-- 3) -->Check the number of Record in each tables -- 

select count(*) from account;
select count(*) from card;
select count(*) from client;
select count(*) from disp;
select count(*) from district;
select count(*) from loan;
select count(*) from orders;
select count(*) from transaction_data;

-- 4) --> Data Cleaning in each table -- 
	-- Account table cleaning --
    select * from account;
# Check null account ID
select count(*) as null_account_id
from account
where account_id is null;

# Check duplicate account_id
select account_id, count(*) as Count
from account
group by account_id
having count(*) > 1;

# finding missing / invalid dates
select count(*) as Null_account_date
from account
where date is null;

# convert date table data type from int to date
alter table account
modify Date date;

# clean & standardize Frequency Column 
select Frequency, count(*)
from account
group by Frequency;

update account
set Frequency = trim(upper(Frequency));

# check null district ID
select count(*) as null_district_id
from account
where district_id is null;

-- accounts whose district doesnt exist in district table
SELECT 
	acc.account_Id,
    acc.district_ID,
    acc.frequency,
	count(*) over() as count
FROM account acc
LEFT JOIN district dist ON acc.District_ID = dist.A1
WHERE dist.A1 IS NULL;

# final validation summary for account table
select 
	count(*) as Total_account,
    count(distinct account_id) as Unique_Account_IDs,
    sum(account_ID is null) as Null_Account_ID,
    sum(District_ID is null) as Null_District_ID,
    sum(Date is null) as Null_Account_Date
from account;



-- card Table cleaning --
select * from card;
# count rows & unique check 

select
	count(*) as Total_rows,
    count(distinct card_id) as Unique_Card_IDs,
    sum(card_id is null) as NUll_Card_ID,
    sum(disp_id is null) as Null_Disp_ID
from card ;

# check Duplicate
select card_id, count(*)
from card
group by card_id
having count(*) > 1;

# Standardize Category
update card
set type = trim(upper(type));

SELECT type, COUNT(*) AS cnt
FROM card
GROUP BY type
ORDER BY cnt DESC;

# fixing issued date datatype 
-- check the column 
select issued
from card
where issued is not null
limit 10;
-- add new column for safty purpose 
alter table card
add column issued_date date;
-- updating new added column
update card
set issued_date = str_to_date(substring(issued, 1, 6), '%y%m%d')
where issued is not null;
-- checking if the updated data is correct or not 
SELECT issued, issued_date
FROM card
LIMIT 10;
-- dropping and unused column
alter table card drop column issued;


SELECT COUNT(*) AS invalid_disp_fk
FROM card c
LEFT JOIN disp d ON c.Disp_ID = d.Disp_ID
WHERE d.Disp_ID IS NULL;

-- Client Table Cleaning--
select * from client;
# basic Profile Check 
select 
	count(*) as Total_rows,
	count(distinct client_id) as Unique_Clients,
    sum(client_id is null) as Null_Client_ID,
    sum(district_ID is null) as Null_District_ID
from client;

# Duplicate check
select 
	client_id,
    count(*) as cnt
from client
group by client_id
having count(*) > 1;

# adding index here to district id for fast query execution
CREATE INDEX idx_client_id ON client(Client_ID);
CREATE INDEX idx_client_district_id ON client(District_ID);


-- Disp Table Cleaning--
select * from Disp;

# Basic profile check 
select 
	count(*) as Total_rows,
	count(distinct disp_id) as Unique_Disp_IDs,
	sum(disp_id is null) as null_disp_id,
	sum(account_id is null) as Null_Account_Id,
	sum(Client_id is null) as Null_Client_ID,
	sum(type is null or trim(type)='') as Blank_type
from disp;

# duplicate CHeck
SELECT Disp_ID, COUNT(*) AS cnt
FROM disp
GROUP BY Disp_ID
HAVING COUNT(*) > 1;

# Standardize type column
update disp
set type = trim(upper(type));

# Distribution Check
SELECT type, COUNT(*) AS cnt
FROM disp
GROUP BY type
ORDER BY cnt DESC;

# referential intergrity checks
-- disp --> account check
select count(*) as Invalid_account_fk
from disp d
left join account a
on d.account_id = a.account_id
where a.account_id is null;

-- disp --> client check
select count(*) as invalid_client_fk
from disp d
left join client c
on d.client_id = c.client_id
where c.client_id is null;

# Check for if account as multiple owner
select account_id, count(*) as owner_count
from disp
where type = 'OWNER'
group by account_id
having count(*) > 1;


# converting column type of 'type' column beacuse its type is not supported for indexes
ALTER TABLE disp
MODIFY type VARCHAR(10);
# Add indexed for making join faster 
create index idx_disp_id on disp(disp_id);
create index idx_account_id on disp(account_id); 
create index idx_disp_Client_id on disp(Client_id); 
create index idx_disp_type on disp(type);

# disp table final summary 
select 
	count(*) as total_disp,
    count(distinct disp_id) as Unique_disp,
    sum(account_id is null) as null_account_id,
    sum(client_id is null) as null_client_id
from disp;

-- District table Cleaning --
select * from district;
# check profiling 
select 
	count(*) as total_rows,
    count(distinct A1) as unique_district_ids,
    sum(A1 is null) as null_district_id
from district;

# Stndardize district name column(A2)
update district
set A2 = trim(A2) 
where A2 is not null;

# fix numeric column
ALTER TABLE district
MODIFY A11 FLOAT,
MODIFY A12 FLOAT,
MODIFY A14 FLOAT;
-- check null in it 
select
	sum(A2 is null or trim(A2) = '') as null_district_name,
    sum(A11 is null) as null_avg_salary,
    sum(A12 is null) as null_unemployment,
    sum(A14 is null) as null_entrepreneur_ratio	
from district;

# add index to district id 
create index idx_district_id on district(A1);

# final validation
select 
	count(*) Total_districts,
    count(distinct A1) as Unique_districts
from district;

-- loan table cleaning --
select * from loan;
# basline check
select Status, count(*) as cnt
from loan
group by Status
order by Status;

# standardize Status values
update loan
set Status = trim(upper(Status));

# check loan_id
select count(*) as null_loan_id
from loan
where loan_id is null;

# duplicate loan_id
select loan_id, count(*) as cnt
from loan
group by loan_id
having count(*) >1;

# fix data type of numeric column
ALTER TABLE loan
MODIFY Amount FLOAT,
MODIFY Duration INT,
MODIFY Payments FLOAT;

# check null
SELECT
  SUM(Account_ID IS NULL) AS null_account_id,
  SUM(Amount IS NULL) AS null_amount,
  SUM(Duration IS NULL) AS null_duration,
  SUM(Payments IS NULL) AS null_payments,
  SUM(Status IS NULL) AS null_status
FROM loan;

# converting date column data type
alter table loan
modify date date;

# check null rows
SELECT COUNT(*) AS loans_without_account
FROM loan ln
LEFT JOIN account acc ON ln.Account_ID = acc.Account_ID
WHERE acc.Account_ID IS NULL;

# modifying Status column dtype text --> varchar for indexing 
alter table loan
modify Status varchar(10);

# add indexes
create index idx_loan_id on loan(loan_id);
create index idx_loan_account on loan(account_id);
create index idx_loan_status on loan(Status);

-- Orders table cleaning --
select * from Orders;
# check profile
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT Order_ID) AS unique_orders,
    SUM(Order_ID IS NULL) AS null_order_id,
    SUM(Account_ID IS NULL) AS null_account_id,
    SUM(Amount IS NULL) AS null_amount
FROM orders;

# check duplicate 
select order_id, count(*) as cnt
from Orders
group by order_id
having count(*) > 1;

# fix data types 
ALTER TABLE orders
MODIFY Amount FLOAT;

# clean categorical columns
-- Standardize K_symbol Columns
UPDATE orders
SET K_symbol = TRIM(UPPER(K_symbol))
WHERE K_symbol IS NOT NULL;

# foregin key check 
-- orders --> account
SELECT COUNT(*) AS invalid_account_fk
FROM orders o
LEFT JOIN account a ON o.Account_ID = a.Account_ID
WHERE a.Account_ID IS NULL;

# adding Indexs
CREATE INDEX idx_orders_id ON orders(Order_ID);
CREATE INDEX idx_orders_account ON orders(Account_ID);


-- Transaction_Data table cleaning --
select * from Transaction_Data;
# check basic Profile 
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT Trans_ID) AS unique_trans,
    SUM(Trans_ID IS NULL) AS null_trans_id,
    SUM(Account_ID IS NULL) AS null_account_id,
    SUM(Amount IS NULL) AS null_amount,
    SUM(Balance IS NULL) AS null_balance
FROM transaction_Data;

# check duplicate trans_id
SELECT Trans_ID, COUNT(*) AS cnt
FROM Transaction_Data
GROUP BY Trans_ID
HAVING COUNT(*) > 1;

# fix data types
ALTER TABLE Transaction_Data
MODIFY Amount FLOAT,
MODIFY Balance FLOAT;

# clean Categorical column
-- type
-- operation
-- k_symbol

# Standardize columns 
UPDATE Transaction_Data
SET 
    Type = TRIM(UPPER(Type)),
    Operation = TRIM(UPPER(Operation)),
    K_symbol = NULLIF(TRIM(UPPER(K_symbol)), '');

# check unique distribution
SELECT Type, COUNT(*) FROM Transaction_Data GROUP BY Type;
SELECT Operation, COUNT(*) FROM Transaction_Data GROUP BY Operation;
SELECT K_symbol, COUNT(*) FROM Transaction_Data GROUP BY K_symbol;

# fis date column data type
SELECT Date
FROM transaction_Data
WHERE Date IS NOT NULL
LIMIT 10;

alter table transaction_data drop column txn_date;
alter table transaction_data add column txn_date date;
update transaction_data
set txn_date = str_to_date(date, '%y%m%d')
where date is not null;

ALTER TABLE transaction_data DROP COLUMN Date;
ALTER TABLE transaction_data CHANGE COLUMN Date transaction_Date DATE;

# foregin key check 
-- transaction_data --> account
SELECT COUNT(*) AS invalid_account_fk
FROM transaction_data t
LEFT JOIN account a ON t.Account_ID = a.Account_ID
WHERE a.Account_ID IS NULL;

# add indexes
CREATE INDEX idx_txn_id ON transaction_data(Trans_ID);
CREATE INDEX idx_txn_account ON transaction_data(Account_ID);
CREATE INDEX idx_txn_date ON transaction_data(transaction_Date);

select * from transaction_Data

