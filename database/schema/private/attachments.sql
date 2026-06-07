/********************************************************************
Phase 4 §4.6 — Transaction Attachments

A receipt-storage table that links arbitrary files (PDFs, JPEGs, bank
statements) to a `private.transaction_header`. The blob itself is *not*
stored in the database — only a pointer (`storage_uri`) and a content
hash for tamper-detection. The dashboard side is free to back this with
local disk, S3, MinIO, or any other object store.

This separation keeps Postgres lean while still letting us answer the
two questions a finance dashboard always asks:

  1. "Show me every receipt for this transaction."
  2. "Has this receipt been edited since I uploaded it?" (hash compare)

Soft-delete mirrors the §4.7 pattern so attachments survive a header
soft-delete and can be replayed for audit.
********************************************************************/

CREATE TABLE IF NOT EXISTS private.attachment (
  attachment_id
    BIGINT GENERATED ALWAYS AS IDENTITY
    CONSTRAINT pk_attachment PRIMARY KEY,

  transaction_uid
    UUID NOT NULL
    CONSTRAINT fk_att_transaction_header
      REFERENCES private.transaction_header (transaction_uid)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  -- Original filename as uploaded by the user. NOT trusted; used only
  -- for display.
  original_filename
    VARCHAR(255) NOT NULL,

  -- MIME type as detected server-side (NOT trusted from the client).
  content_type
    VARCHAR(128) NOT NULL,

  -- Bytes; helps the UI render upload-quota indicators.
  size_bytes
    BIGINT NOT NULL,

  -- Lowercase hex SHA-256 of the file contents at upload time.
  content_sha256
    CHAR(64) NOT NULL,

  -- Opaque pointer interpreted by the application:
  --   * "file:///var/finfolio/blobs/2026/06/abc123.pdf"
  --   * "s3://finfolio-receipts/abc123.pdf"
  --   * "minio://bucket/key"
  storage_uri
    VARCHAR(1024) NOT NULL,

  -- audit columns
  created_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by
    VARCHAR(16),

  -- soft-delete (§4.7)
  deleted_on
    TIMESTAMPTZ,
  deleted_by
    VARCHAR(16),

  CONSTRAINT ck_att_size_positive  CHECK (size_bytes > 0),
  CONSTRAINT ck_att_sha256_format  CHECK (content_sha256 ~ '^[0-9a-f]{64}$'),
  CONSTRAINT ck_att_soft_delete_pair CHECK (
        (deleted_on IS NULL AND deleted_by IS NULL)
     OR (deleted_on IS NOT NULL AND deleted_by IS NOT NULL)
  )
);

CREATE INDEX IF NOT EXISTS ix_attachment_transaction_uid
  ON private.attachment (transaction_uid)
  WHERE deleted_on IS NULL;
