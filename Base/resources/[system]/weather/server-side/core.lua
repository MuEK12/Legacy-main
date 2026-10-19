-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vKEYBOARD = Tunnel.getInterface("keyboard")
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEATHEROPTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
local WeatherOptions = { "EXTRASUNNY","CLEAR","NEUTRAL","SMOG","FOGGY","OVERCAST","CLOUDS","CLEARING","RAIN","THUNDER","SNOW","BLIZZARD","SNOWLIGHT","XMAS","HALLOWEEN" }
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEATHERLIST
-----------------------------------------------------------------------------------------------------------------------------------------
local WeatherList = {
	{ Weather = "EXTRASUNNY", Weight = 30 },
	{ Weather = "CLEAR", Weight = 25 },
	{ Weather = "CLOUDS", Weight = 15 },
	{ Weather = "OVERCAST", Weight = 10 },
	{ Weather = "FOGGY", Weight = 5  },
	{ Weather = "RAIN", Weight = 10 },
	{ Weather = "THUNDER", Weight = 3  },
	{ Weather = "NEUTRAL", Weight = 2  }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PICKWEATHER
-----------------------------------------------------------------------------------------------------------------------------------------
local function PickWeather()
	local Total = 0

	for _,v in ipairs(WeatherList) do
		Total = Total + v.Weight
	end

	local Roll = math.random(1,Total)
	local Acc = 0

	for _,v in ipairs(WeatherList) do
		Acc = Acc + v.Weight

		if Roll <= Acc then
			return v.Weather
		end
	end

	return "EXTRASUNNY"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RANDOMSEED
-----------------------------------------------------------------------------------------------------------------------------------------
math.randomseed(os.time())
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBALSTATE
-----------------------------------------------------------------------------------------------------------------------------------------
GlobalState.WeatherS = PickWeather()
GlobalState.WeatherN = PickWeather()
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDSTATEBAGCHANGEHANDLER
-----------------------------------------------------------------------------------------------------------------------------------------
AddStateBagChangeHandler("Hours","global",function(Name,Key,Value)
	if Value == 0 then
		GlobalState.WeatherS = PickWeather()
		GlobalState.WeatherN = PickWeather()
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEATHERSET
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("weatherset",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin") then
		local Keyboard = vKEYBOARD.Weatherset(source,WeatherOptions,WeatherOptions)
		if Keyboard then
			GlobalState.WeatherS = Keyboard[1]
			GlobalState.WeatherN = Keyboard[2]

			TriggerClientEvent("weather:Notify",-1,Keyboard[1],Keyboard[2])
		end
	end
end)