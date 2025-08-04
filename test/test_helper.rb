require "minitest"
require "shoulda-context"
require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "robot_controller"
