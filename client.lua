local MiningJob = class("MiningJob", vRP.Extension)

local function prepBlips(self)
  for k,v in pairs(self.cfg.blips) do
    local blip = AddBlipForCoord(v.coords[1], v.coords[2], v.coords[3])
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

function MiningJob:__construct()
  vRP.Extension.__construct(self)
  self.cfg = module("vrp_mining", "cfg/cfg")
  prepBlips(self)

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
        Citizen.Wait(0) -- Run every frame
        if targetRock then
          local playerPed = GetPlayerPed(-1)
          local plCoords = GetEntityCoords(playerPed)
          local x, y, z = targetRock[1], targetRock[2], targetRock[3]
          local distance = GetDistanceBetweenCoords(x, y, z, plCoords.x, plCoords.y, plCoords.z, true)

          if distance <= 2.5 then
            DrawMarker(1, x, y, z-1, 0, 0, 0, 0, 0, 0, 0.75, 0.75, 0.75, 255, 0, 0, 200, 0, 0, 0, 0)
          end
        end
      end
    end)
  end)
end

vRP:registerExtension(MiningJob)
