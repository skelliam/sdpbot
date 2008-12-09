require 'uri'

module Bugzilla
  module Attributes
    module Searchable
      def to_search_query
        qs = ""
        unless self.class.prefix.nil? || self.empty?
          qs += "&#{self.class.prefix}"
        end
        if respond_to?(:each)
          each {|s| qs += "&#{self.class.field_name}=#{s}" }
        else
          qs += "&#{self.class.field_name}=#{self}"
        end
        URI.encode(qs)
      end
    end
  end
end

