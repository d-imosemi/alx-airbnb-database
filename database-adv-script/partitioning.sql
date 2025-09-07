-- --------------------------
-- If dealing with very large datasets, consider table partitioning.
-- Assume the Booking table is large and query performance is slow.
-- Assuming bookings table is partitioned by start_date aka booking_date.
-- -------------------------


-- First, analyze the current table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'bookings'
ORDER BY ordinal_position;

-- Check table size and row count
SELECT 
    pg_size_pretty(pg_total_relation_size('bookings')) as total_size,
    pg_size_pretty(pg_relation_size('bookings')) as table_size,
    (SELECT COUNT(*) FROM bookings) as row_count,
    (SELECT MIN(booking_date) FROM bookings) as min_date,
    (SELECT MAX(booking_date) FROM bookings) as max_date;


-- Create the parent partitioned table
CREATE TABLE bookings_partitioned (
    booking_id SERIAL,
    user_id INTEGER NOT NULL,
    property_id INTEGER NOT NULL,
    booking_date DATE NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    booking_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (booking_id, booking_date)
) PARTITION BY RANGE (booking_date);

-- Create comment for documentation
COMMENT ON TABLE bookings_partitioned IS 'Partitioned bookings table by booking_date for performance optimization';


-- Create historical partition for old data
CREATE TABLE bookings_historical PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2000-01-01') TO ('2023-12-31');

-- Create monthly partitions for 2024
CREATE TABLE bookings_2024_01 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2024-01-31');

CREATE TABLE bookings_2024_02 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2024-02-01') TO ('2024-02-29');

CREATE TABLE bookings_2024_03 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2024-03-01') TO ('2024-03-31');

CREATE TABLE bookings_2024_04 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2024-04-01') TO ('2024-04-30');

CREATE TABLE bookings_2024_05 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2024-05-01') TO ('2024-05-31');

CREATE TABLE bookings_2024_06 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2024-06-01') TO ('2024-06-30');

CREATE TABLE bookings_2024_07 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2024-07-01') TO ('2024-07-31');

CREATE TABLE bookings_2024_08 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2024-08-01') TO ('2024-08-31');

CREATE TABLE bookings_2024_09 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2024-09-01') TO ('2024-09-30');

CREATE TABLE bookings_2024_10 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2024-10-01') TO ('2024-10-31');

CREATE TABLE bookings_2024_11 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2024-11-01') TO ('2024-11-30');

CREATE TABLE bookings_2024_12 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2024-12-01') TO ('2024-12-31');

-- Create future partitions (quarterly for better maintenance)
CREATE TABLE bookings_2025_q1 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2025-01-01') TO ('2025-03-31');

CREATE TABLE bookings_2025_q2 PARTITION OF bookings_partitioned
    FOR VALUES FROM ('2025-04-01') TO ('2025-06-30');

-- Default partition for any unexpected dates
CREATE TABLE bookings_default PARTITION OF bookings_partitioned
    DEFAULT;


-- Create indexes on the parent table (inherited by all partitions)
CREATE INDEX idx_bookings_partitioned_booking_date ON bookings_partitioned(booking_date);
CREATE INDEX idx_bookings_partitioned_user_id ON bookings_partitioned(user_id);
CREATE INDEX idx_bookings_partitioned_property_id ON bookings_partitioned(property_id);
CREATE INDEX idx_bookings_partitioned_status ON bookings_partitioned(booking_status);
CREATE INDEX idx_bookings_partitioned_checkin ON bookings_partitioned(check_in_date);
CREATE INDEX idx_bookings_partitioned_checkout ON bookings_partitioned(check_out_date);

-- Create composite indexes for common query patterns
CREATE INDEX idx_bookings_partitioned_user_date ON bookings_partitioned(user_id, booking_date);
CREATE INDEX idx_bookings_partitioned_property_date ON bookings_partitioned(property_id, booking_date);
CREATE INDEX idx_bookings_partitioned_date_status ON bookings_partitioned(booking_date, booking_status);

-- Create indexes on individual partitions for specific optimization
CREATE INDEX idx_bookings_2024_01_user_date ON bookings_2024_01(user_id, booking_date);
CREATE INDEX idx_bookings_2024_01_property_date ON bookings_2024_01(property_id, booking_date);
