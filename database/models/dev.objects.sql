/********************************************************************
A Simple Table to Store Information Regarding Object Storage

The `dev.objectStore` is a developer use case table to store details
about the files inserted into the database. The typically parsed
raw transaction files are saved as an pickle object, however check
the table for more informations.

Copywright © [2024] nxLogics, Debmalya Pramanik
********************************************************************/

CREATE TABLE IF NOT EXISTS "dev.objectStore" (
    filename VARCHAR(256) PRIMARY KEY,
    filepath VARCHAR(512) NOT NULL,

    processed_on DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    start_index_ INTEGER NOT NULL,
    final_index_ INTEGER NOT NULL,

    -- other details related to file read/encodings
    filetype VARCHAR(16) DEFAULT 'pkl.gz' NOT NULL,

    protocol    INTEGER DEFAULT 5,           -- ? for pickle files
    encodings   VARCHAR(16) DEFAULT 'utf-8', -- TODO check integrity
    compression VARCHAR(16) DEFAULT 'gzip'   -- ? for pickle files
);
