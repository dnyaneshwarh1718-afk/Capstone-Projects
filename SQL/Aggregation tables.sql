# Creating Master Table as per business problem
-- Grain: 1 row per Loan_ID
-- Target column: Status
-- All features joined/aggregated properly

-- Build Aggregation tables(feature tables)
-- 1) Transaction Aggregation --> Txn_agg
drop table if exists txn_agg;
create table txn_agg as
select
	Account_ID,
    count(*) as txn_count,
    count(distinct transaction_date) as Active_Days,
    round(avg(amount),2) as Avg_Trans_Amount,
    sum(amount) as Total_Trans_Amount,
    round(avg(Balance),2) as Avg_Balance,
    round(stddev_pop(Balance),2) as Balance_Volatility,
    min(Balance) as Min_Balance,
    Max(Balance) As Max_Balance,
    
    sum(case
		when type = 'PRIJEM' then amount else 0
	end) as Total_Credit,
    sum(case
		when type in ('VYDAJ','VYBER') then abs(amount) else 0
	end) as Total_Debit,
    
    (
		sum(case when type = 'PRIJEM' then amount else 0 end) 
        - sum(case when type in ('VYDAJ','VYBER') then abs(amount) else 0 end)
    ) as Net_Cashflow,
    
    sum(case when k_symbol is null then 1 else 0 end) as K_Symbol_Null_Count,
    sum(case when k_symbol is not null then 1 else 0 end) as K_Symbol_known_Count
from transaction_data
group by account_id;

-- 2) Orders Aggregation --> order_agg
drop table if exists Order_agg;
create table order_agg as
select
	Account_ID,
    count(*) as Order_Count,
    Sum(Amount) as Total_Order_Amount,
    round(avg(Amount),2) as Avg_Order_Amount,
    min(amount) as Min_Order_amount,
    max(Amount) as Max_Order_Amount
from orders
Group by Account_ID;

-- 3) Disp Aggregation --> disp_agg
DROP TABLE IF EXISTS disp_agg;
CREATE TABLE disp_agg AS
SELECT
    Account_ID,
    COUNT(*) AS total_clients_on_account,
    SUM(CASE WHEN type = 'OWNER' THEN 1 ELSE 0 END) AS owner_count,
    SUM(CASE WHEN type = 'USER' THEN 1 ELSE 0 END) AS user_count,
    CASE WHEN COUNT(*) > 1 THEN 1 ELSE 0 END AS is_joint_account,

    -- for master table (one client_id per account rule)
    MAX(CASE WHEN type = 'OWNER' THEN Client_ID END) AS primary_client_id
FROM disp
GROUP BY Account_ID;


-- 4) card Aggregation --> card_agg
DROP TABLE IF EXISTS card_agg;

CREATE TABLE card_agg AS
SELECT
    d.Account_ID,
    COUNT(c.Card_ID) AS Card_Count,
    CASE WHEN COUNT(c.Card_ID) > 0 THEN 1 ELSE 0 END AS Has_Card,
    SUM(CASE WHEN c.type='GOLD' THEN 1 ELSE 0 END) AS Gold_Card_Count,
    SUM(CASE WHEN c.type='JUNIOR' THEN 1 ELSE 0 END) AS Junior_Card_Count,
    SUM(CASE WHEN c.type='CLASSIC' THEN 1 ELSE 0 END) AS Classic_Card_Count
FROM disp d
LEFT JOIN card c ON d.Disp_ID = c.Disp_ID
GROUP BY d.Account_ID;

-- 5) Creating Client_Master Table
DROP TABLE IF EXISTS client_master;

CREATE TABLE client_master AS
SELECT
    c.Client_ID,
    c.District_ID,

    -- District (wrapped)
    MAX(dist.A2) AS district_name,
    MAX(dist.A3) AS region,
    MAX(dist.A11) AS avg_salary,
    MAX(dist.A12) AS unemployment_rate_1,
    MAX(dist.A13) AS unemployment_rate_2,
    AVG((dist.A12 + dist.A13)/2) AS avg_unemployment_rate,
    MAX(dist.A14) AS entrepreneurs_per_1000,
    MAX(dist.A15) AS crimes_1,
    MAX(dist.A16) AS crimes_2,

    -- Client → Accounts info (via disp)
    COUNT(DISTINCT d.Account_ID) AS total_accounts,

    -- Transaction Behavior
    COALESCE(SUM(ta.txn_count), 0) AS total_txn_count,
    COALESCE(AVG(ta.avg_balance), 0) AS avg_balance_across_accounts,
    COALESCE(SUM(ta.total_credit), 0) AS total_credit,
    COALESCE(SUM(ta.total_debit), 0) AS total_debit,

    -- Orders Behavior
    COALESCE(SUM(oa.order_count), 0) AS total_orders,
    COALESCE(SUM(oa.total_order_amount), 0) AS total_order_amount,

    -- Cards
    COALESCE(SUM(ca.card_count), 0) AS total_cards,
    MAX(COALESCE(ca.has_card, 0)) AS has_card,

    -- Loan summary
    COUNT(DISTINCT l.Loan_ID) AS total_loans,
    COALESCE(SUM(l.Amount), 0) AS total_loan_amount,
    COALESCE(AVG(l.Payments), 0) AS avg_loan_payment

FROM client c
LEFT JOIN disp d ON c.Client_ID = d.Client_ID
LEFT JOIN account acc ON d.Account_ID = acc.Account_ID
LEFT JOIN txn_agg ta ON acc.Account_ID = ta.Account_ID
LEFT JOIN order_agg oa ON acc.Account_ID = oa.Account_ID
LEFT JOIN card_agg ca ON acc.Account_ID = ca.Account_ID
LEFT JOIN loan l ON acc.Account_ID = l.Account_ID
LEFT JOIN district dist ON c.District_ID = dist.A1
GROUP BY c.Client_ID, c.District_ID;

-- data_quality_checks
SELECT COUNT(*) FROM client;
SELECT COUNT(*) FROM client_master;

SELECT COUNT(DISTINCT Client_ID) FROM client_master;

