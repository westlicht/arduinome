require 'osc'

# Monome interface class.
# This class uses the OSC protocol to interface with a monome device.
class Monome
  
  # Monome device properties
  SETTINGS = {
    '40h' => { :width => 8,  :height => 8  },
    '64'  => { :width => 8,  :height => 8  },
    '128' => { :width => 16, :height => 16 },
    '256' => { :width => 16, :height => 16 } 
  }
  
  attr_reader :typ, :width, :height

  # Standard constructor
	def initialize(typ = '40h', host = 8080, listen = 8000, prefix = '/40h')
		@typ = typ
		@width = Monome::SETTINGS[typ][:width]
		@height = Monome::SETTINGS[typ][:height]
		@host = host
		@listen = listen
		@prefix = prefix
		@listeners = []

		# setup OSC client
		@client = OSC::UDPSocket.new
		
		# setup OSC server
		@server = OSC::UDPServer.new
		@server.bind('localhost', @listen)
		@server.add_method(@prefix + '/press', 'iii') do |msg|
			press(msg.args[0], msg.args[1], msg.args[2].zero? ? false : true)
		end
		Thread.new do
			@server.serve
		end
	end

  # Switches all leds off.
  def clear
    (0..@height - 1).each do |i|
      led_row(i, false)
    end
  end
	
	# Switches a single led on or off.
	def led(x, y, state)
		msg = OSC::Message.new(@prefix + '/led', 'iii', x, y, state ? 1 : 0)
		@client.send(msg, 0, 'localhost', @host)
	end
	
	# Switches a complete row on or off.
	def led_row(index, state)
		msg = OSC::Message.new(@prefix + '/led_row', 'ii', index, state ? 255 : 0)
		@client.send(msg, 0, 'localhost', @host)
  end
  
  # Switches a complete column on or off.
  def led_col(index, state)
		msg = OSC::Message.new(@prefix + '/led_col', 'ii', index, state ? 255 : 0)
		@client.send(msg, 0, 'localhost', @host)
  end
		
	# Adds a key listener to the monome device. The listener class should define
	# a press(x, y, state) method.
	def add_listener(listener)
	  @listeners << listener
  end

  # Deletes a key listener from the monome device.
  def delete_listener(listener)
    @listeners.delete(listener)
  end
	
	private
	
	# Called when a key is pressed/depressed
	def press(x, y, state)
	  @listeners.each { |listener| listener.press(x, y, state) }
	end

end

