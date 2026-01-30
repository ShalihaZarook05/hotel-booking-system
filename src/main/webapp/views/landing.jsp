<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Ocean View Resort - Luxury beachside hotel in Galle, Sri Lanka">
    <title>Ocean View Resort - Your Paradise Awaits</title>
    
    <style>
        /* ==================== RESET & BASE STYLES ==================== */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            overflow-x: hidden;
        }
        
        /* ==================== NAVIGATION BAR ==================== */
        .navbar {
            position: fixed;
            top: 0;
            width: 100%;
            background: rgba(30, 58, 138, 0.95);
            backdrop-filter: blur(10px);
            padding: 1rem 5%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            z-index: 1000;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .navbar .logo {
            font-size: 1.8rem;
            font-weight: bold;
            color: #fff;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .navbar .logo span {
            color: #f59e0b;
        }
        
        .navbar .nav-links {
            display: flex;
            gap: 2rem;
            list-style: none;
        }
        
        .navbar .nav-links a {
            color: #fff;
            text-decoration: none;
            font-weight: 500;
            transition: color 0.3s;
        }
        
        .navbar .nav-links a:hover {
            color: #f59e0b;
        }
        
        .navbar .auth-buttons {
            display: flex;
            gap: 1rem;
        }
        
        .btn {
            padding: 0.6rem 1.5rem;
            border: none;
            border-radius: 25px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-primary {
            background: #f59e0b;
            color: #fff;
        }
        
        .btn-primary:hover {
            background: #d97706;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(245, 158, 11, 0.3);
        }
        
        .btn-secondary {
            background: transparent;
            color: #fff;
            border: 2px solid #fff;
        }
        
        .btn-secondary:hover {
            background: #fff;
            color: #1e3a8a;
        }
        
        /* ==================== HERO SECTION ==================== */
        .hero {
            height: 100vh;
            background: linear-gradient(rgba(30, 58, 138, 0.4), rgba(13, 148, 136, 0.4)),
                        url('https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=1920') center/cover no-repeat;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            color: #fff;
            position: relative;
        }
        
        .hero-content {
            max-width: 800px;
            padding: 2rem;
            animation: fadeInUp 1s ease;
        }
        
        .hero h1 {
            font-size: 4rem;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 10px rgba(0,0,0,0.3);
        }
        
        .hero p {
            font-size: 1.5rem;
            margin-bottom: 2rem;
            text-shadow: 1px 1px 5px rgba(0,0,0,0.3);
        }
        
        .hero .btn-group {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .hero .btn {
            padding: 1rem 2rem;
            font-size: 1.1rem;
        }
        
        /* ==================== FEATURES SECTION ==================== */
        .features {
            padding: 5rem 5%;
            background: #fff;
        }
        
        .section-title {
            text-align: center;
            font-size: 2.5rem;
            color: #1e3a8a;
            margin-bottom: 3rem;
        }
        
        .section-title span {
            color: #f59e0b;
        }
        
        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .feature-card {
            text-align: center;
            padding: 2rem;
            background: #f9fafb;
            border-radius: 15px;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .feature-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        
        .feature-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
        }
        
        .feature-card h3 {
            color: #1e3a8a;
            margin-bottom: 1rem;
        }
        
        /* ==================== ROOMS SECTION ==================== */
        .rooms {
            padding: 5rem 5%;
            background: linear-gradient(135deg, #fef3c7 0%, #e0f2fe 100%);
        }
        
        .rooms-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .room-card {
            background: #fff;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            transition: transform 0.3s;
        }
        
        .room-card:hover {
            transform: scale(1.05);
        }
        
        .room-card img {
            width: 100%;
            height: 250px;
            object-fit: cover;
        }
        
        .room-info {
            padding: 1.5rem;
        }
        
        .room-info h3 {
            color: #1e3a8a;
            margin-bottom: 0.5rem;
        }
        
        .room-price {
            color: #f59e0b;
            font-size: 1.5rem;
            font-weight: bold;
            margin: 1rem 0;
        }
        
        .room-features {
            display: flex;
            gap: 1rem;
            margin: 1rem 0;
            flex-wrap: wrap;
        }
        
        .room-features span {
            background: #e0f2fe;
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.9rem;
            color: #1e3a8a;
        }
        
        /* ==================== GALLERY SECTION ==================== */
        .gallery {
            padding: 5rem 5%;
            background: #fff;
        }
        
        .gallery-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1rem;
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .gallery-item {
            position: relative;
            overflow: hidden;
            border-radius: 10px;
            height: 250px;
            cursor: pointer;
        }
        
        .gallery-item img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.5s;
        }
        
        .gallery-item:hover img {
            transform: scale(1.1);
        }
        
        .gallery-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(30, 58, 138, 0.7);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 1.5rem;
            opacity: 0;
            transition: opacity 0.3s;
        }
        
        .gallery-item:hover .gallery-overlay {
            opacity: 1;
        }
        
        /* ==================== FOOTER ==================== */
        .footer {
            background: #1e3a8a;
            color: #fff;
            padding: 3rem 5%;
            text-align: center;
        }
        
        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2rem;
            text-align: left;
        }
        
        .footer-section h3 {
            color: #f59e0b;
            margin-bottom: 1rem;
        }
        
        .footer-section p, .footer-section a {
            color: #e0f2fe;
            text-decoration: none;
            display: block;
            margin-bottom: 0.5rem;
        }
        
        .footer-section a:hover {
            color: #f59e0b;
        }
        
        .footer-bottom {
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid rgba(255,255,255,0.1);
            text-align: center;
        }
        
        /* ==================== ANIMATIONS ==================== */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        /* ==================== RESPONSIVE ==================== */
        @media (max-width: 768px) {
            .navbar {
                flex-direction: column;
                gap: 1rem;
            }
            
            .hero h1 {
                font-size: 2.5rem;
            }
            
            .hero p {
                font-size: 1.2rem;
            }
            
            .section-title {
                font-size: 2rem;
            }
        }
    </style>
</head>
<body>
    
    <!-- NAVIGATION -->
    <nav class="navbar">
        <a href="#" class="logo">
            🏖️ Ocean View <span>Resort</span>
        </a>
        <ul class="nav-links">
            <li><a href="#home">Home</a></li>
            <li><a href="#rooms">Rooms</a></li>
            <li><a href="#gallery">Gallery</a></li>
            <li><a href="#contact">Contact</a></li>
        </ul>
        <div class="auth-buttons">
            <a href="<%= request.getContextPath() %>/login" class="btn btn-secondary">Login</a>
            <a href="<%= request.getContextPath() %>/register" class="btn btn-primary">Book Now</a>
        </div>
    </nav>
    
    <!-- HERO SECTION -->
    <section id="home" class="hero">
        <div class="hero-content">
            <h1>Welcome to Paradise</h1>
            <p>Experience luxury beachside living in beautiful Galle, Sri Lanka</p>
            <div class="btn-group">
                <a href="<%= request.getContextPath() %>/register" class="btn btn-primary">Book Your Stay</a>
                <a href="#rooms" class="btn btn-secondary">Explore Rooms</a>
            </div>
        </div>
    </section>
    
    <!-- FEATURES SECTION -->
    <section class="features">
        <h2 class="section-title">Why Choose <span>Ocean View Resort?</span></h2>
        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon">🏖️</div>
                <h3>Beachfront Location</h3>
                <p>Direct access to pristine sandy beaches with breathtaking ocean views</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">🍽️</div>
                <h3>Gourmet Dining</h3>
                <p>Experience world-class cuisine with fresh seafood and local delicacies</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">💆</div>
                <h3>Spa & Wellness</h3>
                <p>Rejuvenate with our luxury spa treatments and wellness programs</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">🏊</div>
                <h3>Infinity Pool</h3>
                <p>Relax by our stunning infinity pool overlooking the Indian Ocean</p>
            </div>
        </div>
    </section>
    
    <!-- ROOMS SECTION -->
    <section id="rooms" class="rooms">
        <h2 class="section-title">Our <span>Luxury Rooms</span></h2>
        <p style="text-align: center; max-width: 800px; margin: -1rem auto 3rem; color: #374151; font-size: 1.1rem;">
            Choose from our carefully curated selection of rooms, each designed to provide the ultimate comfort and luxury during your stay
        </p>
        <div class="rooms-grid">
            
            <!-- Standard Room -->
            <div class="room-card">
                <img src="https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=600" alt="Standard Room">
                <div class="room-info">
                    <h3>🛏️ Standard Room</h3>
                    <p>Cozy and comfortable room perfect for solo travelers or couples. Features modern amenities with garden or courtyard views.</p>
                    <div class="room-price">LKR 8,500 <span style="font-size: 0.8rem; color: #666;">/night</span></div>
                    <div class="room-features">
                        <span>👥 2 Guests</span>
                        <span>📱 Free WiFi</span>
                        <span>❄️ Air Conditioning</span>
                        <span>📺 Smart TV</span>
                        <span>🚿 Hot Shower</span>
                        <span>☕ Tea/Coffee</span>
                    </div>
                    <ul style="list-style: none; padding: 1rem 0; font-size: 0.9rem; color: #666;">
                        <li>✓ 25 sqm room size</li>
                        <li>✓ Queen-size bed</li>
                        <li>✓ Daily housekeeping</li>
                        <li>✓ Complimentary breakfast</li>
                    </ul>
                    <a href="<%= request.getContextPath() %>/register" class="btn btn-primary" style="width: 100%; text-align: center; margin-top: 1rem;">Book Now</a>
                </div>
            </div>
            
            <!-- Deluxe Room -->
            <div class="room-card">
                <img src="https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=600" alt="Deluxe Room">
                <div class="room-info">
                    <h3>🌊 Deluxe Ocean View</h3>
                    <p>Spacious room with breathtaking ocean views from your private balcony. Enhanced comfort with premium furnishings and amenities.</p>
                    <div class="room-price">LKR 15,000 <span style="font-size: 0.8rem; color: #666;">/night</span></div>
                    <div class="room-features">
                        <span>👥 2-3 Guests</span>
                        <span>🌊 Ocean View</span>
                        <span>🏖️ Private Balcony</span>
                        <span>🍷 Mini Bar</span>
                        <span>🛁 Bathtub</span>
                        <span>📱 Free WiFi</span>
                    </div>
                    <ul style="list-style: none; padding: 1rem 0; font-size: 0.9rem; color: #666;">
                        <li>✓ 35 sqm room size</li>
                        <li>✓ King-size bed</li>
                        <li>✓ Premium toiletries</li>
                        <li>✓ Room service 24/7</li>
                        <li>✓ Complimentary breakfast & dinner</li>
                    </ul>
                    <a href="<%= request.getContextPath() %>/register" class="btn btn-primary" style="width: 100%; text-align: center; margin-top: 1rem;">Book Now</a>
                </div>
            </div>
            
            <!-- Suite -->
            <div class="room-card">
                <img src="https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=600" alt="Luxury Suite">
                <div class="room-info">
                    <h3>👑 Presidential Suite</h3>
                    <p>The epitome of luxury living. Panoramic ocean views, separate living area, and personalized butler service for an unforgettable experience.</p>
                    <div class="room-price">LKR 35,000 <span style="font-size: 0.8rem; color: #666;">/night</span></div>
                    <div class="room-features">
                        <span>👥 4-6 Guests</span>
                        <span>🌅 Panoramic View</span>
                        <span>🛀 Jacuzzi</span>
                        <span>🤵 Butler Service</span>
                        <span>🍽️ Dining Area</span>
                        <span>💼 Work Desk</span>
                    </div>
                    <ul style="list-style: none; padding: 1rem 0; font-size: 0.9rem; color: #666;">
                        <li>✓ 80 sqm suite with living room</li>
                        <li>✓ Master bedroom + guest room</li>
                        <li>✓ Private terrace with loungers</li>
                        <li>✓ Premium sound system</li>
                        <li>✓ Complimentary spa treatment</li>
                        <li>✓ Airport transfers included</li>
                    </ul>
                    <a href="<%= request.getContextPath() %>/register" class="btn btn-primary" style="width: 100%; text-align: center; margin-top: 1rem;">Book Now</a>
                </div>
            </div>
            
            <!-- Family Suite -->
            <div class="room-card">
                <img src="https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=600" alt="Family Suite">
                <div class="room-info">
                    <h3>👨‍👩‍👧‍👦 Family Suite</h3>
                    <p>Perfect for families seeking comfort and space. Two bedrooms, spacious living area, and all the amenities for a memorable family vacation.</p>
                    <div class="room-price">LKR 22,000 <span style="font-size: 0.8rem; color: #666;">/night</span></div>
                    <div class="room-features">
                        <span>👥 4-5 Guests</span>
                        <span>🏡 2 Bedrooms</span>
                        <span>🛋️ Living Room</span>
                        <span>🍳 Kitchenette</span>
                        <span>🎮 Kids Area</span>
                        <span>🌳 Garden View</span>
                    </div>
                    <ul style="list-style: none; padding: 1rem 0; font-size: 0.9rem; color: #666;">
                        <li>✓ 55 sqm family suite</li>
                        <li>✓ 1 King bed + 2 Single beds</li>
                        <li>✓ Baby cot available</li>
                        <li>✓ Kids welcome amenities</li>
                        <li>✓ Complimentary meals for kids</li>
                        <li>✓ Board games & toys</li>
                    </ul>
                    <a href="<%= request.getContextPath() %>/register" class="btn btn-primary" style="width: 100%; text-align: center; margin-top: 1rem;">Book Now</a>
                </div>
            </div>
            
            <!-- Honeymoon Suite -->
            <div class="room-card">
                <img src="https://images.unsplash.com/photo-1591088398332-8a7791972843?w=600" alt="Honeymoon Suite">
                <div class="room-info">
                    <h3>💕 Honeymoon Suite</h3>
                    <p>Romance and luxury combined. Intimate setting with ocean views, private pool access, and special honeymoon amenities for your special celebration.</p>
                    <div class="room-price">LKR 28,000 <span style="font-size: 0.8rem; color: #666;">/night</span></div>
                    <div class="room-features">
                        <span>👥 2 Guests</span>
                        <span>💑 Romantic Decor</span>
                        <span>🏊 Pool Access</span>
                        <span>🛀 Luxury Bath</span>
                        <span>🥂 Champagne</span>
                        <span>🌹 Rose Petals</span>
                    </div>
                    <ul style="list-style: none; padding: 1rem 0; font-size: 0.9rem; color: #666;">
                        <li>✓ 45 sqm romantic suite</li>
                        <li>✓ Four-poster king bed</li>
                        <li>✓ Candlelight dinner setup</li>
                        <li>✓ Couple's spa package</li>
                        <li>✓ Sunset cruise included</li>
                        <li>✓ Photographer session</li>
                    </ul>
                    <a href="<%= request.getContextPath() %>/register" class="btn btn-primary" style="width: 100%; text-align: center; margin-top: 1rem;">Book Now</a>
                </div>
            </div>
            
            <!-- Executive Room -->
            <div class="room-card">
                <img src="https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=600" alt="Executive Room">
                <div class="room-info">
                    <h3>💼 Executive Room</h3>
                    <p>Designed for business travelers. Modern workspace, high-speed internet, and all business amenities while enjoying resort comforts.</p>
                    <div class="room-price">LKR 12,500 <span style="font-size: 0.8rem; color: #666;">/night</span></div>
                    <div class="room-features">
                        <span>👥 2 Guests</span>
                        <span>💻 Work Desk</span>
                        <span>📞 Phone Line</span>
                        <span>🖨️ Printer Access</span>
                        <span>☕ Coffee Machine</span>
                        <span>📱 Fast WiFi</span>
                    </div>
                    <ul style="list-style: none; padding: 1rem 0; font-size: 0.9rem; color: #666;">
                        <li>✓ 30 sqm business-friendly room</li>
                        <li>✓ Ergonomic work setup</li>
                        <li>✓ Meeting room access</li>
                        <li>✓ Express laundry service</li>
                        <li>✓ Business center facilities</li>
                        <li>✓ Late checkout available</li>
                    </ul>
                    <a href="<%= request.getContextPath() %>/register" class="btn btn-primary" style="width: 100%; text-align: center; margin-top: 1rem;">Book Now</a>
                </div>
            </div>
            
        </div>
        
        <!-- Additional Information -->
        <div style="max-width: 1200px; margin: 3rem auto; padding: 2rem; background: white; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.1);">
            <h3 style="color: #1e3a8a; text-align: center; margin-bottom: 2rem; font-size: 1.8rem;">✨ All Rooms Include</h3>
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; text-align: center;">
                <div>
                    <div style="font-size: 2.5rem; margin-bottom: 0.5rem;">🍽️</div>
                    <h4 style="color: #1e3a8a; margin-bottom: 0.5rem;">Dining</h4>
                    <p style="color: #666; font-size: 0.9rem;">Complimentary breakfast buffet daily</p>
                </div>
                <div>
                    <div style="font-size: 2.5rem; margin-bottom: 0.5rem;">🏊</div>
                    <h4 style="color: #1e3a8a; margin-bottom: 0.5rem;">Pool Access</h4>
                    <p style="color: #666; font-size: 0.9rem;">Infinity pool & beach access</p>
                </div>
                <div>
                    <div style="font-size: 2.5rem; margin-bottom: 0.5rem;">🅿️</div>
                    <h4 style="color: #1e3a8a; margin-bottom: 0.5rem;">Parking</h4>
                    <p style="color: #666; font-size: 0.9rem;">Free valet parking service</p>
                </div>
                <div>
                    <div style="font-size: 2.5rem; margin-bottom: 0.5rem;">🏋️</div>
                    <h4 style="color: #1e3a8a; margin-bottom: 0.5rem;">Fitness</h4>
                    <p style="color: #666; font-size: 0.9rem;">24/7 gym & yoga sessions</p>
                </div>
                <div>
                    <div style="font-size: 2.5rem; margin-bottom: 0.5rem;">🧳</div>
                    <h4 style="color: #1e3a8a; margin-bottom: 0.5rem;">Concierge</h4>
                    <p style="color: #666; font-size: 0.9rem;">24/7 concierge services</p>
                </div>
                <div>
                    <div style="font-size: 2.5rem; margin-bottom: 0.5rem;">🛡️</div>
                    <h4 style="color: #1e3a8a; margin-bottom: 0.5rem;">Security</h4>
                    <p style="color: #666; font-size: 0.9rem;">In-room safe & 24/7 security</p>
                </div>
            </div>
            
            <div style="margin-top: 2rem; padding: 1.5rem; background: #fef3c7; border-radius: 10px; text-align: center;">
                <p style="color: #92400e; font-size: 1.1rem; font-weight: 600; margin-bottom: 0.5rem;">🎉 Special Offer!</p>
                <p style="color: #78350f;">Book 3 nights or more and get <strong>15% OFF</strong> + Free airport pickup!</p>
            </div>
        </div>
    </section>
    
    <!-- GALLERY SECTION -->
    <section id="gallery" class="gallery">
        <h2 class="section-title">Explore Our <span>Resort</span></h2>
        <div class="gallery-grid">
            <div class="gallery-item">
                <img src="https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600" alt="Resort View">
                <div class="gallery-overlay">Beach View</div>
            </div>
            <div class="gallery-item">
                <img src="https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=600" alt="Pool">
                <div class="gallery-overlay">Infinity Pool</div>
            </div>
            <div class="gallery-item">
                <img src="https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=600" alt="Restaurant">
                <div class="gallery-overlay">Restaurant</div>
            </div>
            <div class="gallery-item">
                <img src="https://images.unsplash.com/photo-1540541338287-41700207dee6?w=600" alt="Spa">
                <div class="gallery-overlay">Spa & Wellness</div>
            </div>
            <div class="gallery-item">
                <img src="https://images.unsplash.com/photo-1596436889106-be35e843f974?w=600" alt="Sunset">
                <div class="gallery-overlay">Sunset View</div>
            </div>
            <div class="gallery-item">
                <img src="https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=600" alt="Beach Activities">
                <div class="gallery-overlay">Beach Activities</div>
            </div>
        </div>
    </section>
    
    <!-- FOOTER -->
    <footer id="contact" class="footer">
        <div class="footer-content">
            <div class="footer-section">
                <h3>Ocean View Resort</h3>
                <p>Experience paradise at Sri Lanka's premier beachside destination</p>
                <p>📍 123 Beach Road, Galle, Sri Lanka</p>
                <p>📞 +94 91 234 5678</p>
                <p>✉️ info@oceanviewresort.lk</p>
            </div>
            <div class="footer-section">
                <h3>Quick Links</h3>
                <a href="#home">Home</a>
                <a href="#rooms">Rooms</a>
                <a href="#gallery">Gallery</a>
                <a href="<%= request.getContextPath() %>/login">Login</a>
                <a href="<%= request.getContextPath() %>/register">Register</a>
            </div>
            <div class="footer-section">
                <h3>Services</h3>
                <a href="#">Room Service</a>
                <a href="#">Spa & Wellness</a>
                <a href="#">Restaurant</a>
                <a href="#">Beach Activities</a>
                <a href="#">Event Planning</a>
            </div>
            <div class="footer-section">
                <h3>Follow Us</h3>
                <a href="#">Facebook</a>
                <a href="#">Instagram</a>
                <a href="#">Twitter</a>
                <a href="#">TripAdvisor</a>
            </div>
        </div>
        <div class="footer-bottom">
            <p>&copy; 2026 Ocean View Resort. All Rights Reserved.</p>
        </div>
    </footer>
    
</body>
</html>
