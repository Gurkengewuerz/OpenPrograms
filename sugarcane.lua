--[[	
	Author: Gurkengewuerz
]]--

local component = require("component")
local computer = require("computer")
local robot = require("robot")
local shell = require("shell")
local sides = require("sides")
 
if not component.isAvailable("robot") then
  print("Nur ein Roboter kann dieses Programm ausfüren")
  return
end
 
local r = component.robot
local lenght = 28
local width = 16
 
local function trymove(side)
  local success = false
  local tries = 0
  while not success do
    if tries >= 10 then
      print("10 Versuche rum...")
      print("Fahre herrunter...")
      computer.shutdown()
    end
 
    if r.move(side) then
      success = true
    else
      tries = tries + 1
      os.sleep(tries)
    end
  end
end
 
-- START
trymove(sides.top)
trymove(sides.top)
 
local function forward(l)
  local l = l
  local i = 1
  while i <= l do
    robot.swing()
    robot.swingDown()
    trymove(sides.front)
    i = i + 1
  end
end
 
local turnCount = 1
function turn()
  if turnCount == 1 then
    print("Muss mich nach Rechts drehen!")
    robot.swingDown()
    robot.turnRight()
    robot.swing()
    trymove(sides.front)
    robot.swingDown()
    robot.turnRight()
    robot.swing()
    turnCount = 2
    return true
  end
 
  if turnCount == 2 then
    print("Muss mich nach Links drehen!")
    robot.swingDown()
    robot.turnLeft()
    robot.swing()
    trymove(sides.front)
    robot.swingDown()
    robot.turnLeft()
    robot.swing()
    turnCount = 1
    return true
  end
  return false
end
 
local function back(w)
  robot.turnRight()
  local i = 1
  while i < w do
    robot.swing()
    robot.swing()
    trymove(sides.front)
    i = i + 1
  end
  robot.turnRight()
  trymove(sides.back)
  trymove(sides.back)
  trymove(sides.bottom)
  trymove(sides.bottom)
end
 
local function stock(l, w)
  turnCount = 1
  local l = l
  forward(l+2)
  turn()
  local i = 2
  while i <= w do
    forward(l)
    i = i +1
    if i <= w then
      turn()
    end
  end
  back(w)
end
 
local function drop()
  robot.turnRight()
  robot.turnRight()
  for i=1,16 do
    robot.select(i)
    robot.drop()
  end
  robot.select(1)
  robot.turnLeft()
  robot.turnLeft()
end
 
stock(lenght, width)
trymove(sides.top)
trymove(sides.top)
trymove(sides.top)
trymove(sides.top)
trymove(sides.top)
trymove(sides.top)
trymove(sides.top)
stock(lenght, width)
trymove(sides.bottom)
trymove(sides.bottom)
trymove(sides.bottom)
trymove(sides.bottom)
trymove(sides.bottom)
drop()