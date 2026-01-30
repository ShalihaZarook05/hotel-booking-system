<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.RoomType" %>
<%@ page import="com.oceanview.model.Room" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Calendar" %>
<%
    if (!SessionManager.isLoggedIn(request) || !SessionManager.isGuest(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    User currentUser = SessionManager.getLoggedInUser(request);
    String errorMessage = SessionManager.getErrorMessage(request);
    List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    Calendar cal = Calendar.getInstance();
    String today = dateFormat.format(cal.getTime());
    cal.add(Calendar.DAY_OF_MONTH, 1);
    String tomorrow = dateFormat.format(cal.getTime());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Reservation - Ocean View Resort</title>
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
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
        
        .navbar h1 { font-size: 1.5rem; }
        
        .navbar a {
            color: white;
            text-decoration: none;
            padding: 0.5rem 1rem;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 5px;
            transition: background 0.3s;
        }
        
        .navbar a:hover { background: rgba(255, 255, 255, 0.3); }
        
        .container {
            max-width: 900px;
            margin: 2rem auto;
            padding: 0 2rem;
        }
        
        .form-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            overflow: hidden;
        }
        
        .form-header {
            background: linear-gradient(135deg, #1e3a8a, #0d9488);
            color: white;
            padding: 2rem;
            text-align: center;
        }
        
        .form-header h2 {
            font-size: 1.8rem;
            margin-bottom: 0.5rem;
        }
        
        .form-body { padding: 2rem; }
        
        .alert {
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fca5a5;
        }
        
        .form-group { margin-bottom: 1.5rem; }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
        }
        
        label {
            display: block;
            margin-bottom: 0.5rem;
            color: #374151;
            font-weight: 600;
        }
        
        .required { color: #dc2626; }
        
        input, select, textarea {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s;
            font-family: inherit;
        }
        
        input:focus, select:focus, textarea:focus {
            outline: none;
            border-color: #3b82f6;
        }
        
        textarea {
            resize: vertical;
            min-height: 100px;
        }
        
        .help-text {
            font-size: 0.85rem;
            color: #6b7280;
            margin-top: 0.25rem;
        }
        
        .room-selection {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 1rem;
            margin-top: 1rem;
        }
        
        .room-option {
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s;
            overflow: hidden;
            position: relative;
        }
        
        .room-option:hover {
            border-color: #3b82f6;
            box-shadow: 0 8px 24px rgba(59, 130, 246, 0.2);
            transform: translateY(-4px);
        }
        
        .room-option.selected {
            border-color: #10b981;
            border-width: 3px;
        }
        
        .room-option input[type="radio"] {
            display: none;
        }
        
        .room-image-carousel {
            position: relative;
            width: 100%;
            height: 200px;
            overflow: hidden;
            background: #f3f4f6;
        }
        
        .room-carousel-track {
            display: flex;
            transition: transform 0.5s ease-in-out;
            height: 100%;
        }
        
        .room-carousel-image {
            min-width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .carousel-nav {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            background: rgba(0, 0, 0, 0.5);
            color: white;
            border: none;
            width: 35px;
            height: 35px;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            transition: background 0.3s;
            z-index: 10;
        }
        
        .carousel-nav:hover {
            background: rgba(0, 0, 0, 0.7);
        }
        
        .carousel-prev {
            left: 10px;
        }
        
        .carousel-next {
            right: 10px;
        }
        
        .carousel-indicators {
            position: absolute;
            bottom: 10px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            gap: 6px;
            z-index: 10;
        }
        
        .carousel-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.5);
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .carousel-dot.active {
            background: white;
            width: 24px;
            border-radius: 4px;
        }
        
        .room-content {
            padding: 1rem;
        }
        
        .selected-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            background: #10b981;
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-weight: 700;
            font-size: 0.9rem;
            z-index: 20;
            display: none;
        }
        
        .room-option.selected .selected-badge {
            display: block;
        }
        
        .room-name {
            font-weight: 700;
            color: #1e3a8a;
            margin-bottom: 0.5rem;
        }
        
        .room-price {
            font-size: 1.2rem;
            font-weight: 600;
            color: #059669;
            margin-bottom: 0.5rem;
        }
        
        .room-details {
            font-size: 0.85rem;
            color: #6b7280;
        }
        
        .price-calculator {
            background: linear-gradient(135deg, #f0f9ff, #e0f2fe);
            padding: 1.5rem;
            border-radius: 10px;
            margin-top: 1.5rem;
            border: 2px solid #3b82f6;
        }
        
        .price-calculator h3 {
            color: #1e3a8a;
            margin-bottom: 1rem;
        }
        
        .price-row {
            display: flex;
            justify-content: space-between;
            padding: 0.5rem 0;
            border-bottom: 1px solid #bfdbfe;
        }
        
        .price-row:last-child {
            border-bottom: none;
            padding-top: 1rem;
            margin-top: 0.5rem;
            border-top: 2px solid #3b82f6;
            font-size: 1.3rem;
            font-weight: 700;
            color: #1e3a8a;
        }
        
        .form-actions {
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
            padding-top: 1rem;
            border-top: 1px solid #e5e7eb;
        }
        
        .btn {
            padding: 0.75rem 2rem;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn:hover { transform: translateY(-2px); }
        
        .btn-primary {
            background: linear-gradient(135deg, #1e3a8a, #0d9488);
            color: white;
        }
        
        .btn-secondary {
            background: linear-gradient(135deg, #6b7280, #4b5563);
            color: white;
        }
        
        @media (max-width: 768px) {
            .form-row { grid-template-columns: 1fr; }
            .room-selection { grid-template-columns: 1fr; }
            .form-actions { flex-direction: column; }
            .btn { width: 100%; }
        }
    </style>
    
    <script>
        let selectedRoomPrice = 0;
        let carouselPositions = {};
        
        function selectRoom(roomId, price, element) {
            // Remove selection from all
            document.querySelectorAll('.room-option').forEach(opt => {
                opt.classList.remove('selected');
            });
            
            // Select this one
            element.classList.add('selected');
            document.getElementById('roomId').value = roomId;
            selectedRoomPrice = price;
            
            calculatePrice();
        }
        
        function moveCarousel(carouselId, direction) {
            const track = document.querySelector('[data-carousel="' + carouselId + '"]');
            const images = track.querySelectorAll('.room-carousel-image');
            const totalImages = images.length;
            
            if (!carouselPositions[carouselId]) {
                carouselPositions[carouselId] = 0;
            }
            
            carouselPositions[carouselId] += direction;
            
            if (carouselPositions[carouselId] < 0) {
                carouselPositions[carouselId] = totalImages - 1;
            } else if (carouselPositions[carouselId] >= totalImages) {
                carouselPositions[carouselId] = 0;
            }
            
            updateCarousel(carouselId);
        }
        
        function goToSlide(carouselId, index) {
            carouselPositions[carouselId] = index;
            updateCarousel(carouselId);
        }
        
        function updateCarousel(carouselId) {
            const track = document.querySelector('[data-carousel="' + carouselId + '"]');
            const position = carouselPositions[carouselId] || 0;
            track.style.transform = 'translateX(-' + (position * 100) + '%)';
            
            // Update indicators
            const dots = document.querySelectorAll('[data-carousel="' + carouselId + '"][data-index]');
            dots.forEach((dot, index) => {
                if (index === position) {
                    dot.classList.add('active');
                } else {
                    dot.classList.remove('active');
                }
            });
        }
        
        // Initialize all carousels
        window.addEventListener('DOMContentLoaded', function() {
            document.querySelectorAll('.room-carousel-track').forEach((track, index) => {
                carouselPositions[index] = 0;
            });
        });
        
        function calculatePrice() {
            const checkIn = document.getElementById('checkInDate').value;
            const checkOut = document.getElementById('checkOutDate').value;
            
            if (checkIn && checkOut && selectedRoomPrice > 0) {
                const date1 = new Date(checkIn);
                const date2 = new Date(checkOut);
                const diffTime = Math.abs(date2 - date1);
                const nights = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                
                if (nights > 0) {
                    const total = nights * selectedRoomPrice;
                    document.getElementById('nightsDisplay').textContent = nights;
                    document.getElementById('pricePerNight').textContent = 'LKR ' + selectedRoomPrice.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
                    document.getElementById('totalPrice').textContent = 'LKR ' + total.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
                    document.getElementById('priceCalculator').style.display = 'block';
                }
            }
        }
        
        function validateForm() {
            const roomId = document.getElementById('roomId').value;
            const checkIn = document.getElementById('checkInDate').value;
            const checkOut = document.getElementById('checkOutDate').value;
            const guests = document.getElementById('numberOfGuests').value;
            
            if (!roomId) {
                alert('❌ Please select a room type!');
                return false;
            }
            
            if (!checkIn || !checkOut) {
                alert('❌ Please select check-in and check-out dates!');
                return false;
            }
            
            const date1 = new Date(checkIn);
            const date2 = new Date(checkOut);
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            
            if (date1 < today) {
                alert('❌ Check-in date cannot be in the past!');
                return false;
            }
            
            if (date2 <= date1) {
                alert('❌ Check-out date must be after check-in date!');
                return false;
            }
            
            if (!guests || guests < 1) {
                alert('❌ Please enter number of guests!');
                return false;
            }
            
            return true;
        }
    </script>
</head>
<body>
    
    <div class="navbar">
        <h1>🏖️ Ocean View Resort - New Reservation</h1>
        <a href="<%= request.getContextPath() %>/guest/reservations">← Back to Reservations</a>
    </div>
    
    <div class="container">
        <div class="form-card">
            <div class="form-header">
                <h2>➕ Make a Reservation</h2>
                <p>Book your perfect getaway at Ocean View Resort</p>
            </div>
            
            <div class="form-body">
                <% if (errorMessage != null) { %>
                    <div class="alert">❌ <%= errorMessage %></div>
                <% } %>
                
                <form action="<%= request.getContextPath() %>/guest/reservation/create" 
                      method="post" 
                      onsubmit="return validateForm()">
                    
                    <input type="hidden" id="roomId" name="roomId" value="">
                    
                    <!-- Room Selection -->
                    <div class="form-group">
                        <label>Select Room Type <span class="required">*</span></label>
                        <div class="room-selection">
                            <% if (roomTypes != null && !roomTypes.isEmpty()) {
                                int roomIndex = 0;
                                for (RoomType type : roomTypes) { 
                                    String[] imageUrls = type.getImageUrlsArray();
                            %>
                                    <div class="room-option" onclick="selectRoom(<%= type.getRoomTypeId() %>, <%= type.getPricePerNight() %>, this)">
                                        <input type="radio" name="roomTypeSelection" value="<%= type.getRoomTypeId() %>">
                                        <div class="selected-badge">✓ Selected</div>
                                        
                                        <!-- Image Carousel -->
                                        <% if (imageUrls != null && imageUrls.length > 0) { %>
                                            <div class="room-image-carousel" id="carousel-<%= roomIndex %>">
                                                <div class="room-carousel-track" data-carousel="<%= roomIndex %>">
                                                    <% for (String imageUrl : imageUrls) { %>
                                                        <img src="<%= imageUrl.trim() %>" alt="<%= type.getTypeName() %>" class="room-carousel-image" onerror="this.src='https://via.placeholder.com/400x250?text=Room+Image'">
                                                    <% } %>
                                                </div>
                                                
                                                <% if (imageUrls.length > 1) { %>
                                                    <button class="carousel-nav carousel-prev" onclick="event.stopPropagation(); moveCarousel(<%= roomIndex %>, -1)">‹</button>
                                                    <button class="carousel-nav carousel-next" onclick="event.stopPropagation(); moveCarousel(<%= roomIndex %>, 1)">›</button>
                                                    
                                                    <div class="carousel-indicators">
                                                        <% for (int i = 0; i < imageUrls.length; i++) { %>
                                                            <div class="carousel-dot <%= i == 0 ? "active" : "" %>" data-carousel="<%= roomIndex %>" data-index="<%= i %>" onclick="event.stopPropagation(); goToSlide(<%= roomIndex %>, <%= i %>)"></div>
                                                        <% } %>
                                                    </div>
                                                <% } %>
                                            </div>
                                        <% } else { %>
                                            <!-- Placeholder when no images available -->
                                            <div class="room-image-carousel">
                                                <img src="https://via.placeholder.com/400x250/3b82f6/ffffff?text=<%= type.getTypeName().replace(" ", "+") %>" 
                                                     alt="<%= type.getTypeName() %>" 
                                                     class="room-carousel-image"
                                                     style="width: 100%; height: 100%; object-fit: cover;">
                                            </div>
                                        <% } %>
                                        
                                        <div class="room-content">
                                            <div class="room-name"><%= type.getTypeName() %></div>
                                            <div class="room-price">LKR <%= String.format("%,.2f", type.getPricePerNight()) %>/night</div>
                                            <div class="room-details">
                                                👥 Capacity: <%= type.getCapacity() %> guests<br>
                                                <%= type.getDescription() != null ? type.getDescription().substring(0, Math.min(60, type.getDescription().length())) + "..." : "" %>
                                            </div>
                                        </div>
                                    </div>
                                <% 
                                    roomIndex++;
                                }
                            } else { %>
                                <p style="color: #991b1b;">No room types available. Please contact administration.</p>
                            <% } %>
                        </div>
                    </div>
                    
                    <!-- Dates -->
                    <div class="form-row">
                        <div class="form-group">
                            <label for="checkInDate">Check-In Date <span class="required">*</span></label>
                            <input type="date" 
                                   id="checkInDate" 
                                   name="checkInDate" 
                                   min="<%= today %>"
                                   required
                                   onchange="calculatePrice()">
                            <div class="help-text">Select arrival date</div>
                        </div>
                        
                        <div class="form-group">
                            <label for="checkOutDate">Check-Out Date <span class="required">*</span></label>
                            <input type="date" 
                                   id="checkOutDate" 
                                   name="checkOutDate" 
                                   min="<%= tomorrow %>"
                                   required
                                   onchange="calculatePrice()">
                            <div class="help-text">Select departure date</div>
                        </div>
                    </div>
                    
                    <!-- Number of Guests -->
                    <div class="form-group">
                        <label for="numberOfGuests">Number of Guests <span class="required">*</span></label>
                        <input type="number" 
                               id="numberOfGuests" 
                               name="numberOfGuests" 
                               min="1" 
                               max="10"
                               placeholder="Enter number of guests"
                               required>
                        <div class="help-text">Maximum capacity depends on room type</div>
                    </div>
                    
                    <!-- Special Requests -->
                    <div class="form-group">
                        <label for="specialRequests">Special Requests</label>
                        <textarea id="specialRequests" 
                                  name="specialRequests" 
                                  placeholder="Any special requests or preferences? (Optional)"
                                  maxlength="500"></textarea>
                        <div class="help-text">Optional: Let us know if you have any special requirements</div>
                    </div>
                    
                    <!-- Price Calculator -->
                    <div id="priceCalculator" class="price-calculator" style="display: none;">
                        <h3>💰 Price Breakdown</h3>
                        <div class="price-row">
                            <span>Number of Nights:</span>
                            <span id="nightsDisplay">0</span>
                        </div>
                        <div class="price-row">
                            <span>Price per Night:</span>
                            <span id="pricePerNight">LKR 0.00</span>
                        </div>
                        <div class="price-row">
                            <span>Total Price:</span>
                            <span id="totalPrice">LKR 0.00</span>
                        </div>
                    </div>
                    
                    <!-- Form Actions -->
                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/guest/reservations" class="btn btn-secondary">
                            ← Cancel
                        </a>
                        <button type="submit" class="btn btn-primary">
                            ✓ Confirm Reservation
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
</body>
</html>
