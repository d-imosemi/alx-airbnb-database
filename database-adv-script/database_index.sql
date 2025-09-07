-- -----------------------------
-- Recommended indexes for User table
-- -----------------------------

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_last_login ON users(last_login);
CREATE INDEX idx_users_phone ON users(phone_number);


-- -----------------------------
-- Recommended indexes for Booking table
-- -----------------------------

CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_property_id ON bookings(property_id);
CREATE INDEX idx_bookings_status ON bookings(booking_status);
CREATE INDEX idx_bookings_check_in ON bookings(check_in_date);
CREATE INDEX idx_bookings_check_out ON bookings(check_out_date);
CREATE INDEX idx_bookings_booking_date ON bookings(booking_date);
CREATE INDEX idx_bookings_payment_status ON bookings(payment_status);

-- Composite indexes for common query patterns
CREATE INDEX idx_bookings_user_date ON bookings(user_id, booking_date);
CREATE INDEX idx_bookings_property_date ON bookings(property_id, check_in_date);
CREATE INDEX idx_bookings_date_status ON bookings(booking_date, booking_status);


-- -----------------------------
-- Recommended indexes for Property table
-- -----------------------------

CREATE INDEX idx_properties_city ON properties(city);
CREATE INDEX idx_properties_country ON properties(country);
CREATE INDEX idx_properties_property_type ON properties(property_type);
CREATE INDEX idx_properties_price ON properties(price_per_night);
CREATE INDEX idx_properties_bedrooms ON properties(bedrooms);
CREATE INDEX idx_properties_rating ON properties(rating);
CREATE INDEX idx_properties_host_id ON properties(host_id);
CREATE INDEX idx_properties_availability ON properties(is_available);

-- Composite indexes for search functionality
CREATE INDEX idx_properties_location_search ON properties(city, property_type, price_per_night);
CREATE INDEX idx_properties_advanced_search ON properties(city, bedrooms, rating, is_available);




-- ---------------------------------
-- General tips
-- Run each EXPLAIN/ANALYZE twice; compare the second run to reduce cold-cache noise.
-- Only drop/create indexes you are testing.
-- After creating indexes, refresh stats: PostgreSQL ANALYZE; MySQL ANALYZE TABLE.
-- Compare plan shape (Seq Scan → Index/Bitmap Scan), rows examined, buffers/IO, and total time.
-- ---------------------------------

-- ---------------------------------
-- Test Queries for Performance Measurement
-- ---------------------------------

-- Query 1: User authentication and recent bookings
EXPLAIN ANALYZE
SELECT u.user_id, u.username, u.email, 
       COUNT(b.booking_id) as total_bookings,
       MAX(b.booking_date) as last_booking
FROM users u
LEFT JOIN bookings b ON u.user_id = b.user_id
WHERE u.email = 'user@example.com'
GROUP BY u.user_id, u.username, u.email;

-- Query 2: Property search with filters
EXPLAIN ANALYZE
SELECT p.property_id, p.property_name, p.city, p.price_per_night,
       p.bedrooms, p.rating, COUNT(b.booking_id) as total_bookings
FROM properties p
LEFT JOIN bookings b ON p.property_id = b.property_id
WHERE p.city = 'New York'
AND p.property_type = 'apartment'
AND p.bedrooms >= 2
AND p.price_per_night BETWEEN 100 AND 300
AND p.is_available = true
GROUP BY p.property_id, p.property_name, p.city, p.price_per_night, p.bedrooms, p.rating
ORDER BY p.rating DESC
LIMIT 10;

-- Query 3: User booking history with date range
EXPLAIN ANALYZE
SELECT b.booking_id, p.property_name, p.city,
       b.check_in_date, b.check_out_date, b.total_amount,
       b.booking_status, b.payment_status
FROM bookings b
JOIN properties p ON b.property_id = p.property_id
WHERE b.user_id = 123
AND b.booking_date >= '2024-01-01'
AND b.booking_status IN ('confirmed', 'completed')
ORDER BY b.booking_date DESC;

-- Query 4: Property performance report
EXPLAIN ANALYZE
SELECT p.property_id, p.property_name, p.city, p.property_type,
       COUNT(b.booking_id) as total_bookings,
       SUM(b.total_amount) as total_revenue,
       AVG(b.total_amount) as avg_booking_value
FROM properties p
JOIN bookings b ON p.property_id = b.property_id
WHERE b.check_in_date BETWEEN '2024-01-01' AND '2024-12-31'
AND b.booking_status = 'completed'
GROUP BY p.property_id, p.property_name, p.city, p.property_type
ORDER BY total_revenue DESC
LIMIT 20;

-- Query 5: Active users with recent activity
EXPLAIN ANALYZE
SELECT u.user_id, u.username, u.email, u.status,
       COUNT(b.booking_id) as booking_count,
       MAX(b.booking_date) as last_booking_date
FROM users u
LEFT JOIN bookings b ON u.user_id = b.user_id
WHERE u.status = 'active'
AND u.last_login >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY u.user_id, u.username, u.email, u.status
HAVING COUNT(b.booking_id) > 0
ORDER BY last_booking_date DESC;


-- ----------------------------
-- Create Performance Comparison Table
-- ----------------------------
CREATE TABLE index_performance_comparison (
    test_id SERIAL PRIMARY KEY,
    query_name TEXT,
    query_description TEXT,
    execution_time_before INTERVAL,
    execution_time_after INTERVAL,
    planning_time_before INTERVAL,
    planning_time_after INTERVAL,
    total_cost_before FLOAT,
    total_cost_after FLOAT,
    index_scans_before BOOLEAN,
    index_scans_after BOOLEAN,
    performance_improvement_percent NUMERIC,
    test_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- -------------------------------
-- Run Performance Tests BEFORE Index Creation
-- -------------------------------
-- Record baseline performance
INSERT INTO index_performance_comparison (query_name, query_description, execution_time_before, planning_time_before, total_cost_before, index_scans_before)
SELECT 
    'User Authentication & Bookings',
    'User lookup with booking statistics',
    (EXPLAIN ANALYZE SELECT u.user_id, u.username, u.email, COUNT(b.booking_id) as total_bookings, MAX(b.booking_date) as last_booking FROM users u LEFT JOIN bookings b ON u.user_id = b.user_id WHERE u.email = 'user@example.com' GROUP BY u.user_id, u.username, u.email)::interval,
    (EXPLAIN ANALYZE SELECT u.user_id, u.username, u.email, COUNT(b.booking_id) as total_bookings, MAX(b.booking_date) as last_booking FROM users u LEFT JOIN bookings b ON u.user_id = b.user_id WHERE u.email = 'user@example.com' GROUP BY u.user_id, u.username, u.email)::interval,
    0, -- Placeholder for cost
    false -- Placeholder for index scans
FROM generate_series(1,1);


-- --------------------------------
-- Create the Recommended Indexes
-- --------------------------------
-- -----------------------------
-- Create User table indexes
-- -----------------------------
CREATE UNIQUE INDEX IF NOT EXISTS ux_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);
CREATE INDEX IF NOT EXISTS idx_users_last_login ON users(last_login);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone_number);

-- -----------------------------
-- Create Booking table indexes
-- -----------------------------
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_property_id ON bookings(property_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(booking_status);
CREATE INDEX IF NOT EXISTS idx_bookings_check_in ON bookings(check_in_date);
CREATE INDEX IF NOT EXISTS idx_bookings_check_out ON bookings(check_out_date);
CREATE INDEX IF NOT EXISTS idx_bookings_booking_date ON bookings(booking_date);
CREATE INDEX IF NOT EXISTS idx_bookings_payment_status ON bookings(payment_status);
CREATE INDEX IF NOT EXISTS idx_bookings_user_date ON bookings(user_id, booking_date);
CREATE INDEX IF NOT EXISTS idx_bookings_property_date ON bookings(property_id, check_in_date);
CREATE INDEX IF NOT EXISTS idx_bookings_date_status ON bookings(booking_date, booking_status);

-- -----------------------------
-- Create Property table indexes
-- -----------------------------
CREATE INDEX IF NOT EXISTS idx_properties_city ON properties(city);
CREATE INDEX IF NOT EXISTS idx_properties_country ON properties(country);
CREATE INDEX IF NOT EXISTS idx_properties_property_type ON properties(property_type);
CREATE INDEX IF NOT EXISTS idx_properties_price ON properties(price_per_night);
CREATE INDEX IF NOT EXISTS idx_properties_bedrooms ON properties(bedrooms);
CREATE INDEX IF NOT EXISTS idx_properties_rating ON properties(rating);
CREATE INDEX IF NOT EXISTS idx_properties_host_id ON properties(host_id);
CREATE INDEX IF NOT EXISTS idx_properties_availability ON properties(is_available);
CREATE INDEX IF NOT EXISTS idx_properties_location_search ON properties(city, property_type, price_per_night);
CREATE INDEX IF NOT EXISTS idx_properties_advanced_search ON properties(city, bedrooms, rating, is_available);


-- --------------------------------
-- Run Performance Tests AFTER Index Creation
-- --------------------------------
-- Update with after-index performance
UPDATE index_performance_comparison 
SET 
    execution_time_after = (EXPLAIN ANALYZE SELECT u.user_id, u.username, u.email, COUNT(b.booking_id) as total_bookings, MAX(b.booking_date) as last_booking FROM users u LEFT JOIN bookings b ON u.user_id = b.user_id WHERE u.email = 'user@example.com' GROUP BY u.user_id, u.username, u.email)::interval,
    planning_time_after = (EXPLAIN ANALYZE SELECT u.user_id, u.username, u.email, COUNT(b.booking_id) as total_bookings, MAX(b.booking_date) as last_booking FROM users u LEFT JOIN bookings b ON u.user_id = b.user_id WHERE u.email = 'user@example.com' GROUP BY u.user_id, u.username, u.email)::interval,
    index_scans_after = true,
    performance_improvement_percent = (
        (EXTRACT(EPOCH FROM execution_time_before) - EXTRACT(EPOCH FROM (EXPLAIN ANALYZE SELECT u.user_id, u.username, u.email, COUNT(b.booking_id) as total_bookings, MAX(b.booking_date) as last_booking FROM users u LEFT JOIN bookings b ON u.user_id = b.user_id WHERE u.email = 'user@example.com' GROUP BY u.user_id, u.username, u.email)::interval)) / 
        EXTRACT(EPOCH FROM execution_time_before) * 100
    )
WHERE query_name = 'User Authentication & Bookings';


-- ------------------------------------
-- Generate Performance Report
-- ------------------------------------
-- Final performance comparison report
SELECT 
    query_name,
    execution_time_before,
    execution_time_after,
    ROUND(EXTRACT(EPOCH FROM execution_time_before)::numeric, 3) as seconds_before,
    ROUND(EXTRACT(EPOCH FROM execution_time_after)::numeric, 3) as seconds_after,
    ROUND(performance_improvement_percent, 2) as improvement_percent,
    CASE 
        WHEN performance_improvement_percent > 50 THEN 'Excellent'
        WHEN performance_improvement_percent > 25 THEN 'Good'
        WHEN performance_improvement_percent > 10 THEN 'Moderate'
        ELSE 'Minimal'
    END as improvement_rating
FROM index_performance_comparison
ORDER BY improvement_percent DESC;

-- ---------------------------------
-- Check Index Usage Statistics
-- ---------------------------------
-- Monitor index usage after implementation
SELECT 
    schemaname,
    relname as table_name,
    indexrelname as index_name,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_all_indexes 
WHERE schemaname = 'public'
AND relname IN ('users', 'bookings', 'properties')
ORDER BY idx_scan DESC, relname;

-- Check for unused indexes
SELECT 
    schemaname,
    relname as table_name, 
    indexrelname as index_name,
    idx_scan as index_scans,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_all_indexes 
WHERE schemaname = 'public'
AND idx_scan = 0
AND relname IN ('users', 'bookings', 'properties')
ORDER BY pg_relation_size(indexrelid) DESC;
