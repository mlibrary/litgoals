-- People belong to units. Units belong to each other. Either can have goals
-- and a unit as a "parent." So, we'll model them as the same thing

DROP TABLE IF EXISTS status;
DROP TABLE IF EXISTS goal;
DROP TABLE IF EXISTS goalowner;

CREATE TABLE IF NOT EXISTS status (
  id INTEGER  PRIMARY KEY,
  name VARCHAR(255) unique
);


CREATE TABLE goalowner (
  id INTEGER  PRIMARY KEY,
  uniqname varchar(255) UNIQUE,  -- uniqname or unit abbreviation
  lastname VARCHAR (255), -- or the whole unit name
  firstname VARCHAR (255),
  parent_uniqname VARCHAR(255),
  created DATE ,
  is_unit BOOLEAN,
  is_admin BOOLEAN,
  updated DATETIME DEFAULT CURRENT_TIMESTAMP
) ;





-- ENUM('Not started', 'On hold', 'In progress', 'Completed', 'Abandoned')

CREATE TABLE IF NOT EXISTS goal (
  id INTEGER  PRIMARY KEY,
  owner_uniqname VARCHAR(255),
  creator_uniqname VARCHAR(255),
  title VARCHAR(255),
  description TEXT,
  status VARCHAR(255),
  platform VARCHAR(255),
  draft INTEGER,
  target_date DATE,
  created DATE,
  updated DATETIME DEFAULT CURRENT_TIMESTAMP
) ;


CREATE TABLE IF NOT EXISTS goaltogoal (
  childgoalid INTEGER UNSIGNED,
  parentgoalid INTEGER UNSIGNED
) ;

