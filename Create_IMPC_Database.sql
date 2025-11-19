-- [CREATING TABLES] -- 
-- The max length of the values in each column (that were't included in the SOP) were looked at through R with the function max(nchar()).
-- Having the maximum value personalised to our data is better for not taking up unnecessary storage space.
-- In the statements below, each table is created by defining its name, the column names, the data types they store, and their maximum allowed lengths.
-- Constraints are also included to enforce rules on the data, in this case, the primary keys, preventing invalid or inconsistent values.

-- [DISEASE] -- 
CREATE TABLE Disease_staging (
    disease_id VARCHAR(255),
    disease_name VARCHAR(255),
    omim_id TEXT,
    mgi_accession_id VARCHAR(255)
);

LOAD DATA LOCAL INFILE '/Users/megantucker/Desktop/MSc/DCDM_25_26/dcdmCoursework/Disease.csv'
INTO TABLE Disease_staging
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES

create table Disease (
    disease_id varchar(20) not null,
    disease_name varchar(150),
    omim_id TEXT, #changed to TEXT from varchar
    constraint disease_pk primary key (disease_id)
);

INSERT INTO Disease (disease_id, disease_name, omim_id)
SELECT 
    disease_id,
    disease_name,
    omim_id
FROM Disease_staging;

#To clear faulty/old data before uploading new
TRUNCATE TABLE Analysis;

-- [PARAMETER] -- 
CREATE TABLE Parameter_staging (
    impc_parameter_orig_id VARCHAR(50),
    parameter_name VARCHAR(255),
    description TEXT,
    parameter_code VARCHAR(255)
);

LOAD DATA LOCAL INFILE '/Users/megantucker/Desktop/MSc/DCDM_25_26/dcdmCoursework/Parameter.csv'
INTO TABLE Parameter_staging
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

create table Parameter (
    impc_parameter_orig_id int not null,
    parameter_code varchar(20),
    parameter_name varchar(100) not null, #100 characters to be changed to 74
	description TEXT, #changed to TEXT from varchar
	constraint parameter_pk primary key (impc_parameter_orig_id)
);

INSERT INTO Parameter (impc_parameter_orig_id, parameter_code, parameter_name, description)
SELECT 
    impc_parameter_orig_id,
    parameter_code,
    parameter_name,
    description
FROM Parameter_staging;

-- [PROCEDURES] --
CREATE TABLE Procedures_staging (
    procedure_name VARCHAR(255),
    description TEXT,
    is_mandatory VARCHAR(6),
    impc_parameter_orig_id VARCHAR(10)
);

LOAD DATA LOCAL INFILE '/Users/megantucker/Desktop/MSc/DCDM_25_26/dcdmCoursework/Procedures.csv'
INTO TABLE Procedures_staging
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

create table Procedures (
    procedure_id int auto_increment not null,
    procedure_name varchar(50) not null,
    description TEXT, #changed to TEXT from varchar
    is_mandatory tinyint not null default 0,
    constraint procedures_pk primary key (procedure_id)
);

INSERT INTO Procedures (procedure_name, description, is_mandatory)
SELECT DISTINCT
    procedure_name,
    description,
    CASE
    	WHEN UPPER (is_mandatory) = 'TRUE' THEN 1
    	WHEN UPPER (is_mandatory) = 'FALSE' THEN 0
    	ELSE NULL
    END AS is_mandatory
FROM Procedures_staging;

-- [ANALYSIS]--

CREATE TABLE Analysis_staging (
    analysis_id VARCHAR(25),
    mgi_accession_id VARCHAR(255),
    gene_symbol VARCHAR(25),
    mouse_life_stage VARCHAR(25),
    mouse_strain VARCHAR(5),
    parameter_id VARCHAR(25),
    parameter_name VARCHAR(255),
    pvalue VARCHAR(5)
);

LOAD DATA LOCAL INFILE '/Users/megantucker/Desktop/MSc/DCDM_25_26/dcdmCoursework/Analysis.csv'
INTO TABLE Analysis_staging
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

create table Analysis (
    analysis_id varchar(25) not null,
    mgi_accession_id varchar(25) not null,
    gene_symbol varchar(25) not null,
    mouse_life_stage varchar(25),
    mouse_strain varchar(5),
    impc_parameter_orig_id int,
    pvalue double,
    constraint analysis_pk primary key (analysis_id),
    foreign key (impc_parameter_orig_id) references Parameter (impc_parameter_orig_id)
);

INSERT INTO Analysis (analysis_id, mgi_accession_id, gene_symbol, mouse_life_stage, mouse_strain, impc_parameter_orig_id, pvalue)
SELECT
    a.analysis_id,
    a.mgi_accession_id,
    a.gene_symbol,
    a.mouse_life_stage,
    a.mouse_strain,
    p.impc_parameter_orig_id,
    a.pvalue
FROM Analysis_staging a
LEFT JOIN Parameter p
	ON a.parameter_id = p.parameter_code
	AND a.parameter_name = p.parameter_name;

-- [CREATING INDEXES]
-- In the following lines, indexes are created on the columns that are most commonly searched by researchers. 
-- Indexes allow the database to quickly locate the rows that match a query without scanning the entire table.
-- This significantly improves query performance.
-- it's better to create them before the joining tables

create index idx_disease_name 
    on Disease (disease_name);

create index idx_parameter_name 
    on Parameter (parameter_name);

create index idx_analysis_columns 
    on Analysis (mgi_accession_id, impc_parameter_orig_id, gene_symbol);

-- [CREATING JOINING TABLES] -- #MEGAN HAS NOT TOUCHED THESE YET

create table impc_analysis_disease (
    mgi_accession_id varchar(11) not null,
    disease_id varchar(20),
    constraint impc_analysis_disease_pk primary key (mgi_accession_id, disease_id),
    foreign key (mgi_accession_id) references impc_analysis (mgi_accession_id),
    foreign key (disease_id) references impc_disease (disease_id)
);

create table impc_parameter_group_member (
    impc_parameter_orig_id int not null,
    parameter_group_id int not null,
    constraint impc_parameter_group_member_pk primary key (impc_parameter_orig_id, parameter_group_id),
    foreign key (impc_parameter_orig_id) references impc_parameter (impc_parameter_orig_id),
    foreign key (parameter_group_id) references impc_parameter_group (parameter_group_id)
);

create table impc_procedure_parameter (
    procedure_id int not null,
    impc_parameter_orig_id int not null,
    constraint impc_procedure_parameter_pk primary key (procedure_id, impc_parameter_orig_id),
    foreign key (procedure_id) references impc_procedure (procedure_id),
    foreign key (impc_parameter_orig_id) references impc_parameter (impc_parameter_orig_id)
);

-- When importing the data it must be imported in dependency order since in a relational database tables will depend on each other through FKs
-- So a value in one table must already exist in another table before it can be referenced.

-- table dependency order:
-- Disease
-- Parameter
-- ParameterGroup
-- Procedure
-- Analysis
-- impc_analysis_disease
-- impc_parameter_group_member
-- impc_procedure_parameter


