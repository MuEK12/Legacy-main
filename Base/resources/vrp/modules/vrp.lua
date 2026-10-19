-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
Proxy = module("lib/Proxy")
Tunnel = module("lib/Tunnel")
vRPC = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vRP = {}
tvRP = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- TUNNER/PROXY
-----------------------------------------------------------------------------------------------------------------------------------------
Proxy.addInterface("vRP",vRP)
Tunnel.bindInterface("vRP",tvRP)
DEVICE = Tunnel.getInterface("device")
REQUEST = Tunnel.getInterface("request")
TASKBAR = Tunnel.getInterface("taskbar")
SURVIVAL = Tunnel.getInterface("survival")
KEYBOARD = Tunnel.getInterface("keyboard")
LETTERGAME = Tunnel.getInterface("lettergame")
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSERVERSTART
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	SetMapName(ServerName)
	SetGameType(ServerName)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLEARINVENTORY
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.ClearInventory(Passport,Ignore)
	local Passport = parseInt(Passport)
	local Inventory = vRP.Inventory(Passport)

	exports.inventory:CleanWeapons(Passport)
	TriggerEvent("DebugWeapons",Passport)
	TriggerEvent("DebugObjects",Passport)

	for _,v in pairs(Inventory) do
		if not exports.vrp:BlockDelete(v.item) then
			vRP.RemoveItem(Passport,v.item,v.amount)
		end
	end

	if not Ignore then
		local Weight = 50
		for Permission,Multiplier in pairs({ Ouro = 25, Prata = 15, Bronze = 5 }) do
			if vRP.HasService(Passport,Permission) then
				Weight = Weight - Multiplier
			end
		end

		if Weight > 0 then
			vRP.UpgradeWeight(Passport,Weight,"-")
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PHONE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Phone(Passport)
	return "Inativo"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLEANPHONE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.CleanPhone(Passport)
	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP.REQUEST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Request(source,Title,Message)
	return REQUEST.Function(source,Title,Message)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP.REVIVE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Revive(source,Health,Arena)
	return SURVIVAL.Revive(source,Health,Arena)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP.TASK
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Task(source,Amount,Speed)
	return TASKBAR.Task(source,Amount,Speed)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP.DEVICE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Device(source,Seconds)
    return DEVICE.Device(source,Seconds)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP.LETTERGAME
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.LetterGame(source,Duration,Speed)
    return LETTERGAME.LetterGame(source,Duration,Speed)
end
------------------------------------------------------------------------------------------------------------------------------------------
-- VRP.CHECKVEHICLEKEY
------------------------------------------------------------------------------------------------------------------------------------------
function vRP.CheckVehicleKey(Passport,Plate)
	local Passport = parseInt(Passport)
	if not Passport or not Plate then
		return false
	end

	local Inventory = vRP.Inventory(Passport)
	local Damaged = false

	for _,v in pairs(Inventory) do
		local Split = splitString(v.item,"-")
		if Split[1] == "vehiclekey" and Split[3] == Plate then
			if not vRP.CheckDamaged(v.item) then
				return true
			end

			Damaged = true
		end
	end

	return Damaged and "Damaged" or false
end
------------------------------------------------------------------------------------------------------------------------------------------
-- TVRP.CHECKVEHICLEKEY
------------------------------------------------------------------------------------------------------------------------------------------
function tvRP.CheckVehicleKey(Plate)
	local source = source
	local Passport = vRP.Passport(source)
	if not Passport then
		return false
	end

	return vRP.CheckVehicleKey(Passport,Plate)
end