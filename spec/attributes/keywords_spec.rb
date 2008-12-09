require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/single_spec'

module Bugzilla
  module Attributes
    describe Keywords do
      before(:all) do
        @klass = Keywords
      end
      it_should_behave_like 'Single'      
    end
  end
end