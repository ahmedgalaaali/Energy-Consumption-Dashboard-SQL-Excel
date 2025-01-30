CREATE TABLE consumptions (
    date DATE,
    building VARCHAR(10),
    water_consumption INT,
    electricity_consumption INT,
    gas_consumption INT
)

COPY consumptions (date, building, water_consumption, electricity_consumption, gas_consumption)
FROM 'C:\Mine\DEPI\Projects\Energy Consumption Dataset\consumptions.csv'
DELIMITER ','
CSV HEADER

CREATE TABLE building_mastery (
    building VARCHAR(10) PRIMARY KEY,
    city VARCHAR(25),
    county VARCHAR(10)
)

COPY building_mastery (building, city, county)
FROM 'C:\Mine\DEPI\Projects\Energy Consumption Dataset\building_master.csv'
DELIMITER ','
CSV HEADER

CREATE TABLE rates (
    year INT,
    energy_type VARCHAR(50),
    price_per_unit MONEY
)

COPY rates (year, energy_type, price_per_unit)
FROM 'C:\Mine\DEPI\Projects\Energy Consumption Dataset\rates.csv'
DELIMITER ','
CSV HEADER
-- :D
;

ALTER TABLE consumptions
ADD CONSTRAINT fk_building FOREIGN KEY (building)
REFERENCES building_mastery (building)
;

CREATE VIEW water_consumption_summary AS
SELECT 
    building AS "Building",
    water_consumption AS "Water Consumption",
    CASE WHEN EXTRACT(YEAR FROM date) = wr.year THEN price_per_unit * water_consumption END AS "Price",
    city AS "City",
    date AS "Date"
FROM consumptions
JOIN building_mastery USING(building)
JOIN (SELECT * FROM rates WHERE energy_type = 'Water') AS wr ON wr.year = EXTRACT(YEAR FROM date);

CREATE VIEW electricity_consumption_summary AS
SELECT 
    building AS "Building",
    electricity_consumption AS "Electricity Consumption",
    CASE WHEN EXTRACT(YEAR FROM date) = e.year THEN price_per_unit * electricity_consumption END AS "Price",
    city AS "City",
    date AS "Date"
FROM consumptions
JOIN building_mastery USING(building)
JOIN (SELECT * FROM rates WHERE energy_type = 'Electricity') AS e ON e.year = EXTRACT(YEAR FROM date);

CREATE VIEW gas_consumption_summary AS
SELECT 
    building AS "Building",
    gas_consumption AS "Gas Consumption",
    CASE WHEN EXTRACT(YEAR FROM date) = g.year THEN price_per_unit * gas_consumption END AS "Price",
    city AS "City",
    date AS "Date"
FROM consumptions
JOIN building_mastery USING(building)
JOIN (SELECT * FROM rates WHERE energy_type = 'Gas') AS g ON g.year = EXTRACT(YEAR FROM date);


INSERT INTO city_states (city, state) VALUES
    ('New York', 'New York'),
    ('Chicago', 'Illinois'),
    ('Houston', 'Texas'),
    ('Phoenix', 'Arizona'),
    ('Los Angeles', 'California');


ALTER TABLE building_mastery
ADD COLUMN state VARCHAR(50)

UPDATE building_mastery
SET state = 
    CASE
        WHEN city = 'New York' THEN 'New York'
        WHEN city = 'Chicago' THEN 'Illinois'
        WHEN city = 'Houston' THEN 'Texas'
        WHEN city = 'Phoenix' THEN 'Arizona'
        WHEN city = 'Los Angeles' THEN 'California'
    END;


