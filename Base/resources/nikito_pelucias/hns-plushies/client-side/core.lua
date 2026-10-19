-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPS = Tunnel.getInterface("vRP")
HNSserver = Tunnel.getInterface("hns-plushies")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Gemstone = 0
local currentPlushie = nil
local currentAnim = nil
local currentAnimData = nil
local currentBlocks = {}
local serverWinner = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPEN
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("hns-plushies:Open",function()
	local data = HNSserver.getData()
	if not data then 
		data = { gems = 0, price = 250 }
	end

	Gemstone = data.gems or 0
	SetNuiFocus(true, true)

	local themeData = {}
	if _G.Theme then
		themeData = {
			main = _G.Theme.main,
			common = _G.Theme.common,
			rare = _G.Theme.rare,
			epic = _G.Theme.epic,
			legendary = _G.Theme.legendary
		}
	end

	-- Filtra pelúcias ocultas (reservadas para reintegração)
	local filteredCatalog = {}
	for id, item in pairs(CollectionsCatalog or {}) do
		if not item.hidden then
			filteredCatalog[id] = item
		end
	end

	SendNUIMessage({
		action = "open",
		catalog = filteredCatalog,
		gems = Gemstone,
		price = data.price or 250,
		theme = themeData
	})

	TriggerEvent("dynamic:Close")
	TriggerEvent("hud:Active", false)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:ADDGEMSTONE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:AddGemstone")
AddEventHandler("hud:AddGemstone",function(Number)
	Gemstone = Gemstone + Number

	SendNUIMessage({ action = "updateGems", gems = Gemstone })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:REMOVEGEMSTONE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:RemoveGemstone")
AddEventHandler("hud:RemoveGemstone",function(Number)
	Gemstone = Gemstone - Number

	if Gemstone < 0 then
		Gemstone = 0
	end

	SendNUIMessage({ action = "updateGems", gems = Gemstone })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EQUIPPLUSHIE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("equipPlushie", function(data, cb)
	HNSserver.equipPlushie(data.id, data.position)
	cb("ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANIMATION THREAD
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 1000

		-- Anti-bypass: reequipa a pelúcia se ela sumir misteriosamente (ex: ao trocar de roupa ou respawnar)
		local state = LocalPlayer.state.plushie
		if state and state.id then
			if not currentPlushie or not DoesEntityExist(currentPlushie) then
				TriggerEvent("hns-plushies:attachProp", state.id, state.position)
				TimeDistance = 2000
			end
		end

		if currentAnimData then
			local Ped = PlayerPedId()
			if GetEntityHealth(Ped) > 101 then
				TimeDistance = 1

				if not IsEntityPlayingAnim(Ped, currentAnimData.dict, currentAnimData.name, 3) then
					if not IsPedRagdoll(Ped) and not IsPedClimbing(Ped) and not IsPedJumping(Ped) then
						TaskPlayAnim(Ped, currentAnimData.dict, currentAnimData.name, 8.0, 8.0, -1, currentAnimData.flag, 1, 0, 0, 0)
					end
				end

				if currentBlocks.hit then
					DisableControlAction(0, 18, true)
					DisableControlAction(0, 24, true)
					DisableControlAction(0, 25, true)
					DisableControlAction(0, 257, true)
					DisableControlAction(0, 263, true)
					DisableControlAction(0, 140, true)
					DisableControlAction(0, 141, true)
					DisableControlAction(0, 142, true)
					DisableControlAction(0, 143, true)
					DisablePlayerFiring(Ped, true)
				end

				if currentBlocks.run then
					DisableControlAction(0, 21, true)
					DisableControlAction(0, 22, true)
				end
			end
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLUSHIEATTACH
-----------------------------------------------------------------------------------------------------------------------------------------
function PlushieAttach(Dict, Anim, Prop, Flag, Bone, Pos, Rot, IsMonkey)
	local Ped = PlayerPedId()

	if DoesEntityExist(currentPlushie) then
		TriggerServerEvent("DeleteObject", NetworkGetNetworkIdFromEntity(currentPlushie))
		currentPlushie = nil
	end

	if currentAnim then
		StopAnimTask(Ped, currentAnim[1], currentAnim[2], 3.0)
		currentAnim = nil
	end

	if Dict ~= "" and Anim ~= "" then
		if LoadAnim(Dict) then
			if not IsMonkey then
				TaskPlayAnim(Ped, Dict, Anim, 8.0, 8.0, -1, Flag, 1, 0, 0, 0)
				currentAnim = { Dict, Anim }
				currentAnimData = { dict = Dict, name = Anim, flag = Flag }
			else
				currentAnimData = nil
			end
		end
	else
		currentAnimData = nil
	end

	if not IsPedInAnyVehicle(Ped) then
		local Coords = GetEntityCoords(Ped)
		
		-- CORREÇÃO AQUI: Pegamos o 'sucesso' (true) e o 'NetID' do objeto separadamente!
		local success, Networked = vRPS.CreateObject(Prop, Coords.x, Coords.y, Coords.z)
		
		-- Se não teve sucesso ou não veio o número da rede, cancela.
		if not success or not Networked or Networked == true then return end

		local Entity = LoadNetwork(Networked)
		if not Entity or not DoesEntityExist(Entity) then return end

		currentPlushie = Entity
		SetEntityLodDist(currentPlushie, 0xFFFF)
		SetEntityCollision(currentPlushie, false, false)

		local px, py, pz = 0.0, 0.0, 0.0
		local rx, ry, rz = 0.0, 0.0, 0.0

		if Pos then
			px, py, pz = Pos.x or 0.0, Pos.y or 0.0, Pos.z or 0.0
		end

		if Rot then
			rx, ry, rz = Rot.x or 0.0, Rot.y or 0.0, Rot.z or 0.0
		end

		AttachEntityToEntity(currentPlushie, Ped, GetPedBoneIndex(Ped, Bone), px, py, pz, rx, ry, rz, true, true, false, true, 1, true)

		if IsMonkey and Dict ~= "" and Anim ~= "" then
			PlayEntityAnim(currentPlushie, Anim, Dict, 1000.0, true, true, true, 0.0, false)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADNETWORK
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadNetwork(Network)
	local Timeout = GetGameTimer() + 10000
	while not NetworkDoesNetworkIdExist(Network) do
		if GetGameTimer() > Timeout then
			return false
		end

		Wait(0)
	end

	local Entitys = NetToEnt(Network)
	if not DoesEntityExist(Entitys) then
		return false
	end

	Timeout = GetGameTimer() + 10000
	NetworkRequestControlOfEntity(Entitys)
	while not NetworkHasControlOfEntity(Entitys) do
		if GetGameTimer() > Timeout then
			return false
		end

		Wait(0)
	end

	Timeout = GetGameTimer() + 10000
	SetEntityAsMissionEntity(Entitys, true, true)
	while not IsEntityAMissionEntity(Entitys) do
		if GetGameTimer() > Timeout then
			return false
		end

		Wait(0)
	end

	return Entitys
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADANIM
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadAnim(Dict)
	if not HasAnimDictLoaded(Dict) then
		RequestAnimDict(Dict)

		local Timeout = GetGameTimer() + 10000
		while not HasAnimDictLoaded(Dict) do
			if GetGameTimer() > Timeout then
				return false
			end

			Wait(0)
		end
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ATTACHPROP
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hns-plushies:attachProp")
AddEventHandler("hns-plushies:attachProp", function(plushieId, positionId)
	local ped = PlayerPedId()

	if DoesEntityExist(currentPlushie) then
		DeleteEntity(currentPlushie)
		currentPlushie = nil
	end

	if currentAnim then
		StopAnimTask(ped, currentAnim[1], currentAnim[2], 3.0)
		currentAnim = nil
	end

	if not plushieId or plushieId == "none" then
		currentAnimData = nil
		currentBlocks = {}
		return
	end

	local item = CollectionsCatalog[plushieId]
	if not item or not item.prop then return end

	currentBlocks = item.blocks or {}

	local propData = item.prop
	local posData = nil

	if positionId and propData.positions then
		for _, pos in ipairs(propData.positions) do
			if pos.id == positionId then
				posData = pos
				break
			end
		end
	else
		posData = propData
	end

	if not posData then return end

	local model = posData.model or propData.model
	if not model then return end

	local animDict = (posData.anim and posData.anim.dict) or ""
	local animName = (posData.anim and posData.anim.name) or ""
	local animFlag = (posData.anim and posData.anim.flag) or 49
	local isMonkey = (item.category == "Caquinhos")

	PlushieAttach(
		animDict, 
		animName, 
		model, 
		animFlag, 
		posData.bone, 
		posData.pos, 
		posData.rot,
		isMonkey
	)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCELPLUSHIE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hns-plushies:cancelPlushie")
AddEventHandler("hns-plushies:cancelPlushie", function()
	if currentPlushie or currentAnimData then
		HNSserver.equipPlushie("none")
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("close", function(data, cb)
	TriggerEvent("hud:Active", true)
	SetNuiFocus(false, false)
	cb("ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hns-plushies:close")
AddEventHandler("hns-plushies:close", function()
	SendNUIMessage({ action = "close" })
	SetNuiFocus(false, false)
	TriggerEvent("hud:Active", true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRANSFERPLUSHIE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("transferPlushie", function(data, cb)
	HNSserver.transferPlushie(data.id)
	cb("ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRYSPIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("trySpin", function(data, cb)
	local result = HNSserver.spinRoulette()

	if result and type(result) == "table" and result.success then
		serverWinner = result.winner
		cb(result) -- Retorna o objeto completo { success = true, winner = ... }
	else
		serverWinner = nil
		cb({ success = false })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WINNOTIFY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("winNotify", function(data, cb)
	if serverWinner then
		TriggerServerEvent("hns-plushies:winPlushie", serverWinner.id)
		TriggerEvent("Notify", "Sucesso", "Parabéns! Você ganhou uma <b>" .. serverWinner.name .. "</b>", "verde", 5000)

		serverWinner = nil
	end

	cb("ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETMYPLUSHIES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("getMyPlushies", function(data, cb)
	local plushies = HNSserver.getPlushies()
	cb(plushies or {})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETTOTALPLUSHIES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("getTotalPlushies", function(data, cb)
	local count = HNSserver.getTotalPlushies(data.id)
	cb(count or 0)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONRESOURCESTOP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStop", function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end

	if DoesEntityExist(currentPlushie) then
		DeleteEntity(currentPlushie)
		currentPlushie = nil
	end

	local ped = PlayerPedId()
	if currentAnim then
		StopAnimTask(ped, currentAnim[1], currentAnim[2], 3.0)
		currentAnim = nil
	end

	currentAnimData = nil

	SendNUIMessage({ action = "close" })
	SetNuiFocus(false, false)
end)