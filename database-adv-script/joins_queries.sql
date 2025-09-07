-- ---------------------------------
-- Use an INNER JOIN to retrieve all bookings and the respective users who made those bookings.
-- Returns only rows with related data in both tables.
-- ---------------------------------
SELECT 
    b.booking_id, 
    b.start_date, 
    b.end_date,
    b.status,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email
FROM 
    bookings b
INNER JOIN 
    users u ON b.user_id = u.user_id
ORDER BY 
    b.booking_id;

-- ---------------------------------
-- Use a LEFT JOIN to retrieve all properties and their reviews, including properties that have no reviews.
-- Gets all properties regardless of review presence.
-- If a property has no reviews, you'll still get one row for the property, with review_id, rating, comment, and review_date set to NULL.
-- Reviews are shown in order of descending creation dates.
-- ---------------------------------
SELECT 
    p.property_id,
    p.title AS property_title,
    p.description,
    r.review_id,
    r.rating,
    r.comment,
    r.created_at AS review_date
FROM 
    properties p
LEFT JOIN 
    reviews r ON p.property_id = r.property_id
ORDER BY 
    p.property_id, r.created_at DESC;

-- ---------------------------------
-- Use a FULL OUTER JOIN to retrieve all users and all bookings, even if the user has no booking or a booking is not linked to a user.
-- All users who have made bookings and all of their bookings. This is the same result an INNER JOIN would give.
-- For users who exist in the users table but have no corresponding records in the bookings table, the columns from the bookings table (booking_id, start_date, end_date, etc.) will be filled with NULL.
-- For bookings that exist in the bookings table but have a user_id that does not match any user in the users table (e.g., due to a data error or a user being deleted), the columns from the users table (user_id, first_name, last_name, etc.) will be filled with NULL.
-- ---------------------------------
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status,
    b.property_id
FROM 
    users u
FULL OUTER JOIN 
    bookings b ON u.user_id = b.user_id
ORDER BY 
    COALESCE(u.user_id, -1), -- Puts users with no bookings first
    b.booking_id;
