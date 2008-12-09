require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/multi_select_spec'

module Bugzilla
  module Attributes
    describe Product do
      before(:all) do
        @klass = Product
      end
      it_should_behave_like 'MultiSelect'
    end
  end
end