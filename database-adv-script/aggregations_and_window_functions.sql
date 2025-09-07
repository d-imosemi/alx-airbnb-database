 ---------------------------------
-- A query to find the total number of bookings made by each user, using the COUNT function and GROUP BY clause.
-- This includes users with no bookings (total_bookings = 0).
-- When booking totals are equal, rows are ordered by user_id in ascending order (default).
-- ---------------------------------
SELECT
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(b.booking_id) AS total_bookings
FROM
    users u
LEFT JOIN
    bookings b ON b.user_id = u.user_id
GROUP BY
    u.user_id, u.first_name, u.last_name, u.email
ORDER BY
    total_bookings DESC, u.user_id;


-- ---------------------------------
-- Use a window function (ROW_NUMBER, RANK) to rank properties based on the total number of bookings they have received.
-- ROW_NUMBER gives a unique sequence (breaks ties by property_id).
-- RANK gives the same rank to ties and skips subsequent ranks (e.g., 1, 1, 3).
-- ---------------------------------
WITH property_counts AS (
  SELECT
    p.property_id,
    p.title,
    COUNT(b.booking_id) AS total_bookings
  FROM properties p
  LEFT JOIN bookings b ON b.property_id = p.property_id
  GROUP BY p.property_id, p.title
)
SELECT
  property_id,
  title,
  total_bookings,
  ROW_NUMBER() OVER (ORDER BY total_bookings DESC, property_id) AS row_number_rank,
  RANK()       OVER (ORDER BY total_bookings DESC)              AS rank
FROM property_counts
ORDER BY total_bookings DESC, property_id;
