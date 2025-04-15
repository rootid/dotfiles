"""
prerequisite - brew install python-tk
Run like this
python3 go_timer_start
"""

import tkinter as tk
from tkinter import messagebox
import time

class TimerApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Timer Application")
        self.root.geometry("350x250")
        self.root.resizable(False, False)

        # Timer variables
        self.is_running = False
        self.start_time = 0
        self.elapsed_time = 0
        self.set_time = 0  # Time in seconds for countdown
        self.is_countdown = False

        # Create UI elements
        self.create_widgets()

        # Update timer display periodically
        self.update_timer()

    def create_widgets(self):
        # Timer display
        self.time_label = tk.Label(self.root, text="00:00:00", font=("Arial", 36))
        self.time_label.pack(pady=10)

        # Set timer frame
        set_timer_frame = tk.Frame(self.root)
        set_timer_frame.pack(pady=5)

        # Time input fields
        tk.Label(set_timer_frame, text="Hours:").grid(row=0, column=0)
        self.hours_entry = tk.Entry(set_timer_frame, width=3)
        self.hours_entry.grid(row=0, column=1)
        self.hours_entry.insert(0, "0")

        tk.Label(set_timer_frame, text="Minutes:").grid(row=0, column=2)
        self.minutes_entry = tk.Entry(set_timer_frame, width=3)
        self.minutes_entry.grid(row=0, column=3)
        self.minutes_entry.insert(0, "0")

        tk.Label(set_timer_frame, text="Seconds:").grid(row=0, column=4)
        self.seconds_entry = tk.Entry(set_timer_frame, width=3)
        self.seconds_entry.grid(row=0, column=5)
        self.seconds_entry.insert(0, "0")

        # Set timer button
        self.set_timer_button = tk.Button(set_timer_frame, text="Set Timer",
                                        command=self.set_timer)
        self.set_timer_button.grid(row=0, column=6, padx=5)

        # Button frame
        button_frame = tk.Frame(self.root)
        button_frame.pack(pady=10)

        # Start/Stop button
        self.start_stop_button = tk.Button(button_frame, text="Start", width=10,
                                         command=self.toggle_start_stop)
        self.start_stop_button.grid(row=0, column=0, padx=10)

        # Reset button
        self.reset_button = tk.Button(button_frame, text="Reset", width=10,
                                    command=self.reset_timer)
        self.reset_button.grid(row=0, column=1, padx=10)

        # Mode indicator
        self.mode_label = tk.Label(self.root, text="Mode: Stopwatch", font=("Arial", 10))
        self.mode_label.pack(pady=5)

    def set_timer(self):
        try:
            hours = int(self.hours_entry.get())
            minutes = int(self.minutes_entry.get())
            seconds = int(self.seconds_entry.get())

            if hours < 0 or minutes < 0 or seconds < 0:
                messagebox.showerror("Invalid Input", "Please enter positive values")
                return

            if minutes >= 60 or seconds >= 60:
                messagebox.showerror("Invalid Input", "Minutes and seconds must be less than 60")
                return

            # Convert to seconds
            self.set_time = hours * 3600 + minutes * 60 + seconds

            if self.set_time > 0:
                self.is_countdown = True
                self.mode_label.config(text="Mode: Countdown")
                self.elapsed_time = 0
                self.display_countdown_time()
            else:
                messagebox.showinfo("Info", "Timer set to zero, using stopwatch mode")
                self.is_countdown = False
                self.mode_label.config(text="Mode: Stopwatch")
                self.time_label.config(text="00:00:00")

        except ValueError:
            messagebox.showerror("Invalid Input", "Please enter valid numbers")

    def toggle_start_stop(self):
        if self.is_running:
            # Stop the timer
            self.is_running = False
            self.start_stop_button.config(text="Start")
            # Store elapsed time when stopping
            self.elapsed_time += time.time() - self.start_time
        else:
            # Start the timer
            self.is_running = True
            self.start_stop_button.config(text="Stop")
            # Record start time
            self.start_time = time.time()

    def reset_timer(self):
        # Reset timer variables
        self.is_running = False
        self.start_stop_button.config(text="Start")
        self.elapsed_time = 0

        if self.is_countdown and self.set_time > 0:
            self.display_countdown_time()
        else:
            self.time_label.config(text="00:00:00")

    def display_countdown_time(self):
        # Display the set time
        remaining = self.set_time
        hours = remaining // 3600
        minutes = (remaining % 3600) // 60
        seconds = remaining % 60
        time_str = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
        self.time_label.config(text=time_str)

    def update_timer(self):
        if self.is_running:
            if self.is_countdown:
                # Calculate remaining time for countdown
                elapsed = time.time() - self.start_time + self.elapsed_time
                remaining = max(0, self.set_time - elapsed)

                # Check if timer has finished
                if remaining <= 0:
                    self.is_running = False
                    self.start_stop_button.config(text="Start")
                    self.elapsed_time = 0
                    messagebox.showinfo("Timer", "Time's up!")
                    remaining = 0

                # Format time as HH:MM:SS
                hours = int(remaining // 3600)
                minutes = int((remaining % 3600) // 60)
                seconds = int(remaining % 60)
            else:
                # Calculate current elapsed time for stopwatch
                current_time = self.elapsed_time + (time.time() - self.start_time)

                # Format time as HH:MM:SS
                hours = int(current_time // 3600)
                minutes = int((current_time % 3600) // 60)
                seconds = int(current_time % 60)

            # Update display
            time_str = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
            self.time_label.config(text=time_str)

        # Schedule next update (every 100ms for smooth display)
        self.root.after(100, self.update_timer)

# Main application entry point
if __name__ == "__main__":
    root = tk.Tk()
    app = TimerApp(root)
    root.mainloop()
