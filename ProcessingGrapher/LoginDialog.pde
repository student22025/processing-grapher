/* * * * * * * * * * * * * * * * * * * * * * *
 * LOGIN DIALOG CLASS
 *
 * @file     LoginDialog.pde
 * @brief    User login interface
 * @author   Processing Grapher Team
 *
 * @license  GNU General Public License v3
 * @class    LoginDialog
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

class LoginDialog {
    
    private boolean isVisible = false;
    private String username = "";
    private String password = "";
    private boolean usernameActive = true;
    private boolean passwordActive = false;
    private String errorMessage = "";
    private int dialogWidth = 400;
    private int dialogHeight = 300;
    private int dialogX, dialogY;
    
    /**
     * Constructor
     */
    LoginDialog() {
        dialogX = (width - dialogWidth) / 2;
        dialogY = (height - dialogHeight) / 2;
    }
    
    /**
     * Show login dialog
     */
    void show() {
        isVisible = true;
        username = "";
        password = "";
        usernameActive = true;
        passwordActive = false;
        errorMessage = "";
        dialogX = (width - dialogWidth) / 2;
        dialogY = (height - dialogHeight) / 2;
    }
    
    /**
     * Hide login dialog
     */
    void hide() {
        isVisible = false;
        username = "";
        password = "";
        errorMessage = "";
    }
    
    /**
     * Check if dialog is visible
     */
    boolean isVisible() {
        return isVisible;
    }
    
    /**
     * Draw login dialog
     */
    void draw() {
        if (!isVisible) return;
        
        // Draw overlay
        fill(0, 0, 0, 150);
        rect(0, 0, width, height);
        
        // Draw dialog box
        fill(c_sidebar);
        stroke(c_sidebar_divider);
        strokeWeight(2);
        rect(dialogX, dialogY, dialogWidth, dialogHeight);
        
        // Title
        fill(c_sidebar_heading);
        textAlign(CENTER, TOP);
        textFont(base_font);
        text("User Login", dialogX + dialogWidth/2, dialogY + 20);
        
        // Username field
        fill(c_sidebar_text);
        textAlign(LEFT, TOP);
        text("Username:", dialogX + 30, dialogY + 70);
        
        // Username input box
        if (usernameActive) {
            fill(c_sidebar_button);
            stroke(c_sidebar_accent);
        } else {
            fill(c_idletab);
            stroke(c_sidebar_divider);
        }
        strokeWeight(1);
        rect(dialogX + 30, dialogY + 90, dialogWidth - 60, 30);
        
        fill(c_sidebar_text);
        textAlign(LEFT, CENTER);
        text(username + (usernameActive && frameCount % 60 < 30 ? "|" : ""), 
             dialogX + 35, dialogY + 105);
        
        // Password field
        fill(c_sidebar_text);
        textAlign(LEFT, TOP);
        text("Password:", dialogX + 30, dialogY + 130);
        
        // Password input box
        if (passwordActive) {
            fill(c_sidebar_button);
            stroke(c_sidebar_accent);
        } else {
            fill(c_idletab);
            stroke(c_sidebar_divider);
        }
        strokeWeight(1);
        rect(dialogX + 30, dialogY + 150, dialogWidth - 60, 30);
        
        fill(c_sidebar_text);
        textAlign(LEFT, CENTER);
        String maskedPassword = "";
        for (int i = 0; i < password.length(); i++) {
            maskedPassword += "*";
        }
        text(maskedPassword + (passwordActive && frameCount % 60 < 30 ? "|" : ""), 
             dialogX + 35, dialogY + 165);
        
        // Login button
        fill(c_sidebar_button);
        stroke(c_sidebar_divider);
        strokeWeight(1);
        rect(dialogX + 30, dialogY + 200, 100, 30);
        
        fill(c_sidebar_text);
        textAlign(CENTER, CENTER);
        text("Login", dialogX + 80, dialogY + 215);
        
        // Cancel button
        fill(c_sidebar_button);
        stroke(c_sidebar_divider);
        strokeWeight(1);
        rect(dialogX + 150, dialogY + 200, 100, 30);
        
        fill(c_sidebar_text);
        textAlign(CENTER, CENTER);
        text("Cancel", dialogX + 200, dialogY + 215);
        
        // Guest access button
        fill(c_idletab);
        stroke(c_sidebar_divider);
        strokeWeight(1);
        rect(dialogX + 270, dialogY + 200, 100, 30);
        
        fill(c_sidebar_text);
        textAlign(CENTER, CENTER);
        text("Guest", dialogX + 320, dialogY + 215);
        
        // Error message
        if (!errorMessage.equals("")) {
            fill(c_red);
            textAlign(CENTER, TOP);
            text(errorMessage, dialogX + dialogWidth/2, dialogY + 240);
        }
        
        // Instructions
        fill(c_terminal_text);
        textAlign(CENTER, BOTTOM);
        text("Default: admin/admin123 or user/user123", 
             dialogX + dialogWidth/2, dialogY + dialogHeight - 10);
    }
    
    /**
     * Handle mouse clicks
     */
    void mousePressed(int mouseX, int mouseY) {
        if (!isVisible) return;
        
        // Check if click is outside dialog
        if (mouseX < dialogX || mouseX > dialogX + dialogWidth ||
            mouseY < dialogY || mouseY > dialogY + dialogHeight) {
            return;
        }
        
        // Username field
        if (mouseX >= dialogX + 30 && mouseX <= dialogX + dialogWidth - 30 &&
            mouseY >= dialogY + 90 && mouseY <= dialogY + 120) {
            usernameActive = true;
            passwordActive = false;
        }
        // Password field
        else if (mouseX >= dialogX + 30 && mouseX <= dialogX + dialogWidth - 30 &&
                 mouseY >= dialogY + 150 && mouseY <= dialogY + 180) {
            usernameActive = false;
            passwordActive = true;
        }
        // Login button
        else if (mouseX >= dialogX + 30 && mouseX <= dialogX + 130 &&
                 mouseY >= dialogY + 200 && mouseY <= dialogY + 230) {
            attemptLogin();
        }
        // Cancel button
        else if (mouseX >= dialogX + 150 && mouseX <= dialogX + 250 &&
                 mouseY >= dialogY + 200 && mouseY <= dialogY + 230) {
            hide();
        }
        // Guest button
        else if (mouseX >= dialogX + 270 && mouseX <= dialogX + 370 &&
                 mouseY >= dialogY + 200 && mouseY <= dialogY + 230) {
            hide();
            // Continue as guest (no login required)
        }
        else {
            usernameActive = false;
            passwordActive = false;
        }
    }
    
    /**
     * Handle keyboard input
     */
    void keyPressed(char key, int keyCode) {
        if (!isVisible) return;
        
        if (key == CODED) {
            if (keyCode == TAB) {
                if (usernameActive) {
                    usernameActive = false;
                    passwordActive = true;
                } else if (passwordActive) {
                    passwordActive = false;
                    usernameActive = true;
                }
            }
        } else if (key == ENTER || key == RETURN) {
            attemptLogin();
        } else if (key == ESC) {
            hide();
        } else if (key == BACKSPACE) {
            if (usernameActive && username.length() > 0) {
                username = username.substring(0, username.length() - 1);
            } else if (passwordActive && password.length() > 0) {
                password = password.substring(0, password.length() - 1);
            }
        } else if (key >= 32 && key <= 126) { // Printable characters
            if (usernameActive && username.length() < 20) {
                username += key;
            } else if (passwordActive && password.length() < 20) {
                password += key;
            }
        }
        
        errorMessage = ""; // Clear error message on input
    }
    
    /**
     * Attempt to login with entered credentials
     */
    void attemptLogin() {
        if (username.trim().equals("") || password.trim().equals("")) {
            errorMessage = "Please enter username and password";
            return;
        }
        
        if (userManager.login(username.trim(), password.trim())) {
            hide();
            redrawUI = true;
            alertMessage("Login Successful\nWelcome, " + userManager.getCurrentUsername() + "!");
        } else {
            errorMessage = "Invalid username or password";
            password = ""; // Clear password on failed login
        }
    }
}