<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="java.math.BigDecimal" %>
<%
    if (!SessionManager.isLoggedIn(request) || 
        (!SessionManager.isAdmin(request) && !SessionManager.isStaff(request))) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    User currentUser = SessionManager.getLoggedInUser(request);
    
    // Get statistics from servlet
    BigDecimal totalRevenue = (BigDecimal) request.getAttribute("totalRevenue");
    Long totalReservations = (Long) request.getAttribute("totalReservations");
    Long totalRooms = (Long) request.getAttribute("totalRooms");
    Long availableRooms = (Long) request.getAttribute("availableRooms");
    Long occupiedRooms = (Long) request.getAttribute("occupiedRooms");
    String occupancyRate = (String) request.getAttribute("occupancyRate");
    
    Long pendingReservations = (Long) request.getAttribute("pendingReservations");
    Long confirmedReservations = (Long) request.getAttribute("confirmedReservations");
    Long checkedInReservations = (Long) request.getAttribute("checkedInReservations");
    Long checkedOutReservations = (Long) request.getAttribute("checkedOutReservations");
    Long cancelledReservations = (Long) request.getAttribute("cancelledReservations");
    
    Long cashPayments = (Long) request.getAttribute("cashPayments");
    Long cardPayments = (Long) request.getAttribute("cardPayments");
    Long onlinePayments = (Long) request.getAttribute("onlinePayments");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports & Analytics - Ocean View Resort</title>
    
    <!-- Chart.js CDN -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f3f4f6; }
        
        .navbar { background: linear-gradient(135deg, #1e3a8a, #0d9488); color: white; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .navbar h1 { font-size: 1.5rem; }
        .navbar .nav-links { display: flex; gap: 1rem; }
        .navbar a { color: white; text-decoration: none; padding: 0.5rem 1rem; background: rgba(255,255,255,0.2); border-radius: 5px; transition: background 0.3s; }
        .navbar a:hover { background: rgba(255,255,255,0.3); }
        
        .container { max-width: 1400px; margin: 2rem auto; padding: 0 2rem; }
        
        .page-header { background: white; padding: 2rem; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 2rem; }
        .page-header h2 { color: #1e3a8a; font-size: 2rem; margin-bottom: 0.5rem; }
        .page-header p { color: #6b7280; }
        
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem; margin-bottom: 2rem; }
        .stat-card { background: white; padding: 2rem; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); transition: transform 0.3s; }
        .stat-card:hover { transform: translateY(-5px); box-shadow: 0 8px 20px rgba(0,0,0,0.1); }
        .stat-card h3 { font-size: 0.9rem; color: #6b7280; margin-bottom: 0.5rem; text-transform: uppercase; letter-spacing: 0.5px; }
        .stat-card .value { font-size: 2.5rem; font-weight: 700; margin-bottom: 0.5rem; }
        .stat-card .subtitle { font-size: 0.85rem; color: #9ca3af; }
        
        .stat-card.revenue .value { color: #10b981; }
        .stat-card.reservations .value { color: #3b82f6; }
        .stat-card.rooms .value { color: #f59e0b; }
        .stat-card.occupancy .value { color: #8b5cf6; }
        
        .charts-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(500px, 1fr)); gap: 2rem; margin-bottom: 2rem; }
        .chart-card { background: white; padding: 2rem; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .chart-card h3 { color: #1e3a8a; margin-bottom: 1.5rem; font-size: 1.2rem; }
        .chart-container { position: relative; height: 350px; }
        
        .full-width-chart { grid-column: 1 / -1; }
        
        @media (max-width: 768px) {
            .charts-grid { grid-template-columns: 1fr; }
            .stat-card .value { font-size: 2rem; }
        }
    </style>
</head>
<body>
    <div class="navbar">
        <h1>📊 Ocean View Resort - Reports & Analytics</h1>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/admin/dashboard">📊 Dashboard</a>
            <a href="<%= request.getContextPath() %>/admin/reservations">📋 Reservations</a>
            <a href="<%= request.getContextPath() %>/reports">📈 Reports</a>
            <a href="<%= request.getContextPath() %>/logout">🚪 Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="page-header">
            <h2>📈 Reports & Analytics Dashboard</h2>
            <p>Real-time statistics and insights about your hotel operations</p>
        </div>
        
        <!-- Key Metrics -->
        <div class="stats-grid">
            <div class="stat-card revenue">
                <h3>💰 Total Revenue</h3>
                <div class="value">LKR <%= totalRevenue != null ? String.format("%,.0f", totalRevenue) : "0" %></div>
                <div class="subtitle">All-time earnings</div>
            </div>
            
            <div class="stat-card reservations">
                <h3>📋 Total Reservations</h3>
                <div class="value"><%= totalReservations != null ? totalReservations : 0 %></div>
                <div class="subtitle">All-time bookings</div>
            </div>
            
            <div class="stat-card rooms">
                <h3>🏠 Total Rooms</h3>
                <div class="value"><%= totalRooms != null ? totalRooms : 0 %></div>
                <div class="subtitle"><%= availableRooms %> available, <%= occupiedRooms %> occupied</div>
            </div>
            
            <div class="stat-card occupancy">
                <h3>📊 Occupancy Rate</h3>
                <div class="value"><%= occupancyRate != null ? occupancyRate : "0.00" %>%</div>
                <div class="subtitle">Current occupancy</div>
            </div>
        </div>
        
        <!-- Charts -->
        <div class="charts-grid">
            <!-- Reservation Status Chart (Doughnut) -->
            <div class="chart-card">
                <h3>📋 Reservation Status Breakdown</h3>
                <div class="chart-container">
                    <canvas id="reservationStatusChart"></canvas>
                </div>
            </div>
            
            <!-- Payment Methods Chart (Pie) -->
            <div class="chart-card">
                <h3>💳 Payment Methods Distribution</h3>
                <div class="chart-container">
                    <canvas id="paymentMethodsChart"></canvas>
                </div>
            </div>
            
            <!-- Room Occupancy Chart (Bar) -->
            <div class="chart-card full-width-chart">
                <h3>🏨 Room Status Overview</h3>
                <div class="chart-container">
                    <canvas id="roomStatusChart"></canvas>
                </div>
            </div>
            
            <!-- Reservation Trends Chart (Line) -->
            <div class="chart-card full-width-chart">
                <h3>📈 Reservation Trends</h3>
                <div class="chart-container">
                    <canvas id="reservationTrendsChart"></canvas>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        // Chart.js configuration
        Chart.defaults.font.family = "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif";
        Chart.defaults.font.size = 14;
        
        // 1. Reservation Status Doughnut Chart
        const reservationStatusCtx = document.getElementById('reservationStatusChart').getContext('2d');
        new Chart(reservationStatusCtx, {
            type: 'doughnut',
            data: {
                labels: ['Pending', 'Confirmed', 'Checked In', 'Checked Out', 'Cancelled'],
                datasets: [{
                    data: [
                        <%= pendingReservations != null ? pendingReservations : 0 %>,
                        <%= confirmedReservations != null ? confirmedReservations : 0 %>,
                        <%= checkedInReservations != null ? checkedInReservations : 0 %>,
                        <%= checkedOutReservations != null ? checkedOutReservations : 0 %>,
                        <%= cancelledReservations != null ? cancelledReservations : 0 %>
                    ],
                    backgroundColor: [
                        '#f59e0b', // Orange - Pending
                        '#3b82f6', // Blue - Confirmed
                        '#10b981', // Green - Checked In
                        '#6b7280', // Gray - Checked Out
                        '#ef4444'  // Red - Cancelled
                    ],
                    borderWidth: 2,
                    borderColor: '#ffffff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { padding: 15, font: { size: 12 } }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const label = context.label || '';
                                const value = context.parsed || 0;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = total > 0 ? ((value / total) * 100).toFixed(1) : 0;
                                return label + ': ' + value + ' (' + percentage + '%)';
                            }
                        }
                    }
                }
            }
        });
        
        // 2. Payment Methods Pie Chart
        const paymentMethodsCtx = document.getElementById('paymentMethodsChart').getContext('2d');
        new Chart(paymentMethodsCtx, {
            type: 'pie',
            data: {
                labels: ['Cash', 'Card', 'Online'],
                datasets: [{
                    data: [
                        <%= cashPayments != null ? cashPayments : 0 %>,
                        <%= cardPayments != null ? cardPayments : 0 %>,
                        <%= onlinePayments != null ? onlinePayments : 0 %>
                    ],
                    backgroundColor: [
                        '#10b981', // Green - Cash
                        '#3b82f6', // Blue - Card
                        '#8b5cf6'  // Purple - Online
                    ],
                    borderWidth: 2,
                    borderColor: '#ffffff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { padding: 15, font: { size: 12 } }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const label = context.label || '';
                                const value = context.parsed || 0;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = total > 0 ? ((value / total) * 100).toFixed(1) : 0;
                                return label + ': ' + value + ' (' + percentage + '%)';
                            }
                        }
                    }
                }
            }
        });
        
        // 3. Room Status Bar Chart
        const roomStatusCtx = document.getElementById('roomStatusChart').getContext('2d');
        new Chart(roomStatusCtx, {
            type: 'bar',
            data: {
                labels: ['Available', 'Occupied', 'Total Rooms'],
                datasets: [{
                    label: 'Number of Rooms',
                    data: [
                        <%= availableRooms != null ? availableRooms : 0 %>,
                        <%= occupiedRooms != null ? occupiedRooms : 0 %>,
                        <%= totalRooms != null ? totalRooms : 0 %>
                    ],
                    backgroundColor: [
                        '#10b981', // Green - Available
                        '#ef4444', // Red - Occupied
                        '#3b82f6'  // Blue - Total
                    ],
                    borderRadius: 8,
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return context.label + ': ' + context.parsed.y + ' rooms';
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: { stepSize: 1 },
                        grid: { color: '#f3f4f6' }
                    },
                    x: {
                        grid: { display: false }
                    }
                }
            }
        });
        
        // 4. Reservation Trends Line Chart (Sample data - replace with real monthly data)
        const reservationTrendsCtx = document.getElementById('reservationTrendsChart').getContext('2d');
        new Chart(reservationTrendsCtx, {
            type: 'line',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                datasets: [{
                    label: 'Reservations',
                    data: [12, 19, 15, 25, 22, 30, 28, 35, 32, 38, 42, 45], // Sample data
                    borderColor: '#3b82f6',
                    backgroundColor: 'rgba(59, 130, 246, 0.1)',
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4,
                    pointRadius: 5,
                    pointHoverRadius: 7,
                    pointBackgroundColor: '#3b82f6',
                    pointBorderColor: '#ffffff',
                    pointBorderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return 'Reservations: ' + context.parsed.y;
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: { stepSize: 5 },
                        grid: { color: '#f3f4f6' }
                    },
                    x: {
                        grid: { display: false }
                    }
                }
            }
        });
    </script>
</body>
</html>
