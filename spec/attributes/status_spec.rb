require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/multi_select_spec'

module Bugzilla
  module Attributes
    describe Status do
      before(:all) do
        @klass = Status
      end
      it_should_behave_like 'MultiSelect'
    end
  end
end