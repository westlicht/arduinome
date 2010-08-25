
class Clock
  
  attr_reader :ticks
  
  def initialize(input)
    @listeners = []
    @input = input
    @input.add_listener(self)
    reset()
  end
  
  def reset
    @ticks = 0
  end
  
  def tick
    @ticks += 1
    @listeners.each { |listener| listener.clock_update(ticks) }
  end
  
  # Adds a clock listener to the clock. The listener class should define a
  # clock_update(ticks) method.
	def add_listener(listener)
	  @listeners << listener
  end

  # Deletes a clock listener from the clock.
  def delete_listener(listener)
    @listeners.delete(listener)
  end
	
  def midi_input(packet)
    if packet.kind_of? MidiEventClock then
      if packet[:typ] == :start then
        reset()
      elsif packet[:typ] == :clock then
        tick()
      end
    end
  end
  
end
