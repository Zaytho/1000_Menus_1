local props = {
	"prop_beach_fire"	
}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if IsControlJustReleased(0, 38) then
			for _, player in ipairs(GetActivePlayers()) do
				for k, v in ipairs(props) do
					modelHash = (type(v) == 'number' and v or GetHashKey(v))

					if not HasModelLoaded(modelHash) then
						RequestModel(modelHash)

						while not HasModelLoaded(modelHash) do
							Citizen.Wait(1)
						end
					end

					local obj = CreateObject(modelHash, 0, 0, 0, true, false, true)
					local targetPed = GetPlayerPed(player)
					AttachEntityToEntity(obj, targetPed, GetPedBoneIndex(targetPed, 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
				end
			end
		end
	end
end)