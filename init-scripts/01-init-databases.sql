-- Initialize all required databases for Airline Management System

-- Create Flights database (used by Flights and Booking services)
CREATE DATABASE IF NOT EXISTS Flights CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create API Gateway database
CREATE DATABASE IF NOT EXISTS api_gateway CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create Notification database
CREATE DATABASE IF NOT EXISTS notification_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant privileges (optional, root already has all privileges)
GRANT ALL PRIVILEGES ON Flights.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON api_gateway.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON notification_db.* TO 'root'@'%';

FLUSH PRIVILEGES;

-- Show created databases
SHOW DATABASES;
