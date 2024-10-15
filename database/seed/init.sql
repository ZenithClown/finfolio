/********************************************************************
Initial Set of Data for the META Tables for the FINFOLIO Application

The initial set of data can also be called from ORM to typically
populate the metadata tables. The initial data has fixed values as
their primary key and thus is easier to understand.

Copywright © [2024] Debmalya Pramanik
********************************************************************/

INSERT INTO meta.user_role (role_id, role_name, role_desc) VALUES
  (1, 'ROOT', 'Root/Super Administrator User'),
  (2, 'SUDO', 'A User with Elevated Privileges'),
  (3, 'USER', 'Normal User with Viewing Rights'),
  (4, 'INT+', 'Internal Normal User without Viewing Rights'),
  (5, 'EXT+', 'External User Typically having a Transactional Relationships');

