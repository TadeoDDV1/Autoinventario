ALTER TABLE productos DROP COLUMN imagen_url;
ALTER TABLE productos ADD COLUMN uso TEXT AFTER descripcion;
