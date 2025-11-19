CREATE TABLE IF NOT EXISTS bans
(
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT                 NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    ban_time    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason      TEXT                   NOT NULL,
    banned_by   BIGINT                 NOT NULL REFERENCES users (id) ON DELETE CASCADE
);