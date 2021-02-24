#!/usr/bin/python3
import os
import sys
from struct import *
#print("Start processing")

# The input binary file has a sequense of numbers stored in big endian
# format:
#   timestamp: 4 bytes unsigned integer big endian
#   x: 2 bytes signed integer 
#   y: 2 bytes signed integer
#   z: 2 bytes signed integer
#Total number of byters per record is 8+2+2+2 = 10

#get number of rows in file
numOfBytesPerRecord = 10
file = open(sys.argv[1], "rb")
numrows = os.path.getsize(sys.argv[1]) / numOfBytesPerRecord 
#print("num of rows is:")
#print(numrows)
firstVal = 0;
# format >Q h h h or 8s 2s 2s 2s
for i in range(0, int(numrows)):
    val = unpack('>Ihhh', file.read(numOfBytesPerRecord))
    print(val)
    #print('\n')
    if i == 0:
        firstVal = val

#print(firstVal)

file.close()
    
