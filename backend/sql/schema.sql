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

CREATE TABLE
    medicines (
        id SERIAL PRIMARY KEY,
        code VARCHAR(50) NOT NULL UNIQUE,
        name VARCHAR(150) NOT NULL,
        active_ingredient VARCHAR(255),
        strength VARCHAR(100),
        dosage_form VARCHAR(100),
        manufacturer VARCHAR(150),
        base_unit VARCHAR(50) NOT NULL,
        low_stock_threshold INTEGER NOT NULL DEFAULT 0,
        is_active BOOLEAN NOT NULL DEFAULT TRUE,
        created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT medicines_code_valid CHECK (
            code != ''
            AND code = BTRIM (code)
        ),
        CONSTRAINT medicines_name_valid CHECK (
            name != ''
            AND name = BTRIM (name)
        ),
        CONSTRAINT medicines_base_unit_valid CHECK (
            base_unit != ''
            AND base_unit = BTRIM (base_unit)
        ),
        CONSTRAINT medicines_low_stock_threshold_valid CHECK (low_stock_threshold >= 0)
    );

CREATE TABLE
    medicine_units (
        id SERIAL PRIMARY KEY,
        medicine_id INTEGER NOT NULL REFERENCES medicines (id),
        unit_name VARCHAR(50) NOT NULL,
        conversion_factor INTEGER NOT NULL,
        selling_price NUMERIC(15, 0) NOT NULL,
        is_active BOOLEAN NOT NULL DEFAULT TRUE,
        created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT medicine_units_name_valid CHECK (
            unit_name != ''
            AND unit_name = BTRIM (unit_name)
        ),
        CONSTRAINT medicine_units_conversion_valid CHECK (conversion_factor > 0),
        CONSTRAINT medicine_units_price_valid CHECK (selling_price >= 0)
    );

CREATE TABLE
    suppliers (
        id SERIAL PRIMARY KEY,
        code VARCHAR(50) NOT NULL UNIQUE,
        name VARCHAR(150) NOT NULL,
        phone VARCHAR(20),
        address TEXT,
        is_active BOOLEAN NOT NULL DEFAULT TRUE,
        created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT suppliers_code_valid CHECK (
            code != ''
            AND code = BTRIM (code)
        ),
        CONSTRAINT suppliers_name_valid CHECK (
            name != ''
            AND name = BTRIM (name)
        )
    );

CREATE TABLE
    medicine_batches (
        id SERIAL PRIMARY KEY,
        medicine_id INTEGER NOT NULL REFERENCES medicines (id),
        batch_number VARCHAR(100) NOT NULL,
        expiry_date DATE NOT NULL,
        quantity_on_hand INTEGER NOT NULL DEFAULT 0,
        first_received_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT medicine_batches_number_valid CHECK (
            batch_number != ''
            AND batch_number = BTRIM (batch_number)
        ),
        CONSTRAINT medicine_batches_quantity_valid CHECK (quantity_on_hand >= 0),
        CONSTRAINT medicine_batches_unique UNIQUE (medicine_id, batch_number, expiry_date)
    );

CREATE TABLE
    purchase_receipts (
        id SERIAL PRIMARY KEY,
        code VARCHAR(50) NOT NULL UNIQUE,
        supplier_id INTEGER NOT NULL REFERENCES suppliers (id),
        created_by INTEGER NOT NULL REFERENCES users (id),
        status VARCHAR(20) NOT NULL DEFAULT 'draft',
        note TEXT,
        created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        confirmed_at TIMESTAMPTZ,
        CONSTRAINT purchase_receipts_code_valid CHECK (
            code != ''
            AND code = BTRIM (code)
        ),
        CONSTRAINT purchase_receipts_status_valid CHECK (status IN ('draft', 'confirmed')),
        CONSTRAINT purchase_receipts_confirmation_valid CHECK (
            (
                status = 'draft'
                AND confirmed_at IS NULL
            )
            OR (
                status = 'confirmed'
                AND confirmed_at IS NOT NULL
            )
        )
    );

CREATE TABLE
    purchase_receipt_items (
        id SERIAL PRIMARY KEY,
        purchase_receipt_id INTEGER NOT NULL REFERENCES purchase_receipts (id),
        medicine_id INTEGER NOT NULL REFERENCES medicines (id),
        medicine_unit_id INTEGER NOT NULL REFERENCES medicine_units (id),
        unit_name VARCHAR(50) NOT NULL,
        conversion_factor INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price NUMERIC(15, 0) NOT NULL,
        batch_number VARCHAR(100) NOT NULL,
        expiry_date DATE NOT NULL,
        CONSTRAINT purchase_items_unit_name_valid CHECK (
            unit_name != ''
            AND unit_name = BTRIM (unit_name)
        ),
        CONSTRAINT purchase_items_conversion_valid CHECK (conversion_factor > 0),
        CONSTRAINT purchase_items_quantity_valid CHECK (quantity > 0),
        CONSTRAINT purchase_items_price_valid CHECK (unit_price >= 0),
        CONSTRAINT purchase_items_batch_number_valid CHECK (
            batch_number != ''
            AND batch_number = BTRIM (batch_number)
        )
    );

CREATE TABLE
    sales_invoices (
        id SERIAL PRIMARY KEY,
        code VARCHAR(50) NOT NULL UNIQUE,
        created_by INTEGER NOT NULL REFERENCES users (id),
        status VARCHAR(20) NOT NULL DEFAULT 'draft',
        note TEXT,
        created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        confirmed_at TIMESTAMPTZ,
        CONSTRAINT sales_invoices_code_valid CHECK (
            code != ''
            AND code = BTRIM (code)
        ),
        CONSTRAINT sales_invoices_status_valid CHECK (status IN ('draft', 'confirmed')),
        CONSTRAINT sales_invoices_confirmation_valid CHECK (
            (
                status = 'draft'
                AND confirmed_at IS NULL
            )
            OR (
                status = 'confirmed'
                AND confirmed_at IS NOT NULL
            )
        )
    );

CREATE TABLE
    sales_invoice_items (
        id SERIAL PRIMARY KEY,
        sales_invoice_id INTEGER NOT NULL REFERENCES sales_invoices (id),
        medicine_id INTEGER NOT NULL REFERENCES medicines (id),
        medicine_unit_id INTEGER NOT NULL REFERENCES medicine_units (id),
        unit_name VARCHAR(50) NOT NULL,
        conversion_factor INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price NUMERIC(15, 0) NOT NULL,
        CONSTRAINT sales_items_unit_name_valid CHECK (
            unit_name != ''
            AND unit_name = BTRIM (unit_name)
        ),
        CONSTRAINT sales_items_conversion_valid CHECK (conversion_factor > 0),
        CONSTRAINT sales_items_quantity_valid CHECK (quantity > 0),
        CONSTRAINT sales_items_price_valid CHECK (unit_price >= 0)
    );

CREATE TABLE
    sales_item_batches (
        id SERIAL PRIMARY KEY,
        sales_invoice_item_id INTEGER NOT NULL REFERENCES sales_invoice_items (id),
        medicine_batch_id INTEGER NOT NULL REFERENCES medicine_batches (id),
        quantity_base INTEGER NOT NULL,
        CONSTRAINT sales_item_batches_quantity_valid CHECK (quantity_base > 0),
        CONSTRAINT sales_item_batches_unique UNIQUE (sales_invoice_item_id, medicine_batch_id)
    );