require "date"

class EclDate < Date
  @semesters = Hash.new({})
  
  def self.apply(year, month, day, wday = nil, cweek = nil)
    date = new(year, month, day)
    date.wday = wday
    date.cweek = cweek
    date
  end
  
  def self.register(year, semester, &block)
    @semesters[year][semester] = Semester.new(&block)
  end
  
  def self.semesters
    @semesters
  end
  
  def wday=(x)
    @wday = x
  end
  
  def wday
    @wday || super
  end
  
  def cweek=(x)
    @cweek = x
  end
  
  def cweek
    @cweek || super
  end
end

class Semester
  attr_accessor :dates
  
  def initialize(&block)
    @dates = []
    instance_eval(&block)
  end
  
  def add(date)
    case date
    when EclDate
      @dates << date
    when Range
      @dates += date.to_a
    when Array
      @dates += date
    end
  end
end

def D(*args)
  EclDate.apply(*args)
end