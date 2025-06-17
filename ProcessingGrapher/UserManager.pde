/* * * * * * * * * * * * * * * * * * * * * * *
 * USER MANAGER CLASS
 *
 * @file     UserManager.pde
 * @brief    User authentication and role management
 * @author   Processing Grapher Team
 *
 * @license  GNU General Public License v3
 * @class    UserManager
 * * * * * * * * * * * * * * * * * * * * * * */

/*
 * Copyright (C) 2024 - Processing Grapher Team
 *
 * This file is part of ProcessingGrapher 
 * <https://github.com/chillibasket/processing-grapher>
 * 
 * ProcessingGrapher is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

class UserManager {
    
    // User roles
    static final int ROLE_GUEST = 0;
    static final int ROLE_USER = 1;
    static final int ROLE_ADMIN = 2;
    
    // Current session
    private String currentUsername = "";
    private int currentUserRole = ROLE_GUEST;
    private boolean isLoggedIn = false;
    
    // User database (in production, this would be stored securely)
    private HashMap<String, UserAccount> users;
    
    // Session timeout (in milliseconds)
    private long sessionTimeout = 30 * 60 * 1000; // 30 minutes
    private long lastActivity = 0;
    
    /**
     * Constructor
     */
    UserManager() {
        users = new HashMap<String, UserAccount>();
        loadUsers();
        lastActivity = millis();
    }
    
    /**
     * User account class
     */
    class UserAccount {
        String username;
        String passwordHash;
        int role;
        boolean isActive;
        long lastLogin;
        
        UserAccount(String username, String passwordHash, int role) {
            this.username = username;
            this.passwordHash = passwordHash;
            this.role = role;
            this.isActive = true;
            this.lastLogin = 0;
        }
    }
    
    /**
     * Load users from configuration file
     */
    void loadUsers() {
        try {
            if (dataFile("users.xml").isFile()) {
                XML xmlFile = loadXML("users.xml");
                XML[] userNodes = xmlFile.getChildren("user");
                
                for (XML userNode : userNodes) {
                    String username = userNode.getString("username");
                    String passwordHash = userNode.getString("password-hash");
                    int role = userNode.getInt("role", ROLE_USER);
                    boolean isActive = userNode.getInt("active", 1) == 1;
                    
                    UserAccount account = new UserAccount(username, passwordHash, role);
                    account.isActive = isActive;
                    users.put(username, account);
                }
            } else {
                // Create default admin account if no users file exists
                createDefaultAdmin();
            }
        } catch (Exception e) {
            println("Error loading users: " + e);
            createDefaultAdmin();
        }
    }
    
    /**
     * Save users to configuration file
     */
    void saveUsers() {
        try {
            XML xmlFile = new XML("users");
            
            for (UserAccount account : users.values()) {
                XML userNode = xmlFile.addChild("user");
                userNode.setString("username", account.username);
                userNode.setString("password-hash", account.passwordHash);
                userNode.setInt("role", account.role);
                userNode.setInt("active", account.isActive ? 1 : 0);
            }
            
            saveXML(xmlFile, "data/users.xml");
        } catch (Exception e) {
            println("Error saving users: " + e);
        }
    }
    
    /**
     * Create default admin account
     */
    void createDefaultAdmin() {
        String defaultPassword = "admin123";
        String hashedPassword = hashPassword(defaultPassword);
        UserAccount admin = new UserAccount("admin", hashedPassword, ROLE_ADMIN);
        users.put("admin", admin);
        
        // Also create a default user account
        String userPassword = "user123";
        String hashedUserPassword = hashPassword(userPassword);
        UserAccount user = new UserAccount("user", hashedUserPassword, ROLE_USER);
        users.put("user", user);
        
        saveUsers();
        println("Default accounts created:");
        println("Admin - Username: admin, Password: admin123");
        println("User - Username: user, Password: user123");
    }
    
    /**
     * Hash password using SHA-256
     */
    String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes("UTF-8"));
            return Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) {
            println("Error hashing password: " + e);
            return password; // Fallback (not secure)
        }
    }
    
    /**
     * Authenticate user
     */
    boolean login(String username, String password) {
        UserAccount account = users.get(username);
        
        if (account != null && account.isActive) {
            String hashedPassword = hashPassword(password);
            if (account.passwordHash.equals(hashedPassword)) {
                currentUsername = username;
                currentUserRole = account.role;
                isLoggedIn = true;
                account.lastLogin = millis();
                lastActivity = millis();
                return true;
            }
        }
        return false;
    }
    
    /**
     * Logout current user
     */
    void logout() {
        currentUsername = "";
        currentUserRole = ROLE_GUEST;
        isLoggedIn = false;
        lastActivity = 0;
    }
    
    /**
     * Check if session is still valid
     */
    boolean isSessionValid() {
        if (!isLoggedIn) return false;
        
        long currentTime = millis();
        if (currentTime - lastActivity > sessionTimeout) {
            logout();
            return false;
        }
        return true;
    }
    
    /**
     * Update last activity time
     */
    void updateActivity() {
        if (isLoggedIn) {
            lastActivity = millis();
        }
    }
    
    /**
     * Get current user role
     */
    int getCurrentUserRole() {
        if (!isSessionValid()) return ROLE_GUEST;
        return currentUserRole;
    }
    
    /**
     * Get current username
     */
    String getCurrentUsername() {
        if (!isSessionValid()) return "Guest";
        return currentUsername;
    }
    
    /**
     * Check if user is logged in
     */
    boolean isUserLoggedIn() {
        return isSessionValid();
    }
    
    /**
     * Check if current user has admin privileges
     */
    boolean isAdmin() {
        return getCurrentUserRole() == ROLE_ADMIN;
    }
    
    /**
     * Check if current user has user privileges or higher
     */
    boolean isUser() {
        return getCurrentUserRole() >= ROLE_USER;
    }
    
    /**
     * Check if user has permission for specific action
     */
    boolean hasPermission(String action) {
        int role = getCurrentUserRole();
        
        switch (action) {
            case "view_data":
                return role >= ROLE_GUEST;
            case "record_data":
                return role >= ROLE_USER;
            case "save_files":
                return role >= ROLE_USER;
            case "modify_settings":
                return role >= ROLE_USER;
            case "advanced_settings":
                return role >= ROLE_ADMIN;
            case "user_management":
                return role >= ROLE_ADMIN;
            case "system_settings":
                return role >= ROLE_ADMIN;
            default:
                return false;
        }
    }
    
    /**
     * Add new user (admin only)
     */
    boolean addUser(String username, String password, int role) {
        if (!isAdmin()) return false;
        
        if (users.containsKey(username)) {
            return false; // User already exists
        }
        
        String hashedPassword = hashPassword(password);
        UserAccount newAccount = new UserAccount(username, hashedPassword, role);
        users.put(username, newAccount);
        saveUsers();
        return true;
    }
    
    /**
     * Remove user (admin only)
     */
    boolean removeUser(String username) {
        if (!isAdmin()) return false;
        if (username.equals(currentUsername)) return false; // Can't remove self
        
        users.remove(username);
        saveUsers();
        return true;
    }
    
    /**
     * Change user password
     */
    boolean changePassword(String username, String oldPassword, String newPassword) {
        // Users can change their own password, admins can change any password
        if (!username.equals(currentUsername) && !isAdmin()) {
            return false;
        }
        
        UserAccount account = users.get(username);
        if (account == null) return false;
        
        // If not admin, verify old password
        if (!isAdmin() || username.equals(currentUsername)) {
            String hashedOldPassword = hashPassword(oldPassword);
            if (!account.passwordHash.equals(hashedOldPassword)) {
                return false;
            }
        }
        
        account.passwordHash = hashPassword(newPassword);
        saveUsers();
        return true;
    }
    
    /**
     * Get list of all users (admin only)
     */
    String[] getUserList() {
        if (!isAdmin()) return new String[0];
        
        String[] userList = new String[users.size()];
        int i = 0;
        for (String username : users.keySet()) {
            UserAccount account = users.get(username);
            String roleStr = getRoleString(account.role);
            String status = account.isActive ? "Active" : "Inactive";
            userList[i] = username + " (" + roleStr + ") - " + status;
            i++;
        }
        return userList;
    }
    
    /**
     * Get role string
     */
    String getRoleString(int role) {
        switch (role) {
            case ROLE_ADMIN: return "Admin";
            case ROLE_USER: return "User";
            case ROLE_GUEST: return "Guest";
            default: return "Unknown";
        }
    }
    
    /**
     * Toggle user active status (admin only)
     */
    boolean toggleUserStatus(String username) {
        if (!isAdmin()) return false;
        if (username.equals(currentUsername)) return false; // Can't disable self
        
        UserAccount account = users.get(username);
        if (account == null) return false;
        
        account.isActive = !account.isActive;
        saveUsers();
        return true;
    }
    
    /**
     * Get remaining session time in minutes
     */
    int getRemainingSessionTime() {
        if (!isLoggedIn) return 0;
        
        long remaining = sessionTimeout - (millis() - lastActivity);
        return (int)(remaining / (60 * 1000));
    }
}