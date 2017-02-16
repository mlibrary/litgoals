CREATE TABLE `goal` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `creator_uniqname` varchar(255) DEFAULT NULL,
  `title` text,
  `description` text,
  `status` varchar(255) DEFAULT NULL,
  `target_date` date DEFAULT NULL,
  `draft` tinyint(4) DEFAULT '0',
  `created` date DEFAULT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `notes` text,
  `goal_year` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;


--
-- Table structure for table `goalowner`
--


CREATE TABLE `goalowner` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniqname` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  `firstname` varchar(255) DEFAULT NULL,
  `parent_uniqname` varchar(255) DEFAULT NULL,
  `created` date DEFAULT NULL,
  `is_unit` tinyint(1) DEFAULT NULL,
  `is_admin` tinyint(1) DEFAULT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqname` (`uniqname`)
) ENGINE=InnoDB AUTO_INCREMENT=79;


--
-- Table structure for table `goaltogoal`
--


CREATE TABLE `goaltogoal` (
  `childgoalid` int(10) unsigned DEFAULT NULL,
  `parentgoalid` int(10) unsigned DEFAULT NULL
) ENGINE=InnoDB;


--
-- Table structure for table `goaltoowner`
--

CREATE TABLE `goaltoowner` (
  `goalid` int(10) unsigned DEFAULT NULL,
  `ownerid` int(10) unsigned DEFAULT NULL
) ENGINE=InnoDB;


--
-- Table structure for table `status`
--


CREATE TABLE `status` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6;
