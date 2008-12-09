require File.dirname(__FILE__) + '/field_spec'

module Bugzilla
  module Attributes
    describe 'Single', :shared => true do
      it_should_behave_like 'Field'

    end
  end
end