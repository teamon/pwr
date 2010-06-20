# encoding: utf-8

module PlanGenerator
  class HTML
    TEMPLATE = File.dirname(__FILE__) + "/../../views/pdf-template.haml"
    HOURS = (7..21).to_a
    HOUR_SIZE = 800 / HOURS.size
    
    def self.generate!(schedule)
      new(schedule).to_html
    end
        
    def initialize(schedule)
      @schedule = schedule
    end
    
    def to_html
      @days = @schedule.days.select {|day| !day.empty? }
      days_count = @days.inject(0) {|s,e| s+e.size }
      @day_size = 550.0 / days_count
          
      Haml::Engine.new(File.read(TEMPLATE)).def_method(self, :render)
      render
    end
    
    protected
    
    def entry_pos_left(time)
      (time[:hour].to_i-HOURS.first)*HOUR_SIZE + (time[:min].to_i / (60/HOUR_SIZE))
    end
    
    def entry_width(entry)
      entry_pos_left(entry.time[:end]) - entry_pos_left(entry.time[:start])
    end    
  end
end