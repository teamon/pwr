# encoding: urf-8

require "prawn"
require "prawn/layout"

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

class PdfGenerator
  def self.generate!(schedule)
    days = schedule.days
    
    Prawn::Document.new(:page_size => 'A4', :page_layout => :landscape) do
      def left(time)
        (time[:hour].to_i-7)*@hour_size + (time[:min].to_i / (60/@hour_size))
      end

      # config
      font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
      hours = (7..21).to_a
      @hour_size = 12
      @entry_height = 5
      
      rows_count = days.inject(0) {|s,e| s+e.size }

      define_grid :rows => rows_count*@entry_height+3, :columns => @hour_size*hours.size
      # grid.show_all
      
      # hours
      hours.each_with_index do |hour, i|
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
      
      
      days.each_with_index do |day, dindex|
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
            text(entry.lecturer || "", :align => :center, :size => 6)
          end
          
          (grid [row+r+3, sl], [row+r+3, el]).bounding_box do
            text "\n", :size => 5
            text entry.location, :align => :center, :size => 8
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