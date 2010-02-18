# encoding: utf-8

require "nokogiri"
require "prawn"
require "prawn/layout"

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

class EclParser
  def self.generate!(html)
    doc = new(html)
    doc.parse!
    doc.generate!
  end
  
  def initialize(html)
    @doc = Nokogiri::HTML(html)
    @days = []
    7.times {|i| @days[i] = Day.new(i) }
  end
  
  def parse!
    trs = @doc.css("table.KOLOROWA")[2].children.drop(4)
    
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
    
    @days.each(&:sort!)
  end
  
  def day_id(day)
    {"pn" => 0, "wt" => 1, "śr" => 2, "cz" => 3, "pt" => 4}[day]
  end
  
  def generate!
    days = @days

    Prawn::Document.new(:page_size => 'A4', :page_layout => :landscape) do
      def left(time)
        (time[:hour].to_i-7)*@hour_size + (time[:min].to_i / (60/@hour_size))
      end

      # config
      font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
      hours = (7..21).to_a
      @hour_size = 12
      @entry_height = 5
      
      sizes = days.map(&:size)
      rows_count = sizes.inject {|s,e| s+e }

      define_grid :rows => rows_count*@entry_height+3, :columns => @hour_size*hours.size
      # grid.show_all
      
      # hours
      hours.each.with_index do |hour, i|
        grid([1, @hour_size*i], [2, @hour_size*(i+1)-1]).bounding_box do
          text "%02d:00" % hour
        end
      end
      
      # copyright
      grid([grid.rows-1, 0], [grid.rows-1, grid.columns-1]).bounding_box do
        text "\n", :size => 6
        text "Plan wygenerowany przez http://pwr.heroku.com. Copyright teamon 2010", :align => :right, :size => 6
      end
      
      row = 2
      
      
      days.each.with_index do |day, dindex|
        next if day.empty?

        ds = day.size*@entry_height
        
        text day.name, :at => [-2.0, grid(row+ds, 0).top], :rotate => 90, :size => 9
        
        day.each do |entry|
          sl = left(entry.time[:start])
          el = left(entry.time[:end])
          r = entry.row*@entry_height
          
          fill_color "EEEEEE"
          (grid [row+r, sl], [row+r+@entry_height-1, el]).bounding_box do
            stroke_color "000000"
            stroke_bounds
            
            fill do
              rectangle bounds.top_left, bounds.width, bounds.height
            end
          end
          
          
          fill_color "000000"
          (grid [row+r, sl], [row+r, el]).bounding_box do
            text "\n", :size => 3
            text entry.course_code, :align => :center, :size => 6
          end
          
          (grid [row+r, sl], [row+r+1, el]).bounding_box do
            text "\n", :size => 10
            text entry.course_name, :align => :center, :size => 8
          end
          
          (grid [row+r+2, sl], [row+r+2, el]).bounding_box do
            text (entry.lecturer || ""), :align => :center, :size => 6
          end
          
          (grid [row+r+3, sl], [row+r+3, el]).bounding_box do
            text "\n", :size => 5
            text "%s (%s)" % [entry.building, entry.room], :align => :center, :size => 8
          end
          
          (grid [row+r+4, sl], [row+r+4, el]).bounding_box do
            fill_color entry.type_color
            fill do
              rectangle bounds.top_left, bounds.width, bounds.height
            end
            
            fill_color "000000"
            text "\n", :size => 5
            text entry.time_string, :align => :center, :size => 8
          end
          
          (grid [row+r+4, el-4], [row+r+4, el]).bounding_box do
            text "\n", :size => 5
            text entry.type_code, :align => :center, :size => 8
          end
          
          (grid [row+r+4, sl], [row+r+4, sl+4]).bounding_box do
            text "\n", :size => 5
            text entry.week, :align => :center, :size => 8
          end
          
        end
        
        (grid [row, 0], [row + ds - 1, grid.columns-1]).bounding_box do
          self.stroke_color = "000000"
          stroke_bounds
        end
        row += ds
      end
    end.render
  end
end

class Prawn::Document::Box
  def show(grid_color = "CCCCCC")
    self.bounding_box do
      original_stroke_color = pdf.stroke_color
      pdf.stroke_color = grid_color
      # pdf.text self.name
      pdf.stroke_bounds
      pdf.stroke_color = original_stroke_color
    end
  end
end
