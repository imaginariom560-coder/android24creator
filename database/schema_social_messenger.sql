-- Social media and messenger schema for SQLite.
-- The users table must exist before inserting rows into these tables.

PRAGMA foreign_keys = ON;

-- ======================
-- SOCIAL MEDIA
-- ======================
CREATE TABLE IF NOT EXISTS posts (
    id              TEXT PRIMARY KEY,
    user_id         TEXT NOT NULL,
    content         TEXT,
    image_url       TEXT,
    created_at      TEXT DEFAULT (datetime('now')),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS likes (
    id              TEXT PRIMARY KEY,
    post_id         TEXT NOT NULL,
    user_id         TEXT NOT NULL,
    created_at      TEXT DEFAULT (datetime('now')),
    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE(post_id, user_id)
);

CREATE TABLE IF NOT EXISTS comments (
    id              TEXT PRIMARY KEY,
    post_id         TEXT NOT NULL,
    user_id         TEXT NOT NULL,
    content         TEXT NOT NULL,
    created_at      TEXT DEFAULT (datetime('now')),
    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS follows (
    id              TEXT PRIMARY KEY,
    follower_id     TEXT NOT NULL,
    following_id    TEXT NOT NULL,
    created_at      TEXT DEFAULT (datetime('now')),
    FOREIGN KEY (follower_id) REFERENCES users(id),
    FOREIGN KEY (following_id) REFERENCES users(id),
    UNIQUE(follower_id, following_id)
);

-- ======================
-- MESSENGER
-- ======================
CREATE TABLE IF NOT EXISTS conversations (
    id              TEXT PRIMARY KEY,
    is_group        INTEGER NOT NULL DEFAULT 0 CHECK (is_group IN (0, 1)),
    title           TEXT,
    created_at      TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS conversation_members (
    id              TEXT PRIMARY KEY,
    conversation_id TEXT NOT NULL,
    user_id         TEXT NOT NULL,
    joined_at       TEXT DEFAULT (datetime('now')),
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE(conversation_id, user_id)
);

CREATE TABLE IF NOT EXISTS messages (
    id              TEXT PRIMARY KEY,
    conversation_id TEXT NOT NULL,
    sender_id       TEXT NOT NULL,
    content         TEXT,
    image_url       TEXT,
    created_at      TEXT DEFAULT (datetime('now')),
    is_read         INTEGER NOT NULL DEFAULT 0 CHECK (is_read IN (0, 1)),
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id)
);

-- ======================
-- INDEXES
-- ======================
CREATE INDEX IF NOT EXISTS idx_posts_user_created
    ON posts(user_id, created_at);

CREATE INDEX IF NOT EXISTS idx_likes_post
    ON likes(post_id);

CREATE INDEX IF NOT EXISTS idx_comments_post_created
    ON comments(post_id, created_at);

CREATE INDEX IF NOT EXISTS idx_follows_follower
    ON follows(follower_id);

CREATE INDEX IF NOT EXISTS idx_follows_following
    ON follows(following_id);

CREATE INDEX IF NOT EXISTS idx_conversation_members_user
    ON conversation_members(user_id);

CREATE INDEX IF NOT EXISTS idx_messages_conversation_created
    ON messages(conversation_id, created_at);

CREATE INDEX IF NOT EXISTS idx_messages_sender
    ON messages(sender_id);
