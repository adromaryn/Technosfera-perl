CREATE TABLE users (
    name VARCHAR(30) NOT NULL PRIMARY KEY,
    karma FLOAT NOT NULL,
    rating FLOAT NOT NULL
) DEFAULT CHARSET utf8;

CREATE TABLE posts (
    id INT NOT NULL PRIMARY KEY,
    author VARCHAR(30) NOT NULL,
    topic VARCHAR(255) NOT NULL,
    rating SMALLINT NOT NULL,
    views INT NOT NULL,
    stars SMALLINT NOT NULL,
    INDEX (author)
) DEFAULT CHARSET utf8;

CREATE TABLE commenters (
    author VARCHAR(30) NOT NULL,
    post INT NOT NULL,
    INDEX (post),
    PRIMARY KEY (`author`, `post`),
    INDEX (author)
) DEFAULT CHARSET utf8;
