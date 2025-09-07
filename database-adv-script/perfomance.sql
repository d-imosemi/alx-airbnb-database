-- -----------------------
-- An initial query that retrieves all bookings along with the user details, property details, and payment details.
-- Keeps all bookings, even if a payment hasn’t been recorded yet.
-- -----------------------
SELECT
  b.booking_id,
  b.user_id,
  b.property_id,
  b.booking_date,
  b.check_in_date,
  b.check_out_date,
  b.booking_status,

  u.first_name,
  u.last_name,
  u.email,
  u.phone_number,

  p.title AS property_title,
  p.city,
  p.country,
  p.price_per_night,

  pay.payment_id,
  pay.payment_status,
  pay.amount,
  pay.currency,
  pay.payment_method,
  pay.transaction_ref,
  pay.paid_at
FROM bookings   AS b
JOIN users      AS u  ON u.user_id = b.user_id
JOIN properties AS p  ON p.property_id = b.property_id
LEFT JOIN payments AS pay
  ON pay.booking_id = b.booking_id
  AND pay.payment_status = 'paid'           -- AND in JOIN to keep only paid payment rows
WHERE
  b.booking_status IN ('confirmed','completed')  -- AND in WHERE
  AND b.booking_date BETWEEN :start_date AND :end_date
  AND p.city = :city
ORDER BY b.booking_date DESC, b.booking_id;

-- ---------------------------
-- Analyze the query’s performance using EXPLAIN
-- ---------------------------


-- First, let's check the table statistics
SELECT 
    relname as table_name,
    n_live_tup as row_count,
    pg_size_pretty(pg_total_relation_size(relid)) as total_size,
    pg_size_pretty(pg_relation_size(relid)) as table_size
FROM pg_stat_user_tables 
WHERE relname IN ('bookings', 'users', 'properties', 'payments');

-- Now analyze the query with full details
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT 
    SELECT
  b.booking_id,
  b.user_id,
  b.property_id,
  b.booking_date,
  b.check_in_date,
  b.check_out_date,
  b.booking_status,

  u.first_name,
  u.last_name,
  u.email,
  u.phone_number,

  p.title AS property_title,
  p.city,
  p.country,
  p.price_per_night,

  pay.payment_id,
  pay.payment_status,
  pay.amount,
  pay.currency,
  pay.payment_method,
  pay.transaction_ref,
  pay.paid_at
FROM bookings   AS b
JOIN users      AS u  ON u.user_id = b.user_id
JOIN properties AS p  ON p.property_id = b.property_id
LEFT JOIN payments AS pay
  ON pay.booking_id = b.booking_id
  AND pay.payment_status = 'paid'           -- AND in JOIN to keep only paid payment rows
WHERE
  b.booking_status IN ('confirmed','completed')  -- AND in WHERE
  AND b.booking_date BETWEEN :start_date AND :end_date
  AND p.city = :city
ORDER BY b.booking_date DESC, b.booking_id;


-- --------------------------
-- Refactor the query to reduce execution time, such as reducing unnecessary joins or using indexing.
-- --------------------------

-- --------------------------
-- Refactored Query 1: With Pagination and Selective Columns
-- Optimized with pagination, selective columns, and proper indexing
-- --------------------------
SELECT 
    b.booking_id,
    b.booking_date,
    b.check_in_date,
    b.check_out_date,
    b.total_amount,
    b.booking_status,
    b.payment_status,
    u.user_id,
    u.username,
    u.email,
    u.first_name || ' ' || u.last_name as user_full_name,
    p.property_id,
    p.property_name,
    p.property_type,
    p.city || ', ' || p.country as property_location,
    p.price_per_night,
    pay.payment_method,
    pay.payment_date,
    pay.amount as payment_amount
FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id
INNER JOIN properties p ON b.property_id = p.property_id
LEFT JOIN LATERAL (
    SELECT payment_method, payment_date, amount
    FROM payments 
    WHERE booking_id = b.booking_id 
    ORDER BY payment_date DESC 
    LIMIT 1
) pay ON true
WHERE b.booking_date >= CURRENT_DATE - INTERVAL '6 months'
ORDER BY b.booking_date DESC
LIMIT 100 OFFSET 0;

-- -----------------------
-- Refactored Query 2: CTE for better readability
-- Using CTE for better organization and potential performance benefits
-- -----------------------
WITH recent_bookings AS (
    SELECT 
        booking_id,
        user_id,
        property_id,
        booking_date,
        check_in_date,
        check_out_date,
        total_amount,
        booking_status,
        payment_status
    FROM bookings
    WHERE booking_date >= CURRENT_DATE - INTERVAL '6 months'
),
latest_payments AS (
    SELECT DISTINCT ON (booking_id)
        booking_id,
        payment_method,
        payment_date,
        amount
    FROM payments
    ORDER BY booking_id, payment_date DESC
)
SELECT 
    b.booking_id,
    b.booking_date,
    b.check_in_date,
    b.check_out_date,
    b.total_amount,
    b.booking_status,
    b.payment_status,
    u.user_id,
    u.username,
    u.email,
    CONCAT(u.first_name, ' ', u.last_name) as user_full_name,
    p.property_id,
    p.property_name,
    p.property_type,
    CONCAT(p.city, ', ', p.country) as property_location,
    p.price_per_night,
    pay.payment_method,
    pay.payment_date,
    pay.amount as payment_amount
FROM recent_bookings b
INNER JOIN users u ON b.user_id = u.user_id
INNER JOIN properties p ON b.property_id = p.property_id
LEFT JOIN latest_payments pay ON b.booking_id = pay.booking_id
ORDER BY b.booking_date DESC
LIMIT 100;


-- -----------------------
-- Performance Optimization Indexes
-- Essential indexes for the optimized queries
-- -----------------------
CREATE INDEX IF NOT EXISTS idx_bookings_date_range ON bookings(booking_date) 
WHERE booking_date >= CURRENT_DATE - INTERVAL '1 year';

CREATE INDEX IF NOT EXISTS idx_bookings_user_property ON bookings(user_id, property_id);

CREATE INDEX IF NOT EXISTS idx_payments_booking_date ON payments(booking_id, payment_date);

CREATE INDEX IF NOT EXISTS idx_users_name_email ON users(first_name, last_name, email);

CREATE INDEX IF NOT EXISTS idx_properties_city_country ON properties(city, country);
