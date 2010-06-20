# encoding: utf-8

module PlanGenerator
  class Calendar
    def self.each_entry(schedule, &block)
      EclDate.semesters[schedule.year][schedule.semester].dates.each do |date|
        schedule.days[date.wday-1].entries.select {|e| e.in_week?(date.cweek) }.each do |entry|
          block.call(date, entry)
        end
      end
    end
  end
  
  
  class ICal < Calendar
    include Icalendar
    
    def self.generate!(schedule)
      cal = Calendar.new
      
      each_entry(schedule) do |date, entry|
        cal.event do
          dtstart DateTime.civil(date.year, date.month, date.day, entry.start_hour, entry.start_min)
          dtend   DateTime.civil(date.year, date.month, date.day, entry.end_hour, entry.end_min)
          summary entry.course_name_with_type
          description entry.lecturer + "\n" + entry.course_code
          location entry.location
        end
      end

      cal.to_ical
    end
  end
  
  class VCS < Calendar
    def self.generate!(schedule)
      cal = Vpim::Icalendar.create2

      each_entry(schedule) do |date, entry|
        cal.add_event do |e|
          e.dtstart DateTime.civil(date.year, date.month, date.day, entry.start_hour, entry.start_min)
          e.dtend   DateTime.civil(date.year, date.month, date.day, entry.end_hour, entry.end_min)
          e.summary entry.course_name_with_type
          e.description entry.lecturer + "\n" + entry.course_code
          # e.location entry.location
        end
      end

      cal.encode
    end
  end
  
end

