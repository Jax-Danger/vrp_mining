local MiningJob = class("MiningJob", vRP.Extension)
MiningJob.tunnel = {}

-- Mining
local function mineRock(self)
  local user = vRP.users_by_source[source]
  if user then
    local itemType = "rock"
    local smeltingConfig = self.cfg.smelting

    if smeltingConfig then
      for _, item in ipairs(smeltingConfig) do
        if item.input == itemType then
          local randomNumber = math.random(item.inamount, item.outamount)
          user:tryGiveItem(item.output, randomNumber, false, false)
          vRP.EXT.Base.remote._notify(user.source, "You've gathered some " .. item.output .. ".")
          return
        end
      end
      vRP.EXT.Base.remote._notify(user.source, "Invalid item type.")
    else
      vRP.EXT.Base.remote._notify(user.source, "Smelting configuration not found.")
    end
  end
end
function MiningJob:mineRocks()
  local user = vRP.users_by_source[source]
  local group = vRP.EXT.Group:getUsersByGroup("miner")
  for k, v in pairs(group) do
    if v.source == source then
      return user:openMenu("rockquarry")
    else
      return vRP.EXT.Base.remote._notify(source, "You must be a miner to mine rocks.")
    end
  end
end
MiningJob.tunnel.mineRocks = MiningJob.mineRocks
function MiningJob:stopMining()
  local user = vRP.users_by_source[source]
  if user then
    return user:closeMenus()
  end
end
MiningJob.tunnel.stopMining = MiningJob.stopMining

-- Smelting/ Processing Ores
function MiningJob:startSmelting()
  print("called.")
  local user = vRP.users_by_source[source]
  local group = vRP.EXT.Group:getUsersByGroup("miner")
  for k, v in pairs(group) do
    if v.source == source then
      return user:openMenu("smelting")
    else
      return vRP.EXT.Base.remote._notify(user.source, "You must be a miner to smelt ores.")
    end
  end
end
MiningJob.tunnel.startSmelting = MiningJob.startSmelting
local function SmeltOres(self)
  local user = vRP.users_by_source[source]
  if user then
    local hasOres = false
    for _, smelt in ipairs(self.cfg.smelting) do
      if user:getItemAmount(smelt.input) > 0 then
        hasOres = true
        break
      end
    end

    if hasOres then
      for _, smelt in ipairs(self.cfg.smelting) do
        local oreAmount = user:getItemAmount(smelt.input)
        if oreAmount > 0 then
          local bars = math.floor(oreAmount / smelt.inamount)
          user:tryTakeItem(smelt.input, oreAmount, false, false)
          user:tryGiveItem(smelt.output, bars * smelt.outamount, false, false)
        end
      end
      vRP.EXT.Base.remote._notify(user.source, "You've smelted your ores.")
    else
      vRP.EXT.Base.remote._notify(user.source, "You don't have any ores to smelt.")
    end
  end
end
function MiningJob:stopSmelting()
  print("called.")
  local user = vRP.users_by_source[source]
  if user then
    return user:closeMenus()
  end
end
MiningJob.tunnel.stopSmelting = MiningJob.stopSmelting

function MiningJob:__construct()
  vRP.Extension.__construct(self)
  self.cfg = module("vrp_mining", "cfg/cfg")
  self.remote.prepNPCs(self)
  vRP.EXT.GUI:registerMenuBuilder(
    "rockquarry",
    function(menu)
      menu.title = "Rock Quarry"
      menu.css = {top = "75px", header_color = "rgba(0,125,255,0.75)"}

      menu:addOption(
        "Mine Rock",
        function(player)
          return mineRock(self)
        end
      )
    end
  )

  vRP.EXT.GUI:registerMenuBuilder(
    "smelting",
    function(menu)
      menu.title = "Processing..."
      menu.css = {top = "75px", height = "100px", header_color = "rgba(0,125,255,0.75)"}

      menu:addOption(
        "Process Ore(s)",
        function(player)
          return SmeltOres(self)
        end
      )
    end
  )
end

vRP:registerExtension(MiningJob)
