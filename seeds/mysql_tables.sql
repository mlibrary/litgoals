CREATE TABLE status (
  id   INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) UNIQUE,
  PRIMARY KEY (`id`)
)
  ENGINE = InnoDB;

-- SPLIT

CREATE TABLE `goal` (
  `id`               INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `creator_uniqname` VARCHAR(255)              DEFAULT NULL,
  `title`            TEXT,
  `description`      TEXT,
  `status`           VARCHAR(255)              DEFAULT NULL,
  `target_date`      DATE                      DEFAULT NULL,
  `draft`            TINYINT(4)                DEFAULT '0',
  `created`          DATE                      DEFAULT NULL,
  `updated`          TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `notes`            TEXT,
  `goal_year`        INT(11)                   DEFAULT NULL,
  PRIMARY KEY (`id`)
)
  ENGINE = InnoDB;

--
-- Table structure for table `goalowner`
--

-- SPLIT


CREATE TABLE `goalowner` (
  `id`              INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `uniqname`        VARCHAR(255)              DEFAULT NULL,
  `lastname`        VARCHAR(255)              DEFAULT NULL,
  `firstname`       VARCHAR(255)              DEFAULT NULL,
  `parent_uniqname` VARCHAR(255)              DEFAULT NULL,
  `created`         DATE                      DEFAULT NULL,
  `is_unit`         TINYINT(1)                DEFAULT NULL,
  `is_admin`        TINYINT(1)                DEFAULT NULL,
  `updated`         TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqname` (`uniqname`)
)
  ENGINE = InnoDB;

--
-- Table structure for table `goaltogoal`
--
-- SPLIT


CREATE TABLE `goaltogoal` (
  `childgoalid`  INT(10) UNSIGNED DEFAULT NULL,
  `parentgoalid` INT(10) UNSIGNED DEFAULT NULL
)
  ENGINE = InnoDB;

--
-- Table structure for table `goaltoowner`
--
-- SPLIT

CREATE TABLE `goaltoowner` (
  `goalid`  INT(10) UNSIGNED DEFAULT NULL,
  `ownerid` INT(10) UNSIGNED DEFAULT NULL
)
  ENGINE = InnoDB;
;

CREATE TABLE goaltosteward (
  goalid    INT(10) UNSIGNED DEFAULT NULL,
  stewardid INT(10) UNSIGNED DEFAULT NULL
) ENGINE = InnoDB;
