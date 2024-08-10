local MiningJob = class("MiningJob", vRP.Extension)
MiningJob.event = {}
MiningJob.tunnel = {}

local function mineRock(self)
  local user = vRP.users_by_source[source]
  if user then
    local itemType = "rock"
    local chanceConfig = self.cfg.chances[itemType]

    if chanceConfig then
      local randomNumber = math.random(chanceConfig.min, chanceConfig.max)
      user:tryGiveItem(itemType, randomNumber, false, false)
      vRP.EXT.Base.remote._notify(user.source, "You've gathered some " .. itemType .. ".")
    else
      vRP.EXT.Base.remote._notify(user.source, "Invalid item type.")
    end
  end
end

function MiningJob:mineRocks()
  local user = vRP.users_by_source[source]
  if user then
    return user:openMenu('rockquarry')
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

function MiningJob:__construct()
  vRP.Extension.__construct(self)
  self.cfg = module("vrp_mining", "cfg/cfg")

  vRP.EXT.GUI:registerMenuBuilder('rockquarry', function(menu)
    menu.title = "Rock Quarry"
    menu.css = {top = "75px", header_color = "rgba(0,125,255,0.75)"}

    menu:addOption('Mine Rock', function(player)
      return mineRock(self)
    end)
  end)
end


vRP:registerExtension(MiningJob)
