require 'set'
require 'date'

WEEK_DAYS = 1..5 # Monday-Friday

class Date
  attr_accessor :name
  
  # Return a set of days of the week for the period
  # If the period end day is not a week-end, it won't be part of the set because
  # date represent 12:01 and we are interrested in the interval not the boundry
  def self.week_days(period_start, period_end)
    s = Set.new
    period_end -= 1
    (period_start..period_end).step(1) {|day|
      s.add day if WEEK_DAYS.include?(day.wday)
    }
    return s
  end
end

