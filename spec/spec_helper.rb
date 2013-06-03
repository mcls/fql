require 'rubygems'
require 'bundler/setup'
require 'fql'
require 'vcr'


# Configure VCR
# Read more: https://github.com/vcr/vcr
#
VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/vcr_cassettes'
  c.hook_into :fakeweb
end
