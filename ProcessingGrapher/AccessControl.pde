/* * * * * * * * * * * * * * * * * * * * * * *
 * ACCESS CONTROL HELPER FUNCTIONS
 *
 * @file     AccessControl.pde
 * @brief    Helper functions for access control throughout the application
 * @author   Processing Grapher Team
 *
 * @license  GNU General Public License v3
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

// Global instances
UserManager userManager;
LoginDialog loginDialog;

/**
 * Initialize access control system
 */
void initializeAccessControl() {
    userManager = new UserManager();
    loginDialog = new LoginDialog();
}

/**
 * Check if user has permission to perform an action
 * Shows appropriate error message if access is denied
 *
 * @param  action The action to check permission for
 * @return True if user has permission, false otherwise
 */
boolean checkPermission(String action) {
    if (!userManager.hasPermission(action)) {
        String message = "Access Denied\n";
        
        switch (action) {
            case "record_data":
                message += "You need user privileges or higher to record data.\nPlease login with appropriate credentials.";
                break;
            case "save_files":
                message += "You need user privileges or higher to save files.\nPlease login with appropriate credentials.";
                break;
            case "modify_settings":
                message += "You need user privileges or higher to modify settings.\nPlease login with appropriate credentials.";
                break;
            case "advanced_settings":
                message += "You need administrator privileges to access advanced settings.\nPlease login as an administrator.";
                break;
            case "user_management":
                message += "You need administrator privileges to manage users.\nPlease login as an administrator.";
                break;
            case "system_settings":
                message += "You need administrator privileges to modify system settings.\nPlease login as an administrator.";
                break;
            default:
                message += "You do not have permission to perform this action.";
                break;
        }
        
        alertMessage(message);
        return false;
    }
    return true;
}

/**
 * Show login dialog if user is not logged in
 */
void promptLogin() {
    if (!userManager.isUserLoggedIn()) {
        loginDialog.show();
    }
}

/**
 * Get user status string for display
 */
String getUserStatusString() {
    if (userManager.isUserLoggedIn()) {
        return userManager.getCurrentUsername() + " (" + userManager.getRoleString(userManager.getCurrentUserRole()) + ")";
    } else {
        return "Guest";
    }
}

/**
 * Check if current user can access a specific tab
 */
boolean canAccessTab(String tabName) {
    switch (tabName) {
        case "Serial":
            return userManager.hasPermission("view_data");
        case "Live Graph":
            return userManager.hasPermission("view_data");
        case "File Graph":
            return userManager.hasPermission("view_data");
        case "Settings":
            return userManager.hasPermission("modify_settings");
        case "User Management":
            return userManager.hasPermission("user_management");
        default:
            return true;
    }
}

/**
 * Get restricted message for tab access
 */
String getTabAccessMessage(String tabName) {
    switch (tabName) {
        case "Settings":
            return "User privileges required to access settings.";
        case "User Management":
            return "Administrator privileges required for user management.";
        default:
            return "Access restricted.";
    }
}

/**
 * Update user activity (call this on user interactions)
 */
void updateUserActivity() {
    if (userManager != null) {
        userManager.updateActivity();
    }
}

/**
 * Show option dialog with multiple choices
 */
String myShowOptionDialog(String title, String message, String[] options) {
    // Simple implementation - in a real application, you might want a more sophisticated dialog
    String optionsStr = "";
    for (int i = 0; i < options.length; i++) {
        optionsStr += (i + 1) + ". " + options[i] + "\n";
    }
    
    String input = myShowInputDialog(title, message + "\n\n" + optionsStr + "\nEnter choice number:", "");
    if (input != null && !input.trim().equals("")) {
        try {
            int choice = Integer.parseInt(input.trim());
            if (choice >= 1 && choice <= options.length) {
                return options[choice - 1];
            }
        } catch (NumberFormatException e) {
            // Invalid input
        }
    }
    return null;
}

/**
 * Enhanced file selection with permission check
 */
void selectOutputWithPermission(String prompt, String callback) {
    if (checkPermission("save_files")) {
        selectOutput(prompt, callback);
    }
}

/**
 * Enhanced file opening with permission check
 */
void selectInputWithPermission(String prompt, String callback) {
    if (checkPermission("view_data")) {
        selectInput(prompt, callback);
    }
}