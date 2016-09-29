-- People belong to units. Units belong to each other. Either can have goals
-- and a unit as a "parent." So, we'll model them as the same thing

DROP TABLE IF EXISTS status;
DROP TABLE IF EXISTS goal;
DROP TABLE IF EXISTS goalowner;

CREATE TABLE IF NOT EXISTS status (
  id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) unique
);


CREATE TABLE goalowner (
  id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  uniqname varchar(255) UNIQUE,  -- uniqname or unit abbreviation
  lastname VARCHAR (255), -- or the whole unit name
  firstname VARCHAR (255),
  parent_uniqname VARCHAR(255),
  created DATE ,
  is_unit BOOLEAN,
  is_admin BOOLEAN,
  updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

)  ENGINE=InnoDB;





-- ENUM('Not started', 'On hold', 'In progress', 'Completed', 'Abandoned')

CREATE TABLE IF NOT EXISTS goal (
  id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  creator_uniqname VARCHAR(255),
  title text,
  description TEXT,
  notes TEXT,
  status VARCHAR(255),
  target_date DATE,
  draft TINYINT DEFAULT 0,
  created DATE,
  updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)  ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS goaltogoal (
  childgoalid INTEGER UNSIGNED,
  parentgoalid INTEGER UNSIGNED
)  ENGINE=InnoDB;

CREATE table IF NOT EXISTS goaltoowner (
  goalid INTEGER UNSIGNED,
  ownerid INTEGER UNSIGNED
) ENGINE=InnoDB;
