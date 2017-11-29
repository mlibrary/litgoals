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
  ENGINE = MyISAM;

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



-- Indexes and views

create fulltext index title_desc_fulltext on goal(title, description);

create view human_owners as
  select goal.id, goal.title, group_concat(concat(o.uniqname,' ', o.lastname, ' ', coalesce(o.firstname, '')) separator ', ') names
  from goal, goalowner o, goaltoowner gto where goal.id = gto.goalid and o.id = gto.ownerid and o.is_unit = 0 group by goal.id;

create view human_stewards as
  select goal.id, goal.title, group_concat(concat(o.uniqname, ' ',  o.lastname, ' ', coalesce(o.firstname, '')) separator ', ') names
  from goal, goalowner o, goaltosteward gts where goal.id = gts.goalid and o.id = gts.stewardid and o.is_unit = 0 group by goal.id;

create view goalsearch AS
  select goal.id, goal.title, goal.description,
    concat(coalesce(human_owners.names, ' '), coalesce(human_stewards.names, ' ')) people from goal
    left OUTER JOIN human_owners on human_owners.id = goal.id
    left OUTER JOIN human_stewards on human_stewards.id = goal.id;

