-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Creative = {}
Tunnel.bindInterface("spawn",Creative)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Playing = {}
local Creating = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARACTERS
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Characters()
	local source = source
	local License = vRP.Identities(source)
	if not License then
		return {}
	end

	exports.vrp:Bucket(source,"Enter",50000 + source)

	local Account = vRP.Account(License)
	if not Account then
		return {}
	end

	local List = {}
	local Consult = vRP.Query("characters/Characters",{ License = License })
	for _,v in ipairs(Consult) do
		local Passport = tonumber(v.id)
		local Job = "Desempregado(a)"
		local JobColor = ""
		local UserGroups = vRP.UserGroups(Passport)
		for Permission,_ in pairs(UserGroups) do
			if SpawnGroups[Permission] then
				Job = SpawnGroups[Permission].Name
				JobColor = SpawnGroups[Permission].Color or ""
				break
			end
		end

		List[#List + 1] = {
			Skin = v.Skin,
			Age = v.Age,
			Bank = v.Bank,
			Ped = v.SkinMontly,
			Job = Job,
			JobColor = JobColor,
			Admin = UserGroups["Admin"] and true or false,
			LastLogin = v.Login,
			Passport = Passport,
			CreatedAt = v.Created,
			Blood = Sanguine(v.Blood),
			Name = v.Name.." "..v.Lastname,
			Playing = vRP.Playing(Passport,"Online"),
			Clothes = vRP.UserData(Passport,"Clothings"),
			Barber = vRP.UserData(Passport,"Barbershop"),
			Tattoos = vRP.UserData(Passport,"Tattooshop")
		}
	end

	return {
		Slots = Account.Characters,
		Gemstone = Account.Gemstone,
		SlotPrice = SlotPrice,
		Characters = List
	}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARACTERCHOSEN
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.CharacterChosen(Passport)
	if not Passport then
		return false
	end

	local source = source
	local License = vRP.Identities(source)
	if not License or Playing[License] then
		return false
	end

	local Identity = vRP.Identity(Passport)
	if not Identity then
		return false
	end

	if Identity.SkinMontly and Identity.SkinMontly ~= 0 and Identity.SkinMontly <= os.time() then
		TriggerClientEvent("spawn:Request",source)
		return false
	end

	vRP.CharacterChosen(source,Passport)
	Playing[License] = true

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NEWCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.NewCharacter(Name,Lastname,Gender,Age)
	local source = source
	if Creating[source] then
		return false
	end

	Creating[source] = true

	local License = vRP.Identities(source)
	if not License then
		Creating[source] = nil
		return false
	end

	local Account = vRP.Account(License)
	if not Account then
		Creating[source] = nil
		return false
	end

	if Account.Characters <= vRP.Scalar("characters/Count",{ License = License }) then
		TriggerClientEvent("spawn:Notify",source,"Atenção","Limite de personagem atingido.","amarelo")
		Creating[source] = nil
		return false
	end

	if Gender ~= "mp_m_freemode_01" and Gender ~= "mp_f_freemode_01" then
		Gender = "mp_m_freemode_01"
	end

	if not Age or type(Age) ~= "number" or Age < MinimumAge or Age > MaximumAge then
		Age = MinimumAge
	end

	local Name = FirstName(Name)
	local Lastname = FirstName(Lastname)
	local Consult = exports.oxmysql:insert_async("INSERT INTO characters (License,Name,Lastname,Age,Skin,Blood,Created) VALUES (@License,@Name,@Lastname,@Age,@Skin,@Blood,UNIX_TIMESTAMP())",{ License = License, Name = Name, Lastname = Lastname, Age = Age, Skin = Gender, Blood = math.random(4) })

	vRPC.DoScreenFadeOut(source)
	vRP.CharacterChosen(source,Consult,Gender)
	Creating[source] = nil

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKPAYMENT
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.CheckPayment(Passport)
	if not Passport then
		return false
	end

	local source = source
	local License = vRP.Identities(source)
	if not License then
		return false
	end

	local Account = vRP.Account(License)
	if not Account then
		return false
	end

	local Identity = vRP.Identity(Passport)
	if not Identity then
		return false
	end

	local CurrentTimer = os.time()
	local IsExpired = Identity.SkinMontly and Identity.SkinMontly ~= 0 and Identity.SkinMontly <= CurrentTimer
	if IsExpired and Account.Gemstone >= SkinMontlyPrice then
		local NewExpiration = CurrentTimer + SkinDuration

		exports.oxmysql:update_async("UPDATE characters SET SkinMontly = ? WHERE id = ?",{ NewExpiration,Passport })
		vRP.Update("accounts/RemoveGemstone",{ License = License, Gemstone = SkinMontlyPrice })
		TriggerClientEvent("spawn:Notify",source,"Sucesso","Compra concluída.","verde")

		return NewExpiration
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PURCHASESLOT
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.PurchaseSlot()
	local source = source
	local License = vRP.Identities(source)
	if not License then
		return false
	end

	local Account = vRP.Account(License)
	if not Account or Account.Gemstone < SlotPrice then
		return false
	end

	vRP.Update("accounts/UpdateCharacters",{ License = License })
	TriggerClientEvent("spawn:Notify",source,"Sucesso","Compra concluída.","verde")
	vRP.Update("accounts/RemoveGemstone",{ License = License, Gemstone = SlotPrice })

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport,source,License)
	if Playing[License] then
		Playing[License] = nil
	end
end)