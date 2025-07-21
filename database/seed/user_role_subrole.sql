/********************************************************************
User Role & Sub-Role Initial Seed Value for Project FINFOLIO

The user role and sub-roles are defined for RLS and CLS purposes, and
is left for an end user to maintain (or maybe will be integrated at a
future point of application development). The roles gives more control
like implementation of security, access control and viewing rights.

Curretntly, the user subroles are kept for future developments only,
and not used in the project.

Copywright © [2024] Debmalya Pramanik (ZenithClown)
********************************************************************/

INSERT INTO meta.user_role (role_id, role_name, role_desc) VALUES
  (1, 'ROOT', 'Root/Super Administrator User'),
  (2, 'SUDO', 'A User with Elevated Privileges'),
  (3, 'USER', 'Normal User with Viewing Rights');
