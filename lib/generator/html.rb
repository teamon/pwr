# encoding: utf-8

module PlanGenerator
  class HTML
    TEMPLATE = File.dirname(__FILE__) + "/../../views/pdf-template.erb"
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
          
      ERB.new(File.read(TEMPLATE)).result(binding)
    end
    
    protected
        
    def entry_size(time)
      sh = time[:start][:hour].to_i
      sm = time[:start][:min].to_i
      eh = time[:end][:hour].to_i
      em = time[:end][:min].to_i
      
      (((eh * 60) + em) - ((sh * 60) + sm)) / 5
    end  
  end
end