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
    trs = trs[4, trs.size-4]
    
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
      
      if td = trs[k+3].css("table tr td").first
        where_when = td.content.strip
      
        m_when = where_when.match(/(.{2})(?:\/(T(?:P|N)?))? (\d{2}):(\d{2})-(\d{2}):(\d{2})/u)
        entry.week = m_when[2] || ""
        entry.time = { :start => { :hour => m_when[3], :min => m_when[4] }, 
                       :end => { :hour => m_when[5], :min => m_when[6] } }
                     
        m_where = where_when.match(/bud. (.+?), sala (.+)/u)
        if m_where
          entry.building = m_where[1]
          entry.room = m_where[2]
        else
          entry.building = "?"
          entry.room = "?"
        end

        @days[day_id(m_when[1])] << entry
      end
    end
    
    @days.each {|d| d.sort! }
    
    schedule.days = @days
    schedule
  end
  
  def day_id(day)
    {"pn" => 0, "wt" => 1, "śr" => 2, "cz" => 3, "pt" => 4}[day]
  end

end

