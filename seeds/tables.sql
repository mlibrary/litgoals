-- People belong to units. Units belong to each other. Either can have goals
-- and a unit as a "parent." So, we'll model them as the same thing

CREATE TABLE IF NOT EXISTS goalowner (
  id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  uniqname varchar(255) UNIQUE,  -- uniqname or unit abbreviation
  lastname VARCHAR (255), -- or the whole unit name
  firstname VARCHAR (255),
  parent_uniqname VARCHAR(255),
  created DATE ,
  is_unit BOOLEAN,
  updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY fk_unit(parent_uniqname) REFERENCES goalowner(uniqname)
     ON UPDATE CASCADE
     ON DELETE RESTRICT
)  ENGINE=InnoDB;




CREATE TABLE IF NOT EXISTS status (
  name VARCHAR(255) PRIMARY KEY NOT NULL
);

-- ENUM('Not started', 'On hold', 'In progress', 'Completed', 'Abandoned')

CREATE TABLE IF NOT EXISTS goal (
  id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  owner VARCHAR(255),
  creator VARCHAR(255),
  title VARCHAR(255),
  description TEXT,
  status VARCHAR(255),
  platform ENUM('Create', 'Scale', 'Build'),
  target_date DATE,
  created DATE,
  updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  foreign key fk_status(status) references status(name) on update cascade,
  FOREIGN KEY fk_owner(owner) REFERENCES goalowner(uniqname) ON DELETE RESTRICT,
  FOREIGN KEY fk_creator(creator) REFERENCES goalowner(uniqname) ON DELETE RESTRICT
)  ENGINE=InnoDB;

