/********************************************************************
User Role & Sub-Role Initial Seed Value for FINFOLIO

Copywright © [2024] Debmalya Pramanik
********************************************************************/

INSERT INTO meta.user_role (role_id, role_name, role_desc) VALUES
  (1, 'ROOT', 'Root/Super Administrator User'),
  (2, 'SUDO', 'A User with Elevated Privileges'),
  (3, 'USER', 'Normal User with Viewing Rights'),
  (4, 'INT+', 'Internal Normal User without Viewing Rights'),
  (5, 'EXT+', 'External User Typically having a Transactional Relationships');

INSERT INTO meta.user_subrole (subrole_id, role_id, subrole_name, subrole_desc) VALUES
  (1, 5, 'FAMILY', 'The user is part of the family, and his account may be tracked.'),
  (2, 5, 'RELATIVE', 'The user is part of the extended family and typically does not have a tracked account.'),
  (3, 5, 'FRIENDS', 'A friend of the user, who typically has a transactional relationship.'),
  (4, 5, 'ORGANIZATION', 'An organization which has a transactional relationship, example companies where the user has worked.');
