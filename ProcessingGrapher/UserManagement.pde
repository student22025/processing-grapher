/* * * * * * * * * * * * * * * * * * * * * * *
 * USER MANAGEMENT TAB CLASS
 * implements TabAPI for Processing Grapher
 *
 * @file     UserManagement.pde
 * @brief    User management interface for admins
 * @author   Processing Grapher Team
 *
 * @license  GNU General Public License v3
 * @class    UserManagement
 * @see      TabAPI <ProcessingGrapher.pde>
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

class UserManagement implements TabAPI {

    int cL, cR, cT, cB;     // Content coordinates (left, right, top bottom)
    int menuScroll;
    int menuHeight;
    int menuLevel;
    ScrollBar sidebarScroll = new ScrollBar(ScrollBar.VERTICAL, ScrollBar.NORMAL);

    String name;
    boolean tabIsVisible = false;
    String[] userList = {};

    /**
     * Constructor
     *
     * @param  setname Name of the tab
     * @param  left    Tab area left x-coordinate
     * @param  right   Tab area right x-coordinate
     * @param  top     Tab area top y-coordinate
     * @param  bottom  Tab area bottom y-coordinate
     */
    UserManagement (String setname, int left, int right, int top, int bottom) {
        name = setname;
        
        cL = left;
        cR = right;
        cT = top;
        cB = bottom;

        menuScroll = 0;
        menuHeight = cB - cT - 1; 
        menuLevel = 0;
    }

    /**
     * Get the name of the current tab
     *
     * @return Tab name
     */
    String getName () {
        return name;
    }

    /**
     * Set tab as being active or hidden
     * 
     * @param  newState True = active, false = hidden
     */
    void setVisibility(boolean newState) {
        tabIsVisible = newState;
        if (newState) {
            refreshUserList();
        }
    }

    /**
     * Set current side menu level
     * 
     * @param  newLevel The new menu level
     */
    void setMenuLevel(int newLevel) {
        menuLevel = newLevel;
        menuScroll = 0;
    }

    /**
     * Redraw all tab content
     */
    void drawContent () {
        // Check if user has admin privileges
        if (!userManager.isAdmin()) {
            String[] message = {"Access Denied", 
                              "You need administrator privileges to access user management.",
                              "Please login as an administrator."};
            drawMessageArea("Access Denied", message, cL + 60 * uimult, cR - 60 * uimult, cT + 30 * uimult);
            return;
        }

        // Show user management interface
        String[] message = {"User Management", 
                          "Current User: " + userManager.getCurrentUsername() + " (" + userManager.getRoleString(userManager.getCurrentUserRole()) + ")",
                          "Session Time Remaining: " + userManager.getRemainingSessionTime() + " minutes",
                          "",
                          "Use the sidebar menu to manage user accounts, change passwords,",
                          "and configure user permissions."};
        drawMessageArea("User Management", message, cL + 60 * uimult, cR - 60 * uimult, cT + 30 * uimult);
    }

    /**
     * Draw new tab data
     */
    void drawNewData () {
        // Not in use
    }

    /**
     * Change tab content area dimensions
     *
     * @param  newL New left x-coordinate
     * @param  newR New right x-coordinate
     * @param  newT New top y-coordinate
     * @param  newB new bottom y-coordinate
     */
    void changeSize (int newL, int newR, int newT, int newB) {
        cL = newL;
        cR = newR;
        cT = newT;
        cB = newB;
    }

    /**
     * Change CSV data file location
     *
     * @param  newoutput Absolute path to the new file location
     */
    void setOutput (String newoutput) {
        // Not in use
    }

    /**
     * Get the current CSV data file location
     *
     * @return Absolute path to the data file
     */
    String getOutput () {
        return "No File Set";
    }

    /**
     * Refresh user list
     */
    void refreshUserList() {
        if (userManager.isAdmin()) {
            userList = userManager.getUserList();
        }
    }

    /**
     * Draw the sidebar menu for the current tab
     */
    void drawSidebar () {
        if (!userManager.isAdmin()) {
            // Show login prompt for non-admin users
            int sT = cT;
            int sL = cR;
            int sW = width - cR;
            int uH = round(sideItemHeight * uimult);
            int tH = round((sideItemHeight - 8) * uimult);
            int iH = round((sideItemHeight - 5) * uimult);
            int iL = round(sL + (10 * uimult));
            int iW = round(sW - (20 * uimult));

            drawHeading("Access Required", iL, sT + (uH * 0), iW, tH);
            drawText("Administrator privileges required", c_sidebar_text, iL, sT + (uH * 1.5), iW, iH);
            drawButton("Login", c_sidebar_button, iL, sT + (uH * 2.5), iW, iH, tH);
            return;
        }

        // Calculate sizing of sidebar
        int sT = cT;
        int sL = cR;
        int sW = width - cR;
        int sH = height - sT;

        int uH = round(sideItemHeight * uimult);
        int tH = round((sideItemHeight - 8) * uimult);
        int iH = round((sideItemHeight - 5) * uimult);
        int iL = round(sL + (10 * uimult));
        int iW = round(sW - (20 * uimult));
        
        if (menuLevel == 0) {
            menuHeight = round((8 + userList.length) * uH);
        } else {
            menuHeight = round(6 * uH);
        }

        // Figure out if scrolling of the menu is necessary
        if (menuHeight > sH) {
            if (menuScroll == -1) menuScroll = 0;
            else if (menuScroll > menuHeight - sH) menuScroll = menuHeight - sH;

            // Draw scroll bar
            fill(c_serial_message_box);
            rect(width - round(15 * uimult) / 2, sT, round(15 * uimult) / 2, sH);

            int scrollbarSize = sH - round(sH * float(menuHeight - sH) / menuHeight);
            if (scrollbarSize < uH) scrollbarSize = uH;
            int scrollbarOffset = round((sH - scrollbarSize) * (menuScroll / float(menuHeight - sH)));
            fill(c_terminal_text);
            rect(width - round(15 * uimult) / 2, sT + scrollbarOffset, round(15 * uimult) / 2, scrollbarSize);
            sidebarScroll.update(menuHeight, sH, width - round(15 * uimult) / 2, sT + scrollbarOffset, round(15 * uimult) / 2, scrollbarSize);

            sT -= menuScroll;
            sL -= round(15 * uimult) / 4;
            iL -= round(15 * uimult) / 4;
        } else {
            menuScroll = -1;
        }

        if (menuLevel == 0) {
            // Current session info
            drawHeading("Current Session", iL, sT + (uH * 0), iW, tH);
            drawDatabox("User: " + userManager.getCurrentUsername(), c_sidebar_text, iL, sT + (uH * 1), iW, iH, tH);
            drawDatabox("Role: " + userManager.getRoleString(userManager.getCurrentUserRole()), c_sidebar_text, iL, sT + (uH * 2), iW, iH, tH);
            drawDatabox("Time: " + userManager.getRemainingSessionTime() + " min", c_sidebar_text, iL, sT + (uH * 3), iW, iH, tH);

            // User management actions
            drawHeading("User Management", iL, sT + (uH * 4.5), iW, tH);
            drawButton("Add New User", c_sidebar_button, iL, sT + (uH * 5.5), iW, iH, tH);
            drawButton("Change Password", c_sidebar_button, iL, sT + (uH * 6.5), iW, iH, tH);
            drawButton("Refresh List", c_sidebar_button, iL, sT + (uH * 7.5), iW, iH, tH);

            // User list
            if (userList.length > 0) {
                drawHeading("User Accounts", iL, sT + (uH * 9), iW, tH);
                float tHnow = 10;
                for (int i = 0; i < userList.length; i++) {
                    String[] parts = userList[i].split(" \\(");
                    String username = parts[0];
                    drawButton(constrainString(userList[i], iW - (10 * uimult)), c_sidebar_button, iL, sT + (uH * tHnow), iW, iH, tH);
                    tHnow++;
                }
            }

        } else if (menuLevel == 1) {
            // Add user form would go here
            drawHeading("Add New User", iL, sT + (uH * 0), iW, tH);
            drawText("Feature coming soon...", c_sidebar_text, iL, sT + (uH * 1.5), iW, iH);
            drawButton("Back", c_sidebar_accent, iL, sT + (uH * 3), iW, iH, tH);
        }
    }

    /**
     * Draw the bottom information bar
     */
    void drawInfoBar() {
        textAlign(LEFT, TOP);
        textFont(base_font);
        fill(c_status_bar);
        text("User Management - " + userManager.getCurrentUsername() + " (" + userManager.getRoleString(userManager.getCurrentUserRole()) + ")", 
            round(5 * uimult), height - round(bottombarHeight * uimult) + round(2*uimult));
    }

    /**
     * Keyboard input handler function
     *
     * @param  key The character of the key that was pressed
     */
    void keyboardInput (char keyChar, int keyCodeInt, boolean codedKey) {
        if (keyChar == ESC) {
            if (menuLevel != 0) {
                menuLevel = 0;
                menuScroll = 0;
                redrawUI = true;
            }
        }

        else if (codedKey) {
            switch (keyCodeInt) {
                case UP:
                    if (mouseX >= cR && menuScroll != -1) {
                        menuScroll -= (12 * uimult);
                        if (menuScroll < 0) menuScroll = 0;
                    }
                    redrawUI = true;
                    break;

                case DOWN:
                    if (mouseX >= cR && menuScroll != -1) {
                        menuScroll += (12 * uimult);
                        if (menuScroll > menuHeight - (height - cT)) menuScroll = menuHeight - (height - cT);
                    }
                    redrawUI = true;
                    break;
            }
        }
    }

    /**
     * Content area mouse click handler function
     *
     * @param  xcoord X-coordinate of the mouse click
     * @param  ycoord Y-coordinate of the mouse click
     */
    void contentClick (int xcoord, int ycoord) {
        // Not in use
    }

    /**
     * Scroll wheel handler function
     *
     * @param  amount Multiplier/velocity of the latest mousewheel movement
     */
    void scrollWheel (float amount) {
        if (mouseX >= cR && menuScroll != -1) {
            menuScroll += (sideItemHeight * amount * uimult);
            if (menuScroll < 0) menuScroll = 0;
            else if (menuScroll > menuHeight - (height - cT)) menuScroll = menuHeight - (height - cT);
        }
        redrawUI = true;
    }

    /**
     * Scroll bar handler function
     *
     * @param  xcoord Current mouse x-coordinate position
     * @param  ycoord Current mouse y-coordinate position
     */
    void scrollBarUpdate (int xcoord, int ycoord) {
        if (sidebarScroll.active()) {
            int previousScroll = menuScroll;
            menuScroll = sidebarScroll.move(xcoord, ycoord, menuScroll, 0, menuHeight - (height - cT));
            if (previousScroll != menuScroll) redrawUI = true;
        }
    }

    /**
     * Sidebar mouse click handler function
     *
     * @param  xcoord X-coordinate of the mouse click
     * @param  ycoord Y-coordinate of the mouse click
     */
    void menuClick (int xcoord, int ycoord) {
        if (!userManager.isAdmin()) {
            // Handle login button for non-admin users
            int sT = cT;
            int sL = cR;
            int sW = width - cR;
            int uH = round(sideItemHeight * uimult);
            int iH = round((sideItemHeight - 5) * uimult);
            int iL = round(sL + (10 * uimult));
            int iW = round(sW - (20 * uimult));

            if (menuXYclick(xcoord, ycoord, sT, uH, iH, 2.5, iL, iW)) {
                loginDialog.show();
            }
            return;
        }

        // Coordinate calculation
        int sT = cT;
        int sL = cR;
        if (menuScroll > 0) sT -= menuScroll;
        if (menuScroll != -1) sL -= round(15 * uimult) / 4;

        int sW = width - cR;
        int uH = round(sideItemHeight * uimult);
        int tH = round((sideItemHeight - 8) * uimult);
        int iH = round((sideItemHeight - 5) * uimult);
        int iL = round(sL + (10 * uimult));
        int iW = round(sW - (20 * uimult));

        // Click on sidebar menu scroll bar
        if ((menuScroll != -1) && sidebarScroll.click(xcoord, ycoord)) {
            startScrolling(false);
        }

        if (menuLevel == 0) {
            // Add new user
            if (menuXYclick(xcoord, ycoord, sT, uH, iH, 5.5, iL, iW)) {
                String newUsername = myShowInputDialog("Add New User", "Username:", "");
                if (newUsername != null && !newUsername.trim().equals("")) {
                    String newPassword = myShowInputDialog("Add New User", "Password:", "");
                    if (newPassword != null && !newPassword.trim().equals("")) {
                        String[] roleOptions = {"User", "Admin"};
                        String roleChoice = myShowOptionDialog("Add New User", "Select Role:", roleOptions);
                        if (roleChoice != null) {
                            int role = roleChoice.equals("Admin") ? UserManager.ROLE_ADMIN : UserManager.ROLE_USER;
                            if (userManager.addUser(newUsername.trim(), newPassword.trim(), role)) {
                                alertMessage("Success\nUser '" + newUsername.trim() + "' has been created.");
                                refreshUserList();
                                redrawUI = true;
                            } else {
                                alertMessage("Error\nUnable to create user. Username may already exist.");
                            }
                        }
                    }
                }
            }

            // Change password
            else if (menuXYclick(xcoord, ycoord, sT, uH, iH, 6.5, iL, iW)) {
                String oldPassword = myShowInputDialog("Change Password", "Current Password:", "");
                if (oldPassword != null && !oldPassword.trim().equals("")) {
                    String newPassword = myShowInputDialog("Change Password", "New Password:", "");
                    if (newPassword != null && !newPassword.trim().equals("")) {
                        String confirmPassword = myShowInputDialog("Change Password", "Confirm New Password:", "");
                        if (confirmPassword != null && newPassword.equals(confirmPassword)) {
                            if (userManager.changePassword(userManager.getCurrentUsername(), oldPassword.trim(), newPassword.trim())) {
                                alertMessage("Success\nPassword has been changed.");
                            } else {
                                alertMessage("Error\nUnable to change password. Please check your current password.");
                            }
                        } else {
                            alertMessage("Error\nNew passwords do not match.");
                        }
                    }
                }
            }

            // Refresh list
            else if (menuXYclick(xcoord, ycoord, sT, uH, iH, 7.5, iL, iW)) {
                refreshUserList();
                redrawUI = true;
            }

            // User list items
            else {
                float tHnow = 10;
                for (int i = 0; i < userList.length; i++) {
                    if (menuXYclick(xcoord, ycoord, sT, uH, iH, tHnow, iL, iW)) {
                        String[] parts = userList[i].split(" \\(");
                        String username = parts[0];
                        
                        String[] options = {"Remove User", "Toggle Status", "Reset Password", "Cancel"};
                        String choice = myShowOptionDialog("User: " + username, "Select Action:", options);
                        
                        if (choice != null) {
                            if (choice.equals("Remove User")) {
                                if (userManager.removeUser(username)) {
                                    alertMessage("Success\nUser '" + username + "' has been removed.");
                                    refreshUserList();
                                    redrawUI = true;
                                } else {
                                    alertMessage("Error\nUnable to remove user.");
                                }
                            } else if (choice.equals("Toggle Status")) {
                                if (userManager.toggleUserStatus(username)) {
                                    alertMessage("Success\nUser status has been updated.");
                                    refreshUserList();
                                    redrawUI = true;
                                } else {
                                    alertMessage("Error\nUnable to update user status.");
                                }
                            } else if (choice.equals("Reset Password")) {
                                String newPassword = myShowInputDialog("Reset Password", "New Password for " + username + ":", "");
                                if (newPassword != null && !newPassword.trim().equals("")) {
                                    if (userManager.changePassword(username, "", newPassword.trim())) {
                                        alertMessage("Success\nPassword has been reset for user '" + username + "'.");
                                    } else {
                                        alertMessage("Error\nUnable to reset password.");
                                    }
                                }
                            }
                        }
                    }
                    tHnow++;
                }
            }

        } else if (menuLevel == 1) {
            // Back button
            if (menuXYclick(xcoord, ycoord, sT, uH, iH, 3, iL, iW)) {
                menuLevel = 0;
                menuScroll = 0;
                redrawUI = true;
            }
        }
    }

    /**
     * Serial port data handler function
     *
     * @param  inputData New data received from the serial port
     * @param  graphable True if data in message can be plotted on a graph
     */
    void parsePortData(String inputData, boolean graphable) {
        // Not in use
    }

    /**
     * Function called when a serial device has connected/disconnected
     *
     * @param  status True if a device has connected, false if disconnected
     */
    void connectionEvent (boolean status) {
        // Not in use
    }

    /**
     * Check whether it is safe to exit the program
     *
     * @return True if the are no tasks active, false otherwise
     */
    boolean checkSafeExit() {
        return true;
    }

    /**
     * End any active processes and safely exit the tab
     */
    void performExit() {
        // Nothing to do here
    }
}