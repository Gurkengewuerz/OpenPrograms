--[[
	A output bundled cable Output Controller
	
	This program controls bundled Redstone
	The Output is defined in the "out" lua table
	If there is a modem available the program creates automatic a socket for communication
	
	Author: Gurkengewuerz
]]--

local component = require("component")
local term = require("term")
local computer = require("computer")
local fs = require("filesystem")
local colors = require("colors")
local side = require("sides")
local event = require("event")
local gpu = component.gpu
local serial = require("serialization")

if not component.isAvailable("redstone") then
  print("Keine Redstone Karte gefunden")
  return
end

-- Config
local scale = 3             -- Bildschirm Größe
local socketCon = true      -- Aktiviert die Socket Connection (Kummunikation über Modem, falls verfügbar)
local port = 8081           -- Socket Port, auf dem gelauscht werden soll
local broadcastPort = 8082	-- Socket port, auf dem der Status automatisch gebroadcastet wird
local pass = "thetown"      -- Socket Passwort, welches immer mitgesendet werden muss
local min = 20              -- Bis wie viel Prozent die Automatische Steuerung den Output an lässt
local timeout = 95          -- Falls die Prozent Anzahl Min unterschritten hat wird erst wieder nach TIMEOUT Prozent angeschaltet
local outSide = side.east   -- Output Seite des Redstone
local out = {               -- Outputs definieren "Name, Bundled Cable Color, Automatisch (Ja, Nein) 
  {name="Kohle Generatoren", color=0, auto=false, status=false},
  {name="Windpark", color=1, auto=false, status=false},
  {name="Ender Quarry", color=2, auto=false, status=false},
  {name="The Last Millenium", color=3, auto=false, status=false},
  {name="Teleporter", color=4, auto=false, status=false},
  {name="Mond", color=5, auto=false, status=false},
  {name="Mars", color=6, auto=false, status=false},
  {name="AUTO: Verfünffachung", color=7, auto=true, status=false},
  {name="Laserdrill", color=8, auto=false, status=false},
  {name="Reaktor Laser", color=9, auto=false, status=false}
}

local rs = component.redstone
local modem = component.modem

local function readCapacity(proxy, ltype)
  capacity = 0
   
  if ltype == 1 then --For IC2
    capacity = proxy.getCapacity()
  end
   
  if ltype == 2 then --For TE and older mek blocks
    capacity = proxy.getMaxEnergyStored()
  end

  if ltype == 3 then --For newer mekanism blocks
    capacity = proxy.getMaxEnergy()
  end

  return capacity
end

local function readStored(proxy, ltype)
  stored = 0
   
  if ltype == 1 then
    stored = proxy.getStored()
  end
   
  if ltype == 2 then
    stored = proxy.getEnergyStored()
  end

  if ltype == 3 then
    stored = proxy.getStored()
  end

  return stored
end

local function getPercent(proxy, ltype)
  return (readStored(proxy, ltype) / readCapacity(proxy, ltype)) * 100
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function automatic(MinOrHigher)
  for count=1,#out do
    if(out[count]["auto"] == true) then
      if(MinOrHigher) then
        rs.setBundledOutput(outSide, out[count]["color"], 9999)
      else
        rs.setBundledOutput(outSide, out[count]["color"], 0)
      end
    end
  end
end

function socketMsg(message)
  changeStatus(message)
end

local loop = true
local setup = false
function handleEvent(eventID, ...)
  local arg = {...}
  if (eventID) then
    if(eventID == "interrupted") then
      loop = false
    end

    if(eventID == "key_up") then
      if(arg[3] == 57) then
        setup = true
      end
    end

	if socketCon then
      if(eventID == "modem_message") then
		if not (arg[2] == modem.adress) then
          if(arg[3] == port) then
            if(tablelength(arg) >= 5) then
			  local socketArgs = {}
			  for i=5,#arg do
				table.insert(socketArgs, arg[i])
			  end
              if(tablelength(socketArgs) >= 2) then
                if(socketArgs[1] == pass) then
                  socketMsg(socketArgs[2])
                end
              end
            end
          end
		end
      end
	end
  end
end

if not (component.modem == nil) and socketCon then
  modem.open(port)
  event.listen("modem_message", handleEvent)  
end

event.listen("key_up", handleEvent)
event.listen("interrupted", handleEvent)

w, h = gpu.maxResolution()
gpu.setResolution(w / scale, h / scale)

function changeStatus(id)
  if (id < #out) then
    if (rs.getBundledOutput(outSide, out[id]["color"]) > 0) then
      rs.setBundledOutput(outSide, out[id]["color"], 0)
      print("Schalte Output " .. id .. " aus")
    else
      rs.setBundledOutput(outSide, out[id]["color"], 9999)
      print("Schalte Output " .. id .. " ein")
    end
  end
end

function updateStatus()
  for count=1,#out do
    if (rs.getBundledOutput(outSide, out[count]["color"]) > 0) then
	  out[count]["status"] = true
    end
  end
  
  if not (component.modem == nil) and socketCon then
	modem.broadcast(broadcastPort, serial.serialize(out))
  end
end

local hitLow = false
while loop do
  updateStatus()
  term.clear()
  local perc = getPercent(component.capacitor_bank, 2)
  print("Aktueller Batterie Status: " .. perc .. "%")
  print("")
  for count=1,#out do
    print(count .. ") " .. out[count]["name"])
  end
  
  if(perc > min) then
    if not hitLow or perc >= timeout then
      automatic(true)
      hitLow = false
    end
  else
    automatic(false)
    hitLow = true
  end

  print("    Leertaste drücken zur Eingabe")
  if setup then
    print("")
    term.write("#OutputID:  ")
    local id = tonumber(io.read())
    if (id > #out) then
      print("Dieser Output ist mir unbekannt")
      os.sleep(5)
      return
    end
	changeStatus(id)
    setup = false
  end
  os.sleep(2)
end