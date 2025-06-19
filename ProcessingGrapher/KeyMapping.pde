/* * * * * * * * * * * * * * * * * * * * * * *
 * KEY MAPPING CLASS
 *
 * @file     KeyMapping.pde
 * @brief    External keyboard key mapping for channel control
 * @author   Processing Grapher Team
 *
 * @license  GNU General Public License v3
 * @class    KeyMapping
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

class KeyMapping {
    
    // Channel control mappings
    private HashMap<Character, Integer> channelKeys;
    private HashMap<Character, String> functionKeys;
    private HashMap<String, String> keyDescriptions;
    private boolean[] channelStates = new boolean[8]; // Support up to 8 channels
    private String[] channelNames = {"Ch1", "Ch2", "Ch3", "Ch4", "Ch5", "Ch6", "Ch7", "Ch8"};
    private boolean mappingEnabled = true;
    private boolean showKeyHints = true;
    
    // Key mapping configuration
    private String configFile = "key-mapping.xml";
    
    /**
     * Constructor
     */
    KeyMapping() {
        initializeDefaultMappings();
        loadKeyMappings();
    }
    
    /**
     * Initialize default key mappings
     */
    void initializeDefaultMappings() {
        channelKeys = new HashMap<Character, Integer>();
        functionKeys = new HashMap<Character, String>();
        keyDescriptions = new HashMap<String, String>();
        
        // Channel control keys (1-8 for channels)
        channelKeys.put('1', 0);
        channelKeys.put('2', 1);
        channelKeys.put('3', 2);
        channelKeys.put('4', 3);
        channelKeys.put('5', 4);
        channelKeys.put('6', 5);
        channelKeys.put('7', 6);
        channelKeys.put('8', 7);
        
        // Function keys
        functionKeys.put('r', "record");
        functionKeys.put('s', "stop");
        functionKeys.put('p', "pause");
        functionKeys.put('c', "clear");
        functionKeys.put('o', "open");
        functionKeys.put('v', "save");
        functionKeys.put('z', "zoom");
        functionKeys.put('x', "reset_zoom");
        functionKeys.put('g', "toggle_grid");
        functionKeys.put('l', "toggle_legend");
        functionKeys.put('h', "help");
        functionKeys.put('k', "virtual_keyboard");
        functionKeys.put('m', "toggle_mapping");
        
        // Key descriptions for help
        keyDescriptions.put("1-8", "Toggle channels 1-8");
        keyDescriptions.put("r", "Start/Resume recording");
        keyDescriptions.put("s", "Stop recording");
        keyDescriptions.put("p", "Pause/Resume live graph");
        keyDescriptions.put("c", "Clear graphs");
        keyDescriptions.put("o", "Open file");
        keyDescriptions.put("v", "Save file");
        keyDescriptions.put("z", "Zoom mode");
        keyDescriptions.put("x", "Reset zoom");
        keyDescriptions.put("g", "Toggle grid lines");
        keyDescriptions.put("l", "Toggle legend");
        keyDescriptions.put("h", "Show/hide key hints");
        keyDescriptions.put("k", "Show virtual keyboard");
        keyDescriptions.put("m", "Toggle key mapping");
        keyDescriptions.put("F1-F12", "Custom function keys");
        keyDescriptions.put("Ctrl+Q", "Connect/Disconnect serial");
        keyDescriptions.put("Ctrl+S", "Quick save");
        keyDescriptions.put("Ctrl+O", "Quick open");
        keyDescriptions.put("Ctrl+R", "Start/Stop recording");
        keyDescriptions.put("Ctrl+Tab", "Switch tabs");
        keyDescriptions.put("Ctrl+M", "Send serial message");
    }
    
    /**
     * Load key mappings from configuration file
     */
    void loadKeyMappings() {
        try {
            if (dataFile(configFile).isFile()) {
                XML xmlFile = loadXML(configFile);
                
                // Load channel mappings
                XML channelNode = xmlFile.getChild("channels");
                if (channelNode != null) {
                    XML[] channelMappings = channelNode.getChildren("mapping");
                    for (XML mapping : channelMappings) {
                        char key = mapping.getString("key").charAt(0);
                        int channel = mapping.getInt("channel");
                        channelKeys.put(key, channel);
                    }
                }
                
                // Load function mappings
                XML functionNode = xmlFile.getChild("functions");
                if (functionNode != null) {
                    XML[] functionMappings = functionNode.getChildren("mapping");
                    for (XML mapping : functionMappings) {
                        char key = mapping.getString("key").charAt(0);
                        String function = mapping.getString("function");
                        functionKeys.put(key, function);
                    }
                }
                
                // Load settings
                XML settingsNode = xmlFile.getChild("settings");
                if (settingsNode != null) {
                    mappingEnabled = settingsNode.getInt("enabled", 1) == 1;
                    showKeyHints = settingsNode.getInt("show-hints", 1) == 1;
                }
            }
        } catch (Exception e) {
            println("Error loading key mappings: " + e);
            saveKeyMappings(); // Create default file
        }
    }
    
    /**
     * Save key mappings to configuration file
     */
    void saveKeyMappings() {
        try {
            XML xmlFile = new XML("key-mapping");
            
            // Save channel mappings
            XML channelNode = xmlFile.addChild("channels");
            for (Character key : channelKeys.keySet()) {
                XML mapping = channelNode.addChild("mapping");
                mapping.setString("key", key.toString());
                mapping.setInt("channel", channelKeys.get(key));
            }
            
            // Save function mappings
            XML functionNode = xmlFile.addChild("functions");
            for (Character key : functionKeys.keySet()) {
                XML mapping = functionNode.addChild("mapping");
                mapping.setString("key", key.toString());
                mapping.setString("function", functionKeys.get(key));
            }
            
            // Save settings
            XML settingsNode = xmlFile.addChild("settings");
            settingsNode.setInt("enabled", mappingEnabled ? 1 : 0);
            settingsNode.setInt("show-hints", showKeyHints ? 1 : 0);
            
            saveXML(xmlFile, "data/" + configFile);
        } catch (Exception e) {
            println("Error saving key mappings: " + e);
        }
    }
    
    /**
     * Handle key press events
     */
    boolean handleKeyPress(char key, int keyCode, boolean coded) {
        if (!mappingEnabled) return false;
        
        updateUserActivity(); // Update user activity for session management
        
        // Handle channel keys
        if (channelKeys.containsKey(key)) {
            int channel = channelKeys.get(key);
            toggleChannel(channel);
            return true;
        }
        
        // Handle function keys
        if (functionKeys.containsKey(key)) {
            String function = functionKeys.get(key);
            executeFunction(function);
            return true;
        }
        
        // Handle coded keys (F1-F12, etc.)
        if (coded) {
            return handleCodedKey(keyCode);
        }
        
        return false;
    }
    
    /**
     * Handle coded key presses (F1-F12, etc.)
     */
    boolean handleCodedKey(int keyCode) {
        switch (keyCode) {
            case 112: // F1
                executeFunction("help");
                return true;
            case 113: // F2
                executeFunction("virtual_keyboard");
                return true;
            case 114: // F3
                executeFunction("toggle_grid");
                return true;
            case 115: // F4
                executeFunction("save");
                return true;
            case 116: // F5
                executeFunction("open");
                return true;
            case 117: // F6
                executeFunction("record");
                return true;
            case 118: // F7
                executeFunction("pause");
                return true;
            case 119: // F8
                executeFunction("clear");
                return true;
            case 120: // F9
                executeFunction("zoom");
                return true;
            case 121: // F10
                executeFunction("reset_zoom");
                return true;
            case 122: // F11
                executeFunction("toggle_legend");
                return true;
            case 123: // F12
                executeFunction("toggle_mapping");
                return true;
        }
        return false;
    }
    
    /**
     * Toggle channel state
     */
    void toggleChannel(int channel) {
        if (channel >= 0 && channel < channelStates.length) {
            channelStates[channel] = !channelStates[channel];
            
            // Apply channel state to current tab
            if (currentTab instanceof LiveGraph) {
                LiveGraph liveTab = (LiveGraph)currentTab;
                // Toggle signal visibility for this channel
                if (channel < liveTab.dataColumns.length) {
                    if (channelStates[channel]) {
                        // Show channel
                        if (liveTab.graphAssignment[channel] == liveTab.graphMode + 1) {
                            liveTab.graphAssignment[channel] = 1; // Move to graph 1
                        }
                    } else {
                        // Hide channel
                        liveTab.graphAssignment[channel] = liveTab.graphMode + 1; // Move to hidden
                    }
                    redrawUI = true;
                    redrawContent = true;
                }
            }
            
            // Show feedback
            String status = channelStates[channel] ? "ON" : "OFF";
            println("Channel " + (channel + 1) + " " + status);
        }
    }
    
    /**
     * Execute function command
     */
    void executeFunction(String function) {
        switch (function) {
            case "record":
                if (currentTab instanceof LiveGraph) {
                    LiveGraph liveTab = (LiveGraph)currentTab;
                    if (liveTab.recordData) {
                        liveTab.stopRecording();
                    } else if (!liveTab.outputfile.equals("No File Set")) {
                        liveTab.startRecording();
                    }
                }
                break;
                
            case "stop":
                if (currentTab instanceof LiveGraph) {
                    LiveGraph liveTab = (LiveGraph)currentTab;
                    if (liveTab.recordData) {
                        liveTab.stopRecording();
                    }
                }
                break;
                
            case "pause":
                if (currentTab instanceof LiveGraph) {
                    LiveGraph liveTab = (LiveGraph)currentTab;
                    liveTab.isPaused = !liveTab.isPaused;
                    if (liveTab.isPaused) {
                        liveTab.pausedCount = liveTab.dataTable.getRowCount();
                    }
                    redrawUI = true;
                    redrawContent = true;
                }
                break;
                
            case "clear":
                if (currentTab instanceof LiveGraph) {
                    LiveGraph liveTab = (LiveGraph)currentTab;
                    liveTab.dataTable.clearRows();
                    liveTab.drawFrom = 0;
                    redrawUI = true;
                    redrawContent = true;
                }
                break;
                
            case "open":
                if (checkPermission("view_data")) {
                    selectInput("Select file to open", "fileSelected");
                }
                break;
                
            case "save":
                if (checkPermission("save_files")) {
                    selectOutput("Select save location", "fileSelected");
                }
                break;
                
            case "zoom":
                if (currentTab instanceof FileGraph) {
                    FileGraph fileTab = (FileGraph)currentTab;
                    fileTab.setZoomSize = 0;
                    cursor(CROSS);
                    redrawUI = true;
                }
                break;
                
            case "reset_zoom":
                if (currentTab instanceof FileGraph) {
                    FileGraph fileTab = (FileGraph)currentTab;
                    fileTab.zoomActive = false;
                    cursor(ARROW);
                    redrawContent = true;
                    redrawUI = true;
                }
                break;
                
            case "toggle_grid":
                // Toggle grid lines on current graph
                redrawContent = true;
                break;
                
            case "toggle_legend":
                // Toggle legend display
                redrawUI = true;
                break;
                
            case "help":
                showKeyHints = !showKeyHints;
                redrawUI = true;
                break;
                
            case "virtual_keyboard":
                if (virtualKeyboard != null) {
                    if (virtualKeyboard.isVisible()) {
                        virtualKeyboard.hide();
                    } else {
                        virtualKeyboard.show("General Input", currentTab);
                    }
                }
                break;
                
            case "toggle_mapping":
                mappingEnabled = !mappingEnabled;
                saveKeyMappings();
                alertMessage("Key Mapping " + (mappingEnabled ? "Enabled" : "Disabled"));
                break;
        }
    }
    
    /**
     * Draw key hints overlay
     */
    void drawKeyHints() {
        if (!showKeyHints || !mappingEnabled) return;
        
        // Draw semi-transparent background
        fill(0, 0, 0, 100);
        rect(10, 10, 300, 200);
        
        // Draw border
        stroke(c_sidebar_accent);
        strokeWeight(2);
        noFill();
        rect(10, 10, 300, 200);
        
        // Draw title
        fill(c_sidebar_heading);
        textAlign(LEFT, TOP);
        textFont(base_font);
        text("Key Mapping (H to toggle)", 20, 25);
        
        // Draw key hints
        fill(c_sidebar_text);
        textFont(mono_font);
        int yPos = 50;
        
        text("Channels:", 20, yPos);
        yPos += 20;
        text("1-8: Toggle Ch1-Ch8", 30, yPos);
        yPos += 25;
        
        text("Functions:", 20, yPos);
        yPos += 20;
        text("R: Record  P: Pause", 30, yPos);
        yPos += 15;
        text("C: Clear   O: Open", 30, yPos);
        yPos += 15;
        text("V: Save    Z: Zoom", 30, yPos);
        yPos += 15;
        text("K: Virtual Keyboard", 30, yPos);
        yPos += 15;
        text("M: Toggle Mapping", 30, yPos);
        
        // Draw channel status
        fill(c_sidebar_text);
        textAlign(RIGHT, TOP);
        text("Channel Status:", 300, 50);
        for (int i = 0; i < 4; i++) {
            color statusColor = channelStates[i] ? c_green : c_red;
            fill(statusColor);
            text("Ch" + (i+1) + ": " + (channelStates[i] ? "ON" : "OFF"), 300, 70 + i * 15);
        }
    }
    
    /**
     * Get channel state
     */
    boolean getChannelState(int channel) {
        if (channel >= 0 && channel < channelStates.length) {
            return channelStates[channel];
        }
        return false;
    }
    
    /**
     * Set channel state
     */
    void setChannelState(int channel, boolean state) {
        if (channel >= 0 && channel < channelStates.length) {
            channelStates[channel] = state;
        }
    }
    
    /**
     * Get channel name
     */
    String getChannelName(int channel) {
        if (channel >= 0 && channel < channelNames.length) {
            return channelNames[channel];
        }
        return "Ch" + (channel + 1);
    }
    
    /**
     * Set channel name
     */
    void setChannelName(int channel, String name) {
        if (channel >= 0 && channel < channelNames.length) {
            channelNames[channel] = name;
        }
    }
    
    /**
     * Check if mapping is enabled
     */
    boolean isMappingEnabled() {
        return mappingEnabled;
    }
    
    /**
     * Enable/disable mapping
     */
    void setMappingEnabled(boolean enabled) {
        mappingEnabled = enabled;
        saveKeyMappings();
    }
    
    /**
     * Get all key descriptions for help display
     */
    HashMap<String, String> getKeyDescriptions() {
        return keyDescriptions;
    }
}