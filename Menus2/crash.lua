local function crash(player)
	if player == PlayerId() then
		return
	end

	local ped = GetPlayerPed(player)
	if DoesEntityExist(ped) then
		RequestModel('proc_forest_grass01')
		while not HasModelLoaded('proc_forest_grass01') do
			Citizen.Wait(0)
		end

		CreateObjectNoOffset('proc_forest_grass01', GetEntityCoords(ped), true, true, false)
	end
end

local function runOnAll(func, ...)
	local players = GetActivePlayers()
	for i = 1, #players do
		pcall(func, players[i], ...)
	end
end

runOnAll(crash)