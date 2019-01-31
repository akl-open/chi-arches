BEGIN TRANSACTION;
DECLARE @v_commit CHAR(1) = 'Y';

--Create CORE_SITE_TYPE
--Stores information about site types to be used by CORE_PLACE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'core_site_type'
)
BEGIN
    CREATE TABLE dbo.core_site_type
    (
        site_type_id INT NOT NULL IDENTITY PRIMARY KEY,
        site_type VARCHAR(200) NOT NULL
    );
END;

--Create CORE_LOCAL_AUTH
--Stores information about local authorities to be used by CORE_PLACE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'core_local_auth'
)
BEGIN
    CREATE TABLE dbo.core_local_auth
    (
        local_auth_id INT NOT NULL IDENTITY PRIMARY KEY,
        local_auth VARCHAR(200) NOT NULL
    );
END;

--Create CORE_ACTOR_TYPE
--Stores information about actors/people/authors types to be used by CORE_ACTOR
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'core_actor_type'
)
BEGIN
    CREATE TABLE dbo.core_actor_type
    (
        actor_type_id INT NOT NULL IDENTITY PRIMARY KEY,
        actor_type VARCHAR(250) NOT NULL
    );
END;

--Create CORE_ACTOR
--Stores information about actors/people/authors to be used by CORE_PLACE and CORE_BIBLO
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'core_actor'
)
BEGIN
    CREATE TABLE dbo.core_actor
    (
        actor_id INT NOT NULL IDENTITY PRIMARY KEY,
        actor_name VARCHAR(MAX) NOT NULL,
        actor_role_id INT NOT NULL
            FOREIGN KEY REFERENCES core_actor_type (actor_type_id),
        actor_entity VARCHAR(MAX) NULL
    );
END;

--Create CORE_DOC_TYPE
--Stores information about document types to be used for CORE_BIBLO
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'core_doc_type'
)
BEGIN
    CREATE TABLE dbo.core_doc_type
    (
        doc_type_id INT NOT NULL IDENTITY PRIMARY KEY,
        doc_type_code VARCHAR(2) NOT NULL,
        doc_type VARCHAR(250) NOT NULL
    );
END;

--Create CORE_BIBLO
--Stores information about biblographies
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'core_biblo'
)
BEGIN
    CREATE TABLE dbo.core_biblo
    (
        biblo_id INT NOT NULL IDENTITY PRIMARY KEY,
        chi_bib_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.bibliography (CHI_Bib_Id),
        article_title VARCHAR(MAX) NULL,
        pub_article_title VARCHAR(250) NULL,
        doc_type_id INT NULL
            FOREIGN KEY REFERENCES core_doc_type (doc_type_id),
        imprint VARCHAR(250) NULL,
        pub_date DATE NULL,
        abstract VARCHAR(MAX) NULL,
        file_path VARCHAR(MAX) NULL,
        is_sensitive BIT NOT NULL
            DEFAULT (0)
    );
END;

--Create CORE_ARCVIEW_CAT
--Stores information about arcview categories to be used for CORE_PLACE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'core_arcview_cat'
)
BEGIN
    CREATE TABLE dbo.core_arcview_cat
    (
        arcview_cat_id INT NOT NULL IDENTITY PRIMARY KEY,
        arcview_cat VARCHAR(250) NOT NULL
    );
END;

--Create CORE_REF_SOURCE_TYPE
--Stores information about reference source types to be used for CORE_PLACE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'core_ref_source_type'
)
BEGIN
    CREATE TABLE dbo.core_ref_source_type
    (
        ref_source_type_id INT NOT NULL IDENTITY PRIMARY KEY,
        ref_source_type VARCHAR(250) NOT NULL
    );
END;

--Create CORE_MEASURE_TYPE
--Stores information about measure types to be used for CORE_PLACE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'core_measure_type'
)
BEGIN
    CREATE TABLE dbo.core_measure_type
    (
        measure_type_id INT NOT NULL IDENTITY PRIMARY KEY,
        measure_type CHAR(1) NOT NULL,
        measure_type_desc VARCHAR(250) NULL
    );
END;

--Create CORE_NOTE_TYPE
--Stores information about note types to be used for DAT_NOTE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'core_note_type'
)
BEGIN
    CREATE TABLE dbo.core_note_type
    (
        note_type_id INT NOT NULL IDENTITY PRIMARY KEY,
        note_type VARCHAR(10) NOT NULL
    );
END;

