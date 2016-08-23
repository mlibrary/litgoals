require 'minitest/spec'
require 'minitest/autorun'

$:.unshift "../lib"
$:.unshift "../seeds"

ENV['RACK_ENV'] = "test"
