
-- Insert Users
INSERT INTO Users (user_id, name, email, password_hash, role, created_at) VALUES
(1, 'Alice Johnson', 'alice@example.com', 'hashed_pw1', 'customer', NOW()),
(2, 'Bob Smith', 'bob@example.com', 'hashed_pw2', 'customer', NOW()),
(3, 'John Doe', 'john@example.com', 'hashed_pw3', 'owner', NOW()),
(4, 'Admin User', 'admin@example.com', 'hashed_pw4', 'admin', NOW());

-- Insert Properties
INSERT INTO Properties (property_id, owner_id, title, description, location, price_per_night, created_at) VALUES
(1, 3, 'Cozy Apartment in Downtown', 'A fully furnished 2-bedroom apartment in the city center.', 'Toronto, ON', 120.00, NOW()),
(2, 3, 'Beachfront Villa', 'Luxury villa with private pool and ocean view.', 'Vancouver, BC', 350.00, NOW()),
(3, 3, 'Mountain Cabin Retreat', 'Rustic cabin with fireplace and hiking trails nearby.', 'Banff, AB', 200.00, NOW());

-- Insert Bookings
INSERT INTO Bookings (booking_id, user_id, property_id, check_in, check_out, status, created_at) VALUES
(1, 1, 1, '2025-09-15', '2025-09-20', 'confirmed', NOW()),
(2, 2, 2, '2025-10-05', '2025-10-10', 'pending', NOW()),
(3, 1, 3, '2025-11-01', '2025-11-05', 'cancelled', NOW());

-- Insert Payments
INSERT INTO Payments (payment_id, booking_id, amount, payment_method, payment_status, created_at) VALUES
(1, 1, 600.00, 'credit_card', 'completed', NOW()), -- 5 nights * 120
(2, 2, 1750.00, 'paypal', 'pending', NOW()),       -- 5 nights * 350
(3, 3, 800.00, 'credit_card', 'refunded', NOW());  -- 4 nights * 200

-- Insert Reviews
INSERT INTO Reviews (review_id, booking_id, user_id, property_id, rating, comment, created_at) VALUES
(1, 1, 1, 1, 5, 'Amazing stay! Very clean and close to downtown.', NOW()),
(2, 2, 2, 2, 4, 'Beautiful villa, but check-in was delayed.', NOW());

-- Insert Amenities
INSERT INTO Amenities (amenity_id, name) VALUES
(1, 'WiFi'),
(2, 'Parking'),
(3, 'Swimming Pool'),
(4, 'Air Conditioning'),
(5, 'Kitchen');

-- Link Property Amenities
INSERT INTO PropertyAmenities (property_id, amenity_id) VALUES
(1, 1), (1, 4), (1, 5), -- Apartment
(2, 1), (2, 2), (2, 3), (2, 4), (2, 5), -- Villa
(3, 1), (3, 2), (3, 5); -- Cabin
