-- MySQL dump 10.13  Distrib 5.5.55, for debian-linux-gnu (x86_64)
--
-- Host: mysql-web    Database: goalsviz
-- ------------------------------------------------------
-- Server version	5.5.55-0+deb8u1-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `goal`
--

DROP TABLE IF EXISTS `goal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  PRIMARY KEY (`id`),
  FULLTEXT KEY `title_desc_fulltext` (`title`,`description`)
) ENGINE=MyISAM AUTO_INCREMENT=164 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `goal`
--

LOCK TABLES `goal` WRITE;
/*!40000 ALTER TABLE `goal` DISABLE KEYS */;
INSERT INTO `goal` VALUES (149,'earleyj','Create Goal Visualization ','Demo goal to test the system.','Not started','2016-06-30',0,NULL,'2017-05-31 20:40:56','',2016),(150,'jweise','Build and Expand a Robust Repository Solution','Why: The library\'s repository infrastructure is twenty years old and no longer meets the evolving needs of its users.\r\n\r\nLong-term direction: LIT will develop a modern repository infrastructure with complementary applications and services in order to sustainably support the management, preservation, and access of digital data/content for the library, its partners, and users. \r\n\r\nIntention for this year: In order to make progress on the establishment of repository services for the areas of greatest need, LIT in close collaboration with library and campus stakeholders, such as Publishing and the The Bentley Historical Library, will investigate, design, and develop repository solutions while assessing their viability. We will simultaneously grow the division?s skills and expertise to solve problems of increasing scope and complexity, so that immediate needs are met with an eye toward future consolidation.\r\n\r\nStewards: John Weise, Sebastien Korner','In progress','2017-06-01',0,NULL,'2017-05-31 20:40:56','',2017),(152,'rvacek','Improve Discovery and Document Delivery Across the Library Web Presence','Why: Our current discovery and document delivery interfaces are fragmented and do not present a uniform, consistently accessible, or efficient experience to our users.\r\n\r\nLong-term direction: Our discovery and delivery interfaces are the primary means by which most library users access the library?s physical and digital resources. LIT will redesign and re-architect these interfaces so users will be able to find and access the information they want without needing to understand the appropriate starting point. \r\n\r\nIntention for this year: We will simplify the library?s web presence by consolidating the library?s multiple discovery interfaces into one application and creating a new document delivery interface as a second standalone application. \r\n\r\nStewards: Ken Varnum, Rachel Vacek','In progress','2017-12-01',0,NULL,'2017-05-31 20:40:56','',2017),(153,'jweise','Establish a Library Analytics Program','Why: Two overlapping needs come together in this goal area. First, the library has expressed a need to better understand how the tools and services it offers are used at a more granular level than total usage. Second, the library is an active participant in the campus-wide learning analytics initiative. Both needs require collection and storage of transaction data over long periods of time, creating the need for a data storage infrastructure and corresponding reporting, visualization, and analysis tools. \r\n\r\nLong-term direction: Library staff will leverage data gathered from LIT-managed and other library sources to better understand knowledge-seeking patterns, improve user success in our discovery-to-delivery pipeline, improve services, and contribute to campus learning analytics research. LIT will provide an analytics platform including an aggregated data warehouse, query mechanisms and dashboard capability, and integrate with campus data warehouses to support the endeavor.\r\n\r\nIntention for the year: In order to provide a proof-of-concept of cross-system analytics for developers and key stakeholders, LIT will design and deploy a data collection architecture, identify a core cross-system data set, and implement query mechanisms and sample dashboards to demonstrate this foundation for future analytics work. LIT will provide training to LIT and library staff for these purposes, and study how existing reporting and metrics map to future intended analytics work.\r\n\r\nStewards: Ken Varnum, Sebastien Korner','In progress','2017-06-01',0,NULL,'2017-05-31 20:40:56','',2017),(154,'jweise','Plan for the Future Migration from Aleph to a New ILS Solution','Why: Our current ILS system, Aleph, is old. The core of the system dates back over thirty years, and we?ve been using Aleph locally for eleven years. While there have been many changes and enhancements over time (those implemented by Ex Libris as well as add-ons, integrations, workarounds, etc. built here), there are some desirable functions that are difficult or impossible in Aleph. In addition, the core architectural framework/assumptions and underlying infrastructure in Aleph are not consistent with current computing norms and practices.\r\n\r\nLong-term direction: In order to continue providing functionality that the Library needs to operate (its acquisitions, catalog, circulation and cataloging functions) and to extend functionality to address the problems of scale faced by a a top-five ARL library, LIT will monitor the ILS and LMS marketplace; research available and upcoming options; and plan for an eventual transition from the Library?s legacy system to a modern one for managing crucial library operations and functions.\r\n\r\nIntention for the year: In order to allow appropriate planning for our eventual transition to a next-generation ILS, LIT will lead an investigation to assess current ILS and LMS systems and determine whether there are any systems that support the Library?s multi-faceted needs, resonate with users, and facilitate the work of many LIT staff. \r\n\r\nSteward: Jon Rothman','In progress','2017-06-01',0,NULL,'2017-05-31 20:40:56','',2017),(155,'jweise','Overhaul the Library Web Presence','Why: The library website is the virtual front door for one of the largest, most prestigious research libraries in the world and should reflect our dedication to service excellence, unique resources, abundant expertise, and our impact on the global community. It therefore becomes essential to maintain a website that is usable, accessible, responsive, and embraces modern practices of iterative design and development in order to meet the expectations of that global community. However, to better understand what enables users to have meaningful and successful research experiences, it is critical to more broadly and holistically examine and improve the library?s overall web presence and not just the main website.\r\n\r\nLong-term direction: In order to create a web presence that meets the needs and expectations of our users, we will utilize user research, improve content strategies, and design cutting-edge features and interfaces across the web presence so that users will have more successful and consistent experiences.\r\n\r\nIntention for the year: \r\nBefore we can embark on a website redesign or make improvements to other areas across the web presence, we need to holistically assess and plan for a new structure that manages and governs the website, and explore new agile web design and development methodologies that supports the new structure. Restructuring committees associated with the website will not only clarify roles and responsibilities associated with managing the various aspects of the website, but improve communication and transparency of decisions.\r\n\r\nSteward: Rachel Vacek','In progress','2017-06-01',0,NULL,'2017-05-31 20:40:56','',2017),(156,'jweise','Harmonize Internal LIT Processes and Services','Why: Internal processes are not harmonized across the division. Consistent processes & services across the division will improve internal efficiency and lead to a better customer experience. \r\n\r\nLong-term direction: In order to scale LIT?s increasingly complex and interdependent work while meeting its commitments and providing excellent service, LIT will consider, adopt, support, and assess a common suite of tools, principles, and practices to facilitate project and service management processes.\r\n\r\nIntention for this year: In order to lay the foundation for connected workflows and communication for LIT staff, LIT will deploy and begin to adopt Atlassian Confluence, JIRA Service Desk, and JIRA Software in an intentional and coordinated division-wide manner so that there is a common way of facilitating and documenting the division?s work while allowing for necessary variation in specific department processes and methods. In addition, we will add robust methods for setting requirements, schedules and outputs for staff.\r\n\r\nStewards: Meghan Musolff, Sebastien Korner','In progress','2017-06-01',0,NULL,'2017-05-31 20:40:56','',2017),(157,'jweise','Engage in Full Lifecycle Management of Digital Collections','Why: LIT is accountable to its stakeholders to provide continuous, high level service for all of the library?s collections. With almost 200 hosted collections for Library, University and outside stakeholders, LIT enables this high level of service through timely and helpful feedback, continuous assessment of usage and voiced concerns regarding particular collections, and thoughtful changes to systems and individual collections as a result of the feedback and concerns. \r\n\r\nLong-term direction: To ensure a high level of service, LIT will provide an evolved and robust preservation and access system that offers the most up-to-date feature set, modern discovery and access interfaces, and trustworthy object preservation. This will be coupled with a high capacity, high quality, digitization effort which is able to manage all sizes of projects and most types of material. \r\n\r\nIntention for this year: In order to lay a foundation for upcoming Hydra work for digital collections and assist with the phased approach to Hydra head development, we will redevelop the framework for our administrative policies, practices and procedures. Also, we will onboard the new Project Manager in DCC (and hopefully DLA), and continue major digitization efforts.\r\n\r\nStewards: Kat Hagedorn, John Weise','In progress','2017-06-01',0,NULL,'2017-05-31 20:40:56','',2017),(158,'jweise','Support HathiTrust','Why: HathiTrust is a fundamental piece of preservation and access infrastructure for our library and libraries at over one hundred partner institutions. The University of Michigan Library has made a longterm commitment to contributing substantially to its well being. \r\n\r\nLong-term direction: In order to support the strategic direction and operational needs for HathiTrust and its constituencies, LIT will collaborate with HathiTrust staff and key partners to develop, evolve, and operate infrastructure, applications, workflows and services so that HathiTrust is successful in its operational and strategic initiatives. \r\n(See https://www.hathitrust.org/mission_goals.)\r\n\r\nIntention for the year: In order to expand the accessibility, infrastructure, and services of HathiTrust, LIT will collaborate with HathiTrust staff and partners to plan and execute projects and tasks so that we meet milestones on key initiatives.\r\n\r\nStewards: John Weise, Rachel Vacek','In progress','2017-06-01',0,NULL,'2017-05-31 20:40:56','',2017),(159,'jweise','Promote Diversity, Equity, Inclusion, and Accessibility in Skills, Systems, and Services','Why:  LIT provides services to a broad user base starting with our colleagues in the library and reaching across the globe to end users everywhere. We want to align with the goals of the library and university by invoking diversity, equity, inclusion, and accessibility (DEI&A) in our values and priorities, exemplified by the skills we develop in ourselves, the application of universal design methods to the systems we build, and by openly engaging with all people in the services we provide. \r\n\r\nLong-term direction: In order to diversify every aspect of who we are, how we do things, and who we are able to serve, for ourselves, our partners, and users, we will encourage the development among staff of skills, systems, and services that will allow us to incorporate diversity with the objective of accommodating the broadest possible population we engage with, near and far. New endeavors will be conceived with these principles in mind. Applications that do not meet these standards will be migrated and phased out, or reconceived and recreated. \r\n\r\nIntention for the year: LIT will adopt principles of universal design for the systems we create and support. We will expand and systematize our accessibility efforts and explore language support across systems. We will support and encourage staff to participate in training and take advantage of resources being offered across U-M (especially Learning & Professional Development) to enrich the DEI&A skill set of LIT staff.\r\n\r\nStewards:  Rachel Vacek, Kat Hagedorn','In progress','2017-06-01',0,NULL,'2017-05-31 20:40:56','',2017),(160,'jweise','Sustain and Enhance Operational Systems and Services','Why: Providing reliable, efficient and useful systems and services to our users requires significant constant attention to keep the core day to day functions of the library working and adapting to developing needs. This critical work includes maintenance, upgrade, troubleshooting, and enhancement of hardware, software infrastructure, and staff-facing systems and processes relied upon for daily management of library operations.\r\n\r\nLong-term direction: In order to continue to provide excellent systems and services to our partners in the library, the broader campus community, and the world, LIT will support, maintain, and enhance our production level systems and related services including tools and processes that facilitate collaboration and communication, such as the Front Door.\r\n\r\nIntention for this year: Automate, enhance, and improve systems and services to increase efficiency and gain advantages in service provisioning, quality, and satisfaction.\r\n\r\nStewards: Jon Rothman, Sebastien Korner, Kat Hagedorn','In progress','2017-06-01',0,NULL,'2017-05-31 20:40:56','',2017),(161,'jweise','Build an Engaged, Inclusive, and Supportive Culture','Why: The culture of the LIT represents who we are as a whole and as individuals. Every day is an opportunity to learn, and apply our wide-ranging skills and talents collaboratively toward ambitious achievements. \r\n\r\nLong-term direction: LIT will actively cultivate the elements of a safe and comfortable work place  that align with our mission and values, creating an environment that is engaging, collaborative, dynamic, inclusive, supportive and overall conducive to professional growth, personal excellence, and productive and satisfying work for all.\r\n\r\nIntention for the year: LIT will create specific plans for investing in and developing those elements of an safe and comfortable work place (including space, training, professional and career development) that align with the strategic initiatives and core operations articulated in the LIT mission, purpose, and goals. We will also work to improve our hiring and onboarding practices with an eye towards hiring and retaining for diversity, and fostering an inclusive environment.\r\n\r\nStewards: John Weise, Maurice York, Marian Leon, Meghan Musolff','In progress','2017-06-01',0,NULL,'2017-05-31 20:40:56','',2017),(162,'jweise','hello world','test','Not started','2017-06-01',0,NULL,'2017-05-31 20:40:56','',2017),(163,'khage','hello world 2','what what','Not started','2015-12-01',0,NULL,'2017-05-31 20:40:56','',2017);
/*!40000 ALTER TABLE `goal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `goalowner`
--

