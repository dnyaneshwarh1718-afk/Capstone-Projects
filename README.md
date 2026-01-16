##  End-to-End Banking Analytics Pipeline: Master Table from Raw Transactions
📌 Project Overview

This project builds a complete Data Engineering + Analytics pipeline using real-world banking datasets. The goal is to convert raw banking data into a clean, structured Master Table by performing proper entity mapping and ETL, enabling further analysis and machine learning use cases.

The pipeline starts from loading raw datasets into a staging database, then applies ETL transformations to integrate multiple relational tables into one unified analytics-ready dataset. 

Problem Statement

🎯 Objective

To create a Master Table by combining all relevant banking datasets using correct entity relationships, ensuring that Client_ID is included as the common identifier across the system. 

Problem Statement

🗂️ Datasets Used

The project integrates multiple banking relations including:

Account → static account details

Client → customer information

Disposition → links clients with accounts (rights/ownership mapping)

Transaction → transaction history per account

Orders → permanent payment orders

Loan → loan details (target dataset, max 1 loan per account)

Card → credit card services

District → demographic and regional information 

Problem Statement

🔥 Key Deliverables

✅ Raw data loaded into staging tables
✅ Entity mapping implemented using proper joins
✅ Aggregation tables created for high-volume datasets (transactions, orders, cards)
✅ Final Loan Master Table created with:

Loan details

Client + Account mapping

Transaction behavior features

Order and card features

Demographic district features 

Problem Statement