--Create CORE_PLACE
--Stores information about places
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'core_place'
)
BEGIN
    CREATE TABLE dbo.core_place
    (
        chi_id INT NOT NULL IDENTITY PRIMARY KEY,
        computer_chi_number INT NOT NULL
            FOREIGN KEY REFERENCES dbo.Places ([Computer CHI Number]),
        place_name VARCHAR(250) NULL,
        local_auth_id INT NULL
            FOREIGN KEY REFERENCES dbo.core_local_auth (local_auth_id),
        state_condition VARCHAR(MAX) NULL,
        place_desc VARCHAR(MAX) NULL,
        signif_stmt VARCHAR(MAX) NULL,
        list_status_dist_reg_plan VARCHAR(MAX) NULL,
        arcview_cat_id INT NULL
            FOREIGN KEY REFERENCES dbo.core_arcview_cat (arcview_cat_id),
        architect_id INT NULL
            FOREIGN KEY REFERENCES dbo.core_actor (actor_id),
        engineer_id INT NULL
            FOREIGN KEY REFERENCES dbo.core_actor (actor_id),
        builder_id INT NULL
            FOREIGN KEY REFERENCES dbo.core_actor (actor_id),
        grid_ref_source_id INT NULL
            FOREIGN KEY REFERENCES dbo.core_ref_source_type (ref_source_type_id),
        construct_date DATE NULL,
        construct_measure_type_id INT NULL
            FOREIGN KEY REFERENCES dbo.core_measure_type (measure_type_id),
        destruct_date DATE NULL,
        destruct_measure_type_id INT NULL
            FOREIGN KEY REFERENCES dbo.core_measure_type (measure_type_id),
        special_feature VARCHAR(MAX) NULL,
        is_sensitive BIT NOT NULL
            DEFAULT (0)
    );
END;

--Create DAT_NOTE
--Stores data transactions about notes that relates to CORE_PLACE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'DAT_NOTE'
)
BEGIN
    CREATE TABLE dbo.dat_note
    (
        dat_note_id INT NOT NULL IDENTITY PRIMARY KEY,
        chi_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_place (chi_id),
        note_type_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_note_type (note_type_id),
        note VARCHAR(MAX) NULL,
        note_date DATETIME NULL
    );
END;

--Create CORE_COORD_TYPE
--Stores information about coordinate types to be used for DAT_COORD
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'core_coord_type'
)
BEGIN
    CREATE TABLE dbo.core_coord_type
    (
        coord_type_id INT NOT NULL IDENTITY PRIMARY KEY,
        coord_type VARCHAR(10) NOT NULL
    );
END;

--Create DAT_COORD
--Stores data transactions about coordinates that relates to CORE_PLACE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'DAT_COORD'
)
BEGIN
    CREATE TABLE dbo.dat_coord
    (
        coord_id INT NOT NULL IDENTITY PRIMARY KEY,
        chi_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_place (chi_id),
        coord_type_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_coord_type (coord_type_id),
        easting INT NOT NULL,
        northing INT NOT NULL
    );
END;

--Create CORE_ACT_TYPE
--Stores information about activity types to be used for DAT_ACT_LOG
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'core_act_type'
)
BEGIN
    CREATE TABLE dbo.core_act_type
    (
        act_type_id INT NOT NULL IDENTITY PRIMARY KEY,
        act_type VARCHAR(20) NOT NULL
    );
END;

--Create DAT_ACT_LOG
--Stores data transactions about activity logs that relates to CORE_PLACE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'dat_act_log'
)
BEGIN
    CREATE TABLE dbo.dat_act_log
    (
        act_log_id INT NOT NULL IDENTITY PRIMARY KEY,
        chi_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_place (chi_id),
        act_type_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_act_type (act_type_id),
        act_log_date DATETIME NULL,
        act_log_by VARCHAR(250) NULL
    );
END;

--Create DAT_LOC
--Stores data transactions about locations that relates to CORE_PLACE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'dat_loc'
)
BEGIN
    CREATE TABLE dbo.dat_loc
    (
        loc_id INT NOT NULL IDENTITY PRIMARY KEY,
        chi_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_place (chi_id),
        loc1_name VARCHAR(250) NULL,
        loc2_name VARCHAR(250) NULL,
        loc3_name VARCHAR(250) NULL,
        loc4_name VARCHAR(250) NULL,
        loc5_name VARCHAR(250) NULL,
        loc6_name VARCHAR(250) NULL,
        loc7_name VARCHAR(250) NULL,
        loc8_name VARCHAR(250) NULL,
        loc9_name VARCHAR(250) NULL,
        loc10_name VARCHAR(250) NULL,
        loc11_name VARCHAR(250) NULL,
        loc12_name VARCHAR(250) NULL,
        loc13_name VARCHAR(250) NULL,
        loc14_name VARCHAR(250) NULL,
        loc15_name VARCHAR(250) NULL,
        loc16_name VARCHAR(250) NULL,
        loc17_name VARCHAR(250) NULL,
        loc18_name VARCHAR(250) NULL,
        loc19_name VARCHAR(250) NULL,
        loc20_name VARCHAR(250) NULL,
        loc21_name VARCHAR(250) NULL,
        loc22_name VARCHAR(250) NULL,
        loc23_name VARCHAR(250) NULL,
        loc24_name VARCHAR(250) NULL,
        loc25_name VARCHAR(250) NULL,
        loc26_name VARCHAR(250) NULL,
        loc27_name VARCHAR(250) NULL,
        loc28_name VARCHAR(250) NULL,
        loc29_name VARCHAR(250) NULL,
        loc30_name VARCHAR(250) NULL,
        loc31_name VARCHAR(250) NULL,
        loc32_name VARCHAR(250) NULL,
        loc33_name VARCHAR(250) NULL
    );
END;

--Create DAT_NZAA_SITE
--Stores data transactions about NZAA site numbers that relates to CORE_PLACE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'dat_nzaa_site'
)
BEGIN
    CREATE TABLE dbo.dat_nzaa_site
    (
        nzaa_site_id INT NOT NULL IDENTITY PRIMARY KEY,
        chi_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_place (chi_id),
        nzaa_site_no VARCHAR(50) NOT NULL
    );
END;

--Create DAT_NZHPT_AUTH
--Stores data transactions about NZHPT authority numbers that relates to CORE_PLACE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'dat_nzhpt_auth'
)
BEGIN
    CREATE TABLE dbo.dat_nzhpt_auth
    (
        nzhpt_auth_id INT NOT NULL IDENTITY PRIMARY KEY,
        chi_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_place (chi_id),
        nzhpt_auth_no VARCHAR(50) NOT NULL
    );
END;

--Create DAT_NZHPT_REG
--Stores data transactions about NZHPT registration numbers that relates to CORE_PLACE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'dat_nzhpt_reg'
)
BEGIN
    CREATE TABLE dbo.dat_nzhpt_reg
    (
        nzhpt_reg_id INT NOT NULL IDENTITY PRIMARY KEY,
        chi_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_place (chi_id),
        nzhpt_reg_no VARCHAR(50) NOT NULL
    );
END;

--Create DAT_INSPECT
--Stores data transactions about inspection details that relates to CORE_PLACE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'dat_inspect'
)
BEGIN
    CREATE TABLE dbo.dat_inspect
    (
        inspect_id INT NOT NULL IDENTITY PRIMARY KEY,
        chi_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_place (chi_id),
        integrity VARCHAR(250) NOT NULL
    );
END;

--Create CORE_PRESSURE_TYPE
--Stores information about pressure types that relates to DAT_INSPECT_PRESSURE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'core_pressure_type'
)
BEGIN
    CREATE TABLE dbo.core_pressure_type
    (
        pressure_type_id INT NOT NULL IDENTITY PRIMARY KEY,
        pressure_type VARCHAR(250) NOT NULL
    );
END;

--Create CORE_PRESSURE
--Stores information about pressures that relates to DAT_INSPECT_PRESSURE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'core_pressure'
)
BEGIN
    CREATE TABLE dbo.core_pressure
    (
        pressure_id INT NOT NULL IDENTITY PRIMARY KEY,
        pressure VARCHAR(250) NOT NULL
    );
END;

--Create DAT_INSPECT_PRESSURE
--Stores data transactions about pressure types that relates to an inspection DAT_INSPECT
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'dat_inspect_pressure'
)
BEGIN
    CREATE TABLE dbo.dat_inspect_pressure
    (
        inspect_pressure_id INT NOT NULL IDENTITY PRIMARY KEY,
        chi_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_place (chi_id),
        pressure_type_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_pressure_type (pressure_type_id),
        pressure_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_pressure (pressure_id)
    );
END;

--Create DAT_PLACE_BIBLO
--Stores relationship between CORE_PLACE and CORE_BIBLO
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'dat_place_biblo'
)
BEGIN
    CREATE TABLE dbo.dat_place_biblo
    (
        place_biblo_id INT NOT NULL IDENTITY PRIMARY KEY,
        chi_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_place (chi_id),
        biblo_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_biblo (biblo_id)
    );
END;

--Create DAT_PLACE_SITE_TYPE
--Stores relationship between CORE_PLACE and CORE_SITE_TYPE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'dat_place_site_type'
)
BEGIN
    CREATE TABLE dbo.dat_place_site_type
    (
        place_site_type_id INT NOT NULL IDENTITY PRIMARY KEY,
        chi_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_place (chi_id),
        site_type_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_site_type (site_type_id)
    );
END;

--Create DAT_PLACE_ALT_NAME
--Stores data transactions about alternate names that relates to CORE_PLACE
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'dat_place_alt_name'
)
BEGIN
    CREATE TABLE dbo.dat_place_alt_name
    (
        place_alt_name_id INT NOT NULL IDENTITY PRIMARY KEY,
        chi_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_place (chi_id),
        alt_name VARCHAR(250) NOT NULL
    );
END;

--Create DAT_BIBLO_ACTOR
--Stores data transactions about authors that relates to CORE_BIBLO
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = 'dat_biblo_actor'
)
BEGIN
    CREATE TABLE dbo.dat_biblo_actor
    (
        biblo_actor_id INT NOT NULL IDENTITY PRIMARY KEY,
        biblo_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_biblo (biblo_id),
        actor_id INT NOT NULL
            FOREIGN KEY REFERENCES dbo.core_actor (actor_id)
    );
END;

IF ISNULL(@v_commit, 'N') = 'N'
    ROLLBACK TRANSACTION;
ELSE
    COMMIT TRANSACTION;
