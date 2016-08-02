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
  updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY fk_unit(parent_uniqname) REFERENCES goalowner(uniqname)
     ON UPDATE CASCADE
     ON DELETE RESTRICT
)  ENGINE=InnoDB;





-- ENUM('Not started', 'On hold', 'In progress', 'Completed', 'Abandoned')

CREATE TABLE IF NOT EXISTS goal (
  id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  owner_uniqname VARCHAR(255),
  creator_uniqname VARCHAR(255),
  title VARCHAR(255),
  description TEXT,
  status VARCHAR(255),
  platform VARCHAR(255),
  target_date DATE,
  created DATE,
  updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  foreign key fk_status(status) references status(name) on update cascade,
  FOREIGN KEY fk_owner(owner_uniqname) REFERENCES goalowner(uniqname) ON DELETE RESTRICT,
  FOREIGN KEY fk_creator(creator_uniqname) REFERENCES goalowner(uniqname) ON DELETE RESTRICT
)  ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS goaltogoal (
  childgoalid INTEGER UNSIGNED,
  parentgoalid INTEGER UNSIGNED,
  foreign KEY fk_ggchild(childgoalid) REFERENCES goal(id),
  foreign KEY fk_ggparent(parentgoalid) REFERENCES goal(id)
)  ENGINE=InnoDB;

