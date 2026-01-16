-- Master table as per problem statement
-- Grain: 1 row per Loan_ID
-- Target column: Status

DROP TABLE IF EXISTS loan_master;

CREATE TABLE loan_master AS
SELECT
    -- Loan (Target Base)
    ln.Loan_ID,
    ln.Account_ID,
    ln.Date     AS Loan_Date,
    ln.Amount   AS Loan_Amount,
    ln.Duration,
    ln.Payments,
    ln.Status,

    -- Account Details
    acc.Frequency,
    acc.Date AS Account_Date,

    -- Disposition (Aggregates)
      
	COALESCE(da.primary_client_id, 0) AS Client_ID,
    COALESCE(da.owner_count, 0)       AS owner_count,
    COALESCE(da.user_count, 0)        AS user_count,
    COALESCE(da.is_joint_account, 0)  AS is_joint_account,

    -- Transaction Behavior (Aggregates)
    COALESCE(ta.txn_count, 0)           AS txn_count,
    COALESCE(ta.active_days, 0)         AS active_days,
    COALESCE(ta.Avg_Trans_Amount, 0)    AS Avg_Trans_Amount,
    COALESCE(ta.total_Trans_amount, 0)  AS Total_Trans_Amount,
    COALESCE(ta.avg_balance, 0)         AS Avg_Balance,
    COALESCE(ta.balance_volatility, 0)  AS Balance_Volatility,
    COALESCE(ta.total_credit, 0)        AS Total_Credit,
    COALESCE(ta.total_debit, 0)         AS Total_Debit,
    COALESCE(ta.net_cashflow, 0)        AS Net_Cashflow,

    -- Orders (Aggregates)
    COALESCE(oa.order_count, 0)         AS Order_Count,
    COALESCE(oa.total_order_amount, 0)  AS Total_Order_Amount,
    COALESCE(oa.avg_order_amount, 0)    AS Avg_Order_Amount,

    -- Cards (Aggregates)
    COALESCE(ca.card_count, 0)       AS card_count,
    COALESCE(ca.has_card, 0)         AS has_card,
    COALESCE(ca.gold_card_count, 0)  AS gold_card_count,

    -- District Info (via Account → District)
    dist.A2 AS district_name,
    dist.A3 AS region,
    dist.A11 AS avg_salary,
    dist.A12 AS unemployment_rate_1,
    dist.A13 AS unemployment_rate_2,
    (dist.A12 + dist.A13) / 2 AS avg_unemployment_rate,
    dist.A14 AS entrepreneurs_per_1000,
    dist.A15 AS crimes_1,
    dist.A16 AS crimes_2

FROM loan ln
LEFT JOIN account acc   ON ln.Account_ID = acc.Account_ID
LEFT JOIN txn_agg ta    ON ln.Account_ID = ta.Account_ID
LEFT JOIN order_agg oa  ON ln.Account_ID = oa.Account_ID
LEFT JOIN card_agg ca   ON ln.Account_ID = ca.Account_ID
LEFT JOIN disp_agg da   ON ln.Account_ID = da.Account_ID
LEFT JOIN district dist ON acc.District_ID = dist.A1;


 -- data_quality_checks
select Status, count(*) from loan_master
group by Status;
select Status, count(*) from loan
group by Status;

# main SQL Query 
select * from loan_master;


