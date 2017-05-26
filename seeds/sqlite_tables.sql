-- noinspection SqlNoDataSourceInspectionForFile
-- noinspection SqlDialectInspectionForFile

CREATE TABLE IF NOT EXISTS status (
  id   INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(255) UNIQUE
);


CREATE TABLE goalowner (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  uniqname        VARCHAR(255) UNIQUE, -- uniqname or unit abbreviation
  lastname        VARCHAR(255), -- or the whole unit name
  firstname       VARCHAR(255),
  parent_uniqname VARCHAR(255),
  created         DATE,
  is_unit         BOOLEAN,
  is_admin        BOOLEAN,
  updated         DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ENUM('Not started', 'On hold', 'In progress', 'Completed', 'Abandoned')

CREATE TABLE IF NOT EXISTS goal (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  creator_uniqname VARCHAR(255),
  title            TEXT,
  description      TEXT,
  notes            TEXT,
  goal_year        INTEGER,
  status           VARCHAR(255),
  target_date      DATE,
  draft            TINYINT  DEFAULT 0,
  created          DATE,
  updated          DATETIME DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS goaltogoal (
  childgoalid  INTEGER,
  parentgoalid INTEGER
);

CREATE TABLE IF NOT EXISTS goaltoowner (
  goalid  INTEGER,
  ownerid INTEGER
);

CREATE TABLE IF NOT EXISTS goaltosteward (
  goalid    INT(10) UNSIGNED DEFAULT NULL,
  stewardid INT(10) UNSIGNED DEFAULT NULL
);
