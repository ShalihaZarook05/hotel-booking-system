<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - Ocean View Resort</title>
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .error-container {
            background: #fff;
            border-radius: 20px;
            padding: 3rem;
            text-align: center;
            max-width: 600px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }
        
        .error-icon {
            font-size: 5rem;
            margin-bottom: 1rem;
        }
        
        h1 {
            color: #1e3a8a;
            font-size: 2.5rem;
            margin-bottom: 1rem;
        }
        
        p {
            color: #6b7280;
            font-size: 1.1rem;
            margin-bottom: 2rem;
        }
        
        .btn {
            display: inline-block;
            padding: 1rem 2rem;
            background: linear-gradient(135deg, #1e3a8a, #0d9488);
            color: #fff;
            text-decoration: none;
            border-radius: 25px;
            font-weight: 600;
            transition: transform 0.3s;
        }
        
        .btn:hover {
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">😕</div>
        <h1>Oops! Something went wrong</h1>
        <p>We couldn't find the page you're looking for.</p>
        <a href="<%= request.getContextPath() %>/" class="btn">← Back to Home</a>
    </div>
</body>
</html>
