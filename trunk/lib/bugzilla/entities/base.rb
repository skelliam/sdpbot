require 'strscan'

module Bugzilla
	module Entities
	  # Base class to represent an entity from Bugzilla
    # By default everything is a bug in Bugzilla, but this uses subclasses to take into account the type of the item
    # to return the proper class type (Bug, Story, Task, Feature)
		class Base < Bugzilla::Base
		  attr :summary
  
		  # Status
		  attr :is_opened
		  attr :status
		  attr :target_milestone
		  attr :version
		  attr :whiteboard
		  attr :cost
		  attr :created_on
		  attr :modified_on
      attr :resolution
      
		  # User stuff
		  attr :assigned_to
		  attr :assigned_to_id
		  attr :reported_by

      @@cache = Cache.new(:expiration => 60 * 5) # 5 Minutes cache        
      @@subclasses = {}
    	self.service_name = "Bug"
                          
      #
      # Class methods
      #
      class << self

        # Collect subclasses to determine which one to use to materialize an item
        def inherited(child)
          @@subclasses[self] ||= []
          @@subclasses[self] << child
          super
        end
        
        def bz_type
          nil
        end
        
        def cache
          @@cache
        end
        def cache=(c)
          @@cache = c
        end
        
        # Return a set of entities matching the ids
        def find(ids)
          ids = [ids] unless ids.is_a?(Array)
          cached = Set.new
          ids_miss = Array.new
          
          # Find items that are cached and remove ids from the query    
          ids.each {|id|
            item = cache[id]
            unless item.nil?
              cached.add item
            else
              ids_miss.push id
            end
          }  
          
          fetched = find_all(ids_miss)
          fetched.each {|item|
            cache.store(item.id, item)
          }
          return cached + fetched
        end  

        # Return a set of entities based on a query.
        # If the query is static, bypass querying Bugzilla web to retrieve ids because we got them already
        def find_from_query(query)
          ids = Array.new

          unless query.is_static?
            # Retrieve csv from bugzilla
            csv = connector.get("#{query.to_s}&ctype=csv")    
            s = StringScanner.new(csv)

            # Collect every id that is in the first position in the csv
            while (!s.eos?) 
              s.skip_until(/\n/)
              id = s.scan(/\d+/)
              break if id.nil?
              ids.push id.to_i
            end
          else
            ids = query.ids
          end
          return find(ids)
        end

        private
        # Find every items
        def find_all(ids)
          unless ids.size == 0
            result = request("get_bugs", { 'ids' => ids })
            instantiate_collection(result['bugs'])
          else
            Set.new
          end
        end

        def instantiate(hash)
          klass = find_class_for_type(hash['internals']['cf_type_'])
          item = klass.new
          item.load_attributes_from_bugzilla_hash(hash)             
          return item 
        end     
        
        # Look thru subclasses and return one that matches the type of entity
        def find_class_for_type(type)
          @@subclasses[self].each {|klass|
            return klass if klass.bz_type == type
          }   
          return self
        end
      end
 		   		  
		  def to_s
		    "#{@id} - #{@summary}"
		  end
		                   
=begin

This is the hash being returned from bugzilla for a bug

      {"last_change_time"=>
        #<XMLRPC::DateTime:0x17b603c
         @day=29,
         @hour=19,
         @min=19,
         @month=1,
         @sec=23,
         @year=2008>,
       "creation_time"=>
        #<XMLRPC::DateTime:0x17b220c
         @day=21,
         @hour=21,
         @min=56,
         @month=1,
         @sec=0,
         @year=2008>,
       "internals"=>
        {"resolution"=>"WORKSFORME",
         "isopened"=>0,
         "everconfirmed"=>1,
         "cf_bug_cost_estimate"=>"",
         "cclist_accessible"=>1,
         "cf_type_"=>"Bug",
         "target_milestone"=>"---",
         "reporter_accessible"=>1,
         "status_whiteboard"=>"",
         "rep_platform"=>"Mac - PPC",
         "product_id"=>2,
         "priority"=>"---",
         "version"=>"0.5 Nightly",
         "delta_ts"=>"2008-01-29 19:19:23",
         "bug_id"=>7000,
         "assigned_to_id"=>2060,
         "component_id"=>89,
         "reporter_id"=>1197,
         "bug_status"=>"RESOLVED",
         "op_sys"=>"Mac OS X Leopard (10.5.x)",
         "bug_severity"=>"major",
         "bug_file_loc"=>"",
         "alias"=>"",
         "short_desc"=>
          "iTunes Library Importer in first run for mac ppc 0.5pre does not seem to be compatible",
         "creation_ts"=>"2008.01.21 21:56",
         "qa_contact_id"=>40,
         "isunconfirmed"=>""},
       "id"=>7000,
       "summary"=>
        "iTunes Library Importer in first run for mac ppc 0.5pre does not seem to be compatible",
       "alias"=>""}
=end      
      def load_attributes_from_bugzilla_hash(hash)
		    load_id_from_bugzilla_hash(hash)
		    
		    @summary = hash['summary']
		    @is_opened = hash['internals']['isopened'] == 1
		    @resolution = hash['internals']['resolution'].to_sym unless hash['internals']['resolution'].nil? || hash['internals']['resolution'].empty?
		    @status = hash['internals']['bug_status'].to_sym
		    @target_milestone = hash['internals']['target_milestone']
		    @version = hash['internals']['version']
		    @whiteboard = hash['internals']['status_whiteboard']		    
		    @created_on = hash['creation_time'].to_time
		    @modified_on = hash['last_change_time'].to_time
		    @assigned_to_id = hash['internals']['assigned_to_id']

		    # Cost field can contain all sorts of funky stuff (3+, 1,2, ?, text, etc)
        # This will get an integer if it's the only thing 
		    @cost = hash['internals']['cf_bug_cost_estimate']
		    # If not, let try remove other stuff
		    unless @cost.is_a?(Integer)
		      s = hash['internals']['cf_bug_cost_estimate'].match(/\d*/)[0]
		      @cost = s.to_i unless s.empty?
		    end
		    # If not, let's make it nil
		    @cost = nil unless @cost.is_a?(Integer)          
      end
      
      def load_id_from_bugzilla_hash(hash)
        @id = hash['id']
      end

      protected
      def create
        #TODO: create in bugzilla
        
        # Update object id with response
        load_id_from_bugzilla_hash(result)
      end      
		end		
	end
end