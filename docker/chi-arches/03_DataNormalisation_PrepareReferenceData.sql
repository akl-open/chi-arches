BEGIN TRANSACTION;
DECLARE @v_commit CHAR(1) = 'Y';

-- Pressure Types
INSERT INTO dbo.core_pressure_type (pressure_type) VALUES ('Identified');
INSERT INTO dbo.core_pressure_type (pressure_type) VALUES ('Potential');

-- Coordinate Types
INSERT INTO dbo.core_coord_type (coord_type) VALUES ('METRIC');
INSERT INTO dbo.core_coord_type (coord_type) VALUES ('GPS');
INSERT INTO dbo.core_coord_type (coord_type) VALUES ('NZTM');

-- Activity Log Types
INSERT INTO dbo.core_act_type (act_type) VALUES ('Last Visited');
INSERT INTO dbo.core_act_type (act_type) VALUES ('Recorded');
INSERT INTO dbo.core_act_type (act_type) VALUES ('Monitored');

-- Actor Types
INSERT INTO dbo.core_actor_type (actor_type) VALUES ('Architect');
INSERT INTO dbo.core_actor_type (actor_type) VALUES ('Builder');
INSERT INTO dbo.core_actor_type (actor_type) VALUES ('Engineer');
INSERT INTO dbo.core_actor_type (actor_type) VALUES ('Author');

-- Note Types
INSERT INTO dbo.core_note_type (note_type) VALUES ('Standard');
INSERT INTO dbo.core_note_type (note_type) VALUES ('Monitoring');

-- Local Authority
INSERT INTO dbo.core_local_auth (local_auth)
SELECT DISTINCT RTRIM(LTRIM(CAST([Local Authority] AS VARCHAR(MAX)))) FROM dbo.Places

-- ArcView Category
INSERT INTO dbo.core_arcview_cat (arcview_cat)
SELECT DISTINCT RTRIM(LTRIM(CAST([ArcView Category] AS VARCHAR(MAX)))) FROM dbo.Places

-- Reference Source Type
INSERT INTO dbo.core_ref_source_type (ref_source_type)
SELECT DISTINCT RTRIM(LTRIM(CAST([Grid Refs Source] AS VARCHAR(MAX)))) FROM dbo.Places

-- Measure Type
INSERT INTO dbo.core_measure_type (measure_type, measure_type_desc) VALUES ('c', 'circa')
INSERT INTO dbo.core_measure_type (measure_type, measure_type_desc) VALUES ('>', 'after or larger than')
INSERT INTO dbo.core_measure_type (measure_type, measure_type_desc) VALUES ('<', 'before or less than')
INSERT INTO dbo.core_measure_type (measure_type, measure_type_desc) VALUES ('?', 'unsure')

-- Document Type
INSERT INTO dbo.core_doc_type (doc_type_code, doc_type) VALUES ('A','JOURNAL ARTICLES')
INSERT INTO dbo.core_doc_type (doc_type_code, doc_type) VALUES ('B','BOOKS')
INSERT INTO dbo.core_doc_type (doc_type_code, doc_type) VALUES ('BK','BOOKLET/LEAFLET/MAGAZINE/BROCHURE/PAMPHLET/POSTER')
INSERT INTO dbo.core_doc_type (doc_type_code, doc_type) VALUES ('C','CONSERVATION PLANS')
INSERT INTO dbo.core_doc_type (doc_type_code, doc_type) VALUES ('CP','CONFERENCE PAPER/PRESENTATION')
INSERT INTO dbo.core_doc_type (doc_type_code, doc_type) VALUES ('ER','ELECTRONIC RESOURCE - CD, DVD, TAPE, VIDEO, WEBSITE')
INSERT INTO dbo.core_doc_type (doc_type_code, doc_type) VALUES ('L','LETTERS')
INSERT INTO dbo.core_doc_type (doc_type_code, doc_type) VALUES ('M','MANAGEMENT PLAN')
INSERT INTO dbo.core_doc_type (doc_type_code, doc_type) VALUES ('MP','MAP/PLAN')
INSERT INTO dbo.core_doc_type (doc_type_code, doc_type) VALUES ('N','NEWSPAPER')
INSERT INTO dbo.core_doc_type (doc_type_code, doc_type) VALUES ('NL','NEWSLETTER')
INSERT INTO dbo.core_doc_type (doc_type_code, doc_type) VALUES ('R','REPORTS')
INSERT INTO dbo.core_doc_type (doc_type_code, doc_type) VALUES ('TH','THESIS')
INSERT INTO dbo.core_doc_type (doc_type_code, doc_type) VALUES ('UP','UNPUBLISHED')

-- Site Type
DECLARE @tbl_site TABLE (site_type VARCHAR(200));
DECLARE @tbl_site_temp TABLE (site_type VARCHAR(200));
DECLARE @tbl_site_final TABLE (site_type VARCHAR(200));
DECLARE @site_type VARCHAR(200);

INSERT INTO @tbl_site (site_type)
SELECT DISTINCT
       CAST([Site Type] AS VARCHAR(MAX)) site_type
FROM dbo.Places;

DECLARE c_type CURSOR LOCAL FAST_FORWARD FOR
SELECT site_type
FROM @tbl_site
WHERE site_type LIKE '%|%';

OPEN c_type;
FETCH c_type
INTO @site_type;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO @tbl_site_temp (site_type)
    SELECT UPPER(LTRIM(RTRIM(tbl.site_type)))
    FROM
    (SELECT items 'site_type' FROM split(@site_type, '|') ) tbl;
    FETCH c_type
    INTO @site_type;

END;

INSERT INTO @tbl_site_temp
SELECT UPPER(RTRIM(LTRIM(site_type)))
FROM @tbl_site
WHERE site_type NOT LIKE '%|%'
     -- OR site_type IS NOT NULL;

INSERT INTO @tbl_site_final (site_type)
SELECT DISTINCT
       UPPER(site_type)
FROM @tbl_site_temp;

INSERT INTO dbo.core_site_type (site_type)
SELECT DISTINCT
       site_type
FROM @tbl_site_final
WHERE LEN(site_type) > 0;

CLOSE c_type;
DEALLOCATE c_type;

IF ISNULL(@v_commit, 'N') = 'N'
    ROLLBACK TRANSACTION;
ELSE
    COMMIT TRANSACTION;
