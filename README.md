# Robot Warehouse Coding Challenge

The RobotController object is designed to control the movement of the warehouse robot.
The size of the grid is 10x10 units, and the controller prevents movement outside of
this area.

## Interface

* Series of commands are sent to the robot with `#parse_commands`,
which can accept a comma separated string, or an array of characters or symbols.
e.g. `parse_commands("N,E,S,W")` or `parse_commands(%i[N E S W])`

* Just for fun I made a `#move_to` method that approximates a straight line using
the Bresenham algorithm. At first I thought this might be more energy efficient, but then I realized it is actually the same or even slightly worse than just moving in two long straight lines!

## Tests

Run the tests with `rake`.
