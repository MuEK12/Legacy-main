-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
HNS = {}
Tunnel.bindInterface("hns-plushies",HNS)
vKEYBOARD = Tunnel.getInterface("keyboard")
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREPARES
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.Prepare("plushies/AddPlushie","INSERT INTO hns_plushies (Passport,Plushie) VALUES (@Passport,@Plushie)")
vRP.Prepare("plushies/GetPlushies","SELECT * FROM hns_plushies WHERE Passport = @Passport")
vRP.Prepare("plushies/GetTotalPlushies","SELECT COUNT(*) as amount FROM hns_plushies WHERE Plushie = @Plushie")
vRP.Prepare("plushies/RemPlushie","DELETE FROM hns_plushies WHERE Passport = @Passport AND Plushie = @Plushie LIMIT 1")
vRP.Prepare("plushies/TransferPlushie","UPDATE hns_plushies SET Passport = @toPassport WHERE id = @id AND Passport = @fromPassport")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local Actived = {}
local PendingWinners = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- WINPLUSHIE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("hns-plushies:winPlushie")
AddEventHandler("hns-plushies:winPlushie",function(Plushie)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Actived[Passport] then
		if PendingWinners[Passport] and PendingWinners[Passport] == Plushie then
			vRP.Query("plushies/AddPlushie",{ Passport = Passport, Plushie = Plushie })
			PendingWinners[Passport] = nil
		else
			print("^1[HNS-PLUSHIES] Jogador "..Passport.." tentou ganhar um item não sorteado: "..tostring(Plushie).."^7")
		end

		Actived[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETPLUSHIES
-----------------------------------------------------------------------------------------------------------------------------------------
function HNS.getPlushies()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		local Consult = vRP.Query("plushies/GetPlushies",{ Passport = Passport })
		return Consult
	end

	return {}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETTOTALPLUSHIES
-----------------------------------------------------------------------------------------------------------------------------------------
function HNS.getTotalPlushies(plushieId)
	local consult = vRP.Query("plushies/GetTotalPlushies", { Plushie = plushieId })
	if consult and consult[1] then
		return consult[1].amount or 0
	end

	return 0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DATA
-----------------------------------------------------------------------------------------------------------------------------------------
function HNS.getData()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		local Identity = vRP.Identity(Passport)
		if Identity then
			return {
				gems = vRP.UserGemstone(Identity.License) or 0,
				price = (Config and Config.RoulettePrice) or 250
			}
		end
	end

	return { gems = 0, price = 250 }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPINROULETTE
-----------------------------------------------------------------------------------------------------------------------------------------
function HNS.spinRoulette()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Actived[Passport] then
		local price = (Config and Config.RoulettePrice) or 250
		
		if vRP.PaymentGems(Passport, price) then
			Actived[Passport] = true

			local rand = math.random(100)
			local chosenRarity = "common"
			local currentPercent = 0

			local rates = (Config and Config.RarityRates) or {
				["common"] = 70,
				["rare"] = 20,
				["epic"] = 8,
				["legendary"] = 2
			}

			local rarities = { "legendary", "epic", "rare", "common" }
			for _, rarity in ipairs(rarities) do
				local chance = rates[rarity] or 0
				if rand <= (currentPercent + chance) then
					chosenRarity = rarity
					break
				end

				currentPercent = currentPercent + chance
			end

			local possibleItems = {}
			local catalog = CollectionsCatalog or {}
			for id, item in pairs(catalog) do
				if (item.rarity or "common") == chosenRarity and not item.hidden then
					table.insert(possibleItems, id)
				end
			end

			if #possibleItems == 0 then
				for id, item in pairs(catalog) do
					if not item.hidden then
						table.insert(possibleItems, id)
					end
				end
			end

			local winnerId = possibleItems[math.random(#possibleItems)]
			local winnerData = catalog[winnerId]

			if winnerData then
				PendingWinners[Passport] = winnerId

				return {
					success = true,
					winner = {
						id = winnerId,
						name = winnerData.name,
						rarity = winnerData.rarity or "common"
					}
				}
			end
		end
	end

	return { success = false }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EQUIPPLUSHIE
-----------------------------------------------------------------------------------------------------------------------------------------
function HNS.equipPlushie(plushieId, position)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		-- Verificação de Reintegração
		local rData = vRP.GetServerData("Reintegracao:"..Passport)
		local expireTime = 0
		if type(rData) ~= "table" then expireTime = tonumber(rData) or 0 end
		if os.time() < expireTime then
			TriggerClientEvent("Notify", source, "Aviso", "Você está em período de reintegração e não pode remover a pelúcia!", "amarelo", 5000)
			return
		end

		if plushieId == "none" then
			Player(source).state:set("plushie", nil, true)
			Player(source).state:set("plushieEquipped", false, true)
			TriggerClientEvent("hns-plushies:attachProp", source, nil)
			TriggerClientEvent("Notify", source, "Sucesso", "Você desequipou a pelúcia!", "verde", 5000)
		else
			local plushieData = CollectionsCatalog[plushieId]
			if plushieData and plushieData.hidden then
				TriggerClientEvent("Notify", source, "Negado", "Esta pelúcia não pode ser equipada.", "vermelho", 5000)
				return
			end
			if plushieData then
				Player(source).state:set("plushie", {
					id = plushieId,
					position = position,
					bonus = Config.Bonification and plushieData.bonus or nil
				}, true)

				Player(source).state:set("plushieEquipped", true, true)
			end
			
			TriggerClientEvent("hns-plushies:attachProp", source, plushieId, position)
			TriggerClientEvent("Notify", source, "Sucesso", "Você equipou a pelúcia!", "verde", 5000)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONRESOURCESTOP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStop", function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end

	local players = GetPlayers()
	for _, source in ipairs(players) do
		Player(source).state:set("plushie", nil, true)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPORTS
-----------------------------------------------------------------------------------------------------------------------------------------
exports("getPlushieBonus", function(source, bonusType)
	if not Config.Bonification then return 0 end

	local state = Player(source).state.plushie
	if state and state.bonus and state.bonus[bonusType] then
		return state.bonus[bonusType]
	end

	return 0
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRANSFERPLUSHIE
-----------------------------------------------------------------------------------------------------------------------------------------
function HNS.transferPlushie(plushieId)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		local Keyboard = vKEYBOARD.Primary(source, "Passaporte")
		if Keyboard then
			local otherPassport = parseInt(Keyboard[1])
			if otherPassport > 0 and otherPassport ~= Passport then
				local otherSource = vRP.Source(otherPassport)
				if otherSource then
					local identity = vRP.Identity(Passport)
					local otherIdentity = vRP.Identity(otherPassport)
					
					if identity and otherIdentity then
						local senderName = (identity.name or identity.Name or "Desconhecido") .. " " .. (identity.name2 or identity.Lastname or "")
						if vRP.Request(otherSource, "Transferência de Pelúcia", "Você deseja aceitar a pelúcia de <b>" .. senderName .. "</b>?") then
							local consult = vRP.Query("plushies/TransferPlushie", { 
								id = plushieId, 
								toPassport = otherPassport, 
								fromPassport = Passport 
							})
							
							if consult then
								TriggerClientEvent("Notify", source, "Sucesso", "Pelúcia transferida com sucesso!", "verde", 5000)
								TriggerClientEvent("Notify", otherSource, "Sucesso", "Você recebeu uma nova pelúcia!", "verde", 5000)
								TriggerClientEvent("hns-plushies:close", source)
							else
								TriggerClientEvent("Notify", source, "Erro", "Não foi possível transferir a pelúcia.", "vermelho", 5000)
							end
						else
							TriggerClientEvent("Notify", source, "Aviso", "A transferência foi recusada.", "amarelo", 5000)
						end
					else
						TriggerClientEvent("Notify", source, "Erro", "Identidade não encontrada.", "vermelho", 5000)
					end
				else
					TriggerClientEvent("Notify", source, "Erro", "O destinatário precisa estar online para aceitar.", "vermelho", 5000)
				end
			else
				TriggerClientEvent("Notify", source, "Erro", "Passaporte inválido ou você não pode transferir para si mesmo.", "vermelho", 5000)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMAND: DAR TODOS OS PETS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("giveallpets", function(source, args, rawCommand)
    local Passport = vRP.Passport(source)
    if Passport then
        -- Verifica se o jogador tem permissão de Admin (Mude "Admin" se a sua permissão for diferente)
        if vRP.HasPermission(Passport, "Admin") or vRP.HasPermission(Passport, "admin") then
            
            -- Se digitar /giveallpets [ID], vai para o ID. Se digitar só /giveallpets, vai para quem digitou.
            local TargetPassport = parseInt(args[1])
            if TargetPassport == 0 or not TargetPassport then
                TargetPassport = Passport
            end

            local count = 0

            -- Faz um loop por toda a lista de pets configurada no seu arquivo shared/client
            for petId, petData in pairs(CollectionsCatalog) do
                
                -- Usa a Query exata que o seu script já possui para inserir no banco de dados
                vRP.Query("plushies/AddPlushie", { Passport = TargetPassport, Plushie = petId })
                
                count = count + 1
            end

            -- Notifica quem usou o comando
            TriggerClientEvent("Notify", source, "Sucesso", "Você enviou <b>"..count.."</b> pets para o Passaporte <b>"..TargetPassport.."</b>.", "verde", 5000)
            
            -- Opcional: Notifica o jogador que recebeu (caso não seja a mesma pessoa)
            if TargetPassport ~= Passport then
                local TargetSource = vRP.Source(TargetPassport)
                if TargetSource then
                    TriggerClientEvent("Notify", TargetSource, "Importante", "Você recebeu todos os pets da coleção da administração!", "azul", 5000)
                end
            end
        else
            TriggerClientEvent("Notify", source, "Negado", "Você não tem permissão para usar este comando.", "vermelho", 5000)
        end
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- REINTEGRACAO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("reintegrar", function(source, args, rawCommand)
	local source = source
	local Passport = vRP.Passport(source)
	
	if Passport and (vRP.HasGroup(Passport, "Admin") or vRP.HasGroup(Passport, "Moderador") or vRP.HasGroup(Passport, "Suporte")) then
		local targetPassport = parseInt(args[1])
		local days = parseInt(args[2])

		if targetPassport > 0 and days > 0 then
			local expireTime = os.time() + (days * 24 * 60 * 60)
			vRP.SetServerData("Reintegracao:"..targetPassport, expireTime)

			TriggerClientEvent("Notify", source, "Sucesso", "Passaporte <b>"..targetPassport.."</b> colocado em reintegração por "..days.." dias.", "verde", 5000)

			-- Se ele estiver online, força a pelúcia agora
			local targetSource = vRP.Source(targetPassport)
			if targetSource then
				TriggerClientEvent("Notify", targetSource, "Aviso", "Você foi colocado em reintegração e recebeu uma marcação temporária.", "amarelo", 10000)
				-- Força equipar (pode precisar do position, se não tiver usa nil)
				local plushieData = CollectionsCatalog and CollectionsCatalog["pokemon1"]
				if plushieData then
					Player(targetSource).state:set("plushie", { id = "pokemon1", position = nil }, true)
					Player(targetSource).state:set("plushieEquipped", true, true)
				end
				TriggerClientEvent("hns-plushies:attachProp", targetSource, "pokemon1", nil)
			end
		else
			TriggerClientEvent("Notify", source, "Aviso", "Uso correto: /reintegrar [passaporte] [dias]", "amarelo", 5000)
		end
	end
end)

RegisterCommand("removerreintegracao", function(source, args, rawCommand)
	local source = source
	local Passport = vRP.Passport(source)
	
	if Passport and (vRP.HasGroup(Passport, "Admin") or vRP.HasGroup(Passport, "Moderador")) then
		local targetPassport = parseInt(args[1])

		if targetPassport > 0 then
			vRP.RemoveServerData("Reintegracao:"..targetPassport)
			TriggerClientEvent("Notify", source, "Sucesso", "Reintegração do passaporte <b>"..targetPassport.."</b> removida.", "verde", 5000)

			local targetSource = vRP.Source(targetPassport)
			if targetSource then
				Player(targetSource).state:set("plushie", nil, true)
				Player(targetSource).state:set("plushieEquipped", false, true)
				TriggerClientEvent("hns-plushies:attachProp", targetSource, nil)
				TriggerClientEvent("Notify", targetSource, "Sucesso", "Seu período de reintegração acabou.", "verde", 5000)
			end
		else
			TriggerClientEvent("Notify", source, "Aviso", "Uso correto: /removerreintegracao [passaporte]", "amarelo", 5000)
		end
	end
end)

AddEventHandler("Connect", function(Passport, source)
	local rData = vRP.GetServerData("Reintegracao:"..Passport)
	local expireTime = 0
	if type(rData) ~= "table" then expireTime = tonumber(rData) or 0 end
	if expireTime > os.time() then
		local src = vRP.Source(Passport)
		if src then
			TriggerClientEvent("Notify", src, "Aviso", "Você ainda está em período de reintegração.", "amarelo", 10000)
			local plushieData = CollectionsCatalog and CollectionsCatalog["pokemon1"]
			if plushieData then
				Player(src).state:set("plushie", { id = "pokemon1", position = nil }, true)
				Player(src).state:set("plushieEquipped", true, true)
			end
			TriggerClientEvent("hns-plushies:attachProp", src, "pokemon1", nil)
		end
	elseif expireTime > 0 and expireTime <= os.time() then
		vRP.RemoveServerData("Reintegracao:"..Passport)
	end
end)