# Index Optimization – ALX Airbnb Database Project

This task demonstrates how **indexes** can be used to improve query performance in the Airbnb database schema.
---

# Step 1: Identify high-usage columns
- ** From the `schema`: **
  ## User table
  -  email (often used for lookups)
  -  user_id (foreign key in Booking, Property, Review)
  
  ## Property table
  -  property_id (foreign key in Booking, Review)
  -  location (likely used for searches/filtering)

  ## Booking table
  -  user_id (foreign key from User)
  -  property_id (foreign key from Property)
  -  status (could be filtered often: WHERE status = 'Confirmed')


---

## 1. Indexes Created
The following indexes were added (see `database_index.sql`):

- **User Table**
  - `idx_user_email` → optimizes login and lookups by email.
- **Booking Table**
  - `idx_booking_user_id` → speeds up joins with the `User` table.
  - `idx_booking_property_id` → speeds up joins with the `Property` table.
  - `idx_booking_user_property` → improves performance when filtering by both user and property.
  - `idx_booking_date` → useful for date range searches.
- **Property Table**
  - `idx_property_location` → optimizes queries filtering/searching by location.

---

## 2. Measuring Performance
I tested queries before and after adding indexes using `EXPLAIN`.


#### Example 1: Booking Join with User
```sql
EXPLAIN SELECT * 
FROM Booking b
JOIN User u ON b.user_id = u.user_id
WHERE b.status = 'Confirmed';



EXPLAIN SELECT * 
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
WHERE p.location = 'Lagos';
**Common JOIN patterns that need indexing:**
```sql
-- User-Booking joins
SELECT * FROM users u
JOIN bookings b ON u.user_id = b.user_id  -- Needs index on bookings.user_id

-- Property-Booking joins  
SELECT * FROM properties p
JOIN bookings b ON p.property_id = b.property_id  -- Needs index on bookings.property_id

-- User-Property joins (for hosts)
SELECT * FROM users u
JOIN properties p ON u.user_id = p.host_id  -- Needs index on properties.host_id
```

## Monitoring and Maintenance

**Check existing indexes:**
```sql
SELECT * FROM pg_indexes WHERE tablename = 'bookings';
```

**Monitor query performance:**
```sql
-- Enable query logging for slow queries
-- Analyze EXPLAIN plans for frequently run queries
```

**Consider partial indexes for better performance:**
```sql
-- Index only active bookings
CREATE INDEX idx_bookings_active ON bookings(booking_status) 
WHERE booking_status IN ('confirmed', 'pending');

-- Index only available properties  
CREATE INDEX idx_properties_available ON properties(is_available) 
WHERE is_available = true;
```

## Priority Order for Index Creation

1. **Primary keys** (should already be indexed)
2. **Foreign keys** (user_id, property_id in bookings table)
3. **Date columns** used in range queries (booking_date, check_in_date)
4. **Status columns** used in WHERE clauses
5. **Search columns** (email, city, property_type)
6. **Composite indexes** for common query patterns

Start with the most frequently queried columns and monitor performance before adding additional indexes, as each index adds overhead to write operations.
