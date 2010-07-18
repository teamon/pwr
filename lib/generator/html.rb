# encoding: utf-8

module PlanGenerator
  class HTML
    TEMPLATE = File.dirname(__FILE__) + "/../../views/pdf-template.haml"
    HOURS = (7..21).to_a
    
    def self.generate!(schedule)
      new(schedule).to_html
    end
        
    def initialize(schedule)
      @schedule = schedule
    end
    
    def to_html
      @days = @schedule.days.select {|day| !day.empty? }
      @row_count = @days.inject(0) {|s,e| s+e.size }
      @hours_count = HOURS.size
          
      Haml::Engine.new(File.read(TEMPLATE)).def_method(self, :render)
      render
    end
    
    protected
    
    def entry_pos_left(time)
      100 * time_size(time) / (HOURS.size*60.0)
    end
    
    def entry_width(entry)
      100 * (time_size(entry.time[:end]) - time_size(entry.time[:start])) / (HOURS.size*60.0)
    end  
    
    def time_size(time)
      (time[:hour].to_i-HOURS.first)*60 + time[:min].to_i
    end  
  end
end