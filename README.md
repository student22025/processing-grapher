# Endoscopy Data Logger

A comprehensive GUI application for logging endoscopy data with user authentication and automated file naming.

## Features

### Authentication System
- **Admin Access**: Full system access with user management capabilities
- **User Access**: Standard data logging functionality
- **Default Credentials**:
  - Admin: `admin` / `admin123`
  - User: `user` / `user123`

### File Naming System
- **Automated Nomenclature**: Follows the pattern `ExperimentTypeModelTypeYearExperienceSubjectTrial.csv`
- **Example**: `CRB1Y1E01S1T1.csv`
- **Components**:
  - Experiment Type (e.g., CR)
  - Model Type (e.g., B1)
  - Year (e.g., Y1)
  - Experience (e.g., E01)
  - Subject (e.g., S1)
  - Trial (e.g., T1)

### Data Logging
- **Auto-detection**: Automatically detects Arduino/serial devices
- **Real-time Logging**: Timestamps all incoming data
- **CSV Format**: Saves data in comma-separated values format
- **Thread-safe**: Non-blocking data collection

## Installation

1. **Install Python 3.7+**
2. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

## Usage

1. **Run the Application**:
   ```bash
   python main.py
   ```

2. **Login**:
   - Use default credentials or create new users
   - Admin users can manage other users

3. **Configure File Naming**:
   - Fill in all required fields
   - Preview shows the generated filename
   - Select output folder

4. **Start Logging**:
   - Click "Detect Arduino" to find connected devices
   - Click "Start Logging" to begin data collection
   - Click "Stop Logging" to end session

## File Structure

```
endoscopy-data-logger/
├── main.py              # Main application
├── requirements.txt     # Python dependencies
├── users.json          # User database (auto-created)
└── Endo_Data/          # Default output folder
```

## Security Features

- **Password Hashing**: SHA-256 encryption for all passwords
- **Session Management**: Secure login/logout functionality
- **Role-based Access**: Different permissions for admin/user roles

## Data Format

The logged CSV files contain:
- **Timestamp**: Date and time with millisecond precision
- **Data**: Raw data from the Arduino/serial device

Example:
```csv
timestamp,data
2024-01-15 14:30:25.123,sensor1,sensor2,sensor3
2024-01-15 14:30:25.456,value1,value2,value3
```

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

## Development

### Adding New Users
Admins can add users through the interface, or manually edit `users.json`:

```json
{
  "username": {
    "password": "hashed_password",
    "role": "user"
  }
}
```

### Customizing File Naming
Modify the `generate_filename()` method in `FileNamingGUI` class to change the naming convention.

## License

This project is licensed under the GNU General Public License v3.0 - see the original ProcessingGrapher license for details.