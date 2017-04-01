
# coding: utf-8

# In[1]:

import os
import re


# In[2]:

# reads lines from a text file given by filename
def readlines(filename):
    file = open(filename, "r")
    return file.readlines()


# In[3]:

def parse_generation_line(line):
    regex = r"(\d+) generations"
    match = re.search(regex, line)
    return match.group(1)


# In[4]:

def parse_duration_line(line):
    regex = r"(\d+\.\d+) seconds"
    match = re.search(regex, line)
    return match.group(1)


# In[5]:

# log files have 2 intro lines, followed by
# a generation count, and duration line

lines_per_test = 30 * 2

def process_test_log(lines, csv_file):
    # Retain runs details
    csv_file.write(lines[0])
    csv_file.write(lines[1])
    lines = lines[2:]

    # write CSV headings
    csv_file.write("generation,duration\n")

    for i in range(0, lines_per_test, 2):
        # generation = parse_generation_line(lines[i])
        duration = parse_duration_line(lines[i+1])
        # print('{}, {}'.format(generation, duration))
        # csv_file.write('{}, {}\n'.format(generation, duration))
        csv_file.write('{}\n'.format(duration))

    # return unprocessed lines
    return lines[lines_per_test:]


# In[6]:

def create_csv_file(logfile):
    prefix, suffix = logfile.split(".")
    # print('prefix: {}\nsuffix: {}'.format(prefix, suffix))    
    
    csv_filename = prefix + ".csv"
    csvfile = open(csv_filename, "w")
    lines = readlines(logfile)

    while (len(lines) > 0):
        lines = process_test_log(lines, csvfile)

    csvfile.close()


# In[7]:

for file in os.listdir("./"):
    if file.endswith(".log"):
        create_csv_file(file)

