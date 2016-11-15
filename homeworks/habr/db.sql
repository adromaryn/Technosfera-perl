CREATE TABLE users (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL,
    karma SMALLINT NOT NULL,
    rating SMALLINT NOT NULL,
    PRIMARY KEY (id)
);
CREATE TABLE posts (
    id INT NOT NULL,
    author VARCHAR(30) NOT NULL,
    topic VARCHAR(255) NOT NULL,
    rating SMALLINT NOT NULL,
    views INT NOT NULL,
    stars SMALLINT NOT NULL
);
CREATE TABLE commenters (
    author VARCHAR(30) NOT NULL,
    post INT NOT NULL
);
