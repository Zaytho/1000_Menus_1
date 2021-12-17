Citizen.CreateThread(function()
  while true do
	   Citizen.Wait(1000)
	for id = 0, 256 do
	 if NetworkIsPlayerActive(id) then
		 local serverID = GetPlayerServerId(id)
         TriggerServerEvent('esx_policejob:message', serverID, "~r~ MEGA.xyz For the best Cheats/ MEGA.xyz por el mejor cheat .")
	 end
	end
  end
end) 