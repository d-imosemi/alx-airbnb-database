### Index Performance Analysis

#### 1. High-Usage Columns
- **properties.location** → Property search.
- **properties.name** → Search/autocomplete features.

#### 2. Create Indexes
```sql
CREATE INDEX idx_properties_location ON properties(location);
CREATE INDEX idx_properties_name ON properties(name);
```

#### 3. Performance Measurement
**EXPLAIN ANALYZE** before and after creating the indexes.
**Example Query**
```sql
EXPLAIN ANALYZE
SELECT u.first_name, COUNT(b.booking_id) AS total_bookings
FROM users u
JOIN bookings b ON u.user_id = b.user_id
GROUP BY u.first_name
ORDER BY total_bookings DESC;
```
...
