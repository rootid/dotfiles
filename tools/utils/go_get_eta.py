#!/usr/bin/env python3

from datetime import date, timedelta

def total_date_diff(start_date, end_date):
    if start_date > end_date:
        start_date, end_date = end_date, start_date

    total_days = (end_date - start_date).days + 1  # +1 to include both start and end dates
    return total_days

def weekday_difference(start_date, end_date):
    total_days = total_date_diff(start_date, end_date)
    full_weeks = total_days // 7
    remaining_days = total_days % 7
    weekdays = 0
    for i in range(remaining_days):
        current_day = (start_date + timedelta(days=full_weeks * 7 + i)).weekday()
        if current_day < 5:  # Monday - Friday (0-4)
            weekdays += 1

    return full_weeks * 5 + weekdays

print(f" WeekDays Left =  {weekday_difference(date(2025, 3, 1), date.today())}")
print(f" Total Days Left =  {total_date_diff(date(2025, 3, 1), date.today())}")