DROP TABLE IF EXISTS `goalowner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `goalowner`
--

LOCK TABLES `goalowner` WRITE;
/*!40000 ALTER TABLE `goalowner` DISABLE KEYS */;
INSERT INTO `goalowner` VALUES (1,'LIT','Library Information & Technology',NULL,NULL,NULL,1,NULL,'2016-09-28 19:21:09'),(2,'A&E','Architecture & Engineering',NULL,'LIT',NULL,1,NULL,'2016-09-28 19:21:09'),(3,'D&D','Design & Discovery',NULL,'LIT',NULL,1,NULL,'2016-09-28 19:21:09'),(4,'DCC','Digital Content & Collections',NULL,'LIT',NULL,1,NULL,'2016-09-28 19:21:09'),(5,'DLA','Digital Library Applications',NULL,'LIT',NULL,1,NULL,'2016-09-28 19:21:09'),(6,'HT','HathiTrust',NULL,NULL,NULL,1,NULL,'2016-09-28 19:21:09'),(7,'SYS','Library Systems',NULL,'LIT',NULL,1,NULL,'2016-09-28 19:21:09'),(8,'TCP','Encoded Text / TCP',NULL,'DCC',NULL,1,NULL,'2016-09-28 19:21:09'),(9,'DCU','Digital Conversion Unit',NULL,'DCC',NULL,1,NULL,'2016-09-28 19:21:09'),(10,'TA','Training & Assessment',NULL,'D&D',NULL,1,NULL,'2016-09-28 19:21:09'),(11,'WS','Web Systems',NULL,'D&D',NULL,1,NULL,'2016-09-28 19:21:09'),(12,'UX','User Experience',NULL,'D&D',NULL,1,NULL,'2016-09-28 19:21:09'),(13,'LTIG','Learning Technologies Incubation Group',NULL,'LIT',NULL,1,NULL,'2016-09-28 19:21:09'),(14,'rcadler','Adler','Richard','DCC',NULL,0,0,'2016-09-28 19:21:09'),(15,'bertrama','Bertram','Albert','D&D',NULL,0,0,'2016-09-28 19:21:09'),(16,'blancoj','Blanco','Jose','DLA',NULL,0,0,'2016-09-28 19:21:09'),(17,'botimer','Botimer','Noah','A&E',NULL,0,0,'2016-09-28 19:21:09'),(18,'heidisb','Burkhardt','Heidi','UX',NULL,0,0,'2016-09-28 19:21:09'),(19,'tburtonw','Burton-West','Tom','DLA',NULL,0,0,'2016-09-28 19:21:09'),(20,'christeh','Christenson','Heather','HT',NULL,0,0,'2016-09-28 19:21:09'),(21,'vjdillon','Dillon','Vicki','SYS',NULL,0,0,'2016-09-28 19:21:09'),(22,'suledwan','Diwan','Suleman','A&E',NULL,0,0,'2016-09-28 19:21:09'),(23,'dobias','Dobias','Trevor','UX',NULL,0,0,'2016-09-28 19:21:09'),(24,'dueberb','Dueber','Bill','DLA',NULL,0,1,'2017-07-03 14:38:06'),(25,'earleyj','Earley','Jonathan','D&D',NULL,0,0,'2016-09-28 19:21:09'),(26,'keden','Eden','Kristina','HT',NULL,0,0,'2016-09-28 19:21:09'),(27,'aelkiss','Elkiss','Aaron','A&E',NULL,0,0,'2016-09-28 19:21:09'),(28,'jimeng','Eng','James','A&E',NULL,0,0,'2016-09-28 19:21:09'),(29,'roger','Espinosa','Roger','DLA',NULL,0,0,'2016-09-28 19:21:09'),(30,'dfulmer','Fulmer','David','SYS',NULL,0,0,'2016-09-28 19:21:09'),(31,'fultonis','Fulton','Colin','D&D',NULL,0,0,'2016-09-28 19:21:09'),(32,'valglenn','Glenn','Valerie','HT',NULL,0,0,'2016-09-28 19:21:09'),(33,'jaglover','Glover','Jason','DCC',NULL,0,0,'2016-09-28 19:21:09'),(34,'grosscol','Gross','Colin','A&E',NULL,0,0,'2016-09-28 19:21:09'),(35,'khage','Hagedorn','Kat','DCC',NULL,0,1,'2016-09-28 19:21:09'),(36,'moseshll','Hall','Brian','DLA',NULL,0,0,'2016-09-28 19:21:09'),(37,'bhock','Hockey','Bryan','A&E',NULL,0,0,'2016-09-28 19:21:09'),(38,'bnhowell','Howell','Ben','UX',NULL,0,0,'2016-09-28 19:21:09'),(39,'mcisrael','Israel','Margaret','DCC',NULL,0,0,'2016-09-28 19:21:09'),(40,'njaffer','Jaffer','Nabeela','DLA',NULL,0,0,'2016-09-28 19:21:09'),(41,'sethajoh','Johnson','Seth','DLA',NULL,0,0,'2016-09-28 19:21:09'),(42,'megrust','Kelly','Margaret','SYS',NULL,0,0,'2016-09-28 19:21:09'),(43,'kopinski','Kopinski','William','SYS',NULL,0,0,'2016-09-28 19:21:09'),(44,'skorner','Korner','Sebastien','A&E',NULL,0,1,'2016-09-28 19:21:09'),(45,'gkostin','Kostin','Greg','DCC',NULL,0,0,'2016-09-28 19:21:09'),(46,'mattlach','LaChance','Matthew','DCC',NULL,0,0,'2016-09-28 19:21:09'),(47,'kllarsen','Larsen','Keith','DCC',NULL,0,0,'2016-09-28 19:21:09'),(48,'lattaj','Latta','John','DCC',NULL,0,0,'2016-09-28 19:21:09'),(49,'gordonl','Leacock','Gordon','DLA',NULL,0,0,'2016-09-28 19:21:09'),(50,'jleasia','Leasia','John','A&E',NULL,0,1,'2016-09-28 19:21:09'),(51,'marianle','Leon','Marian',NULL,NULL,0,0,'2016-09-28 19:21:09'),(52,'monall','Logarbo','Mona','DCC',NULL,0,0,'2016-09-28 19:21:09'),(53,'rjmcinty','McIntyre','Robert','DCC',NULL,0,0,'2016-09-28 19:21:09'),(54,'mcintsan','McIntyre','Sandra','HT',NULL,0,0,'2016-09-28 19:21:09'),(55,'nancymou','Moussa','Nancy','D&D',NULL,0,0,'2016-09-28 19:21:09'),(56,'musolffm','Musolff','Meghan','D&D',NULL,0,1,'2016-09-28 19:21:09'),(57,'conorom','O\'Malley','Conor','DLA',NULL,0,0,'2016-09-28 19:21:09'),(58,'krenee','Ondracek','Kayla','DCC',NULL,0,0,'2016-09-28 19:21:09'),(59,'elpayne','Payne','Lizanne','HT',NULL,0,0,'2016-09-28 19:21:09'),(60,'sooty','Powell','Chris','DCC',NULL,0,0,'2016-09-28 19:21:09'),(61,'timothy','Prettyman','Timothy','SYS',NULL,0,0,'2016-09-28 19:21:09'),(62,'jrothman','Rothman','Jonathan','SYS',NULL,0,1,'2016-09-28 19:21:09'),(63,'rrotter','Rotter','Ryan','A&E',NULL,0,0,'2016-09-28 19:21:09'),(64,'pfs','Schaffner','Paul','DCC',NULL,0,0,'2016-09-28 19:21:09'),(65,'eliotwsc','Scott','Eliot','D&D',NULL,0,0,'2016-09-28 19:21:09'),(66,'rsteg','Stegmeyer','Randal','DCC',NULL,0,0,'2016-09-28 19:21:09'),(67,'jstever','Steverman','Joshua','SYS',NULL,0,0,'2016-09-28 19:21:09'),(68,'mmstewa','Stewart','Melissa','HT',NULL,0,0,'2016-09-28 19:21:09'),(69,'syrigos','Syrigos','Panagis','A&E',NULL,0,0,'2016-09-28 19:21:09'),(70,'ldunger','Unger','Lara','DCC',NULL,0,0,'2016-09-28 19:21:09'),(71,'varnum','Varnum','Ken','D&D',NULL,0,1,'2016-09-28 19:21:09'),(72,'mwarin','Warin','Martin','SYS',NULL,0,0,'2016-09-28 19:21:09'),(73,'jweise','Weise','John','DLA',NULL,0,1,'2016-09-28 19:21:09'),(74,'lwentzel','Wentzel','Lawrence','DCC',NULL,0,0,'2016-09-28 19:21:09'),(75,'azaytsev','Zaytsev','Angelina','HT',NULL,0,1,'2016-09-28 19:21:09'),(76,'mcyork','York','Maurice',NULL,NULL,0,1,'2016-09-28 19:21:09'),(77,'bentobey','Tobey','Ben','D&D',NULL,0,0,'2016-12-02 19:43:42'),(78,'rvacek','Vacek','Rachel','D&D',NULL,0,1,'2017-03-07 15:24:07');
/*!40000 ALTER TABLE `goalowner` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `goalsearch`
--

DROP TABLE IF EXISTS `goalsearch`;
/*!50001 DROP VIEW IF EXISTS `goalsearch`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `goalsearch` (
  `id` tinyint NOT NULL,
  `title` tinyint NOT NULL,
  `description` tinyint NOT NULL,
  `people` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `goaltogoal`
--

DROP TABLE IF EXISTS `goaltogoal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `goaltogoal` (
  `childgoalid` int(10) unsigned DEFAULT NULL,
  `parentgoalid` int(10) unsigned DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `goaltogoal`
--

LOCK TABLES `goaltogoal` WRITE;
/*!40000 ALTER TABLE `goaltogoal` DISABLE KEYS */;
INSERT INTO `goaltogoal` VALUES (132,51),(162,160);
/*!40000 ALTER TABLE `goaltogoal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `goaltoowner`
--

DROP TABLE IF EXISTS `goaltoowner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `goaltoowner` (
  `goalid` int(10) unsigned DEFAULT NULL,
  `ownerid` int(10) unsigned DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `goaltoowner`
--

LOCK TABLES `goaltoowner` WRITE;
/*!40000 ALTER TABLE `goaltoowner` DISABLE KEYS */;
INSERT INTO `goaltoowner` VALUES (3,1),(1,3),(2,3),(3,3),(4,3),(5,3),(6,3),(7,3),(8,3),(9,3),(10,3),(11,3),(12,3),(13,3),(14,7),(15,7),(16,7),(17,7),(18,3),(20,3),(21,3),(22,5),(23,3),(24,5),(25,7),(26,1),(27,1),(28,1),(29,7),(30,7),(31,2),(32,2),(35,5),(37,5),(38,5),(39,7),(40,2),(41,3),(42,3),(43,3),(44,13),(45,5),(46,2),(47,1),(48,1),(49,2),(50,2),(51,2),(52,2),(53,3),(54,5),(55,5),(56,2),(57,2),(58,2),(59,2),(60,7),(61,7),(62,2),(63,3),(64,3),(65,2),(66,1),(67,3),(68,3),(69,3),(70,3),(71,3),(72,1),(73,3),(74,2),(75,3),(76,3),(77,7),(78,7),(79,7),(80,7),(81,7),(82,7),(83,5),(84,5),(85,5),(86,5),(87,5),(88,5),(89,5),(90,5),(91,5),(92,3),(93,3),(94,3),(95,3),(96,3),(97,3),(98,3),(99,5),(100,5),(101,3),(102,5),(103,3),(104,3),(105,2),(106,2),(107,2),(108,2),(109,2),(110,2),(111,2),(112,2),(114,2),(115,2),(116,7),(117,2),(118,3),(119,3),(120,3),(121,3),(122,3),(123,3),(124,3),(125,3),(126,3),(127,3),(128,2),(129,3),(130,3),(131,2),(133,3),(134,5),(135,5),(136,2),(137,2),(138,5),(139,3),(140,3),(141,2),(142,2),(143,2),(144,1),(145,1),(146,2),(19,2),(19,13),(113,2),(113,5),(113,11),(33,2),(33,4),(148,24),(36,5),(132,2),(132,5),(34,2),(149,25),(151,5),(153,1),(150,1),(155,1),(156,1),(157,1),(158,1),(159,1),(160,1),(161,1),(154,1),(162,73),(152,1),(152,3);
/*!40000 ALTER TABLE `goaltoowner` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `goaltosteward`
--

DROP TABLE IF EXISTS `goaltosteward`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `goaltosteward` (
  `goalid` int(10) unsigned DEFAULT NULL,
  `stewardid` int(10) unsigned DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `goaltosteward`
--

LOCK TABLES `goaltosteward` WRITE;
/*!40000 ALTER TABLE `goaltosteward` DISABLE KEYS */;
/*!40000 ALTER TABLE `goaltosteward` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `human_owners`
--

DROP TABLE IF EXISTS `human_owners`;
/*!50001 DROP VIEW IF EXISTS `human_owners`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `human_owners` (
  `id` tinyint NOT NULL,
  `title` tinyint NOT NULL,
  `names` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `human_stewards`
--

DROP TABLE IF EXISTS `human_stewards`;
/*!50001 DROP VIEW IF EXISTS `human_stewards`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `human_stewards` (
  `id` tinyint NOT NULL,
  `title` tinyint NOT NULL,
  `names` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `status`
--

DROP TABLE IF EXISTS `status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `status` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `status`
--

LOCK TABLES `status` WRITE;
/*!40000 ALTER TABLE `status` DISABLE KEYS */;
INSERT INTO `status` VALUES (5,'Abandoned'),(4,'Completed'),(3,'In progress'),(1,'Not started'),(2,'On hold');
/*!40000 ALTER TABLE `status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `goalsearch`
--

/*!50001 DROP TABLE IF EXISTS `goalsearch`*/;
/*!50001 DROP VIEW IF EXISTS `goalsearch`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`dueberb`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `goalsearch` AS select `goal`.`id` AS `id`,`goal`.`title` AS `title`,`goal`.`description` AS `description`,concat(coalesce(`human_owners`.`names`,' '),coalesce(`human_stewards`.`names`,' ')) AS `people` from ((`goal` left join `human_owners` on((`human_owners`.`id` = `goal`.`id`))) left join `human_stewards` on((`human_stewards`.`id` = `goal`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `human_owners`
--

/*!50001 DROP TABLE IF EXISTS `human_owners`*/;
/*!50001 DROP VIEW IF EXISTS `human_owners`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`dueberb`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `human_owners` AS select `goal`.`id` AS `id`,`goal`.`title` AS `title`,group_concat(concat(`o`.`uniqname`,' ',`o`.`lastname`,' ',coalesce(`o`.`firstname`,'')) separator ', ') AS `names` from ((`goal` join `goalowner` `o`) join `goaltoowner` `gto`) where ((`goal`.`id` = `gto`.`goalid`) and (`o`.`id` = `gto`.`ownerid`) and (`o`.`is_unit` = 0)) group by `goal`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `human_stewards`
--

/*!50001 DROP TABLE IF EXISTS `human_stewards`*/;
/*!50001 DROP VIEW IF EXISTS `human_stewards`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`dueberb`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `human_stewards` AS select `goal`.`id` AS `id`,`goal`.`title` AS `title`,group_concat(concat(`o`.`uniqname`,' ',`o`.`lastname`,' ',coalesce(`o`.`firstname`,'')) separator ', ') AS `names` from ((`goal` join `goalowner` `o`) join `goaltosteward` `gts`) where ((`goal`.`id` = `gts`.`goalid`) and (`o`.`id` = `gts`.`stewardid`) and (`o`.`is_unit` = 0)) group by `goal`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-07-21 10:19:45
