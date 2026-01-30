# Ocean View Resort - Database Setup Guide

## 📋 Database Information

- **Database Name:** `ocean_view_resort`
- **Database Engine:** MySQL 8.0+
- **Character Set:** UTF8MB4
- **Collation:** utf8mb4_unicode_ci

---

## 🗄️ Database Schema

### Tables

1. **users** - User accounts (Admin, Staff, Guest)
2. **room_types** - Room categories with pricing
3. **rooms** - Individual hotel rooms
4. **reservations** - Booking records
5. **payments** - Payment transactions
6. **audit_log** - System activity logs

### Views

1. **v_active_reservations** - Active bookings with guest/room details
2. **v_room_availability** - Current room availability status
3. **v_revenue_summary** - Revenue breakdown by date and method

---

## 🚀 Installation Instructions

### Option 1: Using MySQL Command Line

```bash
# Login to MySQL
mysql -u root -p

# Run the initialization script
source /path/to/init_database.sql

# OR run schema and data separately
source /path/to/schema.sql
source /path/to/sample_data.sql
```

### Option 2: Using MySQL Workbench

1. Open MySQL Workbench
2. Connect to your MySQL server
3. Go to **File > Run SQL Script**
4. Select `init_database.sql`
5. Click **Run**

### Option 3: Using phpMyAdmin

1. Login to phpMyAdmin
2. Click on **Import** tab
3. Choose file: `init_database.sql`
4. Click **Go**

### Option 4: Manual Execution

```bash
# Execute schema
mysql -u root -p < schema.sql

# Execute sample data
mysql -u root -p ocean_view_resort < sample_data.sql
```

---

## 👥 Default User Accounts

### Login Credentials

**Password for ALL users:** `password123`  
**SHA-256 Hash:** `ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f`

### Admin Account
- **Username:** admin
- **Full Name:** System Administrator
- **Email:** admin@oceanview.com
- **Role:** ADMIN

### Staff Accounts
| Username | Full Name | Email | Role |
|----------|-----------|-------|------|
| staff1 | John Smith | john.smith@oceanview.com | STAFF |
| staff2 | Sarah Williams | sarah.williams@oceanview.com | STAFF |

### Guest Accounts
| Username | Full Name | Email | Role |
|----------|-----------|-------|------|
| guest1 | Michael Johnson | michael.j@email.com | GUEST |
| guest2 | Emily Brown | emily.brown@email.com | GUEST |
| guest3 | David Wilson | david.wilson@email.com | GUEST |
| guest4 | Jessica Taylor | jessica.t@email.com | GUEST |
| guest5 | Robert Anderson | robert.a@email.com | GUEST |

---

## 🏨 Sample Data Included

### Room Types (5 types)
- Standard Room - LKR 5,000/night (Capacity: 2)
- Deluxe Room - LKR 8,000/night (Capacity: 2)
- Family Suite - LKR 12,000/night (Capacity: 4)
- Deluxe Suite - LKR 15,000/night (Capacity: 2)
- Presidential Suite - LKR 25,000/night (Capacity: 4)

### Rooms (30 rooms)
- **Floor 1:** 10 Standard Rooms (101-110)
- **Floor 2:** 15 Deluxe Rooms & Family Suites (201-215)
- **Floor 3:** 5 Suites (301-305)

### Room Status Distribution
- Available: 24 rooms
- Occupied: 5 rooms
- Maintenance: 1 room

### Reservations (11 bookings)
- Checked-In: 3
- Confirmed: 4
- Pending: 1
- Checked-Out: 2
- Cancelled: 1

### Payments (8 transactions)
- Completed: 7 payments
- Pending: 1 payment
- Total Revenue: LKR 145,000

---

## 🔧 Configuration

### Update Database Connection

Edit `src/main/java/com/oceanview/util/DatabaseConnection.java`:

```java
private static final String DB_URL = "jdbc:mysql://localhost:3306/ocean_view_resort";
private static final String DB_USER = "root";
private static final String DB_PASSWORD = "your_password_here";
```

### Create Database User (Recommended)

```sql
-- Create dedicated user for the application
CREATE USER 'oceanview_user'@'localhost' IDENTIFIED BY 'secure_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON ocean_view_resort.* TO 'oceanview_user'@'localhost';

-- Reload privileges
FLUSH PRIVILEGES;
```

---

## 📊 Useful Queries

### Check Active Reservations
```sql
SELECT * FROM v_active_reservations;
```

### Check Room Availability
```sql
SELECT * FROM v_room_availability WHERE status = 'AVAILABLE';
```

### Get Today's Check-ins
```sql
SELECT * FROM reservations 
WHERE check_in_date = CURDATE() AND status = 'CONFIRMED';
```

### Get Today's Check-outs
```sql
SELECT * FROM reservations 
WHERE check_out_date = CURDATE() AND status = 'CHECKED_IN';
```

### Calculate Total Revenue
```sql
SELECT SUM(amount) AS total_revenue 
FROM payments 
WHERE payment_status = 'COMPLETED';
```

### Occupancy Rate
```sql
SELECT 
    COUNT(*) AS total_rooms,
    SUM(CASE WHEN status = 'OCCUPIED' THEN 1 ELSE 0 END) AS occupied_rooms,
    ROUND((SUM(CASE WHEN status = 'OCCUPIED' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS occupancy_rate
FROM rooms;
```

---

## 🗑️ Database Management

### Backup Database
```bash
mysqldump -u root -p ocean_view_resort > backup_$(date +%Y%m%d).sql
```

### Restore Database
```bash
mysql -u root -p ocean_view_resort < backup_20260128.sql
```

### Drop Database (CAUTION!)
```sql
DROP DATABASE IF EXISTS ocean_view_resort;
```

### Reset Database
```bash
mysql -u root -p < init_database.sql
```

---

## 🔍 Troubleshooting

### Issue: "Access denied for user"
**Solution:** Check MySQL username and password in DatabaseConnection.java

### Issue: "Database already exists"
**Solution:** Drop the database first or modify the script to skip creation

### Issue: "Foreign key constraint fails"
**Solution:** Ensure you run schema.sql before sample_data.sql

### Issue: "Unknown database"
**Solution:** Make sure the database is created: `CREATE DATABASE ocean_view_resort;`

### Issue: "Table doesn't exist"
**Solution:** Run schema.sql to create all tables first

---

## 📞 Support

For issues or questions:
- Check application logs in Tomcat
- Verify MySQL is running: `sudo systemctl status mysql`
- Check MySQL error log: `/var/log/mysql/error.log`

---

## 📝 Database Schema Diagram

```
┌─────────────┐
│    users    │
└──────┬──────┘
       │
       ├─────────┬──────────┐
       │         │          │
       ▼         ▼          ▼
┌──────────┐ ┌──────────────┐ ┌──────────┐
│audit_log │ │ reservations │ │ payments │
└──────────┘ └───────┬──────┘ └────┬─────┘
                     │             │
              ┌──────┴───┐         │
              │          │         │
              ▼          ▼         │
         ┌───────┐ ┌────────────┐ │
         │ rooms │ │ room_types │ │
         └───┬───┘ └────────────┘ │
             │                     │
             └─────────────────────┘
```

---

## ✅ Verification Checklist

After installation, verify:
- [ ] Database `ocean_view_resort` exists
- [ ] All 6 tables created successfully
- [ ] 8 users inserted (1 admin, 2 staff, 5 guests)
- [ ] 5 room types created
- [ ] 30 rooms inserted
- [ ] 11 sample reservations created
- [ ] 8 payment records inserted
- [ ] All foreign key constraints working
- [ ] Views created successfully
- [ ] Can login with admin credentials

---

**Database Version:** 1.0.0  
**Last Updated:** January 28, 2026  
**Maintained by:** Ocean View Resort Development Team
