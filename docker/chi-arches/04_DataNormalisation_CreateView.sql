CREATE VIEW v_bibliography AS
SELECT bib.biblo_id,
       bib.chi_bib_id,
	   bib.abstract,
       act.actor_entity,
       act.actor_name,
       bib.article_title,
       doc.doc_type_code,       
       bib.imprint,       
       bib.pub_article_title,
       bib.pub_date, 
	   bib.file_path, 
	   bib.is_sensitive FROM
dbo.core_biblo bib
JOIN dbo.dat_biblo_actor bibact ON bibact.biblo_id = bib.biblo_id
JOIN dbo.core_actor act ON act.actor_id = bibact.actor_id
JOIN dbo.core_doc_type doc ON doc.doc_type_id = bib.doc_type_id
