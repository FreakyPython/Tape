-- Improved TapeWriter for ComputerCraft in Tekkit 2
local tape = peripheral.find("tape_drive")
term.clear()
term.setCursorPos(1, 1)

-- Check for Tape Drive
if tape == nil then
  print("No Tape Drive found!!")
  return
end

-- Check if HTTP API is enabled
if not http then
  print("HTTP API is disabled on this server!")
  print("Ask your server admin to enable it.")
  return
end

print("TapeWriter v2.0 for Revelation")
print("Let's add some music!")

-- Function to write a track to the tape
local function writeTrack(url)
  -- Validate URL
  if not url:match("%.dfpwm$") then
    print("Warning: URL should point to a .dfpwm file!")
    print("Proceed anyway? (y/n)")
    if read():lower() ~= "y" then
      return false
    end
  end

  -- Download the track
  print("Downloading from: " .. url)
  local response = http.get(url, nil, true)
  if not response then
    print("Failed to download! Check the URL or server settings.")
    return false
  end

  -- Get file size for progress (if available)
  local totalSize = response.getResponseHeaders()["Content-Length"]
  totalSize = totalSize and tonumber(totalSize) or nil
  local downloaded = 0
  local chunkSize = 1024 -- Read in chunks to avoid memory issues

  -- Seek to the end of the tape to append
  tape.seek(-tape.getPosition()) -- Start of tape
  tape.seek(tape.getSize()) -- Move to end for appending

  -- Write in chunks with progress
  while true do
    local chunk = response.read(chunkSize)
    if not chunk then break end
    tape.write(chunk)
    downloaded = downloaded + #chunk
    if totalSize then
      print("Progress: " .. math.floor(downloaded / totalSize * 100) .. "%")
    end
  end
  response.close()
  print("Track added successfully!")
  return true
end

-- Function to play the tape
local function playTape()
  print("Play the tape now? (y/n)")
  if read():lower() == "y" then
    tape.seek(-tape.getPosition()) -- Rewind
    tape.play()
    print("Playing... Press Ctrl+T to stop.")
    os.pullEvent("terminate") -- Wait for user to stop
    tape.stop()
  end
end

-- Main loop to add multiple tracks
while true do
  print("Current tape position: " .. tape.getPosition() .. "/" .. tape.getSize() .. " bytes")
  if tape.getPosition() >= tape.getSize() then
    print("Tape is full! Insert a new tape or restart.")
    break
  end

  write("Enter URL (or 'done' to finish): ")
  local url = read()
  if url:lower() == "done" then break end

  if writeTrack(url) then
    playTape()
  end

  print("Add another track? (y/n)")
  if read():lower() ~= "y" then break end
end

-- Label the tape
print("Got a name for this tape?")
write("Name: ")
local name = read()
if name ~= "" then
  tape.setLabel(name)
  print("Tape labeled as: " .. name)
end

print("All done! Press Ctrl+T to exit.")