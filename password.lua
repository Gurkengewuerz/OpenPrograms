--[[	
	Author: Gurkengewuerz
]]--

-- Edit /home/.shrc for a autorun 
local component = require("component")
local computer = require("computer")
local shell = require("shell")
local event = require("event")
local text = require("text")
local term = require("term")
 
local password = "password"
local right = false
local greetings = "Willkommen zurück\nOpen OS wurde erfolgreich geladen"
 
while (right == false) do
  term.clear()
  print("Bitte Kennwort eingeben: ")
  local pw = string.gsub(term.read(nil, true, nil, "*"), "\n", "")
  if pw==password then
    term.clear()
    right = true
    print("Kennwort richtig. Starte Terminal...")
    for i=0,101 do
      local asciibar = ""
      for j=0,i do
        asciibar = asciibar .. "¦"      
      end
      term.clear()
      print(asciibar .. "        " .. i .. "%")
      os.sleep(math.random(0, 1) / 10)
    end
    term.clear()
    print(greetings)
  else
    computer.shutdown(true)
  end
end