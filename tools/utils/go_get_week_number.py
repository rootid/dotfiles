#!/usr/bin/env python3

import datetime

LOGGED_WEEK_NUMBER  = 27
# Get the current date
today  = datetime.date.today()

# Get the week number
week_number = today.isocalendar()[1]
month_name = today.strftime("%b").lower()
year = today.strftime("%y").lower()
# My week starts from Sunday
if (datetime.date.today().isoweekday() == 7) :
  week_number += 1

sprint_no = week_number - LOGGED_WEEK_NUMBER
# Print the week number
print(f"week number is {week_number} and data is {today}")
# mmm_week#_sprint#_year e.g. aug_32_5_23
# e.g. create planner  touch ~/plain_docs/planner/gtd/aug_32_5_23.org
# Update the
print(f"{month_name}_{week_number}_{sprint_no}_{year}")
