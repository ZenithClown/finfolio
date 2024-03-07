-- Test Database, with Dummy Data
CREATE DATABASE IF NOT EXISTS pOrgz;

-- create default tables under oauth application
USE pOrgz;


DROP TABLE IF EXISTS `users_master`;

CREATE TABLE `users_master` (
  `uuid`  varchar(64)  NOT NULL,
  `fName` varchar(255) NOT NULL,
  `lName` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(64)  DEFAULT NULL,
  `uName` varchar(64)  NOT NULL,
  `pHash` varchar(128) NOT NULL,
  PRIMARY KEY (`uuid`,`uName`),
  UNIQUE KEY `uName` (`uName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `roles_master`;

CREATE TABLE `roles_master` (
  `role_id` varchar(64)   NOT NULL,
  `user_id` varchar(64)   NOT NULL,
  `role_name` varchar(32) NOT NULL,
  PRIMARY KEY (`role_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `roles_master_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users_master` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `logins_master`;

CREATE TABLE `logins_master` (
  `id`         varchar(64) NOT NULL,
  `user_id`    varchar(64) NOT NULL,
  `role_id`    varchar(64) NOT NULL,
  `login_time` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `logins_master_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users_master` (`uuid`),
  CONSTRAINT `logins_master_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles_master` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- create dummy data for testing

-- Dumping data for table `users_master`
LOCK TABLES `users_master` WRITE;

INSERT INTO `users_master` VALUES
  ('5ffe4050-d959-46ec-a8a5-c1a0040c9186','Debmalya','Pramanik','user@example.com',NULL,'user','2219f00c28b7d769aad74c31de2fc955bf021d973affd8b8ac0cfc5b11ff3876'),
  ('71c75892-71b0-4381-89ba-b8bf64e38974','Debmalya','Pramanik','pOrgz@tuta.io',NULL,'dPramanik','2219f00c28b7d769aad74c31de2fc955bf021d973affd8b8ac0cfc5b11ff3876');

UNLOCK TABLES;


-- Dumping data for table `roles_master`
LOCK TABLES `roles_master` WRITE;

INSERT INTO `roles_master` VALUES
  ('35213d98-ef92-11eb-b9fb-a4b1c13e8b0d','5ffe4050-d959-46ec-a8a5-c1a0040c9186','USER'),
  ('d86e953d-ef91-11eb-b531-a4b1c13e8b0d','71c75892-71b0-4381-89ba-b8bf64e38974','ADMIN');

UNLOCK TABLES;


-- Dumping data for table `logins_master`
LOCK TABLES `logins_master` WRITE;

INSERT INTO `logins_master` VALUES
  ('5ffe40535213d9','5ffe4050-d959-46ec-a8a5-c1a0040c9186','35213d98-ef92-11eb-b9fb-a4b1c13e8b0d','Wed Jul 28 16:24:40 2021'),
  ('71c7589d86e953','71c75892-71b0-4381-89ba-b8bf64e38974','d86e953d-ef91-11eb-b531-a4b1c13e8b0d','Wed Jul 28 16:22:04 2021');

UNLOCK TABLES;
