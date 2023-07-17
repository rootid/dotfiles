#!/usr/bin/env python3

import datetime

# Get the current date
current_date = datetime.date.today()

# Get the week number
week_number = current_date.isocalendar()[1]

# Print the week number
print(f"week number is {week_number} and data is {current_date}")
