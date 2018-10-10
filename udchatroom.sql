
CREATE DATABASE udchatroom;

/c udchatroom;

CREATE TABLE chat_log (
   id   BIGSERIAL PRIMARY KEY,
   message TEXT NOT NULL,
   user_name TEXT NOT NULL,
   timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL
);