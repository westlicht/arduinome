require 'monome'
require 'page'
require 'midi'
require 'clock'

class Test
  
  def initialize
    @input = Midi.create_input("Bus 1")
    
    @monome = Monome.new
    @monome.add_listener(self)
    @monome.clear
    
    @clock = Clock.new(@input)
        
    @page_manager = PageManager.new(@monome, @clock)
  end
  
  def run
    @input.start

    while (1)
      sleep(1)
    end
  end
  
  def press(x, y, state)
    #@monome.led(x, y, state)
  end
  
end




def main
  
  Thread.abort_on_exception = true

  t = Test.new
  t.run

end



main()
