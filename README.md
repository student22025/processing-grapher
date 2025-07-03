# Processing Grapher with Endoscopy Data Logger

[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)
[![Issues](https://img.shields.io/github/issues-raw/chillibasket/processing-grapher.svg?maxAge=25000)](https://github.com/chillibasket/processing-grapher/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/chillibasket/processing-grapher.svg?style=flat)](https://github.com/chillibasket/processing-grapher/commits/master)

# Serial Monitor and Real-time Graphing Program with Endoscopy Data Logger

This project is a Processing-based serial terminal and graphing program for the analysis and recording of data from serial devices, such as Arduinos. This program is designed as a replacement for the serial monitor contained within the Arduino IDE. The program contains easy-to-use tools to record data received from serial devices, and to plot numerical data on up to 4 separate graphs in real-time. This makes it useful for quickly analysing sensor data from a micro-controller.

**NEW**: Now includes a specialized **Endoscopy Data Logger** tab with user authentication and automated file naming for medical/research applications.

A full description and set of instructions can be found on my website: [https://wired.chillibasket.com/processing-grapher/](https://wired.chillibasket.com/processing-grapher/)

![](/Images/LiveGraph_tab.jpg)
*Live graph tab, illustrating how real-time data can be plotted on multiple graphs*

## Features 

### Core Features
1. **Serial terminal monitor**
   - Connect to any serial port at any baud rate
   - Send and receive serial communication
   - Record the communication as a text file
   - Change the colour of lines containing specific tags

2. **Live Graphing**
   - Plot real-time data obtained from serial device on a graph
   - Can display data on up to 4 separate graphs
   - Plot data with respect to time, or with respect to one of the inputs
   - Supports comma delimited numbers only (example: 12,24,-15.4)
   - Apply different colours and names to each input
   - Record the real-time data as a comma delimited file

3. **File Graphing**
   - Opens comma delimited files for analysis
   - Apply different colours and names to each input
   - Supports zooming into sections of the waveforms
   - Add vertical markers/labels to the data
   - Apply various filters to remove noise and transform the data
   - Save the edited data to a comma delimited file

4. **Easy UI scaling and colour theme switching**

### NEW: Endoscopy Data Logger Features

5. **User Authentication System**
   - **Admin Access**: Full system access with user management capabilities
   - **User Access**: Standard data logging functionality
   - **Guest Access**: Limited read-only access
   - **Default Credentials**:
     - Admin: `admin` / `admin123`
     - User: `user` / `user123`

6. **Automated File Naming System**
   - **Standardized Nomenclature**: Follows the pattern `ExperimentTypeModelTypeYearExperienceSubjectTrial.csv`
   - **Example**: `CRB1Y1E01S1T1.csv`
   - **Components**:
     - Experiment Type (e.g., CR)
     - Model Type (e.g., B1)
     - Year (e.g., Y1)
     - Experience (e.g., E01)
     - Subject (e.g., S1)
     - Trial (e.g., T1)

7. **Specialized Data Logging**
   - **Auto-detection**: Automatically detects Arduino/serial devices
   - **Real-time Logging**: Timestamps all incoming data with millisecond precision
   - **CSV Format**: Saves data in comma-separated values format
   - **Thread-safe**: Non-blocking data collection
   - **Error Recovery**: Automatic handling of connection issues

8. **Accessibility Features**
   - **Virtual Keyboard**: On-screen keyboard for input accessibility
   - **Key Mapping**: Customizable keyboard shortcuts for channel control
   - **High Contrast Mode**: Enhanced visibility options
   - **Screen Reader Support**: Accessibility announcements
   - **Channel Parity**: Equal access via keyboard and mouse

## Installation/Setup Guide

### Basic Usage in the Processing IDE
1. Download and install the Processing IDE version 3.5.4 from [https://processing.org/](https://processing.org/releases). Note that the newer versions >4.0 are not yet supported.
2. Clone or download all files in this repository.
3. Open the main program file `ProcessingGrapher.pde` in the Processing editor. All the other files should automatically open in separate tabs in the Processing IDE.
4. Press the `Run` button in the top-left of the Processing editor to start the program.

### Using the Program on Linux
To use the program on Linux, there are two additional steps that need to be taken:
1. Change the renderer on line 218 to `final String activeRenderer = JAVA2D`. Unfortunately the renderer used on the other platforms (JavaFX) currently has some compatibility issues on Linux.
2. If the error message `Permission Denied` appears when trying to connect to a serial port, this means that your current user account doesn't have the permissions set up to access the serial ports. To solve you can either run the program using `sudo`, or you can set up your user so that it has access to the ports using these two commands (replace `<user>` with the account username):
   - `sudo usermod -a -G dialout <user>`
   - `sudo usermod -a -G tty <user>` 
   - Reboot the computer to apply the changes.

### Creating a Stand-alone Program
It is possible to create a stand-alone version of the program, which does not require the Processing IDE to run.

1. Open the code in the Processing IDE, as described in the previous steps.
2. In the top bar, click on `File > Export Application...`
3. In the *Export Options* window that pops up, select the platform you want to export for and make sure that the *Embed Java* option is ticked. Finally, click *Export*.
4. This will create an application folder which will include either an `*.exe` file (Windows), shell script (Linux) or `*.app` launch file (OS X) which you can use to run the program.

## Getting Started

### Basic Serial Communication
1. To connect to an Arduino:
   1. Ensure Arduino is plugged into your computer
   2. Go to the "Serial" tab of the program
   3. In the right-hand sidebar, press on `Port: None` button
   4. A list of all available ports should appear. Click on the port you want to connect to
   5. Press on the `Baud: 9600` button and select the baud rate of the serial connection
   6. Finally, click on the `Connect` button to initiate the connection with the Arduino

2. To plot real-time data received from the Arduino:
   1. Make sure that the data consists of numbers being separated by a comma
   2. For example the message `12,25,16` could be sent using Arduino code:
      ```cpp
      Serial.print(dataPoint1);
      Serial.print(",");
      Serial.print(dataPoint2);
      Serial.print(",");
      Serial.println(dataPoint3);
      ```
   3. Important: the last print command must use `Serial.println()` which sends the special "end of line" character, while the other commands should be `Serial.print()`.
   4. Go to the "Live Graph" tab of the program. The data should automatically be plotted on the graph.
   5. To plot different signals on separate graphs, click on the number of graphs (1 to 4) in the "Split" section of the right-hand sidebar.
   6. You can then press the up or down buttons on each signal in the sidebar to move it to a different graph.
   7. To change options (such as graph type, x-axis and y-axis scaling) for a specific graph, click on the graph you want to edit. The options for that graph are then shown in the sidebar.

### NEW: Using the Endoscopy Data Logger

1. **Access the Endoscopy Logger**:
   - Click on the "Endoscopy Logger" tab
   - Login with user credentials (user/user123 or admin/admin123)
   - Guest users have read-only access

2. **Configure File Naming**:
   - Click on each field in the sidebar to edit:
     - Experiment Type (e.g., CR)
     - Model Type (e.g., B1)
     - Year (e.g., Y1)
     - Experience (e.g., E01)
     - Subject (e.g., S1)
     - Trial (e.g., T1)
   - The filename preview updates automatically
   - Select output folder if needed

3. **Start Data Logging**:
   - Ensure Arduino is connected (auto-detection available)
   - Click "Start Logging" to begin data collection
   - Data is saved with timestamps in real-time
   - Click "Stop Logging" when finished

4. **Data Format**:
   The logged CSV files contain:
   ```csv
   timestamp,data
   2024-01-15 14:30:25.123,sensor1,sensor2,sensor3
   2024-01-15 14:30:25.456,value1,value2,value3
   ```

### Accessibility Features

1. **Virtual Keyboard**:
   - Press `Ctrl+F2` or `K` to show virtual keyboard
   - Click keys or use mouse for input
   - Supports modifier keys (Ctrl, Alt, Shift)

2. **Key Mapping**:
   - Keys 1-8: Toggle channels 1-8
   - R: Record, P: Pause, C: Clear
   - O: Open, V: Save, Z: Zoom
   - H: Toggle key hints
   - M: Toggle key mapping
   - Press `Ctrl+Alt+A` for accessibility menu

3. **High Contrast Mode**:
   - Press `Ctrl+F3` to toggle high contrast
   - Enhanced visibility for better accessibility

## User Management

### Default Users
- **Admin**: `admin` / `admin123`
  - Full system access
  - User management capabilities
  - All data logging features

- **User**: `user` / `user123`
  - Standard data logging access
  - File save/load capabilities
  - Settings modification

- **Guest**: No login required
  - Read-only access
  - View data and graphs
  - Limited functionality

### Admin Features
- Add/remove users
- Change user passwords
- Toggle user status (active/inactive)
- Reset user passwords
- View user activity logs

## Security Features
- **Password Hashing**: SHA-256 encryption for all passwords
- **Session Management**: Automatic timeout after 30 minutes of inactivity
- **Role-based Access**: Different permissions for admin/user/guest roles
- **Activity Tracking**: User activity monitoring for security

## Troubleshooting

### Arduino Not Detected
- Ensure Arduino is connected via USB
- Check if drivers are installed
- Try different USB ports
- Manually select COM port if auto-detection fails

### Permission Errors
- Run as administrator on Windows
- Check folder write permissions
- Ensure antivirus isn't blocking the application

### Serial Connection Issues
- Verify baud rate (default: 9600)
- Close other applications using the serial port
- Reset Arduino and try again

### Login Issues
- Use default credentials: admin/admin123 or user/user123
- Check caps lock status
- Contact administrator for password reset

A full set of instructions and documentation can be found on my website at: [https://wired.chillibasket.com/processing-grapher/](https://wired.chillibasket.com/processing-grapher/)

![](/Images/SerialMonitor_tab.jpg) 
*Serial monitor tab, showing the communication with an Arduino*

![](/Images/FileGraph_tab.jpg)
*File graph tab, showing how information from a CSV file can be plotted on a graph*

## Changelog

1. (Latest) Version 1.8.0 [Development]
   1. **NEW**: Added Endoscopy Data Logger tab with specialized medical/research data logging
   2. **NEW**: Implemented comprehensive user authentication system with admin/user/guest roles
   3. **NEW**: Added automated file naming system following standardized nomenclature
   4. **NEW**: Implemented accessibility features including virtual keyboard and key mapping
   5. **NEW**: Added channel management system for equal access via keyboard and mouse
   6. **NEW**: Enhanced security with password hashing and session management
   7. **NEW**: Added user management interface for administrators
   8. **Enhancement**: Improved serial port auto-detection for Arduino devices
   9. **Enhancement**: Added real-time data logging with millisecond precision timestamps
   10. **Enhancement**: Implemented comprehensive error handling and recovery systems

2. (28th April 2024) Version 1.7.0 [Release]
   1. ([#44](https://github.com/chillibasket/processing-grapher/issues/44)) Fixed issue where X-axis data was not being plotted correctly.
   2. ([#43](https://github.com/chillibasket/processing-grapher/issues/43)) Implemented settings option allowing the serial data separator character to be changed.
   3. ([#42](https://github.com/chillibasket/processing-grapher/issues/42)) Added extended baud rate selection menu to cover all possible baud rate options.
   4. Other minor bug fixes and user experience improvements.

3. (4th February 2024) Version 1.6.0 [Release]
   1. ([#36](https://github.com/chillibasket/processing-grapher/issues/36)) Added new buttons to the bottom info bar to quickly connect/disconnect and change the settings of the serial port.
   2. ([#38](https://github.com/chillibasket/processing-grapher/issues/38)) Fixed issue with saving CSV files when the file row count was exceeded.
   3. ([#29](https://github.com/chillibasket/processing-grapher/issues/29)) Fixed graph bug which was introduced when implementing custom x-axis display.
   4. Implemented additional keyboard shortcuts: `CTRL-TAB` to change tab, `CTRL-S` to save file or set output file, `CTRL-Q` to connect/disconnect serial port, `CTRL-R` to start/stop data recording, `CTRL-O` to open a file, `CTRL-M` to send a serial message from any tab.
   5. Fixed some minor bugs and implemented minor improvements to the user experience (UX).

[Previous changelog entries continue...]

## License

This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## Support

If you encounter any issues or have questions:
1. Check the troubleshooting section above
2. Search existing issues on GitHub
3. Create a new issue with detailed information about your problem
4. Visit the project website for additional documentation