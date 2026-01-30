<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.Room" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Check if user is logged in and is staff
    if (!SessionManager.isLoggedIn(request) || !SessionManager.isStaff(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    User currentUser = SessionManager.getLoggedInUser(request);
    String errorMessage = SessionManager.getErrorMessage(request);
    String successMessage = SessionManager.getSuccessMessage(request);
    Reservation reservation = (Reservation) request.getAttribute("reservation");
    User guest = (User) request.getAttribute("guest");
    Room room = (Room) request.getAttribute("room");
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    
    if (reservation == null) {
        response.sendRedirect(request.getContextPath() + "/staff/checkout");
        return;
    }
    
    long nights = (reservation.getCheckOutDate().getTime() - reservation.getCheckInDate().getTime()) / (1000 * 60 * 60 * 24);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Process Check-Out - Ocean View Resort</title>
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f3f4f6;
            min-height: 100vh;
        }
        
        .navbar {
            background: linear-gradient(135deg, #1e3a8a, #0d9488);
            color: white;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        
        .navbar h1 {
            font-size: 1.5rem;
        }
        
        .navbar .nav-links {
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        
        .navbar a {
            color: white;
            text-decoration: none;
            padding: 0.5rem 1rem;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 5px;
            transition: background 0.3s;
        }
        
        .navbar a:hover {
            background: rgba(255, 255, 255, 0.3);
        }
        
        .container {
            max-width: 900px;
            margin: 2rem auto;
            padding: 0 2rem;
        }
        
        .page-header {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 2rem;
        }
        
        .page-header h2 {
            color: #1e3a8a;
            font-size: 1.8rem;
            margin-bottom: 0.5rem;
        }
        
        .page-header p {
            color: #6b7280;
        }
        
        .alert {
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
        }
        
        .alert-error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fca5a5;
        }
        
        .alert-success {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #6ee7b7;
        }
        
        .summary-card {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 1.5rem;
        }
        
        .summary-card h3 {
            color: #1e3a8a;
            margin-bottom: 1rem;
            font-size: 1.3rem;
        }
        
        .info-grid {
            display: grid;
            gap: 1rem;
        }
        
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 0.75rem 0;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .info-row:last-child {
            border-bottom: none;
        }
        
        .info-label {
            color: #6b7280;
            font-weight: 600;
        }
        
        .info-value {
            color: #374151;
            font-weight: 500;
        }
        
        .total-row {
            background: #f9fafb;
            padding: 1rem;
            border-radius: 8px;
            margin-top: 1rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .total-label {
            font-size: 1.2rem;
            font-weight: 700;
            color: #1e3a8a;
        }
        
        .total-value {
            font-size: 1.5rem;
            font-weight: 700;
            color: #10b981;
        }
        
        .form-card {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: #374151;
        }
        
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 1rem;
            font-family: inherit;
        }
        
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }
        
        .form-group textarea {
            resize: vertical;
            min-height: 100px;
        }
        
        .required {
            color: #ef4444;
        }
        
        .form-actions {
            display: flex;
            gap: 1rem;
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid #e5e7eb;
        }
        
        .btn {
            padding: 0.75rem 2rem;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
        }
        
        .btn:hover {
            transform: translateY(-2px);
        }
        
        .btn-danger {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
            flex: 1;
        }
        
        .btn-secondary {
            background: #e5e7eb;
            color: #374151;
        }
        
        @media (max-width: 768px) {
            .form-actions {
                flex-direction: column;
            }
        }
    </style>
    
    <script>
        function confirmCheckout() {
            return confirm('Are you sure you want to process this check-out?\n\nThis will mark the room as available and complete the reservation.');
        }
    </script>
</head>
<body>
    
    <div class="navbar">
        <h1>🏖️ Ocean View Resort - Process Check-Out</h1>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/staff/dashboard">📊 Dashboard</a>
            <a href="<%= request.getContextPath() %>/staff/checkin">📥 Check-Ins</a>
            <a href="<%= request.getContextPath() %>/staff/checkout">📤 Check-Outs</a>
            <a href="<%= request.getContextPath() %>/staff/rooms">🏠 Rooms</a>
            <a href="<%= request.getContextPath() %>/logout">🚪 Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="page-header">
            <h2>📤 Process Check-Out</h2>
            <p>Review reservation details and complete check-out with billing information</p>
        </div>
        
        <% if (errorMessage != null) { %>
            <div class="alert alert-error">❌ <%= errorMessage %></div>
        <% } %>
        
        <% if (successMessage != null) { %>
            <div class="alert alert-success">✅ <%= successMessage %></div>
        <% } %>
        
        <div class="summary-card">
            <h3>👤 Guest Information</h3>
            <div class="info-grid">
                <div class="info-row">
                    <span class="info-label">Guest Name:</span>
                    <span class="info-value"><%= guest != null ? guest.getFullName() : "N/A" %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Email:</span>
                    <span class="info-value"><%= guest != null ? guest.getEmail() : "N/A" %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Phone:</span>
                    <span class="info-value"><%= guest != null ? guest.getPhone() : "N/A" %></span>
                </div>
            </div>
        </div>
        
        <div class="summary-card">
            <h3>🏨 Reservation Details</h3>
            <div class="info-grid">
                <div class="info-row">
                    <span class="info-label">Reservation Number:</span>
                    <span class="info-value"><%= reservation.getReservationNumber() %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Room Number:</span>
                    <span class="info-value"><%= room != null ? room.getRoomNumber() : reservation.getRoomId() %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Room Type:</span>
                    <span class="info-value"><%= room != null && room.getRoomType() != null ? room.getRoomType().getTypeName() : "N/A" %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Check-In Date:</span>
                    <span class="info-value"><%= dateFormat.format(reservation.getCheckInDate()) %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Check-Out Date:</span>
                    <span class="info-value"><%= dateFormat.format(reservation.getCheckOutDate()) %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Number of Nights:</span>
                    <span class="info-value"><%= nights %> night<%= nights != 1 ? "s" : "" %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Number of Guests:</span>
                    <span class="info-value">👥 <%= reservation.getNumberOfGuests() %></span>
                </div>
            </div>
            
            <div class="total-row">
                <span class="total-label">Total Amount:</span>
                <span class="total-value">LKR <%= String.format("%,.2f", reservation.getTotalAmount()) %></span>
            </div>
        </div>
        
        <div class="form-card">
            <h3 style="color: #1e3a8a; margin-bottom: 1.5rem;">💳 Payment Information</h3>
            
            <form action="<%= request.getContextPath() %>/staff/checkout/process" method="post" onsubmit="return confirmCheckout()">
                <input type="hidden" name="reservationId" value="<%= reservation.getReservationId() %>">
                
                <div class="form-group">
                    <label for="paymentMethod">Payment Method <span class="required">*</span></label>
                    <select id="paymentMethod" name="paymentMethod" required>
                        <option value="">-- Select payment method --</option>
                        <option value="CASH">💵 Cash</option>
                        <option value="CREDIT_CARD">💳 Credit Card</option>
                        <option value="DEBIT_CARD">💳 Debit Card</option>
                        <option value="ONLINE">🌐 Online Transfer</option>
                        <option value="OTHER">📝 Other</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="notes">Notes / Comments</label>
                    <textarea id="notes" name="notes" 
                              placeholder="Any additional notes or comments about the check-out..."></textarea>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-danger">✅ Complete Check-Out</button>
                    <a href="<%= request.getContextPath() %>/staff/checkout" class="btn btn-secondary" style="text-align: center; text-decoration: none; line-height: 1.5;">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    
</body>
</html>
