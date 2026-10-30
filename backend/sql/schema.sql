CREATE TABLE
    users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        full_name VARCHAR(50) NOT NULL,
        role VARCHAR(50) NOT NULL DEFAULT 'staff',
        is_active BOOLEAN NOT NULL DEFAULT TRUE,
        created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT users_username_valid CHECK (
            username != ''
            AND username = BTRIM (username)
            AND username = LOWER(username)
        ),
        CONSTRAINT users_full_name_valid CHECK (
            full_name != ''
            AND full_name = BTRIM (full_name)
        ),
        CONSTRAINT users_role_valid CHECK (role IN ('manager', 'staff'))
    );