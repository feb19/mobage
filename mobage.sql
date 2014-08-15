DROP TABLE IF EXISTS games;
CREATE TABLE games (
    id              INTEGER PRIMARY KEY NOT NULL,
    title_raw       TEXT DEFAULT "",
    title           TEXT DEFAULT "",
    title_digest    TEXT DEFAULT "",
    catch_copy      TEXT DEFAULT "",
    description     TEXT DEFAULT "",
    url             TEXT DEFAULT "",
    genre           TEXT DEFAULT "",
    tags            TEXT DEFAULT "",
    sap             TEXT DEFAULT "",
    imageUrl        TEXT DEFAULT "",
    thumbnailUrl    TEXT DEFAULT "",
    ios             INTEGER DEFAULT 0,
    android         INTEGER DEFAULT 0,
    mobile          INTEGER DEFAULT 0,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);