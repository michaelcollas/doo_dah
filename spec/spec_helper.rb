$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'doo_dah'
require 'rspec'
require 'rspec/autorun'
require 'spec/support/byte_matcher'
require 'spec/support/write_capturing_example_group'

RSpec.configure do |config|
  
end
