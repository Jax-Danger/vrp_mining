local Jax = class("Jax", vRP.Extension)
Jax.event = {}
Jax.tunnel = {}

function Jax:__construct()
  vRP.Extension.__construct(self)
end

function Jax:getID()
  local user = vRP.users_by_source[source]
  if user then
    local identity = vRP.EXT.Identity:getIdentity(user.cid)
    local fname = identity.firstname
    local lname = identity.name
    return {fname, lname}
  else
    vRP.EXT.Base.remote._notify(user.source, "You are not logged in. Please relog.")
  end
end
Jax.tunnel.getID = Jax.getID


vRP:registerExtension(Jax)
