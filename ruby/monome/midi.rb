require 'coremidi'

class MidiEventClock < Struct.new(:typ); end
class MidiEventUnknown; end


class MidiInput
  
  include CoreMIDI
  
  def initialize(source)
    @listeners = []
    @client = CoreMIDI.create_client("client")
    @port = CoreMIDI.create_input_port(@client, "port")
    connect_source_to_port(source, @port)
  end
  
  def start
    Thread.new do
      while true
        if packets = new_data?
          packets.each { |packet| midi_input(parse(packet)) }
        end
        sleep(0.01)
      end
    end
  end
  
	# Adds an input listener to the input device. The listener class should
	# define a midi_input(packet) method.
	def add_listener(listener)
	  @listeners << listener
  end

  # Deletes an input listener from the input device.
  def delete_listener(listener)
    @listeners.delete(listener)
  end
	
	private

  def parse(packet)
    case packet.data[0]
    when 144..146
      Note.new(:on, packet.data[1], packet.data[2])
    when 130
      Note.new(:off, packet.data[1], packet.data[2])
    when 176
      Controller.new(packet.data[1], packet.data[2])
    when 0xf8
      MidiEventClock.new(:clock)
    when 0xfa
      MidiEventClock.new(:start)
    when 0xfb
      MidiEventClock.new(:continue)
    when 0xfc
      MidiEventClock.new(:stop)
    else
      MidiEventUnknown.new
    end
  end
  
  def midi_input(packet)
	  @listeners.each { |listener| listener.midi_input(packet) }
  end
  
end

class Midi
      
  def self.sources
    CoreMIDI.sources
  end
  
  def self.create_input(source)
    i = self.sources.index(source)
    MidiInput.new(i)
  end
    
end
