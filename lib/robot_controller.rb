# frozen_string_literal: true

class RobotController
  WAREHOUSE_GRID_SIZE = 10.freeze
  BOUNDS = WAREHOUSE_GRID_SIZE - 1

  attr_reader :x, :y, :power_used

  def initialize(x: 0, y: 0) # default to SW corner
    validate_coordinates!(x, y)
    @power_used = 0
    @x = x
    @y = y
  end

  def move_to(x:, y:)
    validate_coordinates!(x, y)
  
    commands = line_to_commands(x0: @x, y0: @y, x1: x, y1: y)
    parse_commands(commands)
  end
  
  def position
    [x, y]
  end

  def parse_commands(commands)
    raise ArgumentError, "commands must be a String or Array" unless commands.is_a?(String) || commands.is_a?(Array)
    commands = commands.split(",") if commands.is_a?(String)
    commands.each{ move(it) }
  end

  private

  def move(direction)
    case direction.to_sym
    when :N
      @y += 1
    when :E
      @x += 1
    when :S
      @y -= 1
    when :W
      @x -= 1
    else
      raise ArgumentError, "Invalid direction: #{direction}"
    end

    # prevent robot from moving out of bounds
    @x = @x.clamp(0, BOUNDS)
    @y = @y.clamp(0, BOUNDS)

    @power_used += 1 # track power consumption
  end

  def validate_coordinates!(x, y)
    unless x.between?(0, BOUNDS) && y.between?(0, BOUNDS)
      raise ArgumentError, "Coordinates must be between 0 and #{BOUNDS}"
    end
  end

  # use Bresenham's algorithm to make a straight line between two points
  def line_to_commands(x0:, y0:, x1:, y1:)
    dx = x1 - x0
    dy = y1 - y0

    sx = dx <=> 0 # sign of dx
    sy = dy <=> 0 # sign of dy

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

  def direction_for(step, axis)
    case axis
    when :x
      step > 0 ? "E" : "W"
    when :y
      step > 0 ? "N" : "S"
    end
  end

end