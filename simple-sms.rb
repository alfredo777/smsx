require 'serialport' 
require 'time'

def sendSMS(fromnumber, tonumber, msg, serialport)
   #sp = SerialPort.new(serialport, 9600)
   sp = SerialPort.new "/dev/tty.usbmodem142101"
   sp.write "AT\r"
   puts sp
   puts("%c", sp.getc)
   while true do
	 puts("%c", sp.getc)
	 sp.close
   while false
   	 puts "False"
   	 sp.close
   end

   end
end

ports = ['/dev/tty.usbmodem142101', '/dev/tty.usbmodem142103', '/dev/tty.usbmodem142105', '/dev/tty.usbmodem142107', '/dev/tty.usbmodem142201', '/dev/tty.usbmodem142203', '/dev/tty.usbmodem142205', '/dev/tty.usbmodem142207']


fromnumber = '+5212223816259'
tonumber   = '+5215537705731'
msg = "Hola mundo"
serialport = ports[0]

sendSMS(fromnumber, tonumber, msg, serialport)
