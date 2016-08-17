local component = require("component")
--[[
	remote control for the powercontrol
	
	Author: Gurkengewuerz
]]--

local term = require("term")
local computer = require("computer")
local fs = require("filesystem")
local colors = require("colors")
local side = require("sides")
local event = require("event")
local gpu = component.gpu
local serial = require("serialization")

if not component.isAvailable("modem") then
  print("Keine Modem gefunden")
  return
end

local port = 8081
local broadcastPort = 8082
local password = "thetown"

local modem = component.modem

modem.open(broadcastPort)
io.write("Warte auf Daten...")
local _, localNetworkCard, remoteAddress, port, distance, payload = event.pull("modem_message")

function changeStatus(id)
  modem.broadcast(8081, password, 1)
  print("Status gesendet für " .. id)
end

if(port == broadcastPort) then
  io.write(" Daten empfangen. Starte...\n")
  os.sleep(1)
  local out = serial.unserialize(payload)
  term.clear()
  for count=1,#out do
    io.write(count .. ") " .. out[count]["name"])
    local textAk = "AUS"
    if(out[count]["status"]) then
      textAk = "EIN"
    end
    io.write("   " .. textAk .. "\n")
  end
    io.write("#OutputID:  ")
    local id = tonumber(io.read())
    if (id > #out) then
      print("Dieser Output ist mir unbekannt")
      os.sleep(3)
      return
    end
  changeStatus(id)
end