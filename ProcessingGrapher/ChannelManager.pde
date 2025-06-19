/* * * * * * * * * * * * * * * * * * * * * * *
 * CHANNEL MANAGER CLASS
 *
 * @file     ChannelManager.pde
 * @brief    Manage data channels and provide parity across different input methods
 * @author   Processing Grapher Team
 *
 * @license  GNU General Public License v3
 * @class    ChannelManager
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

class ChannelManager {
    
    // Channel data structure
    class Channel {
        String name;
        boolean enabled;
        color channelColor;
        int graphAssignment;
        float minValue;
        float maxValue;
        boolean autoScale;
        String units;
        
        Channel(String name, int index) {
            this.name = name;
            this.enabled = true;
            this.channelColor = c_colorlist[index % c_colorlist.length];
            this.graphAssignment = 1;
            this.minValue = 0;
            this.maxValue = 100;
            this.autoScale = true;
            this.units = "";
        }
    }
    
    private ArrayList<Channel> channels;
    private int maxChannels = 16;
    private boolean parityMode = true; // Ensure equal treatment across input methods
    
    /**
     * Constructor
     */
    ChannelManager() {
        channels = new ArrayList<Channel>();
        initializeDefaultChannels();
    }
    
    /**
     * Initialize default channels
     */
    void initializeDefaultChannels() {
        for (int i = 0; i < 8; i++) {
            channels.add(new Channel("Channel " + (i + 1), i));
        }
    }
    
    /**
     * Add new channel
     */
    int addChannel(String name) {
        if (channels.size() >= maxChannels) {
            return -1; // Maximum channels reached
        }
        
        Channel newChannel = new Channel(name, channels.size());
        channels.add(newChannel);
        return channels.size() - 1;
    }
    
    /**
     * Remove channel
     */
    boolean removeChannel(int index) {
        if (index >= 0 && index < channels.size()) {
            channels.remove(index);
            return true;
        }
        return false;
    }
    
    /**
     * Get channel count
     */
    int getChannelCount() {
        return channels.size();
    }
    
    /**
     * Get channel by index
     */
    Channel getChannel(int index) {
        if (index >= 0 && index < channels.size()) {
            return channels.get(index);
        }
        return null;
    }
    
    /**
     * Set channel enabled state
     */
    void setChannelEnabled(int index, boolean enabled) {
        Channel channel = getChannel(index);
        if (channel != null) {
            channel.enabled = enabled;
            
            // Ensure parity - update key mapping
            if (keyMapping != null) {
                keyMapping.setChannelState(index, enabled);
            }
            
            // Update UI elements
            updateChannelDisplay(index);
        }
    }
    
    /**
     * Toggle channel enabled state
     */
    void toggleChannel(int index) {
        Channel channel = getChannel(index);
        if (channel != null) {
            setChannelEnabled(index, !channel.enabled);
        }
    }
    
    /**
     * Set channel name
     */
    void setChannelName(int index, String name) {
        Channel channel = getChannel(index);
        if (channel != null) {
            channel.name = name;
            
            // Ensure parity - update key mapping
            if (keyMapping != null) {
                keyMapping.setChannelName(index, name);
            }
        }
    }
    
    /**
     * Set channel color
     */
    void setChannelColor(int index, color newColor) {
        Channel channel = getChannel(index);
        if (channel != null) {
            channel.channelColor = newColor;
            updateChannelDisplay(index);
        }
    }
    
    /**
     * Set channel graph assignment
     */
    void setChannelGraph(int index, int graphNumber) {
        Channel channel = getChannel(index);
        if (channel != null) {
            channel.graphAssignment = graphNumber;
            updateChannelDisplay(index);
        }
    }
    
    /**
     * Set channel scaling
     */
    void setChannelScale(int index, float minVal, float maxVal, boolean autoScale) {
        Channel channel = getChannel(index);
        if (channel != null) {
            channel.minValue = minVal;
            channel.maxValue = maxVal;
            channel.autoScale = autoScale;
        }
    }
    
    /**
     * Set channel units
     */
    void setChannelUnits(int index, String units) {
        Channel channel = getChannel(index);
        if (channel != null) {
            channel.units = units;
        }
    }
    
    /**
     * Update channel display across all interfaces
     */
    void updateChannelDisplay(int index) {
        // Update live graph if active
        if (currentTab instanceof LiveGraph) {
            LiveGraph liveTab = (LiveGraph)currentTab;
            Channel channel = getChannel(index);
            
            if (channel != null && index < liveTab.dataColumns.length) {
                // Update signal assignment
                if (channel.enabled) {
                    liveTab.graphAssignment[index] = channel.graphAssignment;
                } else {
                    liveTab.graphAssignment[index] = liveTab.graphMode + 1; // Hidden
                }
                
                // Update signal name
                liveTab.dataColumns[index] = channel.name;
                
                redrawUI = true;
                redrawContent = true;
            }
        }
        
        // Update file graph if active
        if (currentTab instanceof FileGraph) {
            FileGraph fileTab = (FileGraph)currentTab;
            Channel channel = getChannel(index);
            
            if (channel != null && index < fileTab.dataSignals.size()) {
                fileTab.dataSignals.get(index).signalText = channel.name;
                fileTab.dataSignals.get(index).signalColor = channel.channelColor;
                
                redrawUI = true;
                redrawContent = true;
            }
        }
    }
    
    /**
     * Synchronize channels with current tab data
     */
    void synchronizeWithTab() {
        if (currentTab instanceof LiveGraph) {
            LiveGraph liveTab = (LiveGraph)currentTab;
            
            // Ensure we have enough channels
            while (channels.size() < liveTab.dataColumns.length) {
                addChannel("Signal-" + (channels.size() + 1));
            }
            
            // Update channel names and states
            for (int i = 0; i < liveTab.dataColumns.length && i < channels.size(); i++) {
                Channel channel = channels.get(i);
                channel.name = liveTab.dataColumns[i];
                channel.enabled = liveTab.graphAssignment[i] <= liveTab.graphMode;
                channel.graphAssignment = liveTab.graphAssignment[i];
                
                // Sync with key mapping
                if (keyMapping != null) {
                    keyMapping.setChannelState(i, channel.enabled);
                    keyMapping.setChannelName(i, channel.name);
                }
            }
        }
        
        if (currentTab instanceof FileGraph) {
            FileGraph fileTab = (FileGraph)currentTab;
            
            // Ensure we have enough channels
            while (channels.size() < fileTab.dataSignals.size()) {
                addChannel("Signal-" + (channels.size() + 1));
            }
            
            // Update channel names and colors
            for (int i = 0; i < fileTab.dataSignals.size() && i < channels.size(); i++) {
                Channel channel = channels.get(i);
                channel.name = fileTab.dataSignals.get(i).signalText;
                channel.channelColor = fileTab.dataSignals.get(i).signalColor;
                channel.enabled = true; // File graph channels are always enabled
                
                // Sync with key mapping
                if (keyMapping != null) {
                    keyMapping.setChannelName(i, channel.name);
                }
            }
        }
    }
    
    /**
     * Apply channel states to current tab
     */
    void applyChannelStates() {
        if (currentTab instanceof LiveGraph) {
            LiveGraph liveTab = (LiveGraph)currentTab;
            
            for (int i = 0; i < channels.size() && i < liveTab.dataColumns.length; i++) {
                Channel channel = channels.get(i);
                
                if (channel.enabled) {
                    liveTab.graphAssignment[i] = channel.graphAssignment;
                } else {
                    liveTab.graphAssignment[i] = liveTab.graphMode + 1; // Hidden
                }
                
                liveTab.dataColumns[i] = channel.name;
            }
            
            redrawUI = true;
            redrawContent = true;
        }
    }
    
    /**
     * Get channel status summary
     */
    String getChannelStatusSummary() {
        int enabledCount = 0;
        for (Channel channel : channels) {
            if (channel.enabled) enabledCount++;
        }
        
        return enabledCount + "/" + channels.size() + " channels active";
    }
    
    /**
     * Export channel configuration
     */
    void exportChannelConfig(String filename) {
        try {
            XML xmlFile = new XML("channel-config");
            
            for (int i = 0; i < channels.size(); i++) {
                Channel channel = channels.get(i);
                XML channelNode = xmlFile.addChild("channel");
                
                channelNode.setInt("index", i);
                channelNode.setString("name", channel.name);
                channelNode.setInt("enabled", channel.enabled ? 1 : 0);
                channelNode.setString("color", hex(channel.channelColor));
                channelNode.setInt("graph", channel.graphAssignment);
                channelNode.setFloat("min", channel.minValue);
                channelNode.setFloat("max", channel.maxValue);
                channelNode.setInt("auto-scale", channel.autoScale ? 1 : 0);
                channelNode.setString("units", channel.units);
            }
            
            saveXML(xmlFile, filename);
            alertMessage("Success\nChannel configuration exported to " + filename);
        } catch (Exception e) {
            alertMessage("Error\nFailed to export channel configuration: " + e);
        }
    }
    
    /**
     * Import channel configuration
     */
    void importChannelConfig(String filename) {
        try {
            XML xmlFile = loadXML(filename);
            XML[] channelNodes = xmlFile.getChildren("channel");
            
            channels.clear();
            
            for (XML channelNode : channelNodes) {
                int index = channelNode.getInt("index");
                String name = channelNode.getString("name");
                boolean enabled = channelNode.getInt("enabled") == 1;
                color channelColor = unhex("FF" + channelNode.getString("color"));
                int graphAssignment = channelNode.getInt("graph");
                float minValue = channelNode.getFloat("min");
                float maxValue = channelNode.getFloat("max");
                boolean autoScale = channelNode.getInt("auto-scale") == 1;
                String units = channelNode.getString("units");
                
                Channel channel = new Channel(name, index);
                channel.enabled = enabled;
                channel.channelColor = channelColor;
                channel.graphAssignment = graphAssignment;
                channel.minValue = minValue;
                channel.maxValue = maxValue;
                channel.autoScale = autoScale;
                channel.units = units;
                
                channels.add(channel);
            }
            
            // Apply imported configuration
            applyChannelStates();
            alertMessage("Success\nChannel configuration imported from " + filename);
        } catch (Exception e) {
            alertMessage("Error\nFailed to import channel configuration: " + e);
        }
    }
    
    /**
     * Reset all channels to default state
     */
    void resetChannels() {
        channels.clear();
        initializeDefaultChannels();
        applyChannelStates();
    }
    
    /**
     * Check if parity mode is enabled
     */
    boolean isParityMode() {
        return parityMode;
    }
    
    /**
     * Set parity mode
     */
    void setParityMode(boolean enabled) {
        parityMode = enabled;
        if (enabled) {
            synchronizeWithTab();
        }
    }
}