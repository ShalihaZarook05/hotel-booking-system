<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.Room" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%
    // Check if user is logged in and is staff
    if (!SessionManager.isLoggedIn(request) || !SessionManager.isStaff(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    User currentUser = SessionManager.getLoggedInUser(request);
    String errorMessage = SessionManager.getErrorMessage(request);
    String successMessage = SessionManager.getSuccessMessage(request);
    List<Room> availableRooms = (List<Room>) request.getAttribute("availableRooms");
    List<User> guests = (List<User>) request.getAttribute("guests");
    String today = LocalDate.now().toString();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Check-In - Ocean View Resort</title>
    
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
        
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 1rem;
            font-family: inherit;
        }
        
        .form-group input:focus,
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
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }
        
        .required {
            color: #ef4444;
        }
        
        .help-text {
            font-size: 0.875rem;
            color: #6b7280;
            margin-top: 0.25rem;
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
        
        .btn-primary {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            color: white;
            flex: 1;
        }
        
        .btn-secondary {
            background: #e5e7eb;
            color: #374151;
        }
        
        .guest-info {
            background: #f9fafb;
            padding: 1rem;
            border-radius: 8px;
            margin-top: 0.5rem;
            display: none;
        }
        
        .guest-info.show {
            display: block;
        }
        
        .guest-info p {
            margin: 0.25rem 0;
            color: #6b7280;
            font-size: 0.9rem;
        }
        
        @media (max-width: 768px) {
            .form-row {
                grid-template-columns: 1fr;
            }
            
            .form-actions {
                flex-direction: column;
            }
        }
    </style>
    
    <script>
        function calculateTotal() {
            const checkInDate = document.getElementById('checkInDate').value;
            const checkOutDate = document.getElementById('checkOutDate').value;
            const roomSelect = document.getElementById('roomId');
            
            if (checkInDate && checkOutDate && roomSelect.value) {
                const checkIn = new Date(checkInDate);
                const checkOut = new Date(checkOutDate);
                const nights = Math.ceil((checkOut - checkIn) / (1000 * 60 * 60 * 24));
                
                if (nights > 0) {
                    const pricePerNight = parseFloat(roomSelect.options[roomSelect.selectedIndex].getAttribute('data-price') || 0);
                    const total = nights * pricePerNight;
                    document.getElementById('totalAmount').value = total.toFixed(2);
                    document.getElementById('nightsDisplay').textContent = nights + ' night' + (nights > 1 ? 's' : '');
                } else {
                    document.getElementById('totalAmount').value = '';
                    document.getElementById('nightsDisplay').textContent = '';
                }
            }
        }
        
        function showGuestInfo() {
            const guestSelect = document.getElementById('guestId');
            const guestInfo = document.getElementById('guestInfo');
            
            if (guestSelect.value) {
                const selectedOption = guestSelect.options[guestSelect.selectedIndex];
                document.getElementById('guestEmail').textContent = 'Email: ' + selectedOption.getAttribute('data-email');
                document.getElementById('guestPhone').textContent = 'Phone: ' + selectedOption.getAttribute('data-phone');
                guestInfo.classList.add('show');
            } else {
                guestInfo.classList.remove('show');
            }
        }
        
        function validateForm() {
            const checkInDate = document.getElementById('checkInDate').value;
            const checkOutDate = document.getElementById('checkOutDate').value;
            
            if (new Date(checkInDate) >= new Date(checkOutDate)) {
                alert('Check-out date must be after check-in date!');
                return false;
            }
            
            return true;
        }
    </script>
</head>
<body>
    
    <div class="navbar">
        <h1>🏖️ Ocean View Resort - Create Check-In</h1>
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
            <h2>📥 Create New Check-In</h2>
            <p>Register a walk-in guest or create a new reservation</p>
        </div>
        
        <% if (errorMessage != null) { %>
            <div class="alert alert-error">❌ <%= errorMessage %></div>
        <% } %>
        
        <% if (successMessage != null) { %>
            <div class="alert alert-success">✅ <%= successMessage %></div>
        <% } %>
        
        <div class="form-card">
            <form action="<%= request.getContextPath() %>/staff/checkin/create" method="post" onsubmit="return validateForm()">
                
                <div class="form-group">
                    <label for="guestId">Select Guest <span class="required">*</span></label>
                    <select id="guestId" name="guestId" required onchange="showGuestInfo()">
                        <option value="">-- Select a guest --</option>
                        <% if (guests != null) {
                            for (User guest : guests) { %>
                                <option value="<%= guest.getUserId() %>" 
                                        data-email="<%= guest.getEmail() %>"
                                        data-phone="<%= guest.getPhone() %>">
                                    <%= guest.getFullName() %> (<%= guest.getUsername() %>)
                                </option>
                            <% }
                        } %>
                    </select>
                    <div id="guestInfo" class="guest-info">
                        <p id="guestEmail"></p>
                        <p id="guestPhone"></p>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="roomId">Select Room <span class="required">*</span></label>
                    <select id="roomId" name="roomId" required onchange="calculateTotal()">
                        <option value="">-- Select a room --</option>
                        <% if (availableRooms != null) {
                            for (Room room : availableRooms) { %>
                                <option value="<%= room.getRoomId() %>" 
                                        data-price="<%= room.getRoomType() != null ? room.getRoomType().getPricePerNight() : 0 %>">
                                    Room <%= room.getRoomNumber() %> - 
                                    <%= room.getRoomType() != null ? room.getRoomType().getTypeName() : "Unknown" %> 
                                    (LKR <%= room.getRoomType() != null ? String.format("%,.2f", room.getRoomType().getPricePerNight()) : "0.00" %>/night)
                                </option>
                            <% }
                        } %>
                    </select>
                    <p class="help-text">Only available rooms are shown</p>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="checkInDate">Check-In Date <span class="required">*</span></label>
                        <input type="date" id="checkInDate" name="checkInDate" 
                               value="<%= today %>" min="<%= today %>" required onchange="calculateTotal()">
                    </div>
                    
                    <div class="form-group">
                        <label for="checkOutDate">Check-Out Date <span class="required">*</span></label>
                        <input type="date" id="checkOutDate" name="checkOutDate" 
                               min="<%= today %>" required onchange="calculateTotal()">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="numberOfGuests">Number of Guests <span class="required">*</span></label>
                        <input type="number" id="numberOfGuests" name="numberOfGuests" 
                               min="1" max="10" value="1" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="totalAmount">Total Amount (LKR) <span class="required">*</span></label>
                        <input type="number" id="totalAmount" name="totalAmount" 
                               step="0.01" min="0" required readonly>
                        <p class="help-text">Duration: <strong id="nightsDisplay"></strong></p>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="specialRequests">Special Requests</label>
                    <textarea id="specialRequests" name="specialRequests" 
                              placeholder="Any special requests or notes..."></textarea>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">✅ Create Check-In</button>
                    <a href="<%= request.getContextPath() %>/staff/checkin" class="btn btn-secondary" style="text-align: center; text-decoration: none; line-height: 1.5;">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    
</body>
</html>
