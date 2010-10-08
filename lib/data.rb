# encoding: utf-8

class Schedule
  attr_accessor :days, :year, :semester
  
  def days_num
    days[5].empty? && days[6].empty? ? 5 : 7
  end
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
  attr_accessor :group_code, :course_code, :course_name, :type, 
                :week, :time, :building, :room, :lecturer, :row
                
  def initialize
    @row = 0
    @group_code = ""
    @course_code = ""
    @course_name = ""
    @type = ""
    @week = ""
    @time = ""
    @building = ""
    @room = ""
    @lecturer = ""
    @row = ""
  end
                
  def start_time
    @start_time ||= parse_time(time[:start])
  end
  
  def end_time
    @end_time ||= parse_time(time[:end])
  end
  
  def start_hour
    time[:start][:hour].to_i
  end
  
  def start_min
    time[:start][:min].to_i
  end
  
  def end_hour
    time[:end][:hour].to_i
  end
  
  def end_min
    time[:end][:min].to_i
  end
  
  def location
    "#{building} / #{room}"
  end
  
  def time_string
    "#{time[:start][:hour]}:#{time[:start][:min]} - #{time[:end][:hour]}:#{time[:end][:min]}"
  end
  
  TYPES = {"Wykład" => "W", "Ćwiczenia" => "C", "Seminarium" => "S",
    "Zajęcia laboratoryjne" => "L", "Projekt" => "P", "Inne" => "X"}
  
  def type_code
    TYPES[type] || type
  end
  
  def type_color
    {"W" => "ecdf92", "C" => "ff4283", "L" => "b0e35d", 
      "S" => "ffa645", "P" => "bf9bf8"}[type_code] || "FFFFFF"
  end
  
  def in_week?(n)
    week == "" || week == ["TP", "TN"][n%2]
  end
  
  def course_name_with_type
    "#{course_name} (#{type_code})"
  end
  
  protected
  
  def parse_time(time)
    time[:hour].to_i * 100 + time[:min].to_i
  end
end
