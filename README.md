# 🏨 Ocean View Resort - Hotel Booking System

A comprehensive hotel management system built with Java EE, featuring role-based access control for Admins, Staff, and Guests. This web application streamlines hotel operations including room reservations, check-ins/check-outs, billing, and reporting.

[![Java](https://img.shields.io/badge/Java-11-orange.svg)](https://www.oracle.com/java/)
[![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-5.0-blue.svg)](https://jakarta.ee/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue.svg)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 📋 Table of Contents
updated by shaliha zarook
- [Features](#-features)
- [System Architecture](#-system-architecture)
- [Technologies Used](#-technologies-used)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Database Setup](#-database-setup)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [User Roles](#-user-roles)
- [Project Structure](#-project-structure)
- [API Documentation](#-api-documentation)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

### 🔐 User Management
- **Role-Based Access Control**: Three distinct user roles (Admin, Staff, Guest)
- **Secure Authentication**: SHA-256 password hashing
- **User Registration**: Self-service registration for guests
- **Session Management**: Secure session handling with timeout
- **Profile Management**: Users can update their personal information

### 🏠 Room Management
- **Room Types**: Manage different room categories (Standard, Deluxe, Suite, etc.)
- **Room Inventory**: Track individual rooms with unique room numbers
- **Room Status**: Monitor room availability (Available, Occupied, Maintenance)
- **Dynamic Pricing**: Configurable price per night for each room type
- **Room Amenities**: Detailed amenities description for each room type

### 📅 Reservation System
- **Online Booking**: Guests can make reservations through the web interface
- **Availability Check**: Real-time room availability verification
- **Reservation Management**: Create, view, update, and cancel reservations
- **Multiple Status Tracking**: PENDING, CONFIRMED, CHECKED_IN, CHECKED_OUT, CANCELLED
- **Special Requests**: Guests can add special requirements to their bookings
- **Automatic Pricing**: System calculates total amount based on stay duration and room type

### 🏨 Front Desk Operations
- **Check-In Management**: Staff can process guest check-ins
- **Check-Out Management**: Handle guest departures and room status updates
- **Room Status Dashboard**: Real-time view of all room statuses
- **Guest Information**: Quick access to guest details and reservation history

### 💰 Billing & Payments
- **Payment Processing**: Record and track payments for reservations
- **Multiple Payment Methods**: Support for Cash, Credit Card, Debit Card, Online Transfer
- **Payment Status Tracking**: Monitor PENDING, COMPLETED, FAILED, REFUNDED payments
- **Billing History**: Complete payment records for each reservation

### 📊 Reports & Analytics
- **Occupancy Reports**: Track room occupancy rates
- **Revenue Reports**: Monitor financial performance
- **Reservation Statistics**: Analyze booking patterns
- **Custom Date Ranges**: Generate reports for specific periods

## 🏗️ System Architecture

The application follows a **layered MVC (Model-View-Controller)** architecture:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│    (JSP Views + Servlets/Controllers)   │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│         Service/Business Layer          │
│   (Business Logic & Validation)         │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│         Data Access Layer (DAO)         │
│   (Database Operations & CRUD)          │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│         Database Layer (MySQL)          │
│   (Data Persistence)                    │
└─────────────────────────────────────────┘
```

### Design Patterns Used
- **Singleton Pattern**: Database connection management
- **Factory Pattern**: DAO object creation (DAOFactory)
- **MVC Pattern**: Separation of concerns
- **DAO Pattern**: Data access abstraction

## 🛠️ Technologies Used

### Backend
- **Java 11**: Core programming language
- **Jakarta EE 5.0**: Enterprise Java framework
- **Jakarta Servlet API**: Web application framework
- **Jakarta Server Pages (JSP)**: Dynamic web pages
- **JSTL 2.0**: JSP Standard Tag Library

### Database
- **MySQL 8.0+**: Relational database management system
- **JDBC**: Java Database Connectivity

### Build & Deployment
- **Apache Maven 3.x**: Dependency management and build automation
- **Apache Tomcat 10.x** (or compatible Jakarta EE server): Application server

### Development Tools
- **Git**: Version control
- **IntelliJ IDEA / Eclipse / NetBeans**: IDE (any Java IDE)

## 📦 Prerequisites

Before you begin, ensure you have the following installed:

1. **Java Development Kit (JDK) 11 or higher**
   ```bash
   java -version
   ```

2. **Apache Maven 3.6 or higher**
   ```bash
   mvn -version
   ```

3. **MySQL Server 8.0 or higher**
   ```bash
   mysql --version
   ```

4. **Apache Tomcat 10.x** (or compatible Jakarta EE 9+ server)

5. **Git** (for cloning the repository)
   ```bash
   git --version
   ```

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/HamdhiHilmy/My-first.git
cd My-first
```

### 2. Configure Database Connection

Edit the database configuration file:

**File**: `src/main/java/com/oceanview/util/DatabaseConnection.java`

Update the following constants with your MySQL credentials:

```java
private static final String DB_URL = "jdbc:mysql://localhost:3306/ocean_view_resort?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
private static final String DB_USER = "your_mysql_username";
private static final String DB_PASSWORD = "your_mysql_password";
```

> ⚠️ **Security Note**: For production deployments, use environment variables or external configuration files instead of hardcoding credentials.

### 3. Build the Project

```bash
mvn clean install
```

This command will:
- Download all dependencies
- Compile the source code
- Run tests
- Package the application as a WAR file

### 4. Deploy to Tomcat

#### Option A: Manual Deployment
1. Copy the generated WAR file to Tomcat's webapps directory:
   ```bash
   cp target/OceanViewResort.war /path/to/tomcat/webapps/
   ```

2. Start Tomcat:
   ```bash
   /path/to/tomcat/bin/startup.sh   # Linux/Mac
   /path/to/tomcat/bin/startup.bat  # Windows
   ```

#### Option B: IDE Deployment
- Configure your IDE to deploy to Tomcat
- Run the application from your IDE

### 5. Access the Application

Open your web browser and navigate to:
```
http://localhost:8080/OceanViewResort/
```

## 🗄️ Database Setup

### 1. Create the Database

Run the schema creation script:

```bash
mysql -u root -p < src/main/resources/database/schema.sql
```

This will create:
- Database: `ocean_view_resort`
- Tables: `users`, `room_types`, `rooms`, `reservations`, `payments`
- Views: For reporting and analytics
- Indexes: For optimized queries

### 2. Load Sample Data (Optional)

```bash
mysql -u root -p ocean_view_resort < src/main/resources/database/sample_data.sql
```

### 3. Database Schema Overview

#### Main Tables

| Table | Description |
|-------|-------------|
| `users` | Stores user accounts (Admin, Staff, Guest) |
| `room_types` | Defines room categories with pricing |
| `rooms` | Individual room inventory |
| `reservations` | Booking records |
| `payments` | Payment transactions |

#### Relationships

```
users (1) ──→ (*) reservations
rooms (1) ──→ (*) reservations
room_types (1) ──→ (*) rooms
reservations (1) ──→ (*) payments
```

### 4. Default Users

After loading sample data, you can login with:

| Role | Username | Password | Description |
|------|----------|----------|-------------|
| Admin | admin | admin123 | Full system access |
| Staff | staff | staff123 | Front desk operations |
| Guest | guest | guest123 | Booking and reservations |

> 🔒 **Security Note**: Change these default passwords immediately in production!

## ⚙️ Configuration

### Session Timeout

Default session timeout is 30 minutes. To change this, edit `src/main/webapp/WEB-INF/web.xml`:

```xml
<session-config>
    <session-timeout>30</session-timeout> <!-- Minutes -->
</session-config>
```

### Database Connection Pool (Optional)

For production, consider implementing connection pooling using HikariCP or Apache DBCP.

### HTTPS Configuration

For production deployments:
1. Obtain an SSL certificate
2. Configure Tomcat's `server.xml` for HTTPS
3. Update cookie security in `web.xml`:
   ```xml
   <cookie-config>
       <http-only>true</http-only>
       <secure>true</secure>
   </cookie-config>
   ```

## 💻 Usage

### For Guests

1. **Register an Account**
   - Navigate to `/register`
   - Fill in your details
   - Submit to create your guest account

2. **Login**
   - Go to `/login`
   - Enter username/email and password

3. **Make a Reservation**
   - Browse available room types
   - Select dates and number of guests
   - Submit reservation request

4. **Manage Reservations**
   - View your bookings in "My Reservations"
   - Check booking status
   - Cancel if needed

### For Staff

1. **Process Check-Ins**
   - View pending check-ins
   - Verify guest information
   - Complete check-in process

2. **Process Check-Outs**
   - View check-outs for the day
   - Update room status
   - Process final billing

3. **Monitor Room Status**
   - Real-time room availability dashboard
   - Update room maintenance status

### For Admins

1. **Manage Users**
   - Create/Edit/Delete user accounts
   - Assign roles
   - Activate/Deactivate accounts

2. **Manage Room Types & Rooms**
   - Add new room types
   - Configure pricing
   - Add/Edit room inventory

3. **View Reports**
   - Occupancy reports
   - Revenue analytics
   - Reservation statistics

4. **Oversee All Operations**
   - View all reservations
   - Monitor payments
   - Manage system-wide settings

## 👥 User Roles

### 🔑 Admin
- Full system access
- User management
- Room and room type management
- View all reservations and payments
- Generate reports
- System configuration

### 👔 Staff
- Process check-ins and check-outs
- View and manage reservations
- Update room status
- Process payments
- View guest information

### 🧳 Guest
- Register and login
- Make reservations
- View own reservations
- Update profile
- Cancel bookings

## 📁 Project Structure

```
OceanViewResort/
├── src/
│   ├── main/
│   │   ├── java/com/oceanview/
│   │   │   ├── controller/          # Servlets (Controllers)
│   │   │   │   ├── AdminServlet.java
│   │   │   │   ├── LoginServlet.java
│   │   │   │   ├── RegisterServlet.java
│   │   │   │   ├── ReservationServlet.java
│   │   │   │   ├── StaffServlet.java
│   │   │   │   ├── GuestServlet.java
│   │   │   │   ├── BillingServlet.java
│   │   │   │   └── ReportServlet.java
│   │   │   │
│   │   │   ├── model/               # Domain Models
│   │   │   │   ├── User.java
│   │   │   │   ├── Room.java
│   │   │   │   ├── RoomType.java
│   │   │   │   ├── Reservation.java
│   │   │   │   └── Payment.java
│   │   │   │
│   │   │   ├── dao/                 # Data Access Objects
│   │   │   │   ├── UserDAO.java
│   │   │   │   ├── RoomDAO.java
│   │   │   │   ├── ReservationDAO.java
│   │   │   │   ├── PaymentDAO.java
│   │   │   │   └── DAOFactory.java
│   │   │   │
│   │   │   ├── dao/impl/            # DAO Implementations
│   │   │   │   ├── UserDAOImpl.java
│   │   │   │   ├── RoomDAOImpl.java
│   │   │   │   ├── ReservationDAOImpl.java
│   │   │   │   └── PaymentDAOImpl.java
│   │   │   │
│   │   │   ├── service/             # Business Logic Layer
│   │   │   │   ├── UserService.java
│   │   │   │   ├── ReservationService.java
│   │   │   │   ├── BillingService.java
│   │   │   │   └── ValidationService.java
│   │   │   │
│   │   │   └── util/                # Utility Classes
│   │   │       ├── DatabaseConnection.java
│   │   │       ├── PasswordUtil.java
│   │   │       ├── SessionManager.java
│   │   │       └── DateUtil.java
│   │   │
│   │   ├── resources/
│   │   │   └── database/            # Database Scripts
│   │   │       ├── schema.sql
│   │   │       ├── sample_data.sql
│   │   │       └── init_database.sql
│   │   │
│   │   └── webapp/
│   │       ├── views/               # JSP Views
│   │       │   ├── login.jsp
│   │       │   ├── register.jsp
│   │       │   ├── dashboard-admin.jsp
│   │       │   ├── dashboard-staff.jsp
│   │       │   ├── dashboard-guest.jsp
│   │       │   ├── admin/           # Admin views
│   │       │   ├── staff/           # Staff views
│   │       │   └── guest/           # Guest views
│   │       │
│   │       └── WEB-INF/
│   │           └── web.xml          # Deployment descriptor
│   │
│   └── test/
│       └── java/com/oceanview/test/ # Unit tests
│           └── BackendTest.java
│
├── pom.xml                          # Maven configuration
├── .gitignore                       # Git ignore rules
└── README.md                        # This file
```

## 📚 API Documentation

### Servlet Mappings

| URL Pattern | Servlet | Methods | Description |
|-------------|---------|---------|-------------|
| `/login` | LoginServlet | GET, POST | User authentication |
| `/logout` | LogoutServlet | GET | User logout |
| `/register` | RegisterServlet | GET, POST | User registration |
| `/admin/*` | AdminServlet | GET, POST | Admin operations |
| `/staff/*` | StaffServlet | GET, POST | Staff operations |
| `/guest/*` | GuestServlet | GET, POST | Guest operations |
| `/reservations/*` | ReservationServlet | GET, POST | Reservation management |
| `/billing/*` | BillingServlet | GET, POST | Payment processing |
| `/reports/*` | ReportServlet | GET | Report generation |

### Common URL Parameters

- `action`: Specifies the operation (list, create, update, delete, view)
- `id`: Entity identifier (userId, roomId, reservationId, etc.)
- `from`: Start date for date range queries
- `to`: End date for date range queries

## 🧪 Testing

### Run Unit Tests

```bash
mvn test
```

### Run Integration Tests

```bash
mvn verify
```

### Manual Testing

1. **Test Authentication**
   - Try login with valid/invalid credentials
   - Test password hashing

2. **Test Room Booking**
   - Make a reservation
   - Check availability
   - Cancel reservation

3. **Test Role-Based Access**
   - Login as different users
   - Verify access restrictions

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork the Repository**
   ```bash
   git clone https://github.com/HamdhiHilmy/My-first.git
   ```

2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/YourFeatureName
   ```

3. **Commit Your Changes**
   ```bash
   git commit -m "Add some feature"
   ```

4. **Push to the Branch**
   ```bash
   git push origin feature/YourFeatureName
   ```

5. **Open a Pull Request**

### Coding Standards
- Follow Java naming conventions
- Write meaningful commit messages
- Add comments for complex logic
- Update documentation for new features
- Write unit tests for new functionality

## 🐛 Known Issues

- Session management could be enhanced with Remember Me functionality
- Email notifications not yet implemented
- Payment gateway integration pending
- Mobile responsiveness needs improvement

## 🔮 Future Enhancements

- [ ] Email notifications for booking confirmations
- [ ] SMS notifications
- [ ] Online payment gateway integration (Stripe, PayPal)
- [ ] Responsive mobile design
- [ ] Multi-language support
- [ ] Room images and gallery
- [ ] Customer reviews and ratings
- [ ] Loyalty program
- [ ] Advanced reporting with charts
- [ ] RESTful API for mobile apps

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Hamdhi Hilmy**
- GitHub: [@HamdhiHilmy](https://github.com/HamdhiHilmy)
- Repository: [My-first](https://github.com/HamdhiHilmy/My-first.git)

## 🙏 Acknowledgments

- Jakarta EE community for excellent documentation
- MySQL team for the robust database system
- Apache Maven and Tomcat teams
- All contributors and testers

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/HamdhiHilmy/My-first/issues) page
2. Create a new issue if your problem isn't already reported
3. Provide detailed information about the problem

## 🔒 Security

### Reporting Security Issues

If you discover a security vulnerability, please send an email instead of using the issue tracker.

### Security Best Practices Implemented

- ✅ Password hashing with SHA-256
- ✅ SQL injection prevention using PreparedStatements
- ✅ Session management with timeout
- ✅ Role-based access control
- ⚠️ HTTPS recommended for production
- ⚠️ Database credentials should use environment variables in production

---

**Happy Coding! 🚀**

*Made with ❤️ for efficient hotel management*
