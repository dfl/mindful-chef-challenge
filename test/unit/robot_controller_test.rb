# frozen_string_literal: true
require_relative '../test_helper'
class RobotControllerTest < Minitest::Test
  context "#initialize" do
    should "raise an error if the start position is out of bounds" do
      assert_raises(ArgumentError) do
        RobotController.new(x: -1)
      end
      assert_raises(ArgumentError) do
        RobotController.new(y: -1)
      end
      assert_raises(ArgumentError) do
        RobotController.new(y: 11)
      end
      assert_raises(ArgumentError) do
        RobotController.new(x: 11)
      end
    end
  end

  context "Given a RobotController" do
    setup do
      @robot = RobotController.new
    end

    context "#parse_commands" do
      should "validate input type" do
        assert_raises(ArgumentError) do
          @robot.parse_commands(123)
        end
      end

      should "accept a string of commands" do
        @robot.parse_commands("N,E,S,W")
        assert_equal [0, 0], @robot.position

        @robot.parse_commands("N,N,E,E")
        assert_equal [2, 2], @robot.position
      end

      should "accept an array of command chars" do
        @robot.parse_commands(%w[ N E S W ])
        assert_equal [0, 0], @robot.position
      end

      should "accept an array of command symbols" do
        assert_equal [0, 0], @robot.position
        @robot.parse_commands(%i[ N E N E N ])
        assert_equal [2, 3], @robot.position
      end
    end

    context "#move_to" do
      should "move to a given position" do
        @robot.move_to(x: 5, y: 7)
        assert_equal [5, 7], @robot.position
        assert_equal 12, @robot.power_used
      end
    end
  end

end
