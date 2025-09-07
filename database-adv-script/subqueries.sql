-- A query to find all properties where the average rating is greater than 4.0 using a subquery.
-- -----------------------------
SELECT
    p.property_id,
    p.title,
    AVG(r.rating) as avg_rating
FROM
    properties p
JOIN
    reviews r ON p.property_id = r.property_id
GROUP BY
    p.property_id, p.title
HAVING
    AVG(r.rating) > 4.0;

-- -----------------------------
-- A Correlated subquery to find users who have made more than 3 bookings (Emphasizes the subquery, but less efficient for large data).
-- Using GROUP BY and HAVING (Recommended & Efficient).
-- -----------------------------
SELECT 
    p.property_id,
    p.title AS property_title,
    u.user_id,
    u.first_name,
    u.last_name
FROM 
    properties p
JOIN 
    bookings b ON p.property_id = b.property_id
JOIN 
    users u ON b.user_id = u.user_id
WHERE 
    p.property_id IN (
        SELECT r.property_id
        FROM reviews r
        GROUP BY r.property_id
        HAVING AVG(r.rating) > 4.0
    )
    AND
    (
        SELECT COUNT(*)
        FROM bookings b2
        WHERE
            b2.user_id = u.user_id
            AND b2.property_id = p.property_id
    ) > 3
GROUP BY
    p.property_id, p.title, u.user_id, u.first_name, u.last_name
ORDER BY 
    p.title, u.last_name
