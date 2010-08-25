
class DrumNote

  attr :trigger
  
  def initialize()
    @trigger = false
  end
  
  def switch()
    @trigger = !@trigger
  end
  
end



class DrumLine

  attr_reader :length
  
  def initialize(length)
    @length = length
    @notes = Array.new(length) { DrumNote.new }
  end
  
  def [](index)
    @notes[index]
  end
  
end



class DrumSeq
  
  attr_reader :cols, :rows, :pos

  def initialize(cols, rows, clock)
    @cols = cols
    @rows = rows
    @clock = clock
    @divider = 4
    @pos = 0
    @lines = Array.new(rows) { DrumLine.new(cols) }
    
    @clock.add_listener(self)
  end
  
  def [](index)
    @lines[index]
  end
  
  def clock_update(ticks)
    @pos = (ticks / @divider) % @cols
    send_notes(@pos, true) if ticks % @divider == 0
    send_notes(@pos, false) if ticks % @divider == @divider - 1
  end
  
  private
  
  def send_notes(pos, on)
    (0..@rows - 1).each do |y|
      if self[y][pos].trigger then
        puts format("%d/%d = %s", pos, y, on ? "on" : "off")
      end
    end
  end
  
end