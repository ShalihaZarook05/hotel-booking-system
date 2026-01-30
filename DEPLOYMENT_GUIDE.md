# 🚀 IntelliJ IDEA Deployment Guide - Ocean View Resort

## Problem: "deployment source 'OceanView:war exploded' is not valid"

This error occurs when IntelliJ IDEA's artifact configuration is incorrect or corrupted. Follow these steps to fix it.

---

## ✅ Solution 1: Reconfigure IntelliJ IDEA Artifacts (Recommended)

### Step 1: Delete Existing Artifact Configuration

1. Go to **File** → **Project Structure** (or press `Ctrl+Alt+Shift+S` on Windows/Linux, `Cmd+;` on Mac)
2. Select **Artifacts** in the left panel
3. If you see **OceanView:war exploded** or any artifact, select it and click the **minus (-)** button to remove it
4. Click **OK** to save

### Step 2: Reimport Maven Project

1. Open the **Maven** tool window (View → Tool Windows → Maven)
2. Click the **Reload All Maven Projects** button (circular arrows icon)
3. Wait for the import to complete

### Step 3: Create New Artifact

1. Go to **File** → **Project Structure** → **Artifacts**
2. Click the **plus (+)** button
3. Select **Web Application: Exploded** → **From Modules...**
4. Select your project module (should be named **OceanViewResort** or similar)
5. Click **OK**

**Artifact Configuration:**
- **Name**: `OceanViewResort:war exploded`
- **Type**: Web Application: Exploded
- **Output directory**: `{project-root}/target/OceanViewResort`

### Step 4: Verify Artifact Structure

In the Artifact configuration, ensure you have this structure:

```
OceanViewResort:war exploded
├── WEB-INF
│   ├── classes
│   │   └── com.oceanview (compiled classes)
│   ├── lib (dependencies)
│   └── web.xml
├── views (JSP files)
└── (other webapp resources)
```

### Step 5: Configure Tomcat Run Configuration

1. Go to **Run** → **Edit Configurations...**
2. If you have an existing Tomcat configuration, select it; otherwise, click **+** → **Tomcat Server** → **Local**
3. In the **Server** tab:
   - Set **HTTP port**: `8080` (or your preferred port)
   - Set **JRE**: Java 11 or higher

4. In the **Deployment** tab:
   - Click **+** → **Artifact...**
   - Select **OceanViewResort:war exploded**
   - Set **Application context**: `/OceanViewResort` (or just `/`)
   
5. Click **OK** to save

### Step 6: Clean and Rebuild

```bash
# In terminal or IntelliJ Terminal
mvn clean install
```

Or in IntelliJ:
1. **Build** → **Rebuild Project**

### Step 7: Run the Application

1. Click the **Run** button (green play icon)
2. Your application should deploy successfully
3. Access it at: `http://localhost:8080/OceanViewResort/`

---

## ✅ Solution 2: Use Maven Tomcat Plugin (Alternative)

If IntelliJ configuration continues to cause issues, use Maven's Tomcat plugin:

### Step 1: Add Tomcat Maven Plugin

Add this to your `pom.xml` (already configured in your project):

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.tomcat.maven</groupId>
            <artifactId>tomcat7-maven-plugin</artifactId>
            <version>2.2</version>
            <configuration>
                <port>8080</port>
                <path>/OceanViewResort</path>
            </configuration>
        </plugin>
    </plugins>
</build>
```

### Step 2: Run with Maven

```bash
mvn clean package tomcat7:run
```

Or in IntelliJ:
1. Open **Maven** tool window
2. Navigate to **Plugins** → **tomcat7** → **tomcat7:run**
3. Double-click to run

---

## ✅ Solution 3: Deploy WAR File Directly to Tomcat

### Step 1: Build WAR File

```bash
mvn clean package
```

This creates: `target/OceanViewResort.war`

### Step 2: Deploy to Tomcat

**Option A: Copy to Tomcat webapps**
```bash
# Windows
copy target\OceanViewResort.war C:\path\to\tomcat\webapps\

# Linux/Mac
cp target/OceanViewResort.war /path/to/tomcat/webapps/
```

**Option B: Use Tomcat Manager**
1. Access Tomcat Manager: `http://localhost:8080/manager/html`
2. Scroll to **WAR file to deploy**
3. Choose `target/OceanViewResort.war`
4. Click **Deploy**

### Step 3: Access Application

```
http://localhost:8080/OceanViewResort/
```

---

## 🔧 Common Issues & Fixes

### Issue 1: "Port 8080 already in use"

**Fix:**
```bash
# Windows - Find process using port 8080
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# Linux/Mac
lsof -i :8080
kill -9 <PID>
```

Or change the port in Tomcat configuration.

### Issue 2: "ClassNotFoundException" or "NoClassDefFoundError"

**Fix:**
1. Ensure all dependencies are in `WEB-INF/lib`
2. In IntelliJ Project Structure → Artifacts:
   - Make sure **Available Elements** shows your dependencies
   - Select all JARs and click **Put into /WEB-INF/lib**
3. Rebuild the artifact

### Issue 3: "Database connection failed"

**Fix:**
1. Ensure MySQL is running:
   ```bash
   # Windows
   net start MySQL80
   
   # Linux
   sudo systemctl start mysql
   ```

2. Update database credentials in:
   ```
   src/main/java/com/oceanview/util/DatabaseConnection.java
   ```

3. Create the database:
   ```bash
   mysql -u root -p < src/main/resources/database/schema.sql
   ```

### Issue 4: "404 Not Found" after deployment

**Possible causes:**
1. Wrong context path - Check your URL matches the deployment context
2. Welcome file not found - Ensure `home.jsp` exists in `src/main/webapp/`
3. Servlet mappings incorrect - Verify `web.xml` configuration

**Fix:**
- Access the correct URL: `http://localhost:8080/OceanViewResort/`
- Check Tomcat logs in IntelliJ Console for specific errors

### Issue 5: JSP pages not compiling

**Fix:**
1. Ensure Tomcat version supports Jakarta EE 9+ (Tomcat 10.x)
2. If using older Tomcat (9.x or below), downgrade to Java EE dependencies:
   ```xml
   <!-- Use javax instead of jakarta for Tomcat 9.x -->
   <dependency>
       <groupId>javax.servlet</groupId>
       <artifactId>javax.servlet-api</artifactId>
       <version>4.0.1</version>
   </dependency>
   ```

---

## 📋 Deployment Checklist

Before running the application, ensure:

- [ ] ✅ Java 11+ is installed and configured
- [ ] ✅ Maven dependencies are downloaded (`mvn clean install`)
- [ ] ✅ MySQL server is running
- [ ] ✅ Database schema is created (`ocean_view_resort`)
- [ ] ✅ Database credentials are configured in `DatabaseConnection.java`
- [ ] ✅ Tomcat 10.x is installed (for Jakarta EE 9+)
- [ ] ✅ IntelliJ artifact is properly configured
- [ ] ✅ Port 8080 is available (or configured to use another port)
- [ ] ✅ Project is rebuilt after configuration changes

---

## 🎯 Quick Start (Fresh Setup)

If you're setting up the project for the first time:

```bash
# 1. Clone the repository
git clone https://github.com/HamdhiHilmy/My-first.git
cd My-first

# 2. Build the project
mvn clean install

# 3. Setup database
mysql -u root -p < src/main/resources/database/schema.sql
mysql -u root -p ocean_view_resort < src/main/resources/database/sample_data.sql

# 4. Update database credentials
# Edit: src/main/java/com/oceanview/util/DatabaseConnection.java

# 5. Deploy to Tomcat using IntelliJ (follow Solution 1 above)
# OR use Maven plugin
mvn tomcat7:run

# 6. Access the application
# http://localhost:8080/OceanViewResort/
```

---

## 🆘 Still Having Issues?

### Enable Debug Logging

In IntelliJ Run Configuration:
1. **Run** → **Edit Configurations...**
2. Select your Tomcat configuration
3. Go to **Startup/Connection** tab
4. Add VM options:
   ```
   -Dorg.apache.catalina.startup.EXIT_ON_INIT_FAILURE=true
   ```

### Check Tomcat Logs

**Location:**
- IntelliJ: Check the **Run** console output
- Standalone Tomcat: `{TOMCAT_HOME}/logs/catalina.out`

**Look for:**
- Deployment errors
- ClassNotFoundException
- Database connection errors
- Port binding issues

### Verify Project Structure

Your project should look like this:

```
OceanViewResort/
├── src/
│   ├── main/
│   │   ├── java/
│   │   ├── resources/
│   │   └── webapp/
│   │       ├── views/
│   │       └── WEB-INF/
│   │           └── web.xml
│   └── test/
├── target/ (generated after build)
├── pom.xml
└── README.md
```

---

## 📚 Additional Resources

- [IntelliJ IDEA Web Application Deployment](https://www.jetbrains.com/help/idea/deploying-applications.html)
- [Apache Tomcat Documentation](https://tomcat.apache.org/tomcat-10.0-doc/)
- [Maven WAR Plugin](https://maven.apache.org/plugins/maven-war-plugin/)
- [Jakarta EE 9 Migration Guide](https://jakarta.ee/specifications/platform/9/)

---

**Need more help?** Create an issue on the [GitHub repository](https://github.com/HamdhiHilmy/My-first/issues) with:
- Full error message
- IntelliJ IDEA version
- JDK version
- Tomcat version
- Steps you've already tried

---

*Made with ❤️ for smooth deployment*
