require 'serialport' 
require 'time'

class GSM 
	SMSC = "+5212223816259" 
	# SMSC for Vodafone UK - change for other networks
	def initialize(options = {})
		puts options
	    puts "Conection to port #{options[:port]}"
		@port = SerialPort.new(options[:port] || 3, 9600, 8,  1, SerialPort::NONE)
		disconect = @port.write('AT+CMEE=5')
		puts "Iniciando conexión #{disconect}"
		status = @port.write('AT+CREG=?')
		puts "Status #{status}"
		conection = @port.write('AT')
		fact = @port.write('AT+GMI')
		conf = @port.write('AT&V')
		firmware = @port.write('AT+GMR')
		inform = @port.write('AT+CGMI')
		puts "Verificar conxion  #{conection}"
		puts "Información el fabricante #{fact}"
		puts "Configuracion actual #{conf}"
		puts "Firmware del dispositivo #{firmware}"
		puts "INform: #{inform}"
		@debug = options[:debug] 
		puts @debug
		cmd("AT") 
		# Set to text mode 
		cmd("AT+CMGF=1") 
		# Set SMSC number 
		cmd("AT+CSCA=\"#{SMSC}\"") 
	end 

    def close 
		@port.close 
    end 

   def cmd(cmd)
    px = @port.write(cmd)
    puts px
    wait 
   end 

   def wait 
   	  buffer = '' 
   	  while IO.select([@port], [], [], 0.25) 
   	  chr = @port.getc.chr; 
   	  chr if @debug == true 
   	  buffer += chr 
   	  end 
   	  buffer 
   end 

   def send_sms(options) 
   	  puts "opcciones del mensaje #{options}"
   	  cmd("AT+CMGS=\"#{options[:number]}\"") 
   	  cmd("#{options[:message][0..140]}#{26.chr}\r\r") 
   	  sleep 1
   	  wait 
   	  cmd("AT") 
   end 

   class SMS 
     attr_accessor :id, :sender, :message, :connection 
     attr_writer :time 

     def initialize(params) 
     	puts params
        @id = params[:id]; 
        @sender = params[:sender]; 
        @time = params[:time]; 
        @message = params[:message]; 
        @connection = params[:connection] 
     end 

     def delete
      @connection.cmd("AT+CMGD=#{@id}") 
     end 

     def time 
       # This MAY need to be changed for non-UK situations, I'm not sure # how standardized SMS timestamps are.. 
       Time.parse(@time.sub(/(\d+)\D+(\d+)\D+(\d+)/, '\2/\3/20\1')) 
     end 
  end 

  def messages 
  	  sms = cmd("AT+CMGL=\"ALL\"") 
  	  puts "SMS #{sms}"
  # Ugly, ugly, ugly! 
  	  if !sms.nil?
	 	msgs = sms.scan(/\+CMGL\:\s*?(\d+)\,.*?\,\"(.+?)\"\,.*?\,\"(.+?)\".*?\n(.*)/) 
	  else
	  	msgs = nil
	  end

	  puts "............#{msgs}"

	  return nil unless msgs 

	  msgs.collect!{ |m| GSM::SMS.new(:connection => self, :id => m[0], :sender => m[1], :time => m[2], :message => m[3].chomp) } rescue nil end 

  end 
  destination_number = "+5215537705731" 
  ports = ['/dev/tty.usbmodem142101', '/dev/tty.usbmodem142103', '/dev/tty.usbmodem142105', '/dev/tty.usbmodem142107', '/dev/tty.usbmodem142201', '/dev/tty.usbmodem142203', '/dev/tty.usbmodem142205', '/dev/tty.usbmodem142207']
  ports.each do |port|
  	 puts "------------ access to #{port} -------------------------------------\n"
	  p = GSM.new(:debug => false, :port => port) 
	  # Send a text message 
	  p.send_sms(:number => destination_number, :message => "Test at #{Time.now}") 
	  # Read text messages from phone 
	  if !p.messages.nil?
	  	puts "Hay mensajes"
	  	puts p
	  	puts "#{p.messages}"
	    p.messages.each do |msg| 
	    	puts "#{msg.id} - #{msg.time} - #{msg.sender} - #{msg.message}" 
	    end
	  else
	  	puts "cant not sent ---- > not messages"
	  end
	 puts "\n\n"
	  # msg.delete 
end