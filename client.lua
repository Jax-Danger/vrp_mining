local MiningJob = class("MiningJob", vRP.Extension)
MiningJob.tunnel = {}

local function prepBlips(self)
  if not self.cfg or not self.cfg.blips then
    print("Error: self.cfg or self.cfg.blips is nil")
    return
  end

  for k, v in pairs(self.cfg.blips) do
    if not v.coords then
      print("Error: v.coords is nil for blip:", v.name)
      return
    end

    local x, y, z = table.unpack(v.coords)
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, v.id)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, v.size)
    SetBlipColour(blip, v.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(v.name)
    EndTextCommandSetBlipName(blip)
  end
end

function MiningJob:prepNPCs(self)
  if not self.cfg.useNPC then
    return print("NPC spawning is disabled in the configuration.")
  end

  local npc = self.cfg.NPC
  local ped = GetHashKey('s_m_m_autoshop_01')
  RequestModel(ped)
  while not HasModelLoaded(ped) do
    RequestModel(ped)
    Citizen.Wait(0)
  end

  if HasModelLoaded(ped) then
    print("Model loaded successfully.")
  else
    return print("Failed to load model.")
  end

  local npcPed = CreatePed(4, ped, npc.coords[1], npc.coords[2], npc.coords[3], npc.heading, false, true)
  if DoesEntityExist(npcPed) then
    print("NPC created successfully.")
  else
    return print("Failed to create NPC.")
  end

  SetEntityHeading(npcPed, npc.heading)
  FreezeEntityPosition(npcPed, true)
  SetEntityInvincible(npcPed, true)
  SetBlockingOfNonTemporaryEvents(npcPed, true)
end
MiningJob.tunnel.prepNPCs = MiningJob.prepNPCs

function MiningJob:__construct()
  vRP.Extension.__construct(self)
  self.cfg = module("vrp_mining", "cfg/cfg")
  prepBlips(self)
  -- Rocks mining
  Citizen.CreateThread(function()
    local isMining = false
    local targetRock = nil

    -- Thread for checking distance
    Citizen.CreateThread(function()
      while true do
        Citizen.Wait(500) -- Increased wait time to reduce frequency
        local plCoords = GetEntityCoords(GetPlayerPed(-1))
        local closestDistance = math.huge
        targetRock = nil

        for k, v in pairs(self.cfg.rocks) do
          local x, y, z = v[1], v[2], v[3]
          local distance = GetDistanceBetweenCoords(x, y, z, plCoords.x, plCoords.y, plCoords.z, true)
          if distance < closestDistance then
            closestDistance = distance
            targetRock = v
          end
        end

        if targetRock and closestDistance <= 1.5 then
          if not isMining then
            self.remote.mineRocks()
            isMining = true
          end
        elseif isMining and closestDistance > 1.5 then
          self.remote.stopMining()
          isMining = false
        end
      end
    end)

    -- Thread for drawing marker
    Citizen.CreateThread(function()
      while true do
        Citizen.Wait(0)
        if targetRock then
          local playerPed = GetPlayerPed(-1)
          local plCoords = GetEntityCoords(playerPed)
          local x, y, z = targetRock[1], targetRock[2], targetRock[3]
          local distance = GetDistanceBetweenCoords(x, y, z, plCoords.x, plCoords.y, plCoords.z, true)

          if distance <= 1.5 then
            DrawMarker(1, x, y, z-1, 0, 0, 0, 0, 0, 0, 0.75, 0.75, 0.75, 255, 0, 0, 200, 0, 0, 0, 0)
          end
        end
      end
    end)
  end)

  -- Smelting
  Citizen.CreateThread(function()
    local isSmelting = false

    -- Thread for checking distance
    Citizen.CreateThread(function()
      while true do
        Citizen.Wait(500) -- Increased wait time to reduce frequency
        local plCoords = GetEntityCoords(GetPlayerPed(-1))
        local closestDistance = math.huge

        local x, y, z = table.unpack(self.cfg.smelting.coords)
        local distance = GetDistanceBetweenCoords(x, y, z, plCoords.x, plCoords.y, plCoords.z, true)
        if distance < closestDistance then
          closestDistance = distance
        end

        if closestDistance <= 1.5 then
          if not isSmelting then
            self.remote.startSmelting()
            isSmelting = true
          end
        elseif isSmelting and closestDistance > 1.5 then
          self.remote.stopSmelting()
          isSmelting = false
        end
      end
    end)

    -- Thread for drawing marker
    Citizen.CreateThread(function()
      while true do
        Citizen.Wait(0)
        local playerPed = GetPlayerPed(-1)
        local plCoords = GetEntityCoords(playerPed)
        local x, y, z = table.unpack(self.cfg.smelting.coords)
        local distance = GetDistanceBetweenCoords(x, y, z, plCoords.x, plCoords.y, plCoords.z, true)

        if distance <= 1.5 then
          DrawMarker(1, x, y, z-1, 0, 0, 0, 0, 0, 0, 0.75, 0.75, 0.75, 255, 0, 0, 200, 0, 0, 0, 0)
        end
      end
    end)
  end)
end

vRP:registerExtension(MiningJob)
