require 'set'
require 'yaml'
require 'uri'

module Bugzilla        
  class View < Set
    class CostMissingException < Exception
      attr_accessor :view
      attr_accessor :partial_cost
      def initialize(*args)
        @view = View.new
        @partial_cost = 0
      end 
    end
      
    attr_accessor :created_on

    class << self
      # Create a view from a query
      def from_query(query)
        Entities::Base.connector.login unless Entities::Base.connector.logged_in?
        result = Entities::Base.find_from_query(query)
        return new(result)
      end
    
      # Create a view from ids
      def from_ids(ids)
        query = Query.static(ids)
        from_query(query)
      end
    end
    
    def initialize(*args)
      @created_on = Time.now.strftime("%Y-%m-%d %H:%M:%S %z")
      super(*args)
    end
    
    # Returns true if cost is missing for some items
    def cost_missing?
      begin
        total_cost
      rescue CostMissingException => e
        return true
      end
      return false
    end
    
    # Compute the total cost of elements in this view
    # A CostMissingException will be raised if one of the element is missing a cost
    def total_cost
      e = CostMissingException.new "Cost missing for some items"
      
      total = 0
      self.each {|entity|
        if entity.cost.nil?
          e.view.add entity
        else  
          total = total + entity.cost
        end  
      }
      
      if e.view.size > 0 
        e.partial_cost = total
        raise e
      else
        return total
      end
    end
  
    # Substract the total cost of this view with the total cost of the other view
    # A CostMissingException will be raised if one of the element in either view is missing a cost
    def substract_cost_from(other_view)
      if other_view.nil?
        return self.total_cost
      else
        e = CostMissingException.new "Cost missing for some items"

        begin
          this_cost = self.total_cost
        rescue Bugzilla::View::CostMissingException => this_e
          e.partial_cost = this_e.partial_cost
          e.view = this_e.view
        end
      
        begin
          other_cost = other_view.total_cost 
          
          if e.view.size > 0
            e.partial_cost -= other_cost
          end
        rescue Bugzilla::View::CostMissingException => other_e
          # Was any cost missing on the first view?
          if e.view.size > 0
            e.partial_cost -= other_e.partial_cost
          else
            e.partial_cost = this_cost - other_e.partial_cost
          end
          e.view += other_e.view            
        end

        # Was any cost misisng?
        if e.view.size > 0 
          raise e
        else
          return this_cost - other_cost
        end
      end      
    end
    
    # Repopulate the view from the query
    def refresh
      refreshed_view = View.from_query(self.to_query)
      self.clear
      self.merge(refreshed_view)
    end
    
    # Return array of ids representing elements in the view
    def ids
      a = Array.new
      self.each {|entity|
        a.push entity.id
      }
      return a.sort
    end
    
    # Return a static query that represent the view
    def to_query
      Query.static(ids)
    end  
    
    def bugzilla_url
      URI.encode("http://#{Entities::Base.connector.host}#{to_query}")
    end

    # Returns a hash that represent cost distribution for 1,2,3 and unknown costs
    def cost_histogram
      h = { 
        :cost_1   => {:count => 0, :percentage => 0}, 
        :cost_2   => {:count => 0, :percentage => 0}, 
        :cost_3   => {:count => 0, :percentage => 0}, 
        :unknown  => {:count => 0, :percentage => 0}
      }
      self.each {|item|
        case item.cost
        when 1
          h[:cost_1][:count] += 1 
        when 2
          h[:cost_2][:count] += 1           
        when 3
          h[:cost_3][:count] += 1           
        else
          h[:unknown][:count] += 1 
        end                
      }    
      unless size.zero?
        h[:cost_1][:percentage] = ((h[:cost_1][:count].to_f / size.to_f) * 100).round 
        h[:cost_2][:percentage] = ((h[:cost_2][:count].to_f / size.to_f) * 100).round 
        h[:cost_3][:percentage] = ((h[:cost_3][:count].to_f / size.to_f) * 100).round
        h[:unknown][:percentage] = ((h[:unknown][:count].to_f / size.to_f) * 100).round
      end
      return h
    end
    
    def to_s
      s = ""
      self.to_a.sort.each {|entity|
        s += "#{entity.to_s}\n"
      }
      s
    end
        
    def to_yaml(opts = {})
      YAML.quick_emit(object_id, opts) { |out| 
        out.map("tag:songbirdnest.com,2008-01:Bugzilla::View") { |map| 
          to_yaml_properties.each { |iv| 
            map.add( iv[1..-1], instance_eval( iv ) ) 
          } 
          # Add custom field to be able to deserialize the view
          map.add("query", to_query.to_s)
        } 
      } 
    end
    
    def to_yaml_properties
      ["@created_on"]
    end
  end
end

YAML::add_domain_type("songbirdnest.com,2008-01", "Bugzilla::View") do |type, val|
  v = View.new
  unless val['query'].nil?
    v = View.from_query(Query.from_s(val['query']))
  end
  v.created_on = val['created_on'] unless val['created_on'].nil?
  v
end
