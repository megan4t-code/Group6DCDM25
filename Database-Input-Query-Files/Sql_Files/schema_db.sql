-- impc_db.IMPC_disease definition

CREATE TABLE `IMPC_disease` (
  `disease_id` varchar(50) NOT NULL,
  `disease_name` varchar(255) NOT NULL,
  PRIMARY KEY (`disease_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- impc_db.IMPC_gene definition

CREATE TABLE `IMPC_gene` (
  `mgi_accession_id` varchar(20) NOT NULL,
  `gene_symbol` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`mgi_accession_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- impc_db.IMPC_parameter definition

CREATE TABLE `IMPC_parameter` (
  `impc_parameter_orig_id` int NOT NULL,
  `parameter_code` varchar(50) NOT NULL,
  `parameter_name` varchar(255) NOT NULL,
  `parameter_description` text,
  PRIMARY KEY (`impc_parameter_orig_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- impc_db.IMPC_parameter_group definition

CREATE TABLE `IMPC_parameter_group` (
  `parameter_group_id` int NOT NULL AUTO_INCREMENT,
  `group_name` varchar(100) NOT NULL,
  PRIMARY KEY (`parameter_group_id`),
  UNIQUE KEY `uq_impc_parameter_group_name` (`group_name`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- impc_db.IMPC_procedure definition

CREATE TABLE `IMPC_procedure` (
  `procedure_id` int NOT NULL AUTO_INCREMENT,
  `procedure_name` varchar(255) NOT NULL,
  `description` text,
  `is_mandatory` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`procedure_id`),
  UNIQUE KEY `uq_impc_procedure_name` (`procedure_name`)
) ENGINE=InnoDB AUTO_INCREMENT=253 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- impc_db.IMPC_analysis definition

CREATE TABLE `IMPC_analysis` (
  `analysis_id` varchar(20) NOT NULL,
  `mgi_accession_id` varchar(20) NOT NULL,
  `impc_parameter_orig_id` int DEFAULT NULL,
  `mouse_life_stage` varchar(50) DEFAULT NULL,
  `mouse_strain` varchar(50) DEFAULT NULL,
  `p_value` double DEFAULT NULL,
  PRIMARY KEY (`analysis_id`),
  KEY `fk_analysis_parameter` (`impc_parameter_orig_id`),
  KEY `fk_analysis_gene` (`mgi_accession_id`),
  CONSTRAINT `fk_analysis_gene` FOREIGN KEY (`mgi_accession_id`) REFERENCES `IMPC_gene` (`mgi_accession_id`),
  CONSTRAINT `fk_analysis_parameter` FOREIGN KEY (`impc_parameter_orig_id`) REFERENCES `IMPC_parameter` (`impc_parameter_orig_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- impc_db.IMPC_gene_disease definition

CREATE TABLE `IMPC_gene_disease` (
  `mgi_accession_id` varchar(20) NOT NULL,
  `disease_id` varchar(50) NOT NULL,
  PRIMARY KEY (`mgi_accession_id`,`disease_id`),
  KEY `fk_gd_disease` (`disease_id`),
  CONSTRAINT `fk_gd_disease` FOREIGN KEY (`disease_id`) REFERENCES `IMPC_disease` (`disease_id`),
  CONSTRAINT `fk_gd_gene` FOREIGN KEY (`mgi_accession_id`) REFERENCES `IMPC_gene` (`mgi_accession_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- impc_db.IMPC_human_gene_disease definition

CREATE TABLE `IMPC_human_gene_disease` (
  `disease_id` varchar(50) NOT NULL,
  `omim_ids` varchar(50) NOT NULL,
  PRIMARY KEY (`disease_id`,`omim_ids`),
  CONSTRAINT `impc_human_gene_disease_ibfk_1` FOREIGN KEY (`disease_id`) REFERENCES `IMPC_disease` (`disease_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- impc_db.IMPC_parameter_group_member definition

CREATE TABLE `IMPC_parameter_group_member` (
  `impc_parameter_orig_id` int NOT NULL,
  `parameter_group_id` int NOT NULL,
  PRIMARY KEY (`impc_parameter_orig_id`,`parameter_group_id`),
  KEY `fk_pgm_group` (`parameter_group_id`),
  CONSTRAINT `fk_pgm_group` FOREIGN KEY (`parameter_group_id`) REFERENCES `IMPC_parameter_group` (`parameter_group_id`),
  CONSTRAINT `fk_pgm_parameter` FOREIGN KEY (`impc_parameter_orig_id`) REFERENCES `IMPC_parameter` (`impc_parameter_orig_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- impc_db.IMPC_procedure_parameter definition

CREATE TABLE `IMPC_procedure_parameter` (
  `procedure_id` int NOT NULL,
  `impc_parameter_orig_id` int NOT NULL,
  PRIMARY KEY (`procedure_id`,`impc_parameter_orig_id`),
  KEY `fk_pp_parameter` (`impc_parameter_orig_id`),
  CONSTRAINT `fk_pp_parameter` FOREIGN KEY (`impc_parameter_orig_id`) REFERENCES `IMPC_parameter` (`impc_parameter_orig_id`),
  CONSTRAINT `fk_pp_procedure` FOREIGN KEY (`procedure_id`) REFERENCES `IMPC_procedure` (`procedure_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
