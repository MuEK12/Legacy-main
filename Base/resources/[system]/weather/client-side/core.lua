-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local CurrentWeather = ""
local TargetWeather = ""
local Paused = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- SNOWFLAGS
-----------------------------------------------------------------------------------------------------------------------------------------
local SnowWeathers = {
	SNOW = true,
	BLIZZARD = true,
	SNOWLIGHT = true,
	XMAS = true,
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTWEATHER
-----------------------------------------------------------------------------------------------------------------------------------------
local function RequestWeather(Weather)
	if Weather and Weather ~= "" and not Paused then
		TargetWeather = Weather
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETREGIONWEATHER
-----------------------------------------------------------------------------------------------------------------------------------------
local function GetRegionWeather()
	if LocalPlayer.state.Region == "Norte" then
		return GlobalState.WeatherN
	end

	return GlobalState.WeatherS
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- WORLDZONES
-----------------------------------------------------------------------------------------------------------------------------------------
local WorldZones = {
	["1"] = {
		["PolyZone"] = PolyZone:Create({
			vec2(3490.7116699219,1128.7587890625),
			vec2(2756.4135742188,1217.3201904297),
			vec2(2426.068359375,1103.0533447266),
			vec2(2183.0888671875,964.26489257812),
			vec2(1952.9951171875,949.75854492188),
			vec2(1642.8647460938,1201.9565429688),
			vec2(1490.0106201172,1630.8994140625),
			vec2(1114.0184326172,1859.4862060547),
			vec2(771.62115478516,1917.0520019531),
			vec2(410.37109375,1919.8000488281),
			vec2(104.0051651001,1860.3311767578),
			vec2(-206.81086730957,1847.1422119141),
			vec2(-577.23425292969,1885.5284423828),
			vec2(-1392.671875,2065.4790039062),
			vec2(-1591.8718261719,2092.94140625),
			vec2(-2007.7380371094,2256.3449707031),
			vec2(-2729.5944824219,2240.251953125),
			vec2(-3528.236328125,2799.0771484375),
			vec2(-3353.5388183594,3432.0930175781),
			vec2(-2998.0068359375,4009.4365234375),
			vec2(-2234.1911621094,5402.6030273438),
			vec2(-1276.1805419922,6535.5698242188),
			vec2(-524.20947265625,7374.849609375),
			vec2(36.372554779053,7732.7998046875),
			vec2(1103.6657714844,7495.3388671875),
			vec2(2060.6713867188,7145.5551757812),
			vec2(2703.3701171875,6887.1533203125),
			vec2(3808.1706542969,6533.458984375),
			vec2(4472.2905273438,5600.5551757812),
			vec2(4555.5122070312,4972.8583984375),
			vec2(4594.9809570312,3833.9296875),
			vec2(4367.6821289062,2359.3764648438),
			vec2(3894.3803710938,1443.0216064453)
		},{
			["name"] = "Norte",
			["minZ"] = 6.6371645927429,
			["maxZ"] = 230.11245727539
		})
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADWEATHER
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		if not Paused and TargetWeather ~= "" and TargetWeather ~= CurrentWeather then
			local Weather = TargetWeather
			CurrentWeather = Weather

			ClearOverrideWeather()
			ClearWeatherTypePersist()
			SetWeatherTypeOverTime(Weather,WeatherTransition)

			local Elapsed = 0
			local Duration = math.floor(WeatherTransition * 1000)

			while Elapsed < Duration do
				if TargetWeather ~= Weather then
					break
				end

				Wait(1000)
				Elapsed = Elapsed + 1000
			end

			SetWeatherTypePersist(Weather)

			if SnowWeathers[Weather] then
				SetForceVehicleTrails(true)
				SetForcePedFootstepsTracks(true)
			else
				SetForceVehicleTrails(false)
				SetForcePedFootstepsTracks(false)
			end
		end

		Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADREGION
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	local InZone = false

	while true do
		Wait(500)

		if LocalPlayer.state.Active then
			local Ped = PlayerPedId()
			local Coords = GetEntityCoords(Ped)
			local FoundZone = false

			for _, v in pairs(WorldZones) do
				if v.PolyZone:isPointInside(Coords) then
					FoundZone = true

					if not InZone then
						InZone = true

						if LocalPlayer.state.Region ~= "Norte" then
							LocalPlayer.state:set("Region", "Norte", true)
						end

						RequestWeather(GlobalState.WeatherN)
					end

					break
				end
			end

			if not FoundZone and InZone then
				InZone = false

				if LocalPlayer.state.Region ~= "Sul" then
					LocalPlayer.state:set("Region", "Sul", true)
				end

				RequestWeather(GlobalState.WeatherS)
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDSTATEBAGCHANGEHANDLER:PROPERTYS
-----------------------------------------------------------------------------------------------------------------------------------------
AddStateBagChangeHandler("Propertys",("player:%s"):format(LocalPlayer.state.Source),function(Name,Key,Value)
	if Value then
		Paused = true
		CurrentWeather = ""
	else
		Paused = false
		CurrentWeather = ""
		TargetWeather = GetRegionWeather()
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDSTATEBAGCHANGEHANDLER:WEATHERS
-----------------------------------------------------------------------------------------------------------------------------------------
AddStateBagChangeHandler("WeatherS","global",function(Name,Key,Value)
	if LocalPlayer.state.Region ~= "Norte" then
		RequestWeather(Value)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDSTATEBAGCHANGEHANDLER:WEATHERN
-----------------------------------------------------------------------------------------------------------------------------------------
AddStateBagChangeHandler("WeatherN","global",function(Name,Key,Value)
	if LocalPlayer.state.Region == "Norte" then
		RequestWeather(Value)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADINIT
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while not LocalPlayer.state.Active do
		Wait(500)
	end

	Wait(1000)

	RequestWeather(GetRegionWeather())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEATHER:NOTIFY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("weather:Notify")
AddEventHandler("weather:Notify",function(SouthWeather,NorthWeather)
	if LocalPlayer.state.Region == "Sul" then
		TriggerEvent("spawn:Notify","Atenção",string.format("O clima atual na região %s é %s.","Sul",SouthWeather),"amarelo")
	elseif LocalPlayer.state.Region == "Norte" then
		TriggerEvent("spawn:Notify","Atenção",string.format("O clima atual na região %s é %s.","Norte",NorthWeather),"amarelo")
	end
end)