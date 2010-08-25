require 'page'
require 'drumseq'

class PageDrumSeq < Page
  
  def initialize(manager)
    super(manager)
    
    @function_button_y = @manager.monome.height - 1   # Function key row
    @shift_button_x = @manager.monome.width - 2       # Shift button
    
    @page_size = @manager.monome.width                # Size of a page
    @page_count = 1                                   # Number of pages
    @row_count = @manager.monome.height - 1           # Number of rows
    
    @seq = DrumSeq.new(@page_count * @page_size, @row_count, @manager.clock)
    
    @page_index = 0
    @page_ofs = 0
  end
  
  def activate
    super
    @manager.clock.add_listener(self)
  end
  
  def deactivate
    super
    @manager.clock.delete_listener(self)
  end
  
  def press(x, y, state)
    if state then
      if y < @function_button_y then
        get_note(x, y).switch()
        @manager.monome.led(x, y, get_note(x, y).trigger)
      else
        if x < @page_count then
          switch_page(x)
        end
      end
    end
  end
  
  def clock_update(ticks)
    if ticks % 4 == 0 then
      redraw_bar(true)
    elsif ticks % 4 == 1 then
      redraw_bar(false)
    end
  end
    
  private
  
  def switch_page(index)
    @page_index = index
    @page_ofs = index * @page_size
    redraw_page
  end
  
  def get_note(x, y)
    @seq[y][@page_ofs + x]
  end
  
  def redraw_page
    (0..@row_count - 1).each do |y|
      (0..@page_size - 1).each do |x|
        @manager.monome.led(x, y, get_note(x, y).trigger)
      end
    end
  end
  
  def redraw_bar(on)
    x = @seq.pos - @page_ofs
    return if (x < 0) || (x >= @manager.monome.width)
    if on then
      (0..@row_count - 1).each { |y| @manager.monome.led(x, y, true) }
    else
      (0..@row_count - 1).each { |y| @manager.monome.led(x, y, get_note(x, y).trigger) }
    end
  end
  
end