-- Load Biblography data
INSERT INTO dbo.core_biblo (chi_bib_id, article_title, pub_article_title, imprint, abstract, file_path, is_sensitive)
SELECT CHI_Bib_Id,
       --CAST(REPLACE(Date_Of_Publication, '00', '01') AS DATE),
       Article_Title,      
       NULLIF(Publication_Title +  ' ' + Article_Source, '') AS pub_article_title,
       --Document_Type,
       NULLIF(Imprint, '') AS imprint,
       Abstract,
       NULLIF(URL, 'n/a') AS url,
       IsSensitive FROM dbo.bibliography 

DECLARE @tbl_doc_type TABLE
(
    chi_bib_id INT,
    doc_type VARCHAR(50)
);

INSERT INTO @tbl_doc_type
(
    chi_bib_id,
    doc_type
)
SELECT CHI_Bib_Id,
       NULLIF(UPPER(Document_Type), '')
FROM dbo.bibliography
    LEFT JOIN dbo.core_doc_type
        ON Document_Type = doc_type_code
WHERE LEN(Document_Type) < 3;

INSERT INTO @tbl_doc_type
(
    chi_bib_id,
    doc_type
)
SELECT CHI_Bib_Id,
       CASE
           WHEN UPPER(Document_Type) LIKE '%R%' THEN
               'R'
           WHEN Document_Type LIKE '[NONE]' THEN
               NULL
           ELSE
               NULL
       END
FROM dbo.bibliography
WHERE LEN(Document_Type) > 2;

UPDATE dbo.core_biblo
SET doc_type_id = doc.doc_type_id
FROM @tbl_doc_type tbl
JOIN dbo.core_doc_type doc ON tbl.doc_type = doc.doc_type_code
WHERE core_biblo.chi_bib_id = tbl.chi_bib_id;

-- Updating published date to Biblography.
SET DATEFORMAT DMY;

DECLARE @tbl_bib_pub_date TABLE
(
    chi_bib_id INT,
    pub_date DATE
);

INSERT INTO @tbl_bib_pub_date
(
    chi_bib_id,
    pub_date
)
SELECT tbl.CHI_Bib_Id,
       CAST(CASE
                WHEN TRY_CAST(REPLACE(tbl.pub_date, '00/', '01/') AS DATE) IS NULL THEN
                    '01/01/' + SUBSTRING(tbl.pub_date, LEN(tbl.pub_date) - 3, 4)
                ELSE
                    REPLACE(tbl.pub_date, '00/', '01/')
            END AS DATE)
FROM
(
    SELECT CHI_Bib_Id,
           REPLACE(
                      REPLACE(REPLACE(REPLACE(Date_Of_Publication, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''),
                      CHAR(160),
                      ''
                  ) pub_date
    FROM dbo.bibliography
) tbl
WHERE (
          tbl.pub_date LIKE '[0-3][0-9]/[0-1][0-9]/[1-2][0-9][0-9][0-9]'
          OR tbl.pub_date LIKE '[0-3][0-9]/[1-9]/[1-2][0-9][0-9][0-9]'
      );

WITH tbl_clean
AS (SELECT a.CHI_Bib_Id,
           REPLACE(
                      REPLACE(REPLACE(REPLACE(a.Date_Of_Publication, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''),
                      CHAR(160),
                      ''
                  ) pub_date
    FROM dbo.bibliography a
        LEFT JOIN @tbl_bib_pub_date b
            ON b.chi_bib_id = a.CHI_Bib_Id
    WHERE b.chi_bib_id IS NULL)
INSERT INTO @tbl_bib_pub_date
(
    chi_bib_id,
    pub_date
)
SELECT tbl_clean.CHI_Bib_Id,
       CAST('01-' + tbl_clean.pub_date AS DATE)
FROM tbl_clean
WHERE tbl_clean.pub_date LIKE '[a-zA-Z]%-[0-9][0-9]';

WITH tbl_clean
AS (SELECT a.CHI_Bib_Id,
           REPLACE(
                      REPLACE(REPLACE(REPLACE(a.Date_Of_Publication, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''),
                      CHAR(160),
                      ''
                  ) pub_date
    FROM dbo.bibliography a
        LEFT JOIN @tbl_bib_pub_date b
            ON b.chi_bib_id = a.CHI_Bib_Id
    WHERE b.chi_bib_id IS NULL)
INSERT INTO @tbl_bib_pub_date
(
    chi_bib_id,
    pub_date
)
SELECT dat.CHI_Bib_Id,
       dat.pub_date
FROM
(
    SELECT tbl.CHI_Bib_Id,
           CASE
               WHEN TRY_CAST(tbl.pub_date AS DATE) IS NOT NULL THEN
                   tbl.pub_date
               ELSE
                   NULL
           END pub_date
    FROM tbl_clean tbl
    WHERE REPLACE(pub_date, '/', '') LIKE '%[^0]%'
) dat
WHERE dat.pub_date IS NOT NULL;

WITH tbl_clean
AS (SELECT a.CHI_Bib_Id,
           REPLACE(
                      REPLACE(REPLACE(REPLACE(a.Date_Of_Publication, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''),
                      CHAR(160),
                      ''
                  ) pub_date
    FROM dbo.bibliography a
        LEFT JOIN @tbl_bib_pub_date b
            ON b.chi_bib_id = a.CHI_Bib_Id
    WHERE b.chi_bib_id IS NULL)
INSERT INTO @tbl_bib_pub_date
(
    chi_bib_id,
    pub_date
)
SELECT dat.CHI_Bib_Id,
       CAST(dat.pub_date AS DATE) pub_date
FROM
(
    SELECT t1.CHI_Bib_Id,
           CASE
               WHEN UPPER(t1.pub_date) LIKE '%SPRING%' THEN
                   '01/09/' + LTRIM(RTRIM(REPLACE(UPPER(t1.pub_date), 'SPRING', '')))
               WHEN UPPER(t1.pub_date) LIKE '%SUMMER%' THEN
                   '01/12/' + LTRIM(RTRIM(REPLACE(UPPER(t1.pub_date), 'SUMMER', '')))
               WHEN UPPER(t1.pub_date) LIKE '%AUTUMN%' THEN
                   '01/03/' + LTRIM(RTRIM(REPLACE(UPPER(t1.pub_date), 'AUTUMN', '')))
               WHEN UPPER(t1.pub_date) LIKE '%WINTER%' THEN
                   '01/06/' + LTRIM(RTRIM(REPLACE(UPPER(t1.pub_date), 'WINTER', '')))
               WHEN UPPER(t1.pub_date) LIKE '%SPR%' THEN
                   '01/09/' + LTRIM(RTRIM(REPLACE(UPPER(t1.pub_date), 'SPR', '')))
               WHEN UPPER(t1.pub_date) LIKE '%SUM%' THEN
                   '01/12/' + LTRIM(RTRIM(REPLACE(UPPER(t1.pub_date), 'SUM', '')))
               WHEN UPPER(t1.pub_date) LIKE '%AUT%' THEN
                   '01/03/' + LTRIM(RTRIM(REPLACE(UPPER(t1.pub_date), 'AUT', '')))
               WHEN UPPER(t1.pub_date) LIKE '%WIN%' THEN
                   '01/06/' + LTRIM(RTRIM(REPLACE(UPPER(t1.pub_date), 'WIN', '')))
               WHEN t1.pub_date LIKE '%//%' THEN
                   REPLACE(t1.pub_date, '//', '/')
               WHEN t1.pub_date LIKE '[0-3][0-9]/[0-1][0-9]/[0-9][0-9]'
                    AND t1.pub_date LIKE '%00/%' THEN
                   REPLACE(t1.pub_date, '00/', '01/')
               WHEN LTRIM(RTRIM(REPLACE(
                                           REPLACE(
                                                      REPLACE(
                                                                 REPLACE(
                                                                            REPLACE(
                                                                                       REPLACE(
                                                                                                  REPLACE(
                                                                                                             REPLACE(
                                                                                                                        REPLACE(
                                                                                                                                   REPLACE(
                                                                                                                                              REPLACE(
                                                                                                                                                         REPLACE(
                                                                                                                                                                    UPPER(t1.pub_date),
                                                                                                                                                                    'C',
                                                                                                                                                                    ''
                                                                                                                                                                ),
                                                                                                                                                         'S',
                                                                                                                                                         ''
                                                                                                                                                     ),
                                                                                                                                              'LATE',
                                                                                                                                              ''
                                                                                                                                          ),
                                                                                                                                   '(',
                                                                                                                                   ''
                                                                                                                               ),
                                                                                                                        ')',
                                                                                                                        ''
                                                                                                                    ),
                                                                                                             '?',
                                                                                                             ''
                                                                                                         ),
                                                                                                  '.',
                                                                                                  ''
                                                                                              ),
                                                                                       '-',
                                                                                       ''
                                                                                   ),
                                                                            '''',
                                                                            ''
                                                                        ),
                                                                 '"',
                                                                 ''
                                                             ),
                                                      'MID',
                                                      ''
                                                  ),
                                           'UNDATED',
                                           ''
                                       )
                               )
                         ) LIKE '[1-2][0-9][0-9][0-9]' THEN
                   '01/01/'
                   + LTRIM(RTRIM(REPLACE(
                                            REPLACE(
                                                       REPLACE(
                                                                  REPLACE(
                                                                             REPLACE(
                                                                                        REPLACE(
                                                                                                   REPLACE(
                                                                                                              REPLACE(
                                                                                                                         REPLACE(
                                                                                                                                    REPLACE(
                                                                                                                                               REPLACE(
                                                                                                                                                          REPLACE(
                                                                                                                                                                     UPPER(t1.pub_date),
                                                                                                                                                                     'C',
                                                                                                                                                                     ''
                                                                                                                                                                 ),
                                                                                                                                                          'S',
                                                                                                                                                          ''
                                                                                                                                                      ),
                                                                                                                                               'LATE',
                                                                                                                                               ''
                                                                                                                                           ),
                                                                                                                                    '(',
                                                                                                                                    ''
                                                                                                                                ),
                                                                                                                         ')',
                                                                                                                         ''
                                                                                                                     ),
                                                                                                              '?',
                                                                                                              ''
                                                                                                          ),
                                                                                                   '.',
                                                                                                   ''
                                                                                               ),
                                                                                        '-',
                                                                                        ''
                                                                                    ),
                                                                             '''',
                                                                             ''
                                                                         ),
                                                                  '"',
                                                                  ''
                                                              ),
                                                       'MID',
                                                       ''
                                                   ),
                                            'UNDATED',
                                            ''
                                        )
                                )
                          )
               WHEN (
                        t1.pub_date LIKE '00/00%'
                        OR t1.pub_date LIKE '0000/%'
                    )
                    AND TRY_CAST(REPLACE(REPLACE(t1.pub_date, '00/00', '01/01/'), '0000/', '01/01/') AS DATE) IS NOT NULL THEN
                   REPLACE(REPLACE(t1.pub_date, '00/00', '01/01/'), '0000/', '01/01/')
               WHEN t1.pub_date LIKE '%o%'
                    AND TRY_CAST(REPLACE(t1.pub_date, 'o', '0') AS DATE) IS NOT NULL THEN
                   REPLACE(t1.pub_date, 'o', '0')
               WHEN t1.pub_date LIKE '[0-9]/[0-1][0-9]/[1-2][0-9][0-9][0-9]'
                    AND TRY_CAST('01' + SUBSTRING(t1.pub_date, 2, 10) AS DATE) IS NOT NULL THEN
                   '01' + SUBSTRING(t1.pub_date, 2, 10)
               WHEN t1.pub_date LIKE '[0-9]/[0-1][0-9]/[1-2][0-9][0-9][0-9]'
                    AND TRY_CAST('01/01/' + SUBSTRING(t1.pub_date, 6, 10) AS DATE) IS NOT NULL THEN
                   '01/01/' + SUBSTRING(t1.pub_date, 6, 10)
               ELSE
                   NULL
           END pub_date
    FROM tbl_clean t1
    WHERE REPLACE(pub_date, '/', '') LIKE '%[^0]%'
          AND pub_date NOT LIKE '%|%'
) dat
WHERE dat.pub_date IS NOT NULL;

UPDATE bib
SET pub_date = tbl.pub_date
FROM dbo.core_biblo bib
    JOIN @tbl_bib_pub_date tbl
        ON tbl.chi_bib_id = bib.chi_bib_id;

-- Populate CORE_ACTOR (Authors)
DECLARE @i_actor_type_id INT
DECLARE @tbl_actor TABLE (actor_name VARCHAR(MAX), actor_type_id INT, actor_entity VARCHAR(MAX))
DECLARE @tbl_multiple_actor TABLE (actor_name VARCHAR(MAX))

SELECT @i_actor_type_id = actor_type_id FROM dbo.core_actor_type WHERE actor_type = 'Author'

INSERT INTO @tbl_actor (actor_name, actor_type_id, actor_entity)
SELECT DISTINCT Author, @i_actor_type_id, NULLIF(Corporate_Body, '') FROM dbo.bibliography WHERE Author NOT LIKE '%|%'

DECLARE @v_author_names VARCHAR(MAX);
DECLARE @v_author_name VARCHAR(MAX);

DECLARE c_authors CURSOR LOCAL FAST_FORWARD FOR
SELECT DISTINCT Author FROM dbo.bibliography WHERE Author LIKE '%|%' AND NULLIF(Corporate_Body, '') IS NULL

OPEN c_authors;
FETCH c_authors
INTO @v_author_names;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO @tbl_multiple_actor (actor_name) VALUES (@v_author_names)

	DECLARE c_author CURSOR LOCAL FAST_FORWARD FOR
	SELECT actor_name FROM @tbl_multiple_actor

	OPEN c_author;
	FETCH c_author
	INTO @v_author_name;

	WHILE @@FETCH_STATUS = 0
	BEGIN

	INSERT INTO @tbl_actor
	(
	    actor_name,
	    actor_type_id
	)
	SELECT items 'author', @i_actor_type_id FROM split(@v_author_name, '|');

	
	FETCH c_author
    INTO @v_author_name;	
	END;	

	CLOSE c_author;
	DEALLOCATE c_author;

	FETCH c_authors
    INTO @v_author_names;
END;

CLOSE c_authors;
DEALLOCATE c_authors;

INSERT INTO dbo.core_actor
(
    actor_name,
    actor_role_id,
    actor_entity
)
SELECT tbl.author_name, tbl.actor_type_id, tbl.actor_entity  FROM (
SELECT DISTINCT RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(actor_name, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''), CHAR(160), ''))) author_name, @i_actor_type_id actor_type_id, RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(actor_entity, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''), CHAR(160), ''))) actor_entity FROM @tbl_actor) tbl


--Mapping Authors to Bibliography records
DECLARE @tbl_bib_act TABLE
(
    biblo_id INT,
    actor_id INT
);

INSERT INTO @tbl_bib_act
(
    biblo_id,
    actor_id
)
SELECT tbl.biblo_id,
       tbl.actor_id
FROM
(
    SELECT DISTINCT
           bib2.biblo_id,
           bib.Author,
           bib.Corporate_Body,
           act.actor_id
    FROM dbo.bibliography bib
        JOIN dbo.core_biblo bib2
            ON bib2.chi_bib_id = bib.CHI_Bib_Id
        JOIN dbo.core_actor act
            ON act.actor_name = bib.Author
               AND act.actor_entity = bib.Corporate_Body
    WHERE bib.Author NOT LIKE '%|%'
) tbl;


DECLARE @v_author_name VARCHAR(MAX);
DECLARE @i_bib_id INT;


DECLARE c_author CURSOR LOCAL FAST_FORWARD FOR
SELECT DISTINCT
       bib2.biblo_id,
       bib.Author
FROM dbo.bibliography bib
    JOIN dbo.core_biblo bib2
        ON bib2.chi_bib_id = bib.CHI_Bib_Id
WHERE bib.Author LIKE '%|%'
      AND NULLIF(bib.Corporate_Body, '') IS NULL;

OPEN c_author;
FETCH c_author
INTO @i_bib_id,
     @v_author_name;

WHILE @@FETCH_STATUS = 0
BEGIN

    INSERT INTO @tbl_bib_act
    (
        biblo_id,
        actor_id
    )
    SELECT DISTINCT
           @i_bib_id,
           a.actor_id
    FROM dbo.core_actor a
        JOIN
        (
            SELECT RTRIM(LTRIM(REPLACE(
                                          REPLACE(REPLACE(REPLACE(items, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''),
                                          CHAR(160),
                                          ''
                                      )
                              )
                        ) 'actor_name'
            FROM Split(@v_author_name, '|')
        ) b
            ON a.actor_name = b.actor_name
    WHERE a.actor_entity IS NULL;

    FETCH c_author
    INTO @i_bib_id,
         @v_author_name;
END;

CLOSE c_author;
DEALLOCATE c_author;

INSERT INTO dbo.dat_biblo_actor
(
    biblo_id,
    actor_id
)
SELECT DISTINCT
       biblo_id,
       actor_id
FROM @tbl_bib_act;

-- Load Places data
INSERT INTO dbo.core_place
(
    computer_chi_number,
    local_auth_id,
    state_condition,
    place_desc,
    signif_stmt,
    list_status_dist_reg_plan,
    arcview_cat_id,
    grid_ref_source_id,
    special_feature,
    is_sensitive
)
SELECT p.[Computer CHI Number],
       loca.local_auth_id,
       NULLIF(CAST(p.[State or Condition] AS VARCHAR(MAX)), ''),
       NULLIF(CAST(p.Description AS VARCHAR(MAX)), ''),
       NULLIF(CAST(p.[Significance Statement] AS VARCHAR(MAX)), ''),
       NULLIF(CAST(p.[Listing Status in District/Regional Plan] AS VARCHAR(MAX)), ''),
       arc.arcview_cat_id,
       ref.ref_source_type_id,
       NULLIF(CAST(p.[Special Features] AS VARCHAR(MAX)), ''),
       p.IsSensitive
FROM dbo.Places p
    JOIN dbo.core_local_auth loca
        ON UPPER(loca.local_auth) = UPPER(CAST(p.[Local Authority] AS VARCHAR(MAX)))
    JOIN dbo.core_arcview_cat arc
        ON UPPER(arc.arcview_cat) = UPPER(CAST(p.[ArcView Category] AS VARCHAR(MAX)))
    JOIN dbo.core_ref_source_type ref
        ON UPPER(ref.ref_source_type) = UPPER(CAST(p.[Grid Refs Source] AS VARCHAR(MAX)));

-- Populate name and alternate names

DECLARE @i_chi_id INT
DECLARE @v_name VARCHAR(MAX)

DECLARE c_name CURSOR LOCAL FAST_FORWARD FOR
SELECT [Computer CHI Number], Name FROM dbo.Places

DECLARE @tbl_name TABLE(id INT , place_name VARCHAR(250))

OPEN c_name;
FETCH c_name
INTO @i_chi_id, @v_name;

WHILE @@FETCH_STATUS = 0
BEGIN
    
	INSERT INTO @tbl_name (id, place_name)
	SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) 'id', tbl.place_name FROM (
	SELECT DISTINCT LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(items, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''), CHAR(160), ''))) 'place_name' FROM dbo.Split(@v_name, '|')) tbl
		
		UPDATE dbo.core_place
		SET place_name = (SELECT place_name FROM @tbl_name WHERE id = 1)
		WHERE computer_chi_number = @i_chi_id

	--PRINT @i_chi_id

	IF (SELECT COUNT(*) FROM @tbl_name) > 1 
		INSERT INTO dbo.dat_place_alt_name (chi_id, alt_name)
		SELECT @i_chi_id, place_name FROM @tbl_name WHERE id > 1

		DELETE FROM @tbl_name

	FETCH c_name
    INTO @i_chi_id, @v_name;
END;

CLOSE c_name;
DEALLOCATE c_name;

