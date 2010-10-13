# encoding: utf-8

module PlanGenerator
  class HTML
    def template
      File.dirname(__FILE__) + "/../../views/pdf-template.erb"
    end
    
    HOURS = (7..21).to_a
    DEFAULT_COLORS = {
      "c_W" => %w(#f3b6b7 #e63021 #e63021),
      "c_C" => %w(#aeed91 #47ae03 #47ae03),
      "c_L" => %w(#a5c4f7 #1c64dc #1c64dc),
      "c_P" => %w(#efbcf0 #bb3abd #bb3abd),
      "c_S" => %w(#f5dcc0 #f38e00 #f38e00),
      "c_X" => %w(#ccc1ec #5c3ab2 #5c3ab2)     
    }
    
    def self.generate!(schedule, colors = nil)
      new(schedule, colors || DEFAULT_COLORS).to_html
    end
        
    def initialize(schedule, colors)
      @schedule = schedule
      @colors = colors
    end
    
    def colors_css
      @colors.map do |cls, c|
        ".#{cls} {
          background-color: #{c[0]};
          border-color: #{c[1]};
          color: #{c[2]};
        }"
      end.join "\n"
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