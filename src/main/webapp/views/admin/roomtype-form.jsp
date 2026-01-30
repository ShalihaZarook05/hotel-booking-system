<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.RoomType" %>
<%
    // Check if user is logged in and is admin
    if (!SessionManager.isLoggedIn(request) || !SessionManager.isAdmin(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    User currentUser = SessionManager.getLoggedInUser(request);
    RoomType roomType = (RoomType) request.getAttribute("roomType");
    boolean isEdit = (roomType != null);
    String pageTitle = isEdit ? "Edit Room Type" : "Add New Room Type";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> - Ocean View Resort</title>
    
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
        
        .form-header p {
            opacity: 0.9;
        }
        
        .form-body {
            padding: 2rem;
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 1.5rem;
        }
        
        label {
            display: block;
            margin-bottom: 0.5rem;
            color: #374151;
            font-weight: 600;
        }
        
        .required {
            color: #dc2626;
        }
        
        input[type="text"],
        input[type="number"],
        textarea {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s;
            font-family: inherit;
        }
        
        input:focus,
        textarea:focus {
            outline: none;
            border-color: #3b82f6;
        }
        
        textarea {
            resize: vertical;
            min-height: 120px;
        }
        
        .help-text {
            font-size: 0.85rem;
            color: #6b7280;
            margin-top: 0.25rem;
        }
        
        .price-input-group {
            position: relative;
        }
        
        .price-input-group .currency {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: #6b7280;
            font-weight: 600;
            font-size: 1.1rem;
        }
        
        .price-input-group input {
            padding-left: 2.5rem;
        }
        
        .capacity-input-group {
            position: relative;
        }
        
        .capacity-input-group .icon {
            position: absolute;
            right: 1rem;
            top: 50%;
            transform: translateY(-50%);
            font-size: 1.2rem;
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
        
        .btn:hover {
            transform: translateY(-2px);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #1e3a8a, #0d9488);
            color: white;
        }
        
        .btn-secondary {
            background: linear-gradient(135deg, #6b7280, #4b5563);
            color: white;
        }
        
        .preview-card {
            background: linear-gradient(135deg, #f3f4f6, #e5e7eb);
            padding: 1.5rem;
            border-radius: 10px;
            margin-bottom: 1.5rem;
        }
        
        .preview-card h3 {
            color: #1e3a8a;
            margin-bottom: 0.5rem;
        }
        
        .preview-card p {
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
            
            .btn {
                width: 100%;
            }
        }
    </style>
    
    <script>
        function validateForm() {
            const typeName = document.getElementById('typeName').value.trim();
            const description = document.getElementById('description').value.trim();
            const pricePerNight = document.getElementById('pricePerNight').value;
            const capacity = document.getElementById('capacity').value;
            const amenities = document.getElementById('amenities').value.trim();
            
            if (typeName === '') {
                alert('❌ Room type name is required!');
                document.getElementById('typeName').focus();
                return false;
            }
            
            if (typeName.length < 3) {
                alert('❌ Room type name must be at least 3 characters!');
                document.getElementById('typeName').focus();
                return false;
            }
            
            if (description === '') {
                alert('❌ Description is required!');
                document.getElementById('description').focus();
                return false;
            }
            
            if (description.length < 10) {
                alert('❌ Description must be at least 10 characters!');
                document.getElementById('description').focus();
                return false;
            }
            
            if (pricePerNight === '' || parseFloat(pricePerNight) <= 0) {
                alert('❌ Please enter a valid price greater than 0!');
                document.getElementById('pricePerNight').focus();
                return false;
            }
            
            if (capacity === '' || parseInt(capacity) < 1) {
                alert('❌ Capacity must be at least 1!');
                document.getElementById('capacity').focus();
                return false;
            }
            
            if (amenities === '') {
                alert('❌ Please list the amenities!');
                document.getElementById('amenities').focus();
                return false;
            }
            
            return true;
        }
        
        function updatePreview() {
            const typeName = document.getElementById('typeName').value || 'Room Type Name';
            const price = document.getElementById('pricePerNight').value || '0.00';
            const capacity = document.getElementById('capacity').value || '0';
            
            document.getElementById('previewName').textContent = typeName;
            document.getElementById('previewPrice').textContent = 'LKR ' + parseFloat(price).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('previewCapacity').textContent = '👥 ' + capacity + ' Guest' + (capacity != 1 ? 's' : '');
        }
        
        // Update preview on input
        window.onload = function() {
            document.getElementById('typeName').addEventListener('input', updatePreview);
            document.getElementById('pricePerNight').addEventListener('input', updatePreview);
            document.getElementById('capacity').addEventListener('input', updatePreview);
            updatePreview();
        };
    </script>
</head>
<body>
    
    <div class="navbar">
        <h1>🏖️ Ocean View Resort - <%= pageTitle %></h1>
        <a href="<%= request.getContextPath() %>/admin/roomtypes">← Back to Room Types</a>
    </div>
    
    <div class="container">
        <div class="form-card">
            <div class="form-header">
                <h2><%= isEdit ? "✏️ Edit Room Type" : "➕ Add New Room Type" %></h2>
                <p><%= isEdit ? "Update room type information" : "Fill in the details to create a new room type" %></p>
            </div>
            
            <div class="form-body">
                <!-- Live Preview -->
                <div class="preview-card">
                    <h3 id="previewName">Room Type Name</h3>
                    <p>
                        <strong id="previewPrice">LKR 0.00</strong> per night | 
                        <span id="previewCapacity">👥 0 Guests</span>
                    </p>
                </div>
                
                <form action="<%= request.getContextPath() %>/admin/roomtype/<%= isEdit ? "update" : "create" %>" 
                      method="post" 
                      onsubmit="return validateForm()">
                    
                    <% if (isEdit) { %>
                        <input type="hidden" name="roomTypeId" value="<%= roomType.getRoomTypeId() %>">
                    <% } %>
                    
                    <!-- Type Name -->
                    <div class="form-group">
                        <label for="typeName">Room Type Name <span class="required">*</span></label>
                        <input type="text" 
                               id="typeName" 
                               name="typeName" 
                               value="<%= isEdit ? roomType.getTypeName() : "" %>"
                               placeholder="e.g., Deluxe Suite, Ocean View Room"
                               required
                               minlength="3"
                               maxlength="50">
                        <div class="help-text">Descriptive name for this room type</div>
                    </div>
                    
                    <!-- Description -->
                    <div class="form-group">
                        <label for="description">Description <span class="required">*</span></label>
                        <textarea id="description" 
                                  name="description" 
                                  placeholder="Describe the room type, features, views, etc."
                                  required
                                  minlength="10"
                                  maxlength="500"><%= isEdit ? roomType.getDescription() : "" %></textarea>
                        <div class="help-text">Detailed description of the room type (10-500 characters)</div>
                    </div>
                    
                    <!-- Price and Capacity -->
                    <div class="form-row">
                        <div class="form-group">
                            <label for="pricePerNight">Price Per Night <span class="required">*</span></label>
                            <div class="price-input-group">
                                <span class="currency">LKR</span>
                                <input type="number" 
                                       id="pricePerNight" 
                                       name="pricePerNight" 
                                       value="<%= isEdit ? roomType.getPricePerNight() : "" %>"
                                       placeholder="0.00"
                                       required
                                       min="1"
                                       step="0.01">
                            </div>
                            <div class="help-text">Nightly rate in Sri Lankan Rupees</div>
                        </div>
                        
                        <div class="form-group">
                            <label for="capacity">Capacity <span class="required">*</span></label>
                            <div class="capacity-input-group">
                                <input type="number" 
                                       id="capacity" 
                                       name="capacity" 
                                       value="<%= isEdit ? roomType.getCapacity() : "" %>"
                                       placeholder="2"
                                       required
                                       min="1"
                                       max="10">
                                <span class="icon">👥</span>
                            </div>
                            <div class="help-text">Max guests</div>
                        </div>
                    </div>
                    
                    <!-- Amenities -->
                    <div class="form-group">
                        <label for="amenities">Amenities <span class="required">*</span></label>
                        <textarea id="amenities" 
                                  name="amenities" 
                                  placeholder="List amenities (e.g., WiFi, Air Conditioning, Mini Bar, Ocean View, Private Balcony)"
                                  required
                                  minlength="5"
                                  maxlength="500"><%= isEdit ? roomType.getAmenities() : "" %></textarea>
                        <div class="help-text">Comma-separated list of amenities and features</div>
                    </div>
                    
                    <!-- Examples Section -->
                    <div style="background: #f0f9ff; padding: 1rem; border-radius: 8px; margin-bottom: 1.5rem; border-left: 4px solid #3b82f6;">
                        <strong style="color: #1e40af;">💡 Examples:</strong>
                        <ul style="margin-top: 0.5rem; margin-left: 1.5rem; color: #374151;">
                            <li><strong>Standard Room:</strong> WiFi, Air Conditioning, TV, Private Bathroom</li>
                            <li><strong>Deluxe Suite:</strong> WiFi, AC, King Bed, Ocean View, Mini Bar, Balcony, Smart TV</li>
                            <li><strong>Presidential Suite:</strong> WiFi, AC, King Bed, Ocean View, Jacuzzi, Living Room, Kitchen, Butler Service</li>
                        </ul>
                    </div>
                    
                    <!-- Form Actions -->
                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/admin/roomtypes" class="btn btn-secondary">
                            ← Cancel
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "💾 Update Room Type" : "➕ Create Room Type" %>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
</body>
</html>
