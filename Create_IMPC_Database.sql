-- [CREATING TABLES] -- 
-- The max length of the values in each column (that were't included in the SOP) were looked at through R with the function max(nchar()).
-- Having the maximum value personalised to our data is better for not taking up unnecessary storage space.
-- In the statements below, each table is created by defining its name, the column names, the data types they store, and their maximum allowed lengths.
-- Constraints are also included to enforce rules on the data, in this case, the primary keys, preventing invalid or inconsistent values.

create table impc_disease (
    disease_id varchar(20) not null,
    disease_name varchar(150),
    omim_ids varchar(600),
    constraint impc_disease_pk primary key (disease_id)
);

create table impc_parameter (
impc_parameter_orig_id int not null,
parameter_code varchar(20),
parameter_name varchar(74) not null,
description varchar (400),
contraint impc_parameter_pk primary key (impc_parameter_orig_id)
);

create table impc_parameter_group (
    parameter_group_id int auto_increment not null,
    group_name varchar(100) not null,
    constraint impc_parameter_group_pk primary key (parameter_group_id)
);

create table impc_procedure (
    procedure_id int auto_increment not null,
    procedure_name varchar(50) not null,
    description varchar(600),
    is_mandatory tinyint(1) not null default 0,
    constraint impc_procedure_pk primary key (procedure_id)
);

create table impc_analysis (
    analysis_id varchar(15) not null,
    mgi_accession_id varchar(11) not null,
    gene_symbol varchar(13) not null,
    mouse_strain varchar(5),
    mouse_life_stage varchar(17),
    impc_parameter_orig_id int not null,
    pvalue double,
    constraint impc_analysis_pk primary key (analysis_id),
    foreign key (impc_parameter_orig_id) references impc_parameter (impc_parameter_orig_id)
);

-- [CREATING INDEXES]
-- In the following lines, indexes are created on the columns that are most commonly searched by researchers. 
-- Indexes allow the database to quickly locate the rows that match a query without scanning the entire table.
-- This significantly improves query performance.
-- it's better to create them before the joining tables

create index idx_disease_name 
    on impc_disease (disease_name);

create index idx_parameter_name 
    on impc_parameter (parameter_name);

create index idx_analysis_columns 
    on impc_analysis (mgi_accession_id, impc_parameter_orig_id, gene_symbol);

-- [CREATING JOINING TABLES] -- 

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
-- impc_disease
-- impc_parameter
-- impc_parameter_group
-- impc_procedure
-- impc_analysis
-- impc_analysis_disease
-- impc_parameter_group_member
-- impc_procedure_parameter
