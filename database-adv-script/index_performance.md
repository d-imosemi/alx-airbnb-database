# High Usage Columns in the Database tables
Here are the high-usage columns to focus on, based on typical AirBnB-like queries (JOINs on user_id/property_id, filters by status/dates, ORDER BY on names/titles, WHERE on emails/dates):

## 1. Users table

- user_id (PK): used in JOINs to bookings; sometimes in ORDER BY.
- email: frequent WHERE lookups (login/uniqueness).
- last_name, first_name: used in ORDER BY; sometimes filtered (search).
- created_at: filtered or sorted by signup date.
- status/active: filtered to exclude suspended/inactive users.

### User Table High-Usage Columns

**Columns likely used in WHERE clauses:**
```sql
-- Authentication and lookups
WHERE email = 'user@example.com'
WHERE last_name = 'john_doe'
WHERE user_id = 123
WHERE status = 'active'

-- Date-based queries
WHERE created_at >= '2024-01-01'
WHERE last_login >= CURRENT_DATE - INTERVAL '30 days'
```

--- 
## 2. Bookings table

- booking_id (PK): primary key access and sorting in reports.
- user_id (FK): JOIN to users; frequent WHERE filter (user’s bookings).
- property_id (FK): JOIN to properties; frequent WHERE/GROUP BY (per-property stats).
- start_date, end_date: WHERE date-range searches and availability checks; ORDER BY.
- created_at: recent activity feeds, audits; ORDER BY.
- status: WHERE filters (confirmed/cancelled/completed).
- price_total or nightly_rate (if present): reporting/filtering.
- payment_status: WHERE filters (unpaid, partial, paid).

### Booking Table High-Usage Columns

**Columns likely used in WHERE/JOIN clauses:**
```sql
-- User and property relationships
WHERE user_id = 456
WHERE property_id = 789
WHERE status IN ('confirmed', 'completed')

-- Date range queries (very common!)
WHERE start_date BETWEEN '2024-01-01' AND '2024-01-31'
WHERE end_out_date >= CURRENT_DATE
WHERE booking_date >= CURRENT_DATE - INTERVAL '90 days'

-- Financial queries
WHERE price_total > 1000
WHERE payment_status = 'paid'
```

---
## 3. Properties table

- property_id (PK): JOIN to bookings and reviews; sometimes ORDER BY.
- title: used in ORDER BY/search results.
- host_id (FK to users): JOINs for host dashboards.
- city_id/location fields (city, state, country or geohash): frequent WHERE filters.
- price/nightly_rate: filtered/sorted in search.
- bedrooms/capacity/property_type: faceted filters.
- created_at: newest listings sort/filter.
- active/status: WHERE to hide inactive/unlisted.

### Property Table High-Usage Columns

**Columns likely used in WHERE clauses:**
```sql
-- Location-based queries
WHERE city = 'New York'
WHERE country = 'USA'
WHERE zip_code = '10001'

-- Filtering and search
WHERE property_type = 'apartment'
WHERE price_per_night BETWEEN 50 AND 200
WHERE bedrooms >= 2
WHERE rating >= 4.0
WHERE active = true

-- Host relationships
WHERE host_id = 123
```

---
## Indexing tips (to improve performance)

- Ensure all PKs and FKs are indexed:
  - bookings(user_id), bookings(property_id)
  - properties(host_id), properties(city_id)
  - users(email) UNIQUE
- Common composites:
  - bookings(property_id, start_date) for availability and per-property ranges.
  - bookings(user_id, start_date DESC) for user booking history.
  - bookings(property_id, created_at DESC) for recent bookings per property.
  - users(last_name, first_name) if you sort/filter by names often.
  - properties(city_id, price) for search filtering; properties(active, city_id) if you filter by active first.
- ORDER BY alone rarely benefits from an index unless paired with a selective WHERE or the index fully covers the query.
- Avoid over-indexing; monitor actual query plans and add indexes where they reduce cost.


## JOIN Operations Analysis

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
