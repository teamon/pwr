# encoding: utf-8

require "nokogiri"

class EclParser
  def self.parse!(html)
    doc = new(html)
    doc.parse!
  end
  
  def initialize(html)
    @doc = Nokogiri::HTML(html)
    @days = []
    7.times {|i| @days[i] = Day.new(i) }
  end
  
  def parse!
    schedule = Schedule.new

    semester = @doc.css("td.WYBRANA").map {|e| e.content.strip}
    schedule.year = semester[0]
    schedule.semester = semester[1]

    trs = @doc.css("table.KOLOROWA")[2].children
    p trs.size
    trs = trs[4, trs.size-5]
    
    (0...(trs.size / 4)).each do |i|
      k = 4*i
      entry = Entry.new
      
      tds = trs[k].css("td")
      entry.group_code = tds[0].content.strip
      entry.course_code = tds[1].content.strip
      entry.course_name = tds[2].content.strip
      
      tds = trs[k+2].css("td")
      entry.lecturer = tds[0].content.strip
      entry.type = tds[1].content.strip
      
      m = trs[k+3].css("table tr td").first.content.strip.match(/(.{2})(?:\/(T(?:P|N)?))? (\d{2}):(\d{2})-(\d{2}):(\d{2}), bud. (.+?), sala (.+)/u)
      entry.week = m[2] || ""
      entry.time = { :start => { :hour => m[3], :min => m[4] }, 
                     :end => { :hour => m[5], :min => m[6] } }
      entry.building = m[7]
      entry.room = m[8]
      
      @days[day_id(m[1])] << entry
    end
    
    @days.each {|d| d.sort! }
    
    schedule.days = @days
    schedule
  end
  
  def day_id(day)
    {"pn" => 0, "wt" => 1, "śr" => 2, "cz" => 3, "pt" => 4}[day]
  end

end

