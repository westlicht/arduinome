require 'page'

class PageDraw < Page
  
  def initialize(manager)
    super(manager)

    @led_states = Array.new(8 * 7)
  end
  
  def activate
    super
    
    (0..6).each do |y|
      (0..7).each do |x|
        @manager.monome.led(x, y, led_state(x, y))
      end
    end
  end
  
  def deactivate
    super
  end
  
  def press(x, y, state)
    return if y == 7
    if state then
      set_led_state(x, y, led_state(x, y) ? false : true)
      @manager.monome.led(x, y, led_state(x, y))
    end
  end
    
  def led_state(x, y)
    @led_states[y * 8 + x]
  end

  def set_led_state(x, y, value)
    @led_states[y * 8 + x] = value
  end
  
end
