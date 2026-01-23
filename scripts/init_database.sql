/*

===================================================
Create Database and Schemas
===================================================
Script Porpuse: 
  This script creates a new database named 'datawarehouse' after checking if it already exists.
  First, it terminates active connections if the database is active, then it is dropped and recreated.
  Additionally, the script sets up three schemas within the database: 'bronze', 'silver', and 'gold'.

WARNING:
  Running this script will drop the entire 'datawarehouse' database if it exists.
  All data in the database will be permanently deleted. Proceed with caution
  and ensure you have proper backups before running this script.
*/


-- Create Database "DataWarehouse"

USE master;
GO 


-- Drop and Recreate the "DataWarehouse" database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWareHouse;
END;
GO

-- Create Database
CREATE DATABASE DataWareHouse;
GO

USE DataWareHouse;
GO


-- Create Schema
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
