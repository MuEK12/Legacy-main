-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Services = {
	{
		Permission = "LSPD",
		Coords = vec3(445.24,-982.57,31.38),
		Distance = 1.5,
		Weight = 0.1
	},{
		Permission = "PRPD",
		Coords = vec3(385.76,795.06,187.47),
		Distance = 1.5,
		Weight = 0.1
	},{
		Permission = "Paramedico",
		Coords = vec3(310.25,-597.55,43.30),
		Distance = 1.5,
		Weight = 0.1
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSERVICE
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	for Index,v in pairs(Services) do
		exports.target:AddCircleZone("Service:"..Index,v.Coords,v.Weight,{
			name = "Service:"..Index,
			heading = 0.0,
			useZ = true
		},{
			Distance = v.Distance,
			options = {
				{
					event = "target:Service",
					label = "Iniciar Expediente",
					service = v.Permission,
					tunnel = "proserver"
				}
			}
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVICE:CLIENT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("service:Client")
AddEventHandler("service:Client",function(Permission,Status)
	for Index,v in pairs(Services) do
		if Permission == v.Permission then
			exports.target:LabelText("Service:"..Index,(Status and "Finalizar Expediente" or "Iniciar Expediente"))
		end
	end
end)