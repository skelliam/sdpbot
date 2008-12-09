require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/multi_select_spec'

module Bugzilla
  module Attributes
    describe Priority do
      before(:all) do
        @klass = Priority
      end
      it_should_behave_like 'MultiSelect'
    end
  end
end