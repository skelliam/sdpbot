require 'pp'

class String
  def diff(other)
    a = Array.new
    b = Array.new
    res = ""
    self.each_line("\n") {|line|
      a.push line
    }
    other.each_line("\n") {|line|
      b.push line
    }
    a.each_index {|i|
      unless (a[i]<=>b[i]) == 0
        res << "#{i}:#{a[i]}"
        res << "#{i}:#{b[i]}"
      end
    }
    res
  end
end

