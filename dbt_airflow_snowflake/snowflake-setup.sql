USE ROLE ACCOUNTADMIN;

  CREATE OR REPLACE DATABASE LB;

  CREATE OR REPLACE SCHEMA "LB"."RAW";
  CREATE OR REPLACE SCHEMA "LB"."STAGE";

-- Create raw tables
CREATE TABLE lb.raw.contract (
    id INTEGER,
    type VARCHAR(50),
    energy VARCHAR(50),
    usage FLOAT,
    usagenet FLOAT,
    createdat TIMESTAMP,
    startdate DATE,
    enddate DATE,
    city VARCHAR(100),
    status VARCHAR(50),
    productid INTEGER,
    modificationdate TIMESTAMP
);

CREATE TABLE lb.raw.prices (
    id INTEGER,
    productid INTEGER,
    pricecomponentid INTEGER,
    productcomponent VARCHAR(50),
    price FLOAT,
    unit VARCHAR(20),
    modificationdate TIMESTAMP
);

CREATE TABLE lb.raw.products (
    id INTEGER,
    productcode VARCHAR(50),
    productname VARCHAR(100),
    energy VARCHAR(50),
    consumptiontype VARCHAR(50),
    deleted BOOLEAN,
    modificationdate TIMESTAMP
);

-- Create stage table
CREATE TABLE lb.stage.fact_energy_revenue (
    contract_id INTEGER,
    type VARCHAR(50),
    energy VARCHAR(50),
    usage FLOAT,
    usagenet FLOAT,
    createdat TIMESTAMP,
    startdate DATE,
    enddate DATE,
    city VARCHAR(100),
    status VARCHAR(50),
    productid INTEGER,
    productcode VARCHAR(50),
    productname VARCHAR(100),
    grundpreis FLOAT,
    arbeitspreis FLOAT,
    revenue FLOAT,
    modificationdate TIMESTAMP
);

--VIEWS 