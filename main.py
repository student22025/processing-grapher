import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import os
import serial
import serial.tools.list_ports
import time
import threading
import hashlib
import json
from datetime import datetime

class UserManager:
    def __init__(self):
        self.users_file = "users.json"
        self.current_user = None
        self.current_role = None
        self.load_users()
    
    def load_users(self):
        """Load users from file or create default users"""
        try:
            if os.path.exists(self.users_file):
                with open(self.users_file, 'r') as f:
                    self.users = json.load(f)
            else:
                # Create default users
                self.users = {
                    "admin": {
                        "password": self.hash_password("admin123"),
                        "role": "admin"
                    },
                    "user": {
                        "password": self.hash_password("user123"),
                        "role": "user"
                    }
                }
                self.save_users()
        except Exception as e:
            print(f"Error loading users: {e}")
            self.users = {}
    
    def save_users(self):
        """Save users to file"""
        try:
            with open(self.users_file, 'w') as f:
                json.dump(self.users, f, indent=2)
        except Exception as e:
            print(f"Error saving users: {e}")
    
    def hash_password(self, password):
        """Hash password using SHA-256"""
        return hashlib.sha256(password.encode()).hexdigest()
    
    def authenticate(self, username, password):
        """Authenticate user"""
        if username in self.users:
            hashed_password = self.hash_password(password)
            if self.users[username]["password"] == hashed_password:
                self.current_user = username
                self.current_role = self.users[username]["role"]
                return True
        return False
    
    def is_admin(self):
        """Check if current user is admin"""
        return self.current_role == "admin"
    
    def logout(self):
        """Logout current user"""
        self.current_user = None
        self.current_role = None

class LoginWindow:
    def __init__(self, user_manager, on_success_callback):
        self.user_manager = user_manager
        self.on_success_callback = on_success_callback
        self.window = tk.Tk()
        self.window.title("Endoscopy Data Logger - Login")
        self.window.geometry("400x300")
        self.window.resizable(False, False)
        
        # Center the window
        self.center_window()
        
        self.create_widgets()
    
    def center_window(self):
        """Center the window on screen"""
        self.window.update_idletasks()
        x = (self.window.winfo_screenwidth() // 2) - (400 // 2)
        y = (self.window.winfo_screenheight() // 2) - (300 // 2)
        self.window.geometry(f"400x300+{x}+{y}")
    
    def create_widgets(self):
        """Create login interface widgets"""
        # Main frame
        main_frame = ttk.Frame(self.window, padding="20")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Title
        title_label = ttk.Label(main_frame, text="Endoscopy Data Logger", 
                               font=("Arial", 16, "bold"))
        title_label.grid(row=0, column=0, columnspan=2, pady=(0, 20))
        
        # Username
        ttk.Label(main_frame, text="Username:").grid(row=1, column=0, sticky=tk.W, pady=5)
        self.username_var = tk.StringVar()
        self.username_entry = ttk.Entry(main_frame, textvariable=self.username_var, width=25)
        self.username_entry.grid(row=1, column=1, pady=5, padx=(10, 0))
        
        # Password
        ttk.Label(main_frame, text="Password:").grid(row=2, column=0, sticky=tk.W, pady=5)
        self.password_var = tk.StringVar()
        self.password_entry = ttk.Entry(main_frame, textvariable=self.password_var, 
                                       show="*", width=25)
        self.password_entry.grid(row=2, column=1, pady=5, padx=(10, 0))
        
        # Login button
        login_btn = ttk.Button(main_frame, text="Login", command=self.login)
        login_btn.grid(row=3, column=0, columnspan=2, pady=20)
        
        # Default credentials info
        info_frame = ttk.LabelFrame(main_frame, text="Default Credentials", padding="10")
        info_frame.grid(row=4, column=0, columnspan=2, pady=10, sticky=(tk.W, tk.E))
        
        ttk.Label(info_frame, text="Admin: admin / admin123").grid(row=0, column=0, sticky=tk.W)
        ttk.Label(info_frame, text="User: user / user123").grid(row=1, column=0, sticky=tk.W)
        
        # Bind Enter key to login
        self.window.bind('<Return>', lambda e: self.login())
        
        # Focus on username entry
        self.username_entry.focus()
    
    def login(self):
        """Handle login attempt"""
        username = self.username_var.get().strip()
        password = self.password_var.get().strip()
        
        if not username or not password:
            messagebox.showerror("Error", "Please enter both username and password")
            return
        
        if self.user_manager.authenticate(username, password):
            messagebox.showinfo("Success", f"Welcome, {username}!")
            self.window.destroy()
            self.on_success_callback()
        else:
            messagebox.showerror("Error", "Invalid username or password")
            self.password_var.set("")
            self.password_entry.focus()
    
    def run(self):
        """Run the login window"""
        self.window.mainloop()

class FileNamingGUI:
    def __init__(self, user_manager):
        self.user_manager = user_manager
        self.window = tk.Tk()
        self.window.title("Endoscopy Data Logger - File Setup")
        self.window.geometry("600x500")
        self.window.resizable(False, False)
        
        # Center the window
        self.center_window()
        
        # Variables
        self.experiment_type_var = tk.StringVar(value="CR")
        self.model_type_var = tk.StringVar(value="B1")
        self.year_var = tk.StringVar(value="Y1")
        self.experience_var = tk.StringVar(value="E01")
        self.subject_var = tk.StringVar(value="S1")
        self.trial_var = tk.StringVar(value="T1")
        self.output_folder_var = tk.StringVar(value="Endo_Data")
        self.filename_var = tk.StringVar()
        self.full_path_var = tk.StringVar()
        
        # Serial connection variables
        self.serial_port = None
        self.is_logging = False
        self.log_thread = None
        
        self.create_widgets()
        self.update_filename()
    
    def center_window(self):
        """Center the window on screen"""
        self.window.update_idletasks()
        x = (self.window.winfo_screenwidth() // 2) - (600 // 2)
        y = (self.window.winfo_screenheight() // 2) - (500 // 2)
        self.window.geometry(f"600x500+{x}+{y}")
    
    def create_widgets(self):
        """Create the main interface widgets"""
        # Main frame
        main_frame = ttk.Frame(self.window, padding="20")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # User info
        user_frame = ttk.LabelFrame(main_frame, text="Current User", padding="10")
        user_frame.grid(row=0, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 20))
        
        user_info = f"Logged in as: {self.user_manager.current_user} ({self.user_manager.current_role})"
        ttk.Label(user_frame, text=user_info).grid(row=0, column=0, sticky=tk.W)
        
        logout_btn = ttk.Button(user_frame, text="Logout", command=self.logout)
        logout_btn.grid(row=0, column=1, sticky=tk.E)
        
        user_frame.columnconfigure(0, weight=1)
        
        # File naming section
        naming_frame = ttk.LabelFrame(main_frame, text="File Naming Configuration", padding="10")
        naming_frame.grid(row=1, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 20))
        
        # Create entry fields
        fields = [
            ("Experiment Type:", self.experiment_type_var, "e.g., CR"),
            ("Model Type:", self.model_type_var, "e.g., B1"),
            ("Year:", self.year_var, "e.g., Y1"),
            ("Experience:", self.experience_var, "e.g., E01"),
            ("Subject:", self.subject_var, "e.g., S1"),
            ("Trial:", self.trial_var, "e.g., T1")
        ]
        
        for i, (label, var, placeholder) in enumerate(fields):
            ttk.Label(naming_frame, text=label).grid(row=i, column=0, sticky=tk.W, pady=2)
            entry = ttk.Entry(naming_frame, textvariable=var, width=15)
            entry.grid(row=i, column=1, pady=2, padx=(10, 5))
            entry.bind('<KeyRelease>', lambda e: self.update_filename())
            
            ttk.Label(naming_frame, text=placeholder, foreground="gray").grid(
                row=i, column=2, sticky=tk.W, padx=(5, 0))
        
        # Output folder selection
        folder_frame = ttk.Frame(naming_frame)
        folder_frame.grid(row=len(fields), column=0, columnspan=3, sticky=(tk.W, tk.E), pady=(10, 0))
        
        ttk.Label(folder_frame, text="Output Folder:").grid(row=0, column=0, sticky=tk.W)
        folder_entry = ttk.Entry(folder_frame, textvariable=self.output_folder_var, width=30)
        folder_entry.grid(row=0, column=1, padx=(10, 5))
        folder_entry.bind('<KeyRelease>', lambda e: self.update_filename())
        
        browse_btn = ttk.Button(folder_frame, text="Browse", command=self.browse_folder)
        browse_btn.grid(row=0, column=2)
        
        # Preview section
        preview_frame = ttk.LabelFrame(main_frame, text="File Preview", padding="10")
        preview_frame.grid(row=2, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 20))
        
        ttk.Label(preview_frame, text="Filename:").grid(row=0, column=0, sticky=tk.W)
        filename_label = ttk.Label(preview_frame, textvariable=self.filename_var, 
                                  font=("Courier", 10), foreground="blue")
        filename_label.grid(row=0, column=1, sticky=tk.W, padx=(10, 0))
        
        ttk.Label(preview_frame, text="Full Path:").grid(row=1, column=0, sticky=tk.W, pady=(5, 0))
        path_label = ttk.Label(preview_frame, textvariable=self.full_path_var, 
                              font=("Courier", 9), foreground="green")
        path_label.grid(row=1, column=1, sticky=tk.W, padx=(10, 0), pady=(5, 0))
        
        # Serial connection section
        serial_frame = ttk.LabelFrame(main_frame, text="Serial Connection", padding="10")
        serial_frame.grid(row=3, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 20))
        
        # Port detection
        self.port_var = tk.StringVar()
        ttk.Label(serial_frame, text="Arduino Port:").grid(row=0, column=0, sticky=tk.W)
        self.port_label = ttk.Label(serial_frame, textvariable=self.port_var, foreground="blue")
        self.port_label.grid(row=0, column=1, sticky=tk.W, padx=(10, 0))
        
        detect_btn = ttk.Button(serial_frame, text="Detect Arduino", command=self.detect_arduino)
        detect_btn.grid(row=0, column=2, padx=(10, 0))
        
        # Control buttons
        control_frame = ttk.Frame(main_frame)
        control_frame.grid(row=4, column=0, columnspan=2, pady=20)
        
        self.start_btn = ttk.Button(control_frame, text="Start Logging", 
                                   command=self.start_logging, state="disabled")
        self.start_btn.grid(row=0, column=0, padx=(0, 10))
        
        self.stop_btn = ttk.Button(control_frame, text="Stop Logging", 
                                  command=self.stop_logging, state="disabled")
        self.stop_btn.grid(row=0, column=1, padx=(0, 10))
        
        # Status
        self.status_var = tk.StringVar(value="Ready - Please detect Arduino and start logging")
        status_label = ttk.Label(main_frame, textvariable=self.status_var, foreground="blue")
        status_label.grid(row=5, column=0, columnspan=2, pady=(10, 0))
        
        # Configure column weights
        main_frame.columnconfigure(0, weight=1)
        naming_frame.columnconfigure(2, weight=1)
        folder_frame.columnconfigure(1, weight=1)
        preview_frame.columnconfigure(1, weight=1)
        serial_frame.columnconfigure(1, weight=1)
        
        # Auto-detect Arduino on startup
        self.window.after(1000, self.detect_arduino)
    
    def update_filename(self):
        """Update the filename preview"""
        filename = self.generate_filename()
        self.filename_var.set(filename)
        
        folder = self.output_folder_var.get()
        full_path = os.path.join(folder, filename)
        self.full_path_var.set(full_path)
    
    def generate_filename(self):
        """Generate filename based on current inputs"""
        parts = [
            self.experiment_type_var.get(),
            self.model_type_var.get(),
            self.year_var.get(),
            self.experience_var.get(),
            self.subject_var.get(),
            self.trial_var.get()
        ]
        return "".join(parts) + ".csv"
    
    def browse_folder(self):
        """Browse for output folder"""
        folder = filedialog.askdirectory(initialdir=self.output_folder_var.get())
        if folder:
            self.output_folder_var.set(folder)
            self.update_filename()
    
    def detect_arduino(self):
        """Auto-detect Arduino port"""
        try:
            ports = serial.tools.list_ports.comports()
            arduino_port = None
            
            for port in ports:
                if any(keyword in port.description.upper() for keyword in 
                      ['ARDUINO', 'CH340', 'USB SERIAL', 'FTDI']):
                    arduino_port = port.device
                    break
            
            if not arduino_port and ports:
                arduino_port = ports[0].device
            
            if arduino_port:
                self.port_var.set(f"Detected: {arduino_port}")
                self.arduino_port = arduino_port
                self.start_btn.config(state="normal")
                self.status_var.set("Arduino detected - Ready to start logging")
            else:
                self.port_var.set("No Arduino found")
                self.start_btn.config(state="disabled")
                self.status_var.set("No Arduino detected - Please connect Arduino and try again")
        except Exception as e:
            self.port_var.set(f"Error: {str(e)}")
            self.start_btn.config(state="disabled")
    
    def start_logging(self):
        """Start data logging"""
        if self.is_logging:
            return
        
        # Create output folder if it doesn't exist
        folder = self.output_folder_var.get()
        if not os.path.exists(folder):
            try:
                os.makedirs(folder)
            except Exception as e:
                messagebox.showerror("Error", f"Failed to create folder: {e}")
                return
        
        # Check if file already exists
        full_path = self.full_path_var.get()
        if os.path.exists(full_path):
            if not messagebox.askyesno("File Exists", 
                                     f"File {full_path} already exists. Overwrite?"):
                return
        
        # Start logging in separate thread
        self.is_logging = True
        self.log_thread = threading.Thread(target=self.log_data, daemon=True)
        self.log_thread.start()
        
        # Update UI
        self.start_btn.config(state="disabled")
        self.stop_btn.config(state="normal")
        self.status_var.set("Logging data... Press 'Stop Logging' to stop")
    
    def stop_logging(self):
        """Stop data logging"""
        self.is_logging = False
        
        # Update UI
        self.start_btn.config(state="normal")
        self.stop_btn.config(state="disabled")
        self.status_var.set("Logging stopped")
    
    def log_data(self):
        """Log data from Arduino (runs in separate thread)"""
        try:
            # Open serial connection
            ser = serial.Serial(self.arduino_port, 9600, timeout=1)
            time.sleep(2)  # Wait for Arduino to reset
            
            # Open output file
            with open(self.full_path_var.get(), 'w') as f:
                f.write("timestamp,data\n")  # CSV header
                
                while self.is_logging:
                    try:
                        line = ser.readline().decode('utf-8').strip()
                        if line:
                            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]
                            timestamped_line = f"{timestamp},{line}"
                            f.write(timestamped_line + '\n')
                            f.flush()  # Ensure data is written immediately
                            
                            # Update status on main thread
                            self.window.after(0, lambda: self.status_var.set(
                                f"Logging: {line[:50]}..." if len(line) > 50 else f"Logging: {line}"))
                    except Exception as e:
                        print(f"Error reading data: {e}")
                        break
            
            ser.close()
            
        except Exception as e:
            self.window.after(0, lambda: messagebox.showerror("Error", f"Serial connection failed: {e}"))
            self.window.after(0, self.stop_logging)
    
    def logout(self):
        """Logout and return to login screen"""
        if self.is_logging:
            if messagebox.askyesno("Confirm Logout", 
                                 "Data logging is active. Stop logging and logout?"):
                self.stop_logging()
                time.sleep(1)  # Give time for logging to stop
            else:
                return
        
        self.user_manager.logout()
        self.window.destroy()
        
        # Show login window again
        login_window = LoginWindow(self.user_manager, self.show_main_window)
        login_window.run()
    
    def show_main_window(self):
        """Show main window after successful login"""
        self.__init__(self.user_manager)
        self.run()
    
    def on_closing(self):
        """Handle window closing"""
        if self.is_logging:
            if messagebox.askyesno("Confirm Exit", 
                                 "Data logging is active. Stop logging and exit?"):
                self.stop_logging()
                time.sleep(1)  # Give time for logging to stop
                self.window.destroy()
        else:
            self.window.destroy()
    
    def run(self):
        """Run the main application"""
        self.window.protocol("WM_DELETE_WINDOW", self.on_closing)
        self.window.mainloop()

def main():
    """Main application entry point"""
    # Initialize user manager
    user_manager = UserManager()
    
    def start_main_app():
        """Start the main application after successful login"""
        app = FileNamingGUI(user_manager)
        app.run()
    
    # Show login window first
    login_window = LoginWindow(user_manager, start_main_app)
    login_window.run()

if __name__ == "__main__":
    main()