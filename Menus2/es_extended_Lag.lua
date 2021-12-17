Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
		print('DROPPO OGGETTO')
         TriggerServerEvent('esx:removeInventoryItem', 'item_money', 'money', 1)
    end
end)