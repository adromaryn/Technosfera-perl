CREATE TABLE users (
    name VARCHAR(255) NOT NULL PRIMARY KEY,
    hash VARCHAR(31) NOT NULL
) ENGINE=InnoDB CHARACTER SET=UTF8;

CREATE TABLE albums (
    id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    user_name VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    band VARCHAR(255) NOT NULL,
    year INT NOT NULL,
    UNIQUE KEY (user_name, title, band),
    CONSTRAINT `fk_album_user`
      FOREIGN KEY (user_name) REFERENCES users(name)
      ON DELETE CASCADE
) ENGINE=InnoDB CHARACTER SET=UTF8;

CREATE TABLE tracks (
    id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    album_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    format VARCHAR(8) NOT NULL,
    link VARCHAR(255) NOT NULL,
    UNIQUE KEY (album_id, title),
    CONSTRAINT `fk_track_album`
      FOREIGN KEY (album_id) REFERENCES albums(id)
      ON DELETE CASCADE
) ENGINE=InnoDB CHARACTER SET=UTF8;
