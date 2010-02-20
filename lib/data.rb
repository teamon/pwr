class Schedule
  attr_accessor :days, :year, :semester
end

class Day
  attr_accessor :id, :entries
  
  def initialize(id)
    @id = id
    @entries = []
  end
  
  def <<(entry)
    @entries << entry
  end
  
  def name
    ["Poniedziałek", "Wtorek", "środa", "Czwartek", "Piątek", "Sobota", "Niedziela"][id]
  end
  
  def size
    return 0 if @entries.empty?
    
    size = 1
    prev_end_time = 0
    
    @entries.each do |e|
      if e.start_time < prev_end_time
        e.row = 1
        size = 2
      end
      prev_end_time = e.end_time
    end
    
    size
  end

  def sort!
    @entries.sort! {|a,b| a.start_time <=> b.start_time }
  end
  
  def inspect
    "<Day id=#{id.inspect} entries=#{@entries.inspect}>"
  end
  
  def method_missing(method_name, *args, &block)
    entries.send(method_name, *args, &block)
  end
end

class Entry
  attr_accessor :group_code, :course_code, :course_name, :type, :week,
                :time, :building, :room, :lecturer, :row
                
  def initialize
    @row = 0
  end
                
  def start_time
    @start_time ||= parse_time(time[:start])
  end
  
  def end_time
    @end_time ||= parse_time(time[:end])
  end
  
  def inspect
    "<Entry start_time=#{start_time.inspect} end_time=#{end_time.inspect}>"
  end
  
  def time_string
    "#{time[:start][:hour]}:#{time[:start][:min]} - #{time[:end][:hour]}:#{time[:end][:min]}"
  end
  
  def type_code
    {"Wykład" => "W", "Ćwiczenia" => "C", "Zajęcia laboratoryjne" => "L"}[type] || type
  end
  
  def type_color
    {"W" => "FDFF68", "C" => "F9285E", "L" => "00FFD5"}[type_code] || "FFFFFF"
  end
  
  protected
  
  def parse_time(time)
    time[:hour].to_i * 100 + time[:min].to_i
  end
end
