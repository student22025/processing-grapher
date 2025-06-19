/* * * * * * * * * * * * * * * * * * * * * * *
 * ACCESSIBILITY MANAGER CLASS
 *
 * @file     AccessibilityManager.pde
 * @brief    Manage accessibility features and input methods
 * @author   Processing Grapher Team
 *
 * @license  GNU General Public License v3
 * @class    AccessibilityManager
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

// Global accessibility instances
VirtualKeyboard virtualKeyboard;
KeyMapping keyMapping;
ChannelManager channelManager;

class AccessibilityManager {
    
    private boolean highContrastMode = false;
    private boolean largeTextMode = false;
    private boolean screenReaderMode = false;
    private boolean keyboardNavigationMode = true;
    private boolean voiceControlEnabled = false;
    private float textScaleFactor = 1.0;
    private int focusedElement = -1;
    private ArrayList<String> accessibilityLog;
    
    /**
     * Constructor
     */
    AccessibilityManager() {
        accessibilityLog = new ArrayList<String>();
        initializeAccessibilityFeatures();
    }
    
    /**
     * Initialize accessibility features
     */
    void initializeAccessibilityFeatures() {
        // Initialize virtual keyboard
        virtualKeyboard = new VirtualKeyboard();
        
        // Initialize key mapping
        keyMapping = new KeyMapping();
        
        // Initialize channel manager
        channelManager = new ChannelManager();
        
        // Load accessibility settings
        loadAccessibilitySettings();
        
        logAccessibilityEvent("Accessibility Manager initialized");
    }
    
    /**
     * Load accessibility settings
     */
    void loadAccessibilitySettings() {
        try {
            if (dataFile("accessibility.xml").isFile()) {
                XML xmlFile = loadXML("accessibility.xml");
                
                highContrastMode = xmlFile.getInt("high-contrast", 0) == 1;
                largeTextMode = xmlFile.getInt("large-text", 0) == 1;
                screenReaderMode = xmlFile.getInt("screen-reader", 0) == 1;
                keyboardNavigationMode = xmlFile.getInt("keyboard-nav", 1) == 1;
                voiceControlEnabled = xmlFile.getInt("voice-control", 0) == 1;
                textScaleFactor = xmlFile.getFloat("text-scale", 1.0);
                
                applyAccessibilitySettings();
            }
        } catch (Exception e) {
            println("Error loading accessibility settings: " + e);
        }
    }
    
    /**
     * Save accessibility settings
     */
    void saveAccessibilitySettings() {
        try {
            XML xmlFile = new XML("accessibility");
            
            xmlFile.setInt("high-contrast", highContrastMode ? 1 : 0);
            xmlFile.setInt("large-text", largeTextMode ? 1 : 0);
            xmlFile.setInt("screen-reader", screenReaderMode ? 1 : 0);
            xmlFile.setInt("keyboard-nav", keyboardNavigationMode ? 1 : 0);
            xmlFile.setInt("voice-control", voiceControlEnabled ? 1 : 0);
            xmlFile.setFloat("text-scale", textScaleFactor);
            
            saveXML(xmlFile, "data/accessibility.xml");
            logAccessibilityEvent("Accessibility settings saved");
        } catch (Exception e) {
            println("Error saving accessibility settings: " + e);
        }
    }
    
    /**
     * Apply accessibility settings
     */
    void applyAccessibilitySettings() {
        if (highContrastMode) {
            enableHighContrastMode();
        }
        
        if (largeTextMode) {
            enableLargeTextMode();
        }
        
        redrawUI = true;
        redrawContent = true;
    }
    
    /**
     * Enable high contrast mode
     */
    void enableHighContrastMode() {
        // Modify color scheme for high contrast
        c_background = color(0, 0, 0);
        c_sidebar_text = color(255, 255, 255);
        c_sidebar_button = color(255, 255, 255);
        c_sidebar_accent = color(255, 255, 0);
        c_graph_axis = color(255, 255, 255);
        c_graph_gridlines = color(128, 128, 128);
        
        logAccessibilityEvent("High contrast mode enabled");
    }
    
    /**
     * Enable large text mode
     */
    void enableLargeTextMode() {
        textScaleFactor = 1.5;
        uimult *= textScaleFactor;
        uiResize();
        
        logAccessibilityEvent("Large text mode enabled");
    }
    
    /**
     * Handle accessibility key events
     */
    boolean handleAccessibilityKeys(char key, int keyCode, boolean coded) {
        // Let key mapping handle first
        if (keyMapping.handleKeyPress(key, keyCode, coded)) {
            return true;
        }
        
        // Handle accessibility-specific keys
        if (coded) {
            switch (keyCode) {
                case KeyEvent.VK_F1:
                    if (ctrlPressed) {
                        toggleAccessibilityHelp();
                        return true;
                    }
                    break;
                    
                case KeyEvent.VK_F2:
                    if (ctrlPressed) {
                        virtualKeyboard.show("Accessibility Input", currentTab);
                        return true;
                    }
                    break;
                    
                case KeyEvent.VK_F3:
                    if (ctrlPressed) {
                        toggleHighContrastMode();
                        return true;
                    }
                    break;
                    
                case KeyEvent.VK_F4:
                    if (ctrlPressed) {
                        toggleLargeTextMode();
                        return true;
                    }
                    break;
            }
        }
        
        // Handle character keys
        switch (key) {
            case 'A':
            case 'a':
                if (ctrlPressed && altPressed) {
                    showAccessibilityMenu();
                    return true;
                }
                break;
        }
        
        return false;
    }
    
    /**
     * Toggle high contrast mode
     */
    void toggleHighContrastMode() {
        highContrastMode = !highContrastMode;
        
        if (highContrastMode) {
            enableHighContrastMode();
        } else {
            loadColorScheme(colorScheme); // Restore original colors
        }
        
        saveAccessibilitySettings();
        logAccessibilityEvent("High contrast mode " + (highContrastMode ? "enabled" : "disabled"));
    }
    
    /**
     * Toggle large text mode
     */
    void toggleLargeTextMode() {
        largeTextMode = !largeTextMode;
        
        if (largeTextMode) {
            enableLargeTextMode();
        } else {
            textScaleFactor = 1.0;
            uiResize();
        }
        
        saveAccessibilitySettings();
        logAccessibilityEvent("Large text mode " + (largeTextMode ? "enabled" : "disabled"));
    }
    
    /**
     * Show accessibility menu
     */
    void showAccessibilityMenu() {
        String[] options = {
            "Toggle High Contrast (Ctrl+F3)",
            "Toggle Large Text (Ctrl+F4)", 
            "Show Virtual Keyboard (Ctrl+F2)",
            "Show Key Mapping Help (H)",
            "Channel Manager",
            "Accessibility Help (Ctrl+F1)",
            "Close Menu"
        };
        
        String choice = myShowOptionDialog("Accessibility Menu", "Select an option:", options);
        
        if (choice != null) {
            if (choice.contains("High Contrast")) {
                toggleHighContrastMode();
            } else if (choice.contains("Large Text")) {
                toggleLargeTextMode();
            } else if (choice.contains("Virtual Keyboard")) {
                virtualKeyboard.show("Accessibility Input", currentTab);
            } else if (choice.contains("Key Mapping")) {
                keyMapping.showKeyHints = !keyMapping.showKeyHints;
            } else if (choice.contains("Channel Manager")) {
                showChannelManager();
            } else if (choice.contains("Accessibility Help")) {
                toggleAccessibilityHelp();
            }
        }
    }
    
    /**
     * Show channel manager
     */
    void showChannelManager() {
        String[] options = {
            "View Channel Status",
            "Toggle All Channels",
            "Reset Channels",
            "Export Configuration",
            "Import Configuration",
            "Synchronize with Current Tab",
            "Close"
        };
        
        String choice = myShowOptionDialog("Channel Manager", "Select an option:", options);
        
        if (choice != null) {
            if (choice.contains("View Channel Status")) {
                String status = "Channel Status:\n\n";
                for (int i = 0; i < channelManager.getChannelCount(); i++) {
                    ChannelManager.Channel channel = channelManager.getChannel(i);
                    if (channel != null) {
                        status += "Ch" + (i+1) + ": " + channel.name + " - " + 
                                 (channel.enabled ? "ON" : "OFF") + "\n";
                    }
                }
                status += "\n" + channelManager.getChannelStatusSummary();
                alertMessage(status);
                
            } else if (choice.contains("Toggle All")) {
                for (int i = 0; i < channelManager.getChannelCount(); i++) {
                    channelManager.toggleChannel(i);
                }
                
            } else if (choice.contains("Reset")) {
                channelManager.resetChannels();
                
            } else if (choice.contains("Export")) {
                selectOutput("Export channel configuration", "exportChannelConfig");
                
            } else if (choice.contains("Import")) {
                selectInput("Import channel configuration", "importChannelConfig");
                
            } else if (choice.contains("Synchronize")) {
                channelManager.synchronizeWithTab();
            }
        }
    }
    
    /**
     * Toggle accessibility help
     */
    void toggleAccessibilityHelp() {
        String helpText = "ACCESSIBILITY FEATURES:\n\n";
        helpText += "KEYBOARD SHORTCUTS:\n";
        helpText += "Ctrl+F1: This help\n";
        helpText += "Ctrl+F2: Virtual keyboard\n";
        helpText += "Ctrl+F3: High contrast mode\n";
        helpText += "Ctrl+F4: Large text mode\n";
        helpText += "Ctrl+Alt+A: Accessibility menu\n\n";
        
        helpText += "CHANNEL CONTROL:\n";
        helpText += "Keys 1-8: Toggle channels 1-8\n";
        helpText += "R: Record, P: Pause, C: Clear\n";
        helpText += "O: Open, V: Save, Z: Zoom\n";
        helpText += "H: Toggle key hints\n";
        helpText += "K: Virtual keyboard\n";
        helpText += "M: Toggle key mapping\n\n";
        
        helpText += "VIRTUAL KEYBOARD:\n";
        helpText += "- On-screen keyboard for input\n";
        helpText += "- Click keys or use mouse\n";
        helpText += "- Supports modifier keys\n\n";
        
        helpText += "CHANNEL PARITY:\n";
        helpText += "- Equal access via keyboard/mouse\n";
        helpText += "- Consistent channel control\n";
        helpText += "- Synchronized state management\n\n";
        
        helpText += "For more help, press Ctrl+Alt+A for the accessibility menu.";
        
        alertMessage(helpText);
        logAccessibilityEvent("Accessibility help displayed");
    }
    
    /**
     * Log accessibility event
     */
    void logAccessibilityEvent(String event) {
        String timestamp = nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2);
        accessibilityLog.add(timestamp + " - " + event);
        
        // Keep log size manageable
        if (accessibilityLog.size() > 100) {
            accessibilityLog.remove(0);
        }
        
        if (screenReaderMode) {
            println("ACCESSIBILITY: " + event);
        }
    }
    
    /**
     * Draw accessibility overlay
     */
    void drawAccessibilityOverlay() {
        // Draw virtual keyboard if visible
        if (virtualKeyboard != null && virtualKeyboard.isVisible()) {
            virtualKeyboard.draw();
        }
        
        // Draw key mapping hints if enabled
        if (keyMapping != null) {
            keyMapping.drawKeyHints();
        }
        
        // Draw accessibility status
        if (highContrastMode || largeTextMode || screenReaderMode) {
            drawAccessibilityStatus();
        }
    }
    
    /**
     * Draw accessibility status indicator
     */
    void drawAccessibilityStatus() {
        String status = "";
        if (highContrastMode) status += "HC ";
        if (largeTextMode) status += "LT ";
        if (screenReaderMode) status += "SR ";
        if (keyboardNavigationMode) status += "KN ";
        
        if (!status.equals("")) {
            fill(c_sidebar_accent);
            textAlign(RIGHT, TOP);
            textFont(mono_font);
            text("A11Y: " + status.trim(), width - 10, 10);
        }
    }
    
    /**
     * Handle mouse events for accessibility
     */
    void handleAccessibilityMouse(int mouseX, int mouseY, boolean pressed) {
        if (virtualKeyboard != null && virtualKeyboard.isVisible()) {
            if (pressed) {
                virtualKeyboard.mousePressed(mouseX, mouseY);
            }
        }
    }
    
    /**
     * Get accessibility status
     */
    String getAccessibilityStatus() {
        String status = "Accessibility Status:\n";
        status += "High Contrast: " + (highContrastMode ? "ON" : "OFF") + "\n";
        status += "Large Text: " + (largeTextMode ? "ON" : "OFF") + "\n";
        status += "Screen Reader: " + (screenReaderMode ? "ON" : "OFF") + "\n";
        status += "Keyboard Navigation: " + (keyboardNavigationMode ? "ON" : "OFF") + "\n";
        status += "Voice Control: " + (voiceControlEnabled ? "ON" : "OFF") + "\n";
        status += "Text Scale: " + textScaleFactor + "x\n";
        status += "Key Mapping: " + (keyMapping.isMappingEnabled() ? "ON" : "OFF") + "\n";
        status += channelManager.getChannelStatusSummary();
        
        return status;
    }
    
    /**
     * Check if accessibility features are active
     */
    boolean hasAccessibilityFeatures() {
        return highContrastMode || largeTextMode || screenReaderMode || 
               keyboardNavigationMode || voiceControlEnabled;
    }
}

// Global accessibility manager instance
AccessibilityManager accessibilityManager;

/**
 * Initialize accessibility system
 */
void initializeAccessibility() {
    accessibilityManager = new AccessibilityManager();
}

/**
 * File selection callbacks for channel manager
 */
void exportChannelConfig(File selection) {
    if (selection != null && channelManager != null) {
        channelManager.exportChannelConfig(selection.getAbsolutePath());
    }
}

void importChannelConfig(File selection) {
    if (selection != null && channelManager != null) {
        channelManager.importChannelConfig(selection.getAbsolutePath());
    }
}