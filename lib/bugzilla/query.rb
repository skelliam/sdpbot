require 'uri'

module Bugzilla
  # Represent a bugzilla query
	class Query
		attr_accessor :status
		attr_accessor :resolution
		attr_accessor :priority
		attr_accessor :target_milestone
		attr_accessor :start_date
		attr_accessor :end_date
    attr_accessor :email
		attr_accessor :products
		attr_accessor :keywords

		attr_accessor :ids
		attr_accessor :query
    
		def initialize(attributes)
		  @status = Array.new
		  @resolution = Array.new
		  @priority = Array.new
		  @target_milestone = Array.new
		  @cost = Array.new
		  @email = ""
		  attributes.each {|key, value|
  			send(key.to_s + '=', value)
  		}
		end
    
    class << self
      # Return a query instance from a bugzilla query url
      def from_s(s)
        str = s.gsub('http://bugzilla.songbirdnest.com', '')
        str.gsub!("\n", '')
      
        # Quick search queries don't need to be reloaded from Bugzilla web ui, they can be fetched from Bugzilla api
        if str.include?("quicksearch=")
          str = URI.decode(str)
          ids_str = str.gsub(/.*quicksearch=([\d+,]*).*/, '\1')
          ids = ids_str.split(',')
          ids.collect!{|id| id.to_i}
          self.static(ids)
        else
          new({:query => str})
        end    
      end
    
      # Return a query instance from an array of bug ids
      def static(ids)
        new({:ids => ids
              })      
      end

      # Return a query for all issues for a given target milestone
      def all(target_milestone, opts=Hash.new)
        new({:target_milestone => target_milestone}.merge(opts))
  		end
      
      # Return a query for all issues opened for a given target milestone
      def open(target_milestone, opts=Hash.new)
        new({:target_milestone => target_milestone,        
                  :status => [:unconfirmed, :new, :assigned, :reopened],
                  :priority => %w(--- P1 P2 P3),
                }.merge(opts))
  		end

      # Return a query for all issues planned 
      def planned(target_milestone, opts=Hash.new)
        new({:target_milestone => target_milestone,        
                  :status => [:unconfirmed, :new, :assigned, :reopened],
                  :priority => %w(P1)
                }.merge(opts))
  		end

      # Return a query for all issues fixed during the date interval
      def completed(target_milestone, start_date, end_date, opts=Hash.new)
        new({:target_milestone => target_milestone,
                  :resolution => [:fixed],
                  :priority => %w(--- P1 P2 P3),
                  :start_date => start_date,
                  :end_date => end_date
                }.merge(opts))
      end
    
      # Return a query for all issues open
      def carried_over(target_milestone, opts=Hash.new)
        new({:target_milestone => target_milestone,
                  :status => [:unconfirmed, :new, :assigned, :reopened],
                  :priority => %w(P1)
                }.merge(opts))
      end
       
      # Return a query for all issues fixed by a user during the date interval
      def fixed_by(target_milestone, start_date, end_date, email, opts=Hash.new)
        new({:target_milestone => target_milestone,
                  :resolution => [:fixed],
                  :start_date => start_date,
                  :end_date => end_date,
                  :email => email
                }.merge(opts))
      end
    end
  
		def to_s
		  return @query unless @query.nil?
		  
		  if @ids.nil?
		    URI.encode("/buglist.cgi?query_format=advanced#{keywords_qs}#{product_qs}#{assigned_to_qs}#{target_milestone_qs}#{status_qs}#{resolution_qs}#{priority_qs}#{date_range_qs}&field0-0-0=cf_type_&type0-0-0=notequals&value0-0-0=Feature")
		  elsif @ids.size.nonzero?
    		"/buglist.cgi?order=bugs.bug_id&quicksearch=#{ids_qs}"
    	else
    	  nil
		  end
	  end
	  
	  def is_static?
	    !@ids.nil? && @ids.size.nonzero?
	  end

	  private
	  def ids_qs
	    qs = ""
      @ids.sort.each {|s|
        qs += "#{s}"
        qs += "," unless s == @ids.sort.last
      }	    
      qs
	  end
	  
	  
	  def assigned_to_qs
	    unless @email.empty?
	      "&emailassigned_to1=1&emailtype1=exact&email1=#{@email}"
	    end
	  end
	  
	  def target_milestone_qs
	    qs = ""
	    unless @target_milestone.nil?
	      if @target_milestone.respond_to?(:each)
	        @target_milestone.each {|tm|
	          qs += "&target_milestone=#{tm}" 
	        }
	      else
          qs = "&target_milestone=#{@target_milestone}" 
	      end
	    end
	    qs
	  end
	  
	  def date_range_qs
	    unless start_date.nil? || end_date.nil?
	      "&chfieldfrom=#{@start_date.strftime('%Y-%m-%d')}&chfieldto=#{@end_date.strftime('%Y-%m-%d')}"
	    else
	      ""
	    end
	  end
	  
	  def priority_qs
	    qs = ""
	    @priority.each {|s| qs += "&priority=#{s}" }
	    qs
	  end
	  
	  def status_qs
	    qs = ""
	    @status.each {|s| qs += "&bug_status=#{s.to_s.upcase}" }
	    qs
	  end

	  def product_qs
	    qs = ""
	    @products.each {|s| qs += "&product=#{s.to_s}" } unless @products.nil?
	    qs
	  end

	  def keywords_qs
	    qs = ""
	    unless @keywords.nil?
	      qs = "&keywords_type=anywords&keywords="
	      @keywords.each {|s| qs += "#{s.to_s}+" }
	    end
	    qs
	  end

	  def resolution_qs
	    qs = ""
	    @resolution.each {|s| qs += "&resolution=#{s.to_s.upcase}" }
	    unless @start_date.nil? || @end_date.nil? || @resolution.size != 1
	      qs += "&chfield=resolution&chfieldvalue=#{@resolution.last.to_s.upcase}"
	    end      
	    qs
	  end
	end
end