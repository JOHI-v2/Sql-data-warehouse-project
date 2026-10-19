

/*CREATE DATABASE AND SCHEMAS

SCRIPT PURPOSE: this script creates a Database named 'DataWarehouse'
after checking if it esists and in that case it drops the existing one
and recreate it, after, It creates there schemas for the Layers 'Bronze'
, 'Silver' and 'Gold'
*/
use master
GO

IF EXISTS ( SELECT 1 FROM  sys.databases WHERE name = 'DataWarehouse')
BEGIN 
    ALTER DATABASE DataWarehouse
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse
END;
GO    



Create DATABASE DataWarehouse
GO 


USE DataWarehouse  
GO


CREATE SCHEMA Bronze;
GO


CREATE SCHEMA Silver;
GO


CREATE SCHEMA Gold;
GO

SELECT
    name
FROM
    sys.schemas
GO

    
  
