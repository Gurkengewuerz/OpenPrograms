--[[	
	Author: Gurkengewuerz
]]--

local event = require "event"
local computer = require "computer"
local colors = require "colors"
local sides = require "sides"
local c = require('component').redstone

while true
do
  for i=0,15,1
  do
    print(colors[i])
    c.setBundledOutput(sides.back, i, 255)
    if (c.getInput(sides.front) > 1) then
      print(c.getInput(sides.front))
      computer.beep(500, 0.5)
    end
    os.sleep(0.5)
    c.setBundledOutput(sides.back, i, 0)
  end
end