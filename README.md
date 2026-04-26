# IAM490W-GRP7_Junior_Noel
Relational nonprofit fundraising database built using MySQL. Includes ERD, normalized schema, SQL scripts (DDL/DML/queries), CSV datasets, and documentation for full project reproducibility.

This project uses the Mock Nonprofit Fundraising Data dataset from Kaggle.

CSV files included in this repository:
constituents.csv
campaigns.csv
transactions.csv
pledges.csv
pledge_payments.csv
donor_metrics.csv
appeals.csv
funds.csv
households.csv
relationships.csv
How to Reproduce the Database in MySQL Workbench
Step 1 — Create the Database

Open MySQL Workbench and run:

CREATE DATABASE nonprofit_db;
USE nonprofit_db;
Step 2 — Run the DDL Script

Open and execute:

/sql/01_create_tables.sql

This will create all tables with primary and foreign keys.

Step 3 — Import the CSV Files

For each table:

Right-click the table → Table Data Import Wizard
Select the matching CSV file from the /data folder
Ensure column names match exactly
Complete the import
Step 4 — Run the Queries

Open and execute:

/sql/02_queries.sql

This file contains all SELECT, JOIN, aggregation, and analytical queries used in the report and presentation.

Alternative (Fastest Method)

Instead of importing CSV files manually, you may run:

/sql/full_database_with_data.sql

This script:

Creates all tables
Inserts all data
Allows immediate execution of queries
Expected Outcome

After completing the steps above, you will be able to run all queries and reproduce the results shown in the project report and PowerPoint presentation.
