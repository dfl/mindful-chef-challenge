# frozen_string_literal: true

class InvalidCommandError < StandardError; end


##
# RobotController is responsible for controlling the movement of a warehouse robot 
# on a fixed 10x10 grid. It prevents movement outside the grid and tracks energy usage.
#
# === Example
#   robot = RobotController.new(x: 2, y: 3)
#   robot.parse_commands("N,E,E,S")
#   robot.move_to(x: 5, y: 7)
#
# === Grid
# The robot moves within a 10x10 grid (from [0,0] to [9,9]).

class RobotController
  # Size of the warehouse grid
  WAREHOUSE_GRID_SIZE = 10.freeze
  # Maximum coordinate value on either axis
  BOUNDS = WAREHOUSE_GRID_SIZE - 1
  VALID_COMMANDS = %i[N E S W].freeze

  # @return [Integer] Current x-coordinate of the robot
  # @return [Integer] Current y-coordinate of the robot
  # @return [Integer] Total power used (number of moves made)
  attr_reader :x, :y, :power_used

  ##
  # @return [Array<Integer>] Current position as [x, y]
  def position
    [x, y]
  end

  ##
  # Initializes a new robot at the given (x, y) position.
  # Defaults to (0, 0) if no coordinates are given.
  #
  # @param x [Integer] Starting x-coordinate
  # @param y [Integer] Starting y-coordinate
  # @raise [ArgumentError] If coordinates are out of bounds
  def initialize(x: 0, y: 0)
    validate_coordinates!(x, y)
    @power_used = 0
    @x = x
    @y = y
  end

  ##
  # Moves the robot to a specified coordinate using
  # Bresenham's algorithm to approximate a straight path.
  #
  # @param x [Integer] Target x-coordinate
  # @param y [Integer] Target y-coordinate
  # @raise [ArgumentError] If the destination is out of bounds
  def move_to(x:, y:)
    validate_coordinates!(x, y)
    commands = line_to_commands(x0: @x, y0: @y, x1: x, y1: y)
    parse_commands(commands)
  end

  ##
  # Parses a sequence of directional commands and moves the robot accordingly.
  #
  # @param commands [String, Array<String, Symbol>] Comma-separated string (e.g., "N,E") or array of directions (e.g., %i[N E])
  # @raise [ArgumentError] If commands are not a String or Array
  # @raise [InvalidCommandError] If the command sequence contains invalid directions

  def parse_commands(commands)
    raise ArgumentError, "commands must be a String or Array" unless commands.is_a?(String) || commands.is_a?(Array)
    commands = commands.split(",") if commands.is_a?(String)

    validate_commands!(commands)
    commands.each { move!(it) }
  end

  private

  ##
  # Moves the robot in the specified direction and increments power usage.
  # Enforces grid boundaries.
  #
  # @param direction [String, Symbol] One of :N, :E, :S, :W
  # @private
  def move!(direction)
    case direction.to_sym
    when :N then @y += 1
    when :E then @x += 1
    when :S then @y -= 1
    when :W then @x -= 1
    end

    clamp_bounds_and_track_power_used!
  end

  ##
  # Validates that given coordinates are within the warehouse bounds.
  #
  # @param x [Integer]
  # @param y [Integer]
  # @raise [ArgumentError] If coordinates are outside grid
  # @private
  def validate_coordinates!(x, y)
    unless x.between?(0, BOUNDS) && y.between?(0, BOUNDS)
      raise ArgumentError, "Coordinates must be between 0 and #{BOUNDS}"
    end
  end

  ##
  # Validates that all commands are included in the set of valid commands.
  #
  # @param commands [Array<String, Symbol>] An array of command characters or symbols to validate.
  # @raise [InvalidCommandError] If one or more commands are not valid.
  # @private
  def validate_commands!(commands)
    invalid = commands.reject { |cmd| VALID_COMMANDS.include?(cmd.to_sym) }
    raise InvalidCommandError, "Invalid command(s): #{invalid.join(', ')}" if invalid.any?
  end

  ##
  # Computes a set of directional commands using Bresenham's algorithm
  # to approximate a straight line between two points.
  #
  # @param x0 [Integer] Start x
  # @param y0 [Integer] Start y
  # @param x1 [Integer] End x
  # @param y1 [Integer] End y
  # @return [Array<Symbol>] Array of symbols %i[ N E S W ]
  # @private
  def line_to_commands(x0:, y0:, x1:, y1:)
    dx = x1 - x0
    dy = y1 - y0

    sx = dx <=> 0
    sy = dy <=> 0

    dx = dx.abs
    dy = dy.abs

    commands = []

    if dx > dy
      err = dx / 2
      until x0 == x1
        x0 += sx
        commands << direction_for(sx, :x)
        err -= dy
        if err < 0 && y0 != y1
          y0 += sy
          commands << direction_for(sy, :y)
          err += dx
        end
      end
    else
      err = dy / 2
      until y0 == y1
        y0 += sy
        commands << direction_for(sy, :y)
        err -= dx
        if err < 0 && x0 != x1
          x0 += sx
          commands << direction_for(sx, :x)
          err += dy
        end
      end
    end

    commands
  end

  ##
  # Converts a step and axis into a direction string.
  #
  # @param step [Integer] Either -1 or 1
  # @param axis [Symbol] :x or :y
  # @return [Symbol] One of :N, :S, :E, :W
  # @private
  def direction_for(step, axis)
    case axis
    when :x
      step > 0 ? :E : :W
    when :y
      step > 0 ? :N : :S
    end
  end

  # @private
  def clamp_bounds_and_track_power_used!
    prior_state = position
    # prevent robot from moving out of bounds
    @x = @x.clamp(0, BOUNDS)
    @y = @y.clamp(0, BOUNDS)
    @power_used += 1 unless nop = (prior_state != position)
  end

end
