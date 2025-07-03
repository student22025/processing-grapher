/* * * * * * * * * * * * * * * * * * * * * * *
 * ENDOSCOPY DATA LOGGER CLASS
 * implements TabAPI for Processing Grapher
 *
 * @file     EndoscopyDataLogger.pde
 * @brief    Specialized data logger for endoscopy experiments
 * @author   Processing Grapher Team
 *
 * @license  GNU General Public License v3
 * @class    EndoscopyDataLogger
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

class EndoscopyDataLogger implements TabAPI {

    int cL, cR, cT, cB;     // Content coordinates (left, right, top bottom)
    int menuScroll;
    int menuHeight;
    int menuLevel;
    ScrollBar sidebarScroll = new ScrollBar(ScrollBar.VERTICAL, ScrollBar.NORMAL);

    String name;
    boolean tabIsVisible = false;
    
    // File naming variables
    String experimentType = "CR";
    String modelType = "B1";
    String year = "Y1";
    String experience = "E01";
    String subject = "S1";
    String trial = "T1";
    String outputFolder = "Endo_Data";
    String currentFilename = "";
    String fullFilePath = "";
    
    // Data logging variables
    boolean isLogging = false;
    CustomTable dataTable;
    int recordCounter = 0;
    boolean autoDetectArduino = true;
    String detectedPort = "No Arduino Detected";
    
    // UI state
    int editingField = -1; // -1 = none, 0-5 = field index
    String[] fieldNames = {"Experiment Type", "Model Type", "Year", "Experience", "Subject", "Trial"};
    String[] fieldValues = {experimentType, modelType, year, experience, subject, trial};
    String[] fieldPlaceholders = {"e.g., CR", "e.g., B1", "e.g., Y1", "e.g., E01", "e.g., S1", "e.g., T1"};

    /**
     * Constructor
     *
     * @param  setname Name of the tab
     * @param  left    Tab area left x-coordinate
     * @param  right   Tab area right x-coordinate
     * @param  top     Tab area top y-coordinate
     * @param  bottom  Tab area bottom y-coordinate
     */
    EndoscopyDataLogger (String setname, int left, int right, int top, int bottom) {
        name = setname;
        
        cL = left;
        cR = right;
        cT = top;
        cB = bottom;

        menuScroll = 0;
        menuHeight = cB - cT - 1; 
        menuLevel = 0;
        
        dataTable = new CustomTable();
        updateFilename();
        
        // Auto-detect Arduino on startup
        detectArduino();
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
            detectArduino();
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
        // Check if user has permission to record data
        if (!userManager.hasPermission("record_data")) {
            String[] message = {"Access Denied", 
                              "You need user privileges or higher to record data.",
                              "Please login with appropriate credentials."};
            drawMessageArea("Access Denied", message, cL + 60 * uimult, cR - 60 * uimult, cT + 30 * uimult);
            return;
        }

        // Main content area
        fill(c_sidebar_text);
        textAlign(LEFT, TOP);
        textFont(base_font);
        
        int yPos = cT + 30;
        int xPos = cL + 30;
        
        // Title
        textSize(18 * uimult);
        fill(c_sidebar_heading);
        text("Endoscopy Data Logger", xPos, yPos);
        yPos += 40 * uimult;
        
        // Current user info
        textSize(12 * uimult);
        fill(c_sidebar_text);
        text("Current User: " + getUserStatusString(), xPos, yPos);
        yPos += 25 * uimult;
        
        // File naming section
        textSize(14 * uimult);
        fill(c_sidebar_heading);
        text("File Naming Configuration", xPos, yPos);
        yPos += 30 * uimult;
        
        textSize(12 * uimult);
        fill(c_sidebar_text);
        
        // Display current filename
        text("Generated Filename: " + currentFilename, xPos, yPos);
        yPos += 20 * uimult;
        text("Full Path: " + fullFilePath, xPos, yPos);
        yPos += 40 * uimult;
        
        // Arduino detection status
        textSize(14 * uimult);
        fill(c_sidebar_heading);
        text("Arduino Connection", xPos, yPos);
        yPos += 30 * uimult;
        
        textSize(12 * uimult);
        if (detectedPort.equals("No Arduino Detected")) {
            fill(c_red);
        } else {
            fill(c_green);
        }
        text("Status: " + detectedPort, xPos, yPos);
        yPos += 40 * uimult;
        
        // Logging status
        textSize(14 * uimult);
        fill(c_sidebar_heading);
        text("Data Logging", xPos, yPos);
        yPos += 30 * uimult;
        
        textSize(12 * uimult);
        if (isLogging) {
            fill(c_green);
            text("Status: Logging Active (" + recordCounter + " records)", xPos, yPos);
        } else {
            fill(c_sidebar_text);
            text("Status: Ready to Log", xPos, yPos);
        }
        
        // Show instructions if not logging
        if (!isLogging && showInstructions) {
            yPos += 60 * uimult;
            String[] instructions = {
                "Instructions:",
                "1. Configure file naming parameters in the sidebar",
                "2. Ensure Arduino is connected and detected",
                "3. Click 'Start Logging' to begin data collection",
                "4. Data will be saved with timestamp to the specified file",
                "5. Click 'Stop Logging' when finished"
            };
            
            for (String instruction : instructions) {
                text(instruction, xPos, yPos);
                yPos += 20 * uimult;
            }
        }
    }

    /**
     * Draw new tab data
     */
    void drawNewData () {
        // Not in use for this tab
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
        if (newoutput != null && !newoutput.equals("No File Set")) {
            outputFolder = newoutput;
            updateFilename();
        }
    }

    /**
     * Get the current CSV data file location
     *
     * @return Absolute path to the data file
     */
    String getOutput () {
        return fullFilePath;
    }

    /**
     * Update filename based on current parameters
     */
    void updateFilename() {
        // Update field values array
        fieldValues[0] = experimentType;
        fieldValues[1] = modelType;
        fieldValues[2] = year;
        fieldValues[3] = experience;
        fieldValues[4] = subject;
        fieldValues[5] = trial;
        
        // Generate filename without underscores
        currentFilename = experimentType + modelType + year + experience + subject + trial + ".csv";
        
        // Create full path
        fullFilePath = outputFolder + "/" + currentFilename;
    }

    /**
     * Detect Arduino port automatically
     */
    void detectArduino() {
        if (!autoDetectArduino) return;
        
        try {
            String[] portList = Serial.list();
            detectedPort = "No Arduino Detected";
            
            if (portList.length > 0) {
                // Try to find Arduino-like port names
                for (String port : portList) {
                    if (port.contains("Arduino") || port.contains("USB") || port.contains("ACM") || port.contains("COM")) {
                        detectedPort = port;
                        break;
                    }
                }
                
                // If no Arduino-specific port found, use first available
                if (detectedPort.equals("No Arduino Detected")) {
                    detectedPort = portList[0];
                }
            }
        } catch (Exception e) {
            detectedPort = "Error detecting ports";
            println("Error detecting Arduino: " + e);
        }
        
        redrawUI = true;
    }

    /**
     * Start data logging
     */
    void startLogging() {
        if (!checkPermission("record_data")) return;
        if (isLogging) return;
        if (detectedPort.equals("No Arduino Detected")) {
            alertMessage("Error\nNo Arduino detected. Please connect Arduino and try again.");
            return;
        }
        
        // Create output directory if it doesn't exist
        File outputDir = new File(sketchPath(outputFolder));
        if (!outputDir.exists()) {
            outputDir.mkdirs();
        }
        
        // Check if file already exists
        File outputFile = new File(sketchPath(fullFilePath));
        if (outputFile.exists()) {
            String[] options = {"Overwrite", "Cancel"};
            String choice = myShowOptionDialog("File Exists", 
                "File " + currentFilename + " already exists. Overwrite?", options);
            if (choice == null || choice.equals("Cancel")) {
                return;
            }
        }
        
        // Initialize data table
        dataTable = new CustomTable();
        dataTable.addColumn("timestamp");
        dataTable.addColumn("data");
        
        // Open CSV output stream
        if (!dataTable.openCSVoutput(sketchPath(fullFilePath))) {
            alertMessage("Error\nUnable to create output file: " + fullFilePath);
            return;
        }
        
        // Connect to serial port if not already connected
        if (!serialConnected || !serialPort.name().equals(detectedPort)) {
            try {
                if (serialConnected) {
                    serialPort.stop();
                }
                serialPort = new Serial(this, detectedPort, baudRate);
                serialConnected = true;
                serialBuffer = "";
            } catch (Exception e) {
                alertMessage("Error\nFailed to connect to Arduino on port " + detectedPort + "\n" + e);
                dataTable.closeCSVoutput();
                return;
            }
        }
        
        isLogging = true;
        recordCounter = 0;
        redrawUI = true;
        
        alertMessage("Success\nData logging started.\nFile: " + currentFilename);
    }

    /**
     * Stop data logging
     */
    void stopLogging() {
        if (!isLogging) return;
        
        isLogging = false;
        
        if (dataTable.closeCSVoutput()) {
            alertMessage("Success\nLogging stopped.\nRecorded " + recordCounter + " samples to " + currentFilename);
        } else {
            alertMessage("Error\nThere was an issue closing the output file.");
        }
        
        redrawUI = true;
    }

    /**
     * Draw the sidebar menu for the current tab
     */
    void drawSidebar () {
        if (!userManager.hasPermission("record_data")) {
            // Show login prompt for users without permission
            int sT = cT;
            int sL = cR;
            int sW = width - cR;
            int uH = round(sideItemHeight * uimult);
            int tH = round((sideItemHeight - 8) * uimult);
            int iH = round((sideItemHeight - 5) * uimult);
            int iL = round(sL + (10 * uimult));
            int iW = round(sW - (20 * uimult));

            drawHeading("Access Required", iL, sT + (uH * 0), iW, tH);
            drawText("User privileges required", c_sidebar_text, iL, sT + (uH * 1.5), iW, iH);
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
        
        menuHeight = round((18 + fieldNames.length) * uH);

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

        // Current user info
        drawHeading("Current User", iL, sT + (uH * 0), iW, tH);
        drawDatabox(getUserStatusString(), c_sidebar_text, iL, sT + (uH * 1), iW, iH, tH);

        // File naming configuration
        drawHeading("File Naming", iL, sT + (uH * 2.5), iW, tH);
        
        float tHnow = 3.5;
        for (int i = 0; i < fieldNames.length; i++) {
            color buttonColor = (editingField == i) ? c_sidebar_accent : c_sidebar_button;
            drawButton(fieldNames[i] + ": " + fieldValues[i], buttonColor, iL, sT + (uH * tHnow), iW, iH, tH);
            tHnow++;
        }
        
        // Output folder
        tHnow += 0.5;
        drawButton("Output Folder", c_sidebar_button, iL, sT + (uH * tHnow), iW, iH, tH);
        tHnow++;
        drawDatabox(outputFolder, c_sidebar_text, iL, sT + (uH * tHnow), iW, iH, tH);
        
        // File preview
        tHnow += 1.5;
        drawHeading("File Preview", iL, sT + (uH * tHnow), iW, tH);
        tHnow++;
        drawDatabox(currentFilename, c_sidebar_text, iL, sT + (uH * tHnow), iW, iH, tH);

        // Arduino connection
        tHnow += 1.5;
        drawHeading("Arduino Connection", iL, sT + (uH * tHnow), iW, tH);
        tHnow++;
        color portColor = detectedPort.equals("No Arduino Detected") ? c_red : c_green;
        drawDatabox(detectedPort, portColor, iL, sT + (uH * tHnow), iW, iH, tH);
        tHnow++;
        drawButton("Detect Arduino", c_sidebar_button, iL, sT + (uH * tHnow), iW, iH, tH);

        // Data logging controls
        tHnow += 1.5;
        drawHeading("Data Logging", iL, sT + (uH * tHnow), iW, tH);
        tHnow++;
        
        if (isLogging) {
            drawButton("Stop Logging", c_red, iL, sT + (uH * tHnow), iW, iH, tH);
            tHnow++;
            drawDatabox("Records: " + recordCounter, c_green, iL, sT + (uH * tHnow), iW, iH, tH);
        } else {
            color startColor = detectedPort.equals("No Arduino Detected") ? c_idletab_text : c_sidebar_button;
            drawButton("Start Logging", startColor, iL, sT + (uH * tHnow), iW, iH, tH);
        }
    }

    /**
     * Draw the bottom information bar
     */
    void drawInfoBar() {
        textAlign(LEFT, TOP);
        textFont(base_font);
        fill(c_status_bar);
        String status = isLogging ? "Logging: " + currentFilename : "Ready: " + currentFilename;
        text(status, round(5 * uimult), height - round(bottombarHeight * uimult) + round(2*uimult));
    }

    /**
     * Keyboard input handler function
     *
     * @param  key The character of the key that was pressed
     */
    void keyboardInput (char keyChar, int keyCodeInt, boolean codedKey) {
        if (keyChar == ESC) {
            editingField = -1;
            redrawUI = true;
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
        // Not in use for this tab
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
        if (!userManager.hasPermission("record_data")) {
            // Handle login button for users without permission
            int sT = cT;
            int sL = cR;
            int sW = width - cR;
            int uH = round(sideItemHeight * uimult);
            int iH = round((sideItemHeight - 5) * uimult);
            int iL = round(sL + (10 * uimult));
            int iW = round(sW - (20 * uimult));

            if (menuXYclick(xcoord, ycoord, sT, uH, iH, 2.5, iL, iW)) {
                promptLogin();
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

        // File naming fields
        float tHnow = 3.5;
        for (int i = 0; i < fieldNames.length; i++) {
            if (menuXYclick(xcoord, ycoord, sT, uH, iH, tHnow, iL, iW)) {
                String newValue = myShowInputDialog("Edit " + fieldNames[i], fieldNames[i] + ":", fieldValues[i]);
                if (newValue != null && !newValue.trim().equals("")) {
                    switch (i) {
                        case 0: experimentType = newValue.trim(); break;
                        case 1: modelType = newValue.trim(); break;
                        case 2: year = newValue.trim(); break;
                        case 3: experience = newValue.trim(); break;
                        case 4: subject = newValue.trim(); break;
                        case 5: trial = newValue.trim(); break;
                    }
                    updateFilename();
                    redrawUI = true;
                }
            }
            tHnow++;
        }

        // Output folder
        tHnow += 0.5;
        if (menuXYclick(xcoord, ycoord, sT, uH, iH, tHnow, iL, iW)) {
            selectOutput("Select output folder", "endoscopyFolderSelected");
        }

        // Detect Arduino
        tHnow += 4;
        if (menuXYclick(xcoord, ycoord, sT, uH, iH, tHnow, iL, iW)) {
            detectArduino();
        }

        // Start/Stop logging
        tHnow += 2;
        if (menuXYclick(xcoord, ycoord, sT, uH, iH, tHnow, iL, iW)) {
            if (isLogging) {
                stopLogging();
            } else {
                startLogging();
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
        if (!isLogging) return;
        
        try {
            // Add timestamp and data to table
            TableRow newRow = dataTable.addRow();
            String timestamp = nf(year(), 4) + "-" + nf(month(), 2) + "-" + nf(day(), 2) + " " +
                              nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2) + "." +
                              nf(millis() % 1000, 3);
            
            newRow.setString("timestamp", timestamp);
            newRow.setString("data", inputData);
            
            // Save to file immediately
            if (dataTable.saveCSVentries(dataTable.lastRowIndex(), dataTable.lastRowIndex())) {
                recordCounter++;
                redrawUI = true;
            } else {
                // Handle save error
                alertMessage("Error\nFailed to save data to file. Stopping logging.");
                stopLogging();
            }
            
        } catch (Exception e) {
            println("Error logging data: " + e);
        }
    }

    /**
     * Function called when a serial device has connected/disconnected
     *
     * @param  status True if a device has connected, false if disconnected
     */
    void connectionEvent (boolean status) {
        if (!status && isLogging) {
            // Stop logging if serial connection is lost
            stopLogging();
            alertMessage("Warning\nSerial connection lost. Logging stopped.");
        }
        
        if (tabIsVisible) {
            detectArduino();
        }
    }

    /**
     * Check whether it is safe to exit the program
     *
     * @return True if the are no tasks active, false otherwise
     */
    boolean checkSafeExit() {
        return !isLogging;
    }

    /**
     * End any active processes and safely exit the tab
     */
    void performExit() {
        if (isLogging) {
            stopLogging();
        }
    }
}

/**
 * File selection callback for endoscopy data logger
 */
void endoscopyFolderSelected(File selection) {
    if (selection != null && currentTab instanceof EndoscopyDataLogger) {
        EndoscopyDataLogger endoTab = (EndoscopyDataLogger)currentTab;
        endoTab.outputFolder = selection.getAbsolutePath();
        endoTab.updateFilename();
        redrawUI = true;
    }
}