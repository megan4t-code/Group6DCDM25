-- [CREATING THE IMPC DATABASE] ----------------------------------------------------------------------------------------------------------
-- Max values of columns where chosen to aproximatelely.

-- =====================================================================
-- PROCEDURES AND PARAMETERS
-- =====================================================================

create table impc_procedure_original (
    impc_parameter_orig_id int not null,
    procedure_name varchar(50) not null,
    description text,
    is_mandatory varchar(5),
    constraint impc_procedure_original_pk primary key (impc_parameter_orig_id)
)

-- This is a staging table used only for the initial data import.
-- It stores the original columns exactly as they appear in the source files, which makes loading the raw data straightforward.
-- Later, we will transform this data into the final 'impc_procedure' table.
-- Once the transformation is complete, this staging table will be dropped.

-- ************ 1. Import clean procedure table with original columns *********

create table impc_procedure (
    procedure_id int auto_increment not null,
    procedure_name varchar(50) not null,
    description text,
    is_mandatory varchar(5),
    constraint impc_procedure_pk primary key (procedure_id)
)

-- This is the final 'impc_procedure' table, where 'procedure_id' will be the auto-increment primary key and we will no longer have impc_parameter_orig_id as a column.

create table impc_parameter (
    impc_parameter_orig_id int not null,
    parameter_code varchar(20),
    parameter_name varchar(100) not null,
    description text,
    constraint impc_parameter_pk primary key (impc_parameter_orig_id)
)

-- Running a diagnostic check before creating the joining table, just to understand if the relationship between procedure and parameter
-- is one-to-many (one procedure can have many parameters) or many to many.

-- ************ 2. Import clean parameters table *********

select impc_parameter_orig_id, 
       count(distinct procedure_name) as num_procedures
from impc_procedure_original
group by impc_parameter_orig_id
having num_procedures > 1;

-- result: should not return rows. This query only shows rows where the same impc_parameter_orig_id appears in more than one procedure. 
-- If it returns no rows, that means: For every impc_parameter_orig_id in impc_procedure_original, there is only one procedure_name.

create table impc_procedure_parameter (
    procedure_id int not null,
    impc_parameter_orig_id int not null,
    constraint pk_procedure_parameter primary key (procedure_id, impc_parameter_orig_id),
    constraint fk_pp_procedure foreign key (procedure_id)
        references impc_procedure(procedure_id),
    constraint fk_pp_parameter foreign key (impc_parameter_orig_id)
        references impc_parameter(impc_parameter_orig_id)
)

-- This is the joining table of impc_procedure and impc_parameter
-- Even though the relationship is one-to-many (one procedure can have many parameters), we still use a joining table to keep the design flexible and fully normalised.

insert into impc_procedure (procedure_name, description, is_mandatory)
select 
    procedure_name,
    min(description) as description, -- since description isn't grouped
    is_mandatory
from impc_procedure_original
group by procedure_name, is_mandatory

-- Here we are inserting data into the final 'impc_procedure' table with one row per distinct procedure.
-- We group by (procedure_name and  is_mandatory) because the impc_procedure_original table has one row per parameter, so the same procedure can appear many times.
-- By doing this we avoid repetition and redundancies
-- 'procedure_id' is generated here as the new primary key.

insert into impc_procedure_parameter (procedure_id, impc_parameter_orig_id)
select
    p.procedure_id,
    o.impc_parameter_orig_id
from impc_procedure p
join impc_procedure_original o
      on p.procedure_name = o.procedure_name
     and p.is_mandatory  = o.is_mandatory
     
 
-- Adding information into the joining table impc_procedure_parameter.
-- For each row in the staging table, we: find the matching procedure in 'impc_procedure' (same name + is_mandatory), take its new 'procedure_id'
-- and link it to the corresponding 'impc_parameter_orig_id'. This is called MAPPING.
     
-- =====================================================================
--  disease + omim + gene
-- =====================================================================
     
 -- For this part we have previously split disease into diseas table and Omim records since there are many omim records for one disease.

create table disease (
    disease_id varchar(20) not null,
    disease_name varchar(150),
    constraint disease_pk primary key (disease_id)
)

-- ***************** 3. upload split disease table (the table that only has disease id and disease name) *****

create table gene (
    mgi_accession_id varchar(15) not null,
    gene_symbol varchar(20),
    constraint gene_pk primary key (mgi_accession_id)
)

-- Why it is a good idea for gene to have its own table:
-- If one day you update the gene table and the gene symbol changes, you must update 1 row in the IMPC_gene table, but if you left it in
-- Analysis, you must update possibly thousands of rows, and the database becomes inconsistent
-- It is better for gene to have it's own identity.
-- no need to upload any file because we will populate it below.

create table omim_records (
    disease_id varchar(20) not null,
    omim_id varchar(20) not null,
    constraint omim_records_pk primary key (disease_id, omim_id), -- COMPOSITE PK
    constraint omim_records_disease_fk foreign key (disease_id) references disease(disease_id)
)

-- Since Disease id will be repeated as well as Omim Id, then the PK for this table has to be the unique combination of both.

-- ***************** 4. upload split Omim records table (the table that only has disease id and Omim record) *****

-- =====================================================================
--  analysis staging table
-- =====================================================================

create table impc_analysis_original (
    analysis_id varchar(15) not null,
    mgi_accession_id varchar(15) not null,
    gene_symbol varchar(15) not null,
    mouse_strain varchar(5),
    mouse_life_stage varchar(20),
    parameter_id varchar(20),
    parameter_name varchar(100),
    pvalue double
)

-- we also need a staging table for analysis given that we want to introduce impc_parameter_orig_id into this table later and we will remove gene symbol to remove redundancies

-- ***************** 5. upload clean analysis table with the original columns *****

-- =====================================================================
-- populate gene (before creating analysis fk)
-- =====================================================================

insert into gene (mgi_accession_id, gene_symbol)
select distinct mgi_accession_id, gene_symbol
from impc_analysis_original

-- so gene will have data that came from the original analysis table

-- =====================================================================
-- 5. final normalised analysis table (no gene_symbol here)
-- =====================================================================

create table analysis (
    analysis_id varchar(15) not null,
    mgi_accession_id varchar(15) not null,
    mouse_strain varchar(5),
    mouse_life_stage varchar(20),
    all_parameter_codes varchar(20),
    impc_parameter_orig_id int null,
    parameter_name varchar(100),
    pvalue double,
    constraint analysis_pk primary key (analysis_id),
    constraint analysis_parameter_fk foreign key (impc_parameter_orig_id) references impc_parameter(impc_parameter_orig_id),
    constraint analysis_gene_fk foreign key (mgi_accession_id) references gene(mgi_accession_id)
)
-- We include 'impc_parameter_orig_id' as a (nullable) foreign key to 'impc_parameter'.
-- We cannot use 'all_parameter_codes' as a foreign key because it mixes IMPC and non-IMPC codes, and the 'impc_parameter' table only contains IMPC parameters. There is not a
-- one-to-one match between all_parameter_codes and rows in 'impc_parameter'.
-- A foreign key column itself may be NULL, but whenever it is NOT NULL, the referenced value must exist in the parent table.
-- We keep 'all_parameter_codes' as well because it still holds useful information about non-IMPC codes that cannot be linked to the 'impc_parameter' table.
 
-- =====================================================================
-- Insert cleaned data into final analysis table
-- =====================================================================

insert into analysis (
    analysis_id,
    mgi_accession_id,
    mouse_strain,
    mouse_life_stage,
    all_parameter_codes,
    impc_parameter_orig_id,
    parameter_name,
    pvalue
)
select
    a.analysis_id,
    a.mgi_accession_id,
    a.mouse_strain,
    a.mouse_life_stage,
    a.parameter_id as all_parameter_codes,
    min(i.impc_parameter_orig_id) as impc_parameter_orig_id,
    a.parameter_name,
    a.pvalue
from impc_analysis_original a
left join impc_parameter i
       on i.parameter_code = a.parameter_id
      and i.parameter_name = a.parameter_name
group by
    a.analysis_id,
    a.mgi_accession_id,
    a.mouse_strain,
    a.mouse_life_stage,
    a.parameter_id,
    a.parameter_name,
    a.pvalue
    
-- Here we are inserting the final data in the columns we want the final Analysis table to have
-- We must group them because:
-- IMPC parameters are duplicated across different procedures/tests and codes are often reused
-- The grouped insert is the safe, normalised, stable way to map your analysis data: we preserve exactly one row per analysis, the same non duplicate original 22,472 analysis tests
-- This time the 22,472 match the impc paramater original id if they have one (they won't if they are non IMPC)

 -- [JOINING TABLE FOR ANALYSIS DISEASE]
  
create table analysis_disease (
    analysis_id varchar(15) not null,
    disease_id  varchar(20) not null,
    constraint analysis_disease_pk primary key (analysis_id, disease_id),
    constraint analysis_disease_analysis_fk foreign key (analysis_id) references analysis(analysis_id),
    constraint analysis_disease_disease_fk foreign key (disease_id) references disease(disease_id)
)

-- This is done since anlaysis and disease is a many to many relationship

-- =====================================================================
--  Parameter groupings
-- =====================================================================

create table impc_group (
    group_id int auto_increment not null,
    group_name varchar(50) not null,
    constraint impc_parameter_group_pk primary key (group_id)
)

-- No need to insert data here as we will insert it manually below.

create table impc_parameter_group (
    impc_parameter_orig_id int,
    group_id int not null,
    constraint impc_parameter_group_pk primary key (impc_parameter_orig_id, group_id),
    constraint impc_pg_parameter_fk foreign key (impc_parameter_orig_id) references impc_parameter(impc_parameter_orig_id),
    constraint impc_pg_group_fk foreign key (group_id) references impc_group(group_id)
)

-- This will be the joining table since parameters and groups will be a many to many relatioship so it is scalable. Again it is a composit primary key that is used
 
insert into impc_group (group_name) values
    ('weight'),
    ('images'),
    ('brain'),
    ('blood'),
    ('bone'),
    ('liver'),
    ('skin')

-- Here we insert into the group table the parameters we want to have
    
insert into impc_parameter_group (impc_parameter_orig_id, group_id)
select
    impc_parameter.impc_parameter_orig_id,
    impc_group.group_id
from impc_parameter
join impc_group
  on lower(impc_parameter.parameter_name) -- The match is done using a case-insensitive like comparison.
     like concat('%', lower(impc_group.group_name), '%')
 
     -- How do we match group name with parameter name?
     -- Mappings between parameters and groups: For each parameter, we find any group whose name appears inside the parameter_name 
     -- E.g the group_name "Brain" appears in the parameter_name "Brain_MRI"
     -- This automatically assigns parameters to groups based on keyword matching.
 
-- =====================================================================
--  QUERYING THE FOUR GENES
-- =====================================================================

 select -- (1) Here we select what we want to see from each table
    gene.gene_symbol, -- We want the gene_symbol since we are querying that
    analysis.analysis_id, -- We want to know the analysis tests that were done on that gene
    analysis.pvalue, -- The significance of that analysis
    analysis.parameter_name, -- The parameter_name that was measured in that analysis
    impc_parameter.parameter_code, -- The IMPC code (parameter_code) since they would like to know the procedures and groupings and that is only linked to  
    impc_group.group_name, -- The group of the parameter if it is an IMPC parameter that belongs to a group
    impc_procedure.procedure_name -- The IMPC procedure that was used on that parameter if it is an IMPC parameter
from gene -- (2) We must start from where we want to query, gene symbol is in gene table so that's where we start
join analysis
  on analysis.mgi_accession_id = gene.mgi_accession_id  -- (3) Join each gene to its analysis results
left join impc_parameter -- (4) Add the IMPC parameter information for those analysis rows 
  on impc_parameter.impc_parameter_orig_id = analysis.impc_parameter_orig_id -- this has to be with impc_parameter_orig_id (the link between the two tables) and must use the command LEFT JOIN which keeps all rows from analysis that dont have IMPC parameter information
left join impc_parameter_group -- (5) Link the IMPC parameter to the parameter–group mapping table. Not all parameters belong to a group, so LEFT JOIN is used again.
  on impc_parameter_group.impc_parameter_orig_id = impc_parameter.impc_parameter_orig_id
left join impc_group -- (6) Link the group name to the parameter-group mapping, again, not all parameters belong to a group, so LEFT JOIN is used again.
  on impc_group.group_id = impc_parameter_group.group_id
left join impc_procedure_parameter -- (7) Link the parameter to the procedure–parameter table to find which IMPC procedure the IMPC parameter belongs to
  on impc_procedure_parameter.impc_parameter_orig_id = impc_parameter.impc_parameter_orig_id
left join impc_procedure  -- (8) bring in the procedure name that is linked to the procedure–parameter mapping.
  on impc_procedure.procedure_id = impc_procedure_parameter.procedure_id
where lower(gene.gene_symbol) in ('htr1a', 'dcx', 'setd4', 'usp4') -- (9) Filter for the four gene symbols of interest
order by gene.gene_symbol, analysis.analysis_id -- Sort the output nicely by gene and analysis
