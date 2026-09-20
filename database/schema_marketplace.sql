-- HOLOOS / Marketplace schema for SQLite.
-- Execute this file with SQLite, not directly in the shell.
-- Example: sqlite3 holoos.db < database/schema_marketplace.sql

PRAGMA foreign_keys = ON;

-- ======================
-- MARKETPLACE
-- ======================
CREATE TABLE IF NOT EXISTS businesses (
    id              TEXT PRIMARY KEY,
    name            TEXT NOT NULL,
    location        TEXT,
    created_at      TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS cities (
    id              TEXT PRIMARY KEY,
    name            TEXT NOT NULL,
    location        TEXT,
    created_at      TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS consumers (
    id              TEXT PRIMARY KEY,
    default_location TEXT,
    created_at      TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS products (
    id              TEXT PRIMARY KEY,
    business_id     TEXT NOT NULL,
    name            TEXT NOT NULL,
    original_price  REAL NOT NULL CHECK (original_price >= 0),
    created_at      TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (business_id) REFERENCES businesses(id)
);

CREATE TABLE IF NOT EXISTS orders (
    id                  TEXT PRIMARY KEY,
    consumer_id         TEXT NOT NULL,
    product_id          TEXT NOT NULL,
    status              TEXT NOT NULL DEFAULT 'pending',
    estimated_minutes   INTEGER CHECK (estimated_minutes IS NULL OR estimated_minutes >= 0),
    assigned_at         TEXT,
    delivered_at        TEXT,
    created_at          TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (consumer_id) REFERENCES consumers(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- SQLite stores JSON as TEXT. JSON validity is checked when json1 is available.
CREATE TABLE IF NOT EXISTS matching_scores (
    id              TEXT PRIMARY KEY,
    consumer_id     TEXT NOT NULL,
    product_id      TEXT NOT NULL,
    score           REAL NOT NULL CHECK (score >= 0 AND score <= 1),
    distance_m      INTEGER CHECK (distance_m IS NULL OR distance_m >= 0),
    factors         TEXT,
    calculated_at   TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (consumer_id) REFERENCES consumers(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE IF NOT EXISTS predictions (
    id               TEXT PRIMARY KEY,
    business_id      TEXT NOT NULL,
    type             TEXT NOT NULL CHECK (type IN ('demand', 'surplus')),
    predicted_value  REAL NOT NULL,
    horizon_hours    INTEGER NOT NULL CHECK (horizon_hours > 0),
    created_at       TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (business_id) REFERENCES businesses(id)
);

-- ======================
-- INDEXES
-- ======================
-- SQLite does not support PostgreSQL's USING GIST syntax. Location values are
-- stored as TEXT, so these indexes cover relational lookups only.
CREATE INDEX IF NOT EXISTS idx_businesses_location
    ON businesses(location);

CREATE INDEX IF NOT EXISTS idx_cities_location
    ON cities(location);

CREATE INDEX IF NOT EXISTS idx_consumers_location
    ON consumers(default_location);

CREATE INDEX IF NOT EXISTS idx_orders_status
    ON orders(status);

CREATE INDEX IF NOT EXISTS idx_orders_created
    ON orders(created_at);

CREATE INDEX IF NOT EXISTS idx_products_business
    ON products(business_id);

CREATE INDEX IF NOT EXISTS idx_matching_consumer
    ON matching_scores(consumer_id);

CREATE INDEX IF NOT EXISTS idx_matching_product
    ON matching_scores(product_id);

CREATE INDEX IF NOT EXISTS idx_predictions_business
    ON predictions(business_id);
