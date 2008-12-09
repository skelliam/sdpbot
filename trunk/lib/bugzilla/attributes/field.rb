module Bugzilla
  module Attributes
    module Field
      def self.included(class_name)
        # Add some class methods
        class << class_name
          attr_accessor :choices

          def prefixed_by(s)
            @prefix = s
          end
          def prefix
            @prefix
          end
        
          def named(s)
            @field_name = s          
          end
          def field_name
            # Class name will be used if no field name was specified
            return self.name.downcase if @field_name.nil?
            return @field_name
          end
        
          def with_choices(a)
            @choices = a
          end
  
          def method_missing(m, *args)
            o = new 
            if @choices.include?(m.to_s)
              return o << m.to_s
            # Treat dash dash dash specially because it's not a valid method name
            elsif m == :unspecified
              return o << '---'
            else
              super(m, *args)
            end
          end        
  
          def inherited(subclass)
            String.send(:define_method, "to_#{subclass.simple_name.snake_case}".to_sym, lambda { subclass.new << self })
            super
          end
              
          def all
            new(@choices)
          end        
        end
      end
    end
  end
end