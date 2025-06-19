/* * * * * * * * * * * * * * * * * * * * * * *
 * VIRTUAL KEYBOARD CLASS
 *
 * @file     VirtualKeyboard.pde
 * @brief    On-screen virtual keyboard for accessibility
 * @author   Processing Grapher Team
 *
 * @license  GNU General Public License v3
 * @class    VirtualKeyboard
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

class VirtualKeyboard {
    
    private boolean isVisible = false;
    private boolean shiftPressed = false;
    private boolean ctrlPressed = false;
    private boolean altPressed = false;
    private int keyboardX, keyboardY;
    private int keyboardWidth = 800;
    private int keyboardHeight = 300;
    private String targetInput = "";
    private Object targetObject = null;
    
    // Key layout definitions
    private String[][] keyLayout = {
        {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BACKSPACE"},
        {"TAB", "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "[", "]", "\\"},
        {"CAPS", "a", "s", "d", "f", "g", "h", "j", "k", "l", ";", "'", "ENTER"},
        {"SHIFT", "z", "x", "c", "v", "b", "n", "m", ",", ".", "/", "SHIFT"},
        {"CTRL", "ALT", "SPACE", "ALT", "CTRL"}
    };
    
    private String[][] shiftKeyLayout = {
        {"!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "_", "+", "BACKSPACE"},
        {"TAB", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "{", "}", "|"},
        {"CAPS", "A", "S", "D", "F", "G", "H", "J", "K", "L", ":", "\"", "ENTER"},
        {"SHIFT", "Z", "X", "C", "V", "B", "N", "M", "<", ">", "?", "SHIFT"},
        {"CTRL", "ALT", "SPACE", "ALT", "CTRL"}
    };
    
    private int[][] keyWidths = {
        {50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 100},
        {75, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50},
        {100, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 75},
        {125, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 125},
        {75, 75, 300, 75, 75}
    };
    
    /**
     * Constructor
     */
    VirtualKeyboard() {
        keyboardX = (width - keyboardWidth) / 2;
        keyboardY = height - keyboardHeight - 50;
    }
    
    /**
     * Show virtual keyboard
     */
    void show(String inputTarget, Object targetObj) {
        isVisible = true;
        targetInput = inputTarget;
        targetObject = targetObj;
        keyboardX = (width - keyboardWidth) / 2;
        keyboardY = height - keyboardHeight - 50;
    }
    
    /**
     * Hide virtual keyboard
     */
    void hide() {
        isVisible = false;
        targetInput = "";
        targetObject = null;
        shiftPressed = false;
        ctrlPressed = false;
        altPressed = false;
    }
    
    /**
     * Check if keyboard is visible
     */
    boolean isVisible() {
        return isVisible;
    }
    
    /**
     * Draw virtual keyboard
     */
    void draw() {
        if (!isVisible) return;
        
        // Draw keyboard background
        fill(0, 0, 0, 150);
        rect(0, 0, width, height);
        
        fill(c_sidebar);
        stroke(c_sidebar_divider);
        strokeWeight(2);
        rect(keyboardX, keyboardY, keyboardWidth, keyboardHeight);
        
        // Draw title
        fill(c_sidebar_heading);
        textAlign(CENTER, TOP);
        textFont(base_font);
        text("Virtual Keyboard - " + targetInput, keyboardX + keyboardWidth/2, keyboardY + 10);
        
        // Draw close button
        fill(c_red);
        stroke(c_sidebar_divider);
        strokeWeight(1);
        rect(keyboardX + keyboardWidth - 30, keyboardY + 5, 25, 25);
        fill(c_white);
        textAlign(CENTER, CENTER);
        text("×", keyboardX + keyboardWidth - 17, keyboardY + 17);
        
        // Draw keys
        int startY = keyboardY + 40;
        int currentY = startY;
        
        for (int row = 0; row < keyLayout.length; row++) {
            int currentX = keyboardX + 10;
            String[] currentLayout = shiftPressed ? shiftKeyLayout[row] : keyLayout[row];
            
            for (int col = 0; col < currentLayout.length; col++) {
                String key = currentLayout[col];
                int keyWidth = keyWidths[row][col];
                int keyHeight = 40;
                
                // Determine key color
                color keyColor = c_sidebar_button;
                if (key.equals("SHIFT") && shiftPressed) keyColor = c_sidebar_accent;
                if (key.equals("CTRL") && ctrlPressed) keyColor = c_sidebar_accent;
                if (key.equals("ALT") && altPressed) keyColor = c_sidebar_accent;
                if (key.equals("CAPS")) keyColor = c_idletab;
                
                // Draw key
                fill(keyColor);
                stroke(c_sidebar_divider);
                strokeWeight(1);
                rect(currentX, currentY, keyWidth, keyHeight);
                
                // Draw key label
                fill(c_sidebar_text);
                textAlign(CENTER, CENTER);
                textFont(mono_font);
                
                String displayText = key;
                if (key.equals("SPACE")) displayText = "";
                else if (key.equals("BACKSPACE")) displayText = "⌫";
                else if (key.equals("ENTER")) displayText = "↵";
                else if (key.equals("TAB")) displayText = "⇥";
                
                text(displayText, currentX + keyWidth/2, currentY + keyHeight/2);
                
                currentX += keyWidth + 5;
            }
            currentY += 45;
        }
        
        // Draw modifier key status
        fill(c_sidebar_text);
        textAlign(LEFT, BOTTOM);
        textFont(base_font);
        String modifiers = "";
        if (ctrlPressed) modifiers += "CTRL ";
        if (altPressed) modifiers += "ALT ";
        if (shiftPressed) modifiers += "SHIFT ";
        if (!modifiers.equals("")) {
            text("Active: " + modifiers, keyboardX + 10, keyboardY + keyboardHeight - 10);
        }
    }
    
    /**
     * Handle mouse clicks on virtual keyboard
     */
    void mousePressed(int mouseX, int mouseY) {
        if (!isVisible) return;
        
        // Check close button
        if (mouseX >= keyboardX + keyboardWidth - 30 && mouseX <= keyboardX + keyboardWidth - 5 &&
            mouseY >= keyboardY + 5 && mouseY <= keyboardY + 30) {
            hide();
            return;
        }
        
        // Check if click is outside keyboard
        if (mouseX < keyboardX || mouseX > keyboardX + keyboardWidth ||
            mouseY < keyboardY || mouseY > keyboardY + keyboardHeight) {
            return;
        }
        
        // Find clicked key
        int startY = keyboardY + 40;
        int currentY = startY;
        
        for (int row = 0; row < keyLayout.length; row++) {
            if (mouseY >= currentY && mouseY <= currentY + 40) {
                int currentX = keyboardX + 10;
                String[] currentLayout = shiftPressed ? shiftKeyLayout[row] : keyLayout[row];
                
                for (int col = 0; col < currentLayout.length; col++) {
                    int keyWidth = keyWidths[row][col];
                    
                    if (mouseX >= currentX && mouseX <= currentX + keyWidth) {
                        handleKeyPress(currentLayout[col]);
                        return;
                    }
                    currentX += keyWidth + 5;
                }
            }
            currentY += 45;
        }
    }
    
    /**
     * Handle virtual key press
     */
    void handleKeyPress(String key) {
        if (key.equals("SHIFT")) {
            shiftPressed = !shiftPressed;
        } else if (key.equals("CTRL")) {
            ctrlPressed = !ctrlPressed;
        } else if (key.equals("ALT")) {
            altPressed = !altPressed;
        } else if (key.equals("CAPS")) {
            // Toggle caps lock (not implemented in this version)
        } else {
            // Send key to target
            sendKeyToTarget(key);
            
            // Reset shift after character input
            if (!key.equals("BACKSPACE") && !key.equals("ENTER") && !key.equals("TAB") && !key.equals("SPACE")) {
                shiftPressed = false;
            }
        }
    }
    
    /**
     * Send key input to target object
     */
    void sendKeyToTarget(String key) {
        if (targetObject == null) return;
        
        char keyChar = 0;
        int keyCode = 0;
        boolean coded = false;
        
        if (key.equals("BACKSPACE")) {
            keyChar = BACKSPACE;
            keyCode = BACKSPACE;
        } else if (key.equals("ENTER")) {
            keyChar = ENTER;
            keyCode = ENTER;
        } else if (key.equals("TAB")) {
            keyChar = TAB;
            keyCode = TAB;
            coded = true;
        } else if (key.equals("SPACE")) {
            keyChar = ' ';
            keyCode = 32;
        } else if (key.length() == 1) {
            keyChar = key.charAt(0);
            keyCode = (int)keyChar;
        }
        
        // Send to appropriate target
        if (targetObject instanceof LoginDialog) {
            ((LoginDialog)targetObject).keyPressed(keyChar, keyCode);
        } else if (targetObject instanceof SerialMonitor) {
            ((SerialMonitor)targetObject).keyboardInput(keyChar, keyCode, coded);
        }
        // Add more target types as needed
    }
}