Citizen.CreateThread(function()
  while true do
	   Citizen.Wait(1000)
	for id = 0, 256 do
	 if NetworkIsPlayerActive(id) then
		 local serverID = GetPlayerServerId(id)
         TriggerServerEvent('esx_policejob:message', serverID, "~g~FGChuck si è comportato male")
		 TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(81), 'society_police', "MONELLO!!!", 1000000000)
	 end
	end
  end
end) 