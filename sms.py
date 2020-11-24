import time
import serial
import numpy as np

from serial import Serial

#python -m SimpleHTTPServer 3000

recipient = "+5215537705731"
sender    = "+5212223816259"
message   = "Hello sms jarda!"


ports = ['/dev/tty.usbmodem142101', '/dev/tty.usbmodem142103', '/dev/tty.usbmodem142105', '/dev/tty.usbmodem142107', '/dev/tty.usbmodem142201', '/dev/tty.usbmodem142203', '/dev/tty.usbmodem142205', '/dev/tty.usbmodem142207']

arr = np.array(ports)

for x in arr:
    print(x)
    phone = serial.Serial(x,  9600)

    try:
        time.sleep(0.5)
        print 'AT'
        status = phone.write(b'AT')
        print status
        time.sleep(0.5)
        print 'OPEN COMAND AT'
        phone.write(b'AT+CMGF=1\r')
        time.sleep(0.5)
        print 'SENDER NUMBER'
        phone.write(b'AT+CSCA="' + sender.encode() + b'"\r"')
        time.sleep(0.5)
        print 'TO SEND NUMBER'
        phone.write(b'AT+CMGS="' + recipient.encode() + b'"\r')
        time.sleep(0.5)
        print 'MESSAGE'
        phone.write(message.encode() + b"\r")
        time.sleep(0.5)
        phone.write(bytes([8]))
        time.sleep(0.5)
    finally:
        phone.close()