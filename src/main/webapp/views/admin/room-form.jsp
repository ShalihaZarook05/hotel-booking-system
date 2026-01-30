<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.Room" %>
<%@ page import="com.oceanview.model.RoomType" %>
<%@ page import="java.util.List" %>
<%
    // Check if user is logged in and is admin
    if (!SessionManager.isLoggedIn(request) || !SessionManager.isAdmin(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    User currentUser = SessionManager.getLoggedInUser(request);
    Room room = (Room) request.getAttribute("room");
    List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
    boolean isEdit = (room != null);
    String pageTitle = isEdit ? "Edit Room" : "Add New Room";
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
            max-width: 800px;
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
            grid-template-columns: 1fr 1fr;
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
        select {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s;
        }
        
        input:focus,
        select:focus {
            outline: none;
            border-color: #3b82f6;
        }
        
        .help-text {
            font-size: 0.85rem;
            color: #6b7280;
            margin-top: 0.25rem;
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
        
        .status-preview {
            display: flex;
            gap: 1rem;
            margin-top: 0.5rem;
        }
        
        .status-option {
            flex: 1;
            padding: 0.75rem;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .status-option:hover {
            border-color: #3b82f6;
        }
        
        .status-option.selected {
            border-color: #3b82f6;
            background: #dbeafe;
        }
        
        .status-option input[type="radio"] {
            display: none;
        }
        
        .status-option label {
            cursor: pointer;
            margin: 0;
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
            const roomNumber = document.getElementById('roomNumber').value.trim();
            const roomTypeId = document.getElementById('roomTypeId').value;
            const floorNumber = document.getElementById('floorNumber').value;
            const status = document.querySelector('input[name="status"]:checked');
            
            if (roomNumber === '') {
                alert('❌ Room number is required!');
                document.getElementById('roomNumber').focus();
                return false;
            }
            
            if (roomNumber.length < 2) {
                alert('❌ Room number must be at least 2 characters!');
                document.getElementById('roomNumber').focus();
                return false;
            }
            
            if (roomTypeId === '') {
                alert('❌ Please select a room type!');
                document.getElementById('roomTypeId').focus();
                return false;
            }
            
            if (floorNumber === '' || floorNumber < 1) {
                alert('❌ Please enter a valid floor number (minimum 1)!');
                document.getElementById('floorNumber').focus();
                return false;
            }
            
            if (!status) {
                alert('❌ Please select a room status!');
                return false;
            }
            
            return true;
        }
        
        function selectStatus(statusValue) {
            document.querySelectorAll('.status-option').forEach(opt => {
                opt.classList.remove('selected');
            });
            
            const selectedOption = document.querySelector(`input[value="${statusValue}"]`).closest('.status-option');
            selectedOption.classList.add('selected');
        }
        
        window.onload = function() {
            const checkedStatus = document.querySelector('input[name="status"]:checked');
            if (checkedStatus) {
                selectStatus(checkedStatus.value);
            }
        };
    </script>
</head>
<body>
    
    <div class="navbar">
        <h1>🏖️ Ocean View Resort - <%= pageTitle %></h1>
        <a href="<%= request.getContextPath() %>/admin/rooms">← Back to Rooms</a>
    </div>
    
    <div class="container">
        <div class="form-card">
            <div class="form-header">
                <h2><%= isEdit ? "✏️ Edit Room" : "➕ Add New Room" %></h2>
                <p><%= isEdit ? "Update room information" : "Fill in the details to create a new room" %></p>
            </div>
            
            <div class="form-body">
                <form action="<%= request.getContextPath() %>/admin/room/<%= isEdit ? "update" : "create" %>" 
                      method="post" 
                      onsubmit="return validateForm()">
                    
                    <% if (isEdit) { %>
                        <input type="hidden" name="roomId" value="<%= room.getRoomId() %>">
                    <% } %>
                    
                    <!-- Room Number and Room Type -->
                    <div class="form-row">
                        <div class="form-group">
                            <label for="roomNumber">Room Number <span class="required">*</span></label>
                            <input type="text" 
                                   id="roomNumber" 
                                   name="roomNumber" 
                                   value="<%= isEdit ? room.getRoomNumber() : "" %>"
                                   placeholder="e.g., 101, A-201"
                                   required
                                   minlength="2"
                                   maxlength="10">
                            <div class="help-text">Unique room identifier</div>
                        </div>
                        
                        <div class="form-group">
                            <label for="roomTypeId">Room Type <span class="required">*</span></label>
                            <select id="roomTypeId" name="roomTypeId" required>
                                <option value="">Select room type</option>
                                <% if (roomTypes != null && !roomTypes.isEmpty()) {
                                    for (RoomType type : roomTypes) { %>
                                        <option value="<%= type.getRoomTypeId() %>" 
                                                <%= isEdit && room.getRoomTypeId() == type.getRoomTypeId() ? "selected" : "" %>>
                                            <%= type.getTypeName() %> - LKR <%= String.format("%,.2f", type.getPricePerNight()) %>/night
                                        </option>
                                    <% }
                                } else { %>
                                    <option value="">No room types available</option>
                                <% } %>
                            </select>
                            <div class="help-text">Select the type of room</div>
                        </div>
                    </div>
                    
                    <!-- Floor Number -->
                    <div class="form-group">
                        <label for="floorNumber">Floor Number <span class="required">*</span></label>
                        <input type="number" 
                               id="floorNumber" 
                               name="floorNumber" 
                               value="<%= isEdit ? room.getFloorNumber() : "" %>"
                               placeholder="Enter floor number"
                               required
                               min="1"
                               max="50">
                        <div class="help-text">Which floor is this room on? (1-50)</div>
                    </div>
                    
                    <!-- Room Status -->
                    <div class="form-group">
                        <label>Room Status <span class="required">*</span></label>
                        <div class="status-preview">
                            <div class="status-option" onclick="selectStatus('AVAILABLE')">
                                <input type="radio" 
                                       name="status" 
                                       id="statusAvailable" 
                                       value="AVAILABLE" 
                                       <%= !isEdit || "AVAILABLE".equals(room.getStatus()) ? "checked" : "" %>>
                                <label for="statusAvailable">
                                    <div style="font-size: 2rem;">✅</div>
                                    <div style="font-weight: 600; margin-top: 0.5rem;">Available</div>
                                    <div style="font-size: 0.85rem; color: #6b7280;">Ready for booking</div>
                                </label>
                            </div>
                            
                            <div class="status-option" onclick="selectStatus('OCCUPIED')">
                                <input type="radio" 
                                       name="status" 
                                       id="statusOccupied" 
                                       value="OCCUPIED" 
                                       <%= isEdit && "OCCUPIED".equals(room.getStatus()) ? "checked" : "" %>>
                                <label for="statusOccupied">
                                    <div style="font-size: 2rem;">🔒</div>
                                    <div style="font-weight: 600; margin-top: 0.5rem;">Occupied</div>
                                    <div style="font-size: 0.85rem; color: #6b7280;">Currently in use</div>
                                </label>
                            </div>
                            
                            <div class="status-option" onclick="selectStatus('MAINTENANCE')">
                                <input type="radio" 
                                       name="status" 
                                       id="statusMaintenance" 
                                       value="MAINTENANCE" 
                                       <%= isEdit && "MAINTENANCE".equals(room.getStatus()) ? "checked" : "" %>>
                                <label for="statusMaintenance">
                                    <div style="font-size: 2rem;">🔧</div>
                                    <div style="font-weight: 600; margin-top: 0.5rem;">Maintenance</div>
                                    <div style="font-size: 0.85rem; color: #6b7280;">Under repair</div>
                                </label>
                            </div>
                        </div>
                        <div class="help-text">Select the current status of the room</div>
                    </div>
                    
                    <!-- Form Actions -->
                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/admin/rooms" class="btn btn-secondary">
                            ← Cancel
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "💾 Update Room" : "➕ Create Room" %>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
</body>
</html>
