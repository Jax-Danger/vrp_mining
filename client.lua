--[[
Miner Job | Created by JaxDanger
This File is under fivem's escrow. If you see this, then shame on you for leaking my script.
]]--
if not vRP.modules.Jax then return print('modules.Jax doesn\'t exist.') end

-- this module define some Jax tools and functions
local Jax = class("Jax", vRP.Extension)

function Jax:__construct()
  vRP.Extension.__construct(self)

  self.miner = false

	local blip = AddBlipForCoord(2942.82, 2785.14, 39.81)
	SetBlipSprite(blip, 1)
	SetBlipColour(blip, 1)
	SetBlipScale(blip, 1.0)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Test")
	EndTextCommandSetBlipName(blip)
end






vRP:registerExtension(Jax)
