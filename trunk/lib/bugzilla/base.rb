module Bugzilla
  # Base class to persist/retrieve an item from Bugzilla
	class Base  
    attr :id
          
    #
    # Class methods
    #
    
    # TODO: Refactor service name class variable. It won't work when subclass change it
    @@service_name=nil
    @@connector=nil
    
    class << self
      def service_name
        @@service_name
      end
      def service_name=(s)
        @@service_name = s
      end
      def connector
        @@connector
      end
      def connector=(c)
        @@connector = c
      end
      
      def create(attributes={})
        o = self.new(attributes)
        o.save
        return o
      end
      
      def find(ids=Array.new)
        raise NotImplementedError, "needs to be overriden in subclass"
      end  

      private
      def instantiate_collection(collection)
        collection.collect! {|hash| instantiate(hash)}
      end

      def instantiate(hash)
        raise NotImplementedError, "needs to be overriden in subclass"
      end
      
      def request(method, params={})
        return connector.call("#{service_name}.#{method}", params)          
      end      
    end

	  def initialize(attributes={})
      load(attributes)
	  end
	  
	  def <=>(other)
	    return 0 if @id == other.id
	    return 1 if @id > other.id
	    return -1 if @id < other.id
	  end
	  
	  def eql?(other)
	    self.hash == other.hash
	  end
	  
	  def hash
	    @id
	  end
	  		  
	  def new?
	    @id.nil?
	  end
	  
	  def save
	    new? ? create : update
	  end      
    
    def load(attributes)
      raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
      attributes.each {|key, value|
        send("#{key}", value)
      }
    end

    def load_attributes_from_bugzilla_hash(hash)
      raise NotImplementedError, "needs to be overriden in subclass"
    end      
    
    def load_id_from_bugzilla_hash(hash)
      raise NotImplementedError, "needs to be overriden in subclass"
    end

    protected
    def create
      raise NotImplementedError, "needs to be overriden in subclass"
    end

    def update
      raise NotImplementedError, "needs to be overriden in subclass"
    end
  end
end
