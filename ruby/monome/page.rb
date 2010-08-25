

class Page
  
  def initialize(manager)
    @manager = manager
  end
  
  def activate
    @manager.monome.add_listener(self)
  end
  
  def deactivate
    @manager.monome.delete_listener(self)
  end
  
  def press(x, y, state)
  end
    
end


require 'page_draw'
require 'page_drumseq'


class PageManager
  
  PAGE_SWITCH_ROW = 7
  PAGE_SWITCH_BUTTON = [7, PAGE_SWITCH_ROW]
  
  attr_reader :monome, :clock
  
  def initialize(monome, clock)
    @monome = monome
    @monome.add_listener(self)
    
    @clock = clock
    
    @pages = []
    @current_page = nil
    
    @page_switch = false
    
    add_page(PageDrumSeq.new(self))
    (0..5).each { add_page(PageDraw.new(self)) }
  end
  
  def add_page(page)
    @pages << page
    if !@current_page then
      @current_page = page
      @current_page.activate
    end
  end
  
  def delete_page(page)
    @pages.delete(page)
  end
    
  def press(x, y, state)
    key = [x, y]
    # Check for page switch button
    if key == PageManager::PAGE_SWITCH_BUTTON then
      @page_switch = state
      @monome.led(x, y, state)
    # Check for page switch destination buttons
    elsif y == PAGE_SWITCH_ROW then
      if @page_switch && state then
        switch_page(x)
      end
    end
  end
  
  def switch_page(index)
    @current_page.deactivate
    @current_page = @pages[index]
    @current_page.activate
  end
  
end