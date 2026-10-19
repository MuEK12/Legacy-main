-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local LastVehicle = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAFEZONES
-----------------------------------------------------------------------------------------------------------------------------------------
local SafeZones = {
	PolyZone:Create({
		vec2(129.4407043457,-993.74652099609),
		vec2(152.42665100098,-1001.5345458984),
		vec2(155.37255859375,-1008.0953369141),
		vec2(162.08224487305,-1010.5667114258),
		vec2(205.3254699707,-1025.1632080078),
		vec2(208.05278015137,-1025.9981689453),
		vec2(210.56558227539,-1025.3786621094),
		vec2(212.85954284668,-1023.5993041992),
		vec2(213.87251281738,-1021.9645996094),
		vec2(219.81781005859,-1005.3919677734),
		vec2(266.17633056641,-877.15301513672),
		vec2(266.81530761719,-873.68963623047),
		vec2(266.83895874023,-871.85736083984),
		vec2(266.28128051758,-869.68176269531),
		vec2(264.34539794922,-867.49523925781),
		vec2(262.51568603516,-865.53735351562),
		vec2(259.97180175781,-864.49664306641),
		vec2(254.1240234375,-862.248046875),
		vec2(251.51641845703,-861.91809082031),
		vec2(248.99926757812,-863.26678466797),
		vec2(246.76164245605,-863.31756591797),
		vec2(196.50503540039,-844.85803222656),
		vec2(195.27763366699,-843.50659179688),
		vec2(193.31602478027,-840.45379638672),
		vec2(191.82531738281,-839.31677246094),
		vec2(189.96673583984,-839.2109375),
		vec2(187.88198852539,-839.19830322266),
		vec2(185.60710144043,-840.34234619141),
		vec2(183.95611572266,-841.72863769531),
		vec2(182.82550048828,-843.45465087891),
		vec2(176.67687988281,-860.99725341797),
		vec2(173.51698303223,-868.55120849609),
		vec2(171.23924255371,-873.716796875),
		vec2(168.84397888184,-878.16345214844),
		vec2(166.66683959961,-880.75463867188),
		vec2(164.33799743652,-883.72521972656),
		vec2(162.3219909668,-886.86224365234),
		vec2(160.86120605469,-889.27026367188),
		vec2(159.67761230469,-892.3896484375),
		vec2(128.00598144531,-979.52691650391),
		vec2(125.66033172607,-985.53704833984),
		vec2(125.26899719238,-987.44702148438),
		vec2(125.52068328857,-989.23315429688),
		vec2(125.93435668945,-990.50799560547),
		vec2(126.73490142822,-991.96746826172),
		vec2(128.0207824707,-993.26556396484),
		vec2(129.71951293945,-994.04571533203)
	},{ name = "Praça" }),
	PolyZone:Create({
		vec2(-70.361297607422,-1117.5511474609),
		vec2(-68.405029296875,-1111.1518554688),
		vec2(-64.618217468262,-1101.5891113281),
		vec2(-53.452548980713,-1070.0823974609),
		vec2(-22.061050415039,-1081.5045166016),
		vec2(-19.563009262085,-1075.0866699219),
		vec2(-1.5884290933609,-1081.6328125),
		vec2(-14.746128082275,-1117.5534667969),
		vec2(-15.398586273193,-1120.1049804688),
		vec2(-28.848789215088,-1120.9742431641),
		vec2(-39.36120223999,-1121.0072021484),
		vec2(-64.73316192627,-1122.3962402344)
	},{ name = "Concessíonaria" }),
	PolyZone:Create({
		vec2(5588.77,13887.28),
		vec2(5477.89,13777.98),
		vec2(5383.17,13902.15),
		vec2(5480.4,13984.92)
	},{ name = "Banned", minZ = 8.99, maxZ = 33.99 })
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local Inside = false
		local Ped = PlayerPedId()
		local Coords = GetEntityCoords(Ped)

		for _,Poly in ipairs(SafeZones) do
			if Poly:isPointInside(Coords) then
				Inside = Poly.name
				break
			end
		end

		local SafeState = LocalPlayer.state.Safezone
		if Inside and not SafeState then
			LocalPlayer.state:set("Safezone",Inside,true)
			NetworkSetFriendlyFireOption(false)
			SetEntityInvincible(Ped,true)
			SetLocalPlayerAsGhost(true)

			if IsPedArmed(Ped,7) then
				TriggerEvent("inventory:CleanWeapons")
			end
		elseif not Inside and SafeState then
			SetLocalPlayerAsGhost(false)
			SetEntityInvincible(Ped,false)
			NetworkSetFriendlyFireOption(true)
			LocalPlayer.state:set("Safezone",false,true)
		end

		Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADZONE
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 999
		local Ped = PlayerPedId()

		if LocalPlayer.state.Safezone then
			TimeDistance = 0

			DisableControlAction(0,24,true)
			DisableControlAction(0,25,true)
			DisableControlAction(0,68,true)
			DisableControlAction(0,69,true)
			DisableControlAction(0,70,true)
			DisableControlAction(0,91,true)
			DisableControlAction(0,92,true)
			DisableControlAction(0,140,true)
			DisableControlAction(0,142,true)
			DisableControlAction(0,257,true)
			DisablePlayerFiring(Ped,true)

			local Vehicle = GetVehiclePedIsIn(Ped)
			if Vehicle > 0 then
				if LastVehicle ~= Vehicle then
					if LastVehicle and DoesEntityExist(LastVehicle) then
						SetNetworkVehicleAsGhost(LastVehicle,false)
					end

					LastVehicle = Vehicle
					SetNetworkVehicleAsGhost(Vehicle,true)
				end
			elseif LastVehicle then
				if DoesEntityExist(LastVehicle) then
					SetNetworkVehicleAsGhost(LastVehicle,false)
				end

				LastVehicle = nil
			end
		elseif LastVehicle then
			if DoesEntityExist(LastVehicle) then
				SetNetworkVehicleAsGhost(LastVehicle,false)
			end

			LastVehicle = nil
		end

		Wait(TimeDistance)
	end
end)