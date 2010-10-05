# encoding: utf-8

module PlanGenerator
  class HTML
    def template
      File.dirname(__FILE__) + "/../../views/pdf-template.erb"
    end
    
    HOURS = (7..21).to_a
    
    def self.generate!(schedule)
      new(schedule).to_html
    end
        
    def initialize(schedule)
      @schedule = schedule
    end
    
    def to_html
      @days = @schedule.days #.select {|day| !day.empty? }
      @row_count = @days.inject(0) {|s,e| s+e.size }
      @hours_count = HOURS.size
          
      ERB.new(File.read(template)).result(binding)
    end
    
    protected
        
    def entry_top_and_size(entry)
      sh = entry.time[:start][:hour].to_i
      sm = entry.time[:start][:min].to_i
      eh = entry.time[:end][:hour].to_i
      em = entry.time[:end][:min].to_i
      
      top = (((sh - HOURS.first) * 60) + sm) / 5
      size = (((eh * 60) + em) - ((sh * 60) + sm)) / 5
      
      [top, size]
    end
  end
  
  class MiniHTML < HTML
    def template
      File.dirname(__FILE__) + "/../../views/pdf-template-mini.erb"
    end
  end
end