CREATE TABLE users (
    name VARCHAR(30) NOT NULL,
    karma FLOAT NOT NULL,
    rating FLOAT NOT NULL,
    PRIMARY KEY (name)
);
CREATE TABLE posts (
    id INT NOT NULL,
    author VARCHAR(30) NOT NULL,
    topic VARCHAR(255) NOT NULL,
    rating SMALLINT NOT NULL,
    views INT NOT NULL,
    stars SMALLINT NOT NULL,
    PRIMARY KEY (id)
);
CREATE TABLE commenters (
    author VARCHAR(30) NOT NULL,
    post INT NOT NULL,
    PRIMARY KEY (`author`, `post`)
);
