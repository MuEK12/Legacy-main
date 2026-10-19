-----------------------------------------------------------------------------------------------------------------------------------------
-- SELECTVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.SelectVehicle(Passport,Name)
	return vRP.SingleQuery("vehicles/selectVehicles",{ Passport = Passport, Vehicle = Name })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCKVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.LockVehicle(Source,Network)
	local Entitys = NetworkGetEntityFromNetworkId(Network)
	if not DoesEntityExist(Entitys) or GetEntityType(Entitys) ~= 2 then
		return false
	end

	local DoorStatus = tonumber(GetVehicleDoorLockStatus(Entitys)) or 0
	local Mode

	local Coords = GetEntityCoords(Entitys)

	if DoorStatus <= 1 then
		TriggerClientEvent("Notify:Lock",Source,"locked")
		TriggerClientEvent("sounds:playSoundDistance",-1,"locked","locked",0.5,false,Coords,5)
		SetVehicleDoorsLocked(Entitys,2)
		Mode = "locked"
	else
		TriggerClientEvent("Notify:Lock",Source,"unlocked")
		TriggerClientEvent("sounds:playSoundDistance",-1,"unlocked","unlocked",0.5,false,Coords,5)
		SetVehicleDoorsLocked(Entitys,1)
		Mode = "unlocked"
	end

	if not vRP.InsideVehicle(Source) then
		vRPC.playAnim(Source,true,{"anim@mp_player_intmenu@key_fob@","fob_click_fp"},false)

		CreateThread(function()
			Wait(350)
			vRPC.stopAnim(Source)
		end)
	end

	return Mode
end