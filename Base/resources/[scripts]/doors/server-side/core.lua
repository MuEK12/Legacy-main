-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Creative = {}
Tunnel.bindInterface("doors",Creative)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DOORS
-----------------------------------------------------------------------------------------------------------------------------------------
local Doors = {
	-- Boolingbroke
	["1"] = { Coords = vec3(1844.99,2604.81,44.63), Hash = 741314661, Disabled = false, Lock = true, Distance = 7.0, Permission = "Emergencia" },
	["2"] = { Coords = vec3(1818.54,2604.40,44.61), Hash = 741314661, Disabled = false, Lock = true, Distance = 7.0, Permission = "Emergencia" }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Permission(Number)
	local source = source
	local Passport = vRP.Passport(source)

	if not Passport then
		return false
	end

	if Doors[Number] and Doors[Number].Permission and not vRP.HasGroup(Passport,Doors[Number].Permission) then
		return false
	end

	Doors[Number].Lock = not Doors[Number].Lock

	local Other = Doors[Number].Other
	if Other and Doors[Other] then
		Doors[Other].Lock = not Doors[Other].Lock
	end

	TriggerClientEvent("doors:Sync",-1,Number,Doors[Number].Lock,Other)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Connect",function(Passport,source)
	TriggerClientEvent("doors:Connect",source,Doors)
end)