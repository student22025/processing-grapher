/* * * * * * * * * * * * * * * * * * * * * * *
 * PROCESSING GRAPHER
 *
 * @file     ProcessingGrapher.pde
 * @brief    Main program file for the Processing Grapher
 * @author   Simon Bluett
 *
 * @license  GNU General Public License v3
 * @version  1.7.0
 * @date     28th April 2024
 * * * * * * * * * * * * * * * * * * * * * * */

/*
 * Copyright (C) 2022 - Simon Bluett <hello@chillibasket.com>
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

import processing.serial.*;
import java.awt.event.KeyEvent;
import java.util.concurrent.locks.ReentrantLock;

// Program information
final String versionNumber = "1.7.0";
final String buildDate = "28th April 2024";

// Renderer selection
// Use JAVA2D for Linux, FX2D for Windows/Mac
final String activeRenderer = FX2D;

// Tab interface
interface TabAPI {
	String getName();
	void setVisibility(boolean newState);
	void setMenuLevel(int newLevel);
	void drawContent();
	void drawNewData();
	void changeSize(int newL, int newR, int newT, int newB);
	void setOutput(String newoutput);
	String getOutput();
	void drawSidebar();
	void drawInfoBar();
	void keyboardInput(char keyChar, int keyCodeInt, boolean codedKey);
	void contentClick(int xcoord, int ycoord);
	void scrollWheel(float amount);
	void scrollBarUpdate(int xcoord, int ycoord);
	void menuClick(int xcoord, int ycoord);
	void parsePortData(String inputData, boolean graphable);
	void connectionEvent(boolean status);
	boolean checkSafeExit();
	void performExit();
}

// Fonts
PFont base_font;
PFont mono_font;

// Colours
color c_white = color(255, 255, 255);
color c_lightgrey = color(200, 200, 200);
color c_grey = color(150, 150, 150);
color c_darkgrey = color(100, 100, 100);
color c_black = color(0, 0, 0);
color c_red = color(255, 108, 96);
color c_orange = color(255, 206, 84);
color c_yellow = color(255, 233, 105);
color c_green = color(144, 190, 109);
color c_blue = color(85, 165, 217);
color c_purple = color(178, 118, 178);
color c_pink = color(255, 167, 209);

// Colour scheme
color c_background;
color c_tabbar;
color c_tabbar_h;
color c_idletab;
color c_tabbar_text;
color c_idletab_text;
color c_sidebar;
color c_sidebar_h;
color c_sidebar_heading;
color c_sidebar_text;
color c_sidebar_button;
color c_sidebar_divider;
color c_sidebar_accent;
color c_terminal_text;
color c_message_text;
color c_graph_axis;
color c_graph_gridlines;
color c_graph_border;
color c_serial_message_box;
color c_message_box_outline;
color c_alert_message_box;
color c_info_message_box;
color c_status_bar;
color c_highlight_background;

// Graph colours
color[] c_colorlist = {c_red, c_blue, c_green, c_orange, c_purple, c_yellow, c_pink, c_lightgrey};

// UI sizing
float uimult = 1.0;
int tabHeight = 35;
int sidebarWidth = 200;
int bottombarHeight = 20;
int sideItemHeight = 24;

// UI state
boolean redrawUI = true;
boolean redrawContent = true;
boolean drawNewData = false;
boolean drawFPS = false;
boolean showInstructions = true;
boolean settingsMenuActive = false;
boolean scrollingActive = false;
boolean scrollingVertical = false;
int colorScheme = 1;

// Tabs
TabAPI[] tabList;
TabAPI currentTab;
int currentTabID = 0;
String[] tabNames = {"Serial", "Live Graph", "File Graph", "Endoscopy Logger", "Settings"};

// Serial communication
Serial serialPort;
boolean serialConnected = false;
String serialBuffer = "";
int baudRate = 9600;
char lineEnding = '\n';
char serialParity = 'N';
int serialDatabits = 8;
float serialStopbits = 1.0;
char separator = ',';

// Keyboard state
boolean ctrlPressed = false;
boolean altPressed = false;
boolean shiftPressed = false;

/**
 * Main setup function
 */
void setup() {
	// Window setup
	size(1000, 700);
	surface.setTitle("Processing Grapher v" + versionNumber);
	surface.setResizable(true);
	
	// Load fonts
	try {
		base_font = createFont("Arial", 12);
		mono_font = loadFont("Inconsolata-SemiBold-12.vlw");
	} catch (Exception e) {
		println("Error loading fonts: " + e);
		base_font = createFont("Arial", 12);
		mono_font = createFont("Courier", 12);
	}
	
	// Initialize color scheme
	loadColorScheme(colorScheme);
	
	// Initialize access control and accessibility
	initializeAccessControl();
	initializeAccessibility();
	
	// Initialize tabs
	initializeTabs();
	
	// Load user settings
	if (tabList[4] instanceof Settings) {
		((Settings)tabList[4]).loadSettings();
	}
	
	println("Processing Grapher v" + versionNumber + " initialized");
}

/**
 * Initialize all tabs
 */
void initializeTabs() {
	tabList = new TabAPI[5];
	
	// Calculate tab content area
	int contentL = 0;
	int contentR = width - sidebarWidth;
	int contentT = tabHeight;
	int contentB = height - bottombarHeight;
	
	// Initialize tabs
	tabList[0] = new SerialMonitor("Serial", contentL, contentR, contentT, contentB);
	tabList[1] = new LiveGraph("Live Graph", contentL, contentR, contentT, contentB);
	tabList[2] = new FileGraph("File Graph", contentL, contentR, contentT, contentB);
	tabList[3] = new EndoscopyDataLogger("Endoscopy Logger", contentL, contentR, contentT, contentB);
	tabList[4] = new Settings("Settings", contentL, contentR, contentT, contentB);
	
	// Set initial tab
	currentTab = tabList[0];
	currentTab.setVisibility(true);
}

/**
 * Main draw function
 */
void draw() {
	// Handle UI redraw
	if (redrawUI || redrawContent) {
		background(c_background);
		
		// Draw tab bar
		drawTabBar();
		
		// Draw current tab content
		if (redrawContent) {
			currentTab.drawContent();
		}
		
		// Draw new data if needed
		if (drawNewData) {
			currentTab.drawNewData();
			drawNewData = false;
		}
		
		// Draw sidebar
		currentTab.drawSidebar();
		
		// Draw bottom info bar
		currentTab.drawInfoBar();
		
		// Draw accessibility overlay
		if (accessibilityManager != null) {
			accessibilityManager.drawAccessibilityOverlay();
		}
		
		// Draw FPS if enabled
		if (drawFPS) {
			drawFPSCounter();
		}
		
		redrawUI = false;
		redrawContent = false;
	}
}

/**
 * Draw tab bar
 */
void drawTabBar() {
	// Tab bar background
	fill(c_tabbar);
	noStroke();
	rect(0, 0, width, tabHeight);
	
	// Draw tabs
	int tabWidth = (width - sidebarWidth) / tabNames.length;
	for (int i = 0; i < tabNames.length; i++) {
		int tabX = i * tabWidth;
		
		// Check if user can access this tab
		boolean canAccess = canAccessTab(tabNames[i]);
		
		// Tab background
		if (i == currentTabID) {
			fill(c_background);
		} else if (canAccess) {
			fill(c_idletab);
		} else {
			fill(c_tabbar_h);
		}
		rect(tabX, 0, tabWidth, tabHeight);
		
		// Tab text
		if (i == currentTabID) {
			fill(c_tabbar_text);
		} else if (canAccess) {
			fill(c_idletab_text);
		} else {
			fill(c_darkgrey);
		}
		
		textAlign(CENTER, CENTER);
		textFont(base_font);
		text(tabNames[i], tabX + tabWidth/2, tabHeight/2);
		
		// Tab border
		stroke(c_tabbar_h);
		strokeWeight(1);
		if (i > 0) line(tabX, 0, tabX, tabHeight);
	}
	
	// Sidebar area
	fill(c_sidebar);
	rect(width - sidebarWidth, 0, sidebarWidth, tabHeight);
	
	// User status in sidebar
	fill(c_sidebar_text);
	textAlign(RIGHT, CENTER);
	text(getUserStatusString(), width - 10, tabHeight/2);
}

/**
 * Draw FPS counter
 */
void drawFPSCounter() {
	fill(c_sidebar_accent);
	textAlign(LEFT, TOP);
	textFont(mono_font);
	text("FPS: " + nf(frameRate, 0, 1), 10, 10);
}

/**
 * Handle window resize
 */
void windowResized() {
	uiResize();
}

/**
 * Resize UI elements
 */
void uiResize() {
	// Recalculate content area
	int contentL = 0;
	int contentR = width - round(sidebarWidth * uimult);
	int contentT = round(tabHeight * uimult);
	int contentB = height - round(bottombarHeight * uimult);
	
	// Update all tabs
	for (TabAPI tab : tabList) {
		if (tab != null) {
			tab.changeSize(contentL, contentR, contentT, contentB);
		}
	}
	
	redrawUI = true;
	redrawContent = true;
}

/**
 * Handle mouse clicks
 */
void mousePressed() {
	updateUserActivity();
	
	// Handle accessibility mouse events
	if (accessibilityManager != null) {
		accessibilityManager.handleAccessibilityMouse(mouseX, mouseY, true);
	}
	
	// Check tab clicks
	if (mouseY < tabHeight * uimult) {
		int tabWidth = (width - round(sidebarWidth * uimult)) / tabNames.length;
		int clickedTab = mouseX / tabWidth;
		
		if (clickedTab >= 0 && clickedTab < tabNames.length && clickedTab != currentTabID) {
			if (canAccessTab(tabNames[clickedTab])) {
				switchToTab(clickedTab);
			} else {
				alertMessage("Access Denied\n" + getTabAccessMessage(tabNames[clickedTab]));
			}
		}
		return;
	}
	
	// Check sidebar clicks
	if (mouseX >= width - round(sidebarWidth * uimult)) {
		currentTab.menuClick(mouseX, mouseY);
		return;
	}
	
	// Content area clicks
	currentTab.contentClick(mouseX, mouseY);
}

/**
 * Switch to a different tab
 */
void switchToTab(int tabIndex) {
	if (tabIndex >= 0 && tabIndex < tabList.length) {
		currentTab.setVisibility(false);
		currentTabID = tabIndex;
		currentTab = tabList[tabIndex];
		currentTab.setVisibility(true);
		redrawUI = true;
		redrawContent = true;
	}
}

/**
 * Handle mouse wheel scrolling
 */
void mouseWheel(MouseEvent event) {
	currentTab.scrollWheel(event.getCount());
}

/**
 * Handle mouse drag for scroll bars
 */
void mouseDragged() {
	currentTab.scrollBarUpdate(mouseX, mouseY);
}

/**
 * Handle key presses
 */
void keyPressed() {
	updateUserActivity();
	
	// Update modifier key states
	ctrlPressed = (keyCode == CONTROL) || (key == CODED && keyCode == 157);
	altPressed = (keyCode == ALT) || (key == CODED && keyCode == 18);
	shiftPressed = (keyCode == SHIFT) || (key == CODED && keyCode == 16);
	
	// Handle accessibility keys first
	if (accessibilityManager != null && accessibilityManager.handleAccessibilityKeys(key, keyCode, key == CODED)) {
		return;
	}
	
	// Handle global shortcuts
	if (ctrlPressed) {
		switch (key) {
			case 'q':
			case 'Q':
				// Quick connect/disconnect
				toggleSerialConnection();
				return;
			case 's':
			case 'S':
				// Quick save
				if (currentTab instanceof LiveGraph) {
					LiveGraph liveTab = (LiveGraph)currentTab;
					if (liveTab.getOutput().equals("No File Set")) {
						selectOutput("Select output file", "fileSelected");
					}
				}
				return;
			case 'o':
			case 'O':
				// Quick open
				if (checkPermission("view_data")) {
					selectInput("Select file to open", "fileSelected");
				}
				return;
			case 'r':
			case 'R':
				// Start/stop recording
				if (currentTab instanceof LiveGraph) {
					LiveGraph liveTab = (LiveGraph)currentTab;
					if (liveTab.recordData) {
						liveTab.stopRecording();
					} else if (!liveTab.getOutput().equals("No File Set")) {
						liveTab.startRecording();
					}
				}
				return;
			case 'm':
			case 'M':
				// Send serial message
				if (currentTab instanceof SerialMonitor) {
					((SerialMonitor)currentTab).showSendMessageDialog();
				}
				return;
			case '\t':
				// Switch tabs
				int nextTab = (currentTabID + 1) % tabNames.length;
				while (!canAccessTab(tabNames[nextTab]) && nextTab != currentTabID) {
					nextTab = (nextTab + 1) % tabNames.length;
				}
				if (nextTab != currentTabID) {
					switchToTab(nextTab);
				}
				return;
		}
	}
	
	// Pass to current tab
	currentTab.keyboardInput(key, keyCode, key == CODED);
}

/**
 * Handle key releases
 */
void keyReleased() {
	// Update modifier key states
	if (keyCode == CONTROL || (key == CODED && keyCode == 157)) ctrlPressed = false;
	if (keyCode == ALT || (key == CODED && keyCode == 18)) altPressed = false;
	if (keyCode == SHIFT || (key == CODED && keyCode == 16)) shiftPressed = false;
}

/**
 * Toggle serial connection
 */
void toggleSerialConnection() {
	if (serialConnected) {
		disconnectSerial();
	} else {
		connectSerial();
	}
}

/**
 * Connect to serial port
 */
void connectSerial() {
	if (serialConnected) return;
	
	try {
		String[] portList = Serial.list();
		if (portList.length == 0) {
			alertMessage("Error\nNo serial ports available");
			return;
		}
		
		// Use first available port or previously detected port
		String portName = portList[0];
		serialPort = new Serial(this, portName, baudRate);
		serialConnected = true;
		serialBuffer = "";
		
		// Notify all tabs
		for (TabAPI tab : tabList) {
			if (tab != null) {
				tab.connectionEvent(true);
			}
		}
		
		redrawUI = true;
		println("Connected to serial port: " + portName);
		
	} catch (Exception e) {
		alertMessage("Error\nFailed to connect to serial port:\n" + e.getMessage());
	}
}

/**
 * Disconnect from serial port
 */
void disconnectSerial() {
	if (!serialConnected) return;
	
	try {
		serialPort.stop();
		serialConnected = false;
		
		// Notify all tabs
		for (TabAPI tab : tabList) {
			if (tab != null) {
				tab.connectionEvent(false);
			}
		}
		
		redrawUI = true;
		println("Disconnected from serial port");
		
	} catch (Exception e) {
		println("Error disconnecting serial port: " + e);
	}
}

/**
 * Handle incoming serial data
 */
void serialEvent(Serial port) {
	try {
		while (port.available() > 0) {
			char inChar = (char)port.read();
			
			if (inChar == lineEnding) {
				// Process complete message
				String message = serialBuffer.trim();
				if (message.length() > 0) {
					// Check if message is graphable (contains numbers and separators)
					boolean graphable = isGraphableData(message);
					
					// Send to all tabs
					for (TabAPI tab : tabList) {
						if (tab != null) {
							tab.parsePortData(message, graphable);
						}
					}
				}
				serialBuffer = "";
			} else {
				serialBuffer += inChar;
			}
		}
	} catch (Exception e) {
		println("Error reading serial data: " + e);
	}
}

/**
 * Check if data can be plotted on a graph
 */
boolean isGraphableData(String data) {
	if (data == null || data.trim().length() == 0) return false;
	
	String[] parts = data.split(String.valueOf(separator));
	if (parts.length < 2) return false;
	
	// Check if at least 2 parts are numbers
	int numberCount = 0;
	for (String part : parts) {
		try {
			Float.parseFloat(part.trim());
			numberCount++;
		} catch (NumberFormatException e) {
			// Not a number
		}
	}
	
	return numberCount >= 2;
}

/**
 * File selection callback
 */
void fileSelected(File selection) {
	if (selection == null) return;
	
	String path = selection.getAbsolutePath();
	
	if (currentTab instanceof LiveGraph) {
		currentTab.setOutput(path);
	} else if (currentTab instanceof FileGraph) {
		currentTab.setOutput(path);
	}
	
	redrawUI = true;
}

/**
 * Handle program exit
 */
void exit() {
	// Check if it's safe to exit
	boolean safeToExit = true;
	for (TabAPI tab : tabList) {
		if (tab != null && !tab.checkSafeExit()) {
			safeToExit = false;
			break;
		}
	}
	
	if (!safeToExit) {
		String[] options = {"Force Exit", "Cancel"};
		String choice = myShowOptionDialog("Confirm Exit", 
			"Some operations are still active. Force exit?", options);
		if (choice == null || choice.equals("Cancel")) {
			return;
		}
	}
	
	// Perform cleanup
	for (TabAPI tab : tabList) {
		if (tab != null) {
			tab.performExit();
		}
	}
	
	if (serialConnected) {
		disconnectSerial();
	}
	
	super.exit();
}

/**
 * UI scaling helper function
 */
void uiResize(float delta) {
	uimult += delta;
	if (uimult < 0.5) uimult = 0.5;
	if (uimult > 2.0) uimult = 2.0;
	
	// Update UI element sizes
	tabHeight = round(35 * uimult);
	sidebarWidth = round(200 * uimult);
	bottombarHeight = round(20 * uimult);
	sideItemHeight = round(24 * uimult);
	
	uiResize();
}

/**
 * Show input dialog
 */
String myShowInputDialog(String title, String message, String defaultValue) {
	try {
		return FxDialogs.showTextInput(title, message, defaultValue);
	} catch (Exception e) {
		// Fallback for non-JavaFX environments
		return javax.swing.JOptionPane.showInputDialog(null, message, defaultValue);
	}
}

/**
 * Show alert message
 */
void alertMessage(String message) {
	try {
		String[] parts = message.split("\n", 2);
		String title = parts.length > 1 ? parts[0] : "Information";
		String content = parts.length > 1 ? parts[1] : message;
		FxDialogs.showInformation(title, content);
	} catch (Exception e) {
		// Fallback for non-JavaFX environments
		javax.swing.JOptionPane.showMessageDialog(null, message);
	}
}

/**
 * Utility functions for UI drawing
 */
void drawHeading(String text, int x, int y, int w, int h) {
	fill(c_sidebar_heading);
	textAlign(LEFT, CENTER);
	textFont(base_font);
	text(text, x, y + h/2);
}

void drawButton(String text, color bgColor, int x, int y, int w, int h, int textHeight) {
	fill(bgColor);
	stroke(c_sidebar_divider);
	strokeWeight(1);
	rect(x, y, w, h);
	
	fill(c_sidebar_text);
	textAlign(CENTER, CENTER);
	textFont(base_font);
	text(text, x + w/2, y + h/2);
}

void drawDatabox(String text, color textColor, int x, int y, int w, int h, int textHeight) {
	fill(c_idletab);
	stroke(c_sidebar_divider);
	strokeWeight(1);
	rect(x, y, w, h);
	
	fill(textColor);
	textAlign(LEFT, CENTER);
	textFont(base_font);
	text(constrainString(text, w - 10), x + 5, y + h/2);
}

void drawText(String text, color textColor, int x, int y, int w, int h) {
	fill(textColor);
	textAlign(LEFT, CENTER);
	textFont(base_font);
	text(text, x, y + h/2);
}

void drawRectangle(color fillColor, int x, int y, int w, int h) {
	fill(fillColor);
	noStroke();
	rect(x, y, w, h);
}

void drawTriangle(color fillColor, int x1, int y1, int x2, int y2, int x3, int y3) {
	fill(fillColor);
	noStroke();
	triangle(x1, y1, x2, y2, x3, y3);
}

/**
 * Constrain string to fit within specified width
 */
String constrainString(String text, int maxWidth) {
	if (text == null) return "";
	
	textFont(base_font);
	if (textWidth(text) <= maxWidth) {
		return text;
	}
	
	String constrained = text;
	while (textWidth(constrained + "...") > maxWidth && constrained.length() > 0) {
		constrained = constrained.substring(0, constrained.length() - 1);
	}
	
	return constrained + "...";
}

/**
 * Check if click is within specified area
 */
boolean menuXYclick(int mouseX, int mouseY, int startY, int unitHeight, int itemHeight, float row, int itemLeft, int itemWidth) {
	int targetY = round(startY + (unitHeight * row));
	return (mouseX >= itemLeft && mouseX <= itemLeft + itemWidth && 
	        mouseY >= targetY && mouseY <= targetY + itemHeight);
}

boolean menuXclick(int mouseX, int itemLeft, int itemWidth) {
	return (mouseX >= itemLeft && mouseX <= itemLeft + itemWidth);
}

/**
 * Mathematical utility functions
 */
float roundToSigFig(float value, int sigFigs) {
	if (value == 0) return 0;
	float magnitude = pow(10, floor(log(abs(value)) / log(10)) - sigFigs + 1);
	return round(value / magnitude) * magnitude;
}

float floorToSigFig(float value, int sigFigs) {
	if (value == 0) return 0;
	float magnitude = pow(10, floor(log(abs(value)) / log(10)) - sigFigs + 1);
	return floor(value / magnitude) * magnitude;
}

float ceilToSigFig(float value, int sigFigs) {
	if (value == 0) return 0;
	float magnitude = pow(10, floor(log(abs(value)) / log(10)) - sigFigs + 1);
	return ceil(value / magnitude) * magnitude;
}

/**
 * Draw message area with title and content
 */
void drawMessageArea(String title, String[] messages, int x1, int x2, int y1) {
	int messageHeight = round(20 * uimult);
	int totalHeight = round((messages.length + 2) * messageHeight);
	
	// Background
	fill(c_info_message_box);
	stroke(c_message_box_outline);
	strokeWeight(1);
	rect(x1, y1, x2 - x1, totalHeight);
	
	// Title
	fill(c_sidebar_heading);
	textAlign(CENTER, TOP);
	textFont(base_font);
	text(title, (x1 + x2) / 2, y1 + messageHeight/2);
	
	// Messages
	fill(c_message_text);
	textAlign(LEFT, TOP);
	for (int i = 0; i < messages.length; i++) {
		text(messages[i], x1 + 10, y1 + (i + 2) * messageHeight);
	}
}

/**
 * Start scrolling operation
 */
void startScrolling(boolean vertical) {
	scrollingActive = true;
	scrollingVertical = vertical;
}