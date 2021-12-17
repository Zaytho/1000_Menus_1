======================
Money
======================
TriggerServerEvent('AdminMenu:giveCash', money)
TriggerServerEvent('AdminMenu:giveBank', money)
TriggerServerEvent('AdminMenu:giveDirtyMoney', money)
TriggerServerEvent('esx_truckerjob:pay', 2400000)
TriggerServerEvent('vrp_slotmachine:server:2', 100000)
TriggerServerEvent("esx_pizza:pay", 1000000)
TriggerServerEvent("pizza:pourboire", 1)
TriggerServerEvent('esx_jobs:caution', 'give_back', 1000000)
TriggerServerEvent('lscustoms:payGarage', 1000000)
TriggerServerEvent('esx_tankerjob:pay', 1000000)
TriggerServerEvent('esx_vehicletrunk:giveDirty', 100000)
TriggerServerEvent('f0ba1292-b68d-4d95-8823-6230cdf282b6', 100000)
TriggerServerEvent('gambling:spend', 100000)
TriggerServerEvent('265df2d8-421b-4727-b01d-b92fd6503f5e', 100000)
TriggerServerEvent('AdminMenu:giveBank', 1000000)
TriggerServerEvent('AdminMenu:giveCash', 1000000)
TriggerServerEvent('esx_billing:sendBill', 131, "Purposeless", "Payday", 100)
TriggerServerEvent('paycheck:salary', 20000) (Give yourself money)
======================
Drugs
======================
-Harvesting
TriggerServerEvent('esx_drugs:startHarvestWeed')
TriggerServerEvent('esx_drugs:startHarvestMeth')
TriggerServerEvent('esx_drugs:startHarvestOpium')
TriggerServerEvent('esx_drugs:stopHarvestWeed')
TriggerServerEvent('esx_drugs:stopHarvestCoke')
TriggerServerEvent('esx_drugs:stopHarvestMeth')
TriggerServerEvent('esx_drugs:stopHarvestOpium')
-Processing
TriggerServerEvent('esx_drugs:startTransformWeed')
TriggerServerEvent('esx_drugs:startTransformCoke')
TriggerServerEvent('esx_drugs:startTransformMeth')
TriggerServerEvent('esx_drugs:startTransformOpium')
TriggerServerEvent('esx_drugs:stopTransformWeed')
TriggerServerEvent('esx_drugs:stopTransformCoke')
TriggerServerEvent('esx_drugs:stopTransformMeth')
TriggerServerEvent('esx_drugs:stopTransformOpium')
-Selling
TriggerServerEvent('esx_drugs:startSellWeed')
TriggerServerEvent('esx_drugs:startSellCoke')
TriggerServerEvent('esx_drugs:startSellMeth')
TriggerServerEvent('esx_drugs:startSellOpium')
TriggerServerEvent('esx_drugs:stopSellWeed')
TriggerServerEvent('esx_drugs:stopSellCoke')
TriggerServerEvent('esx_drugs:stopSellMeth')
TriggerServerEvent('esx_drugs:stopSellOpium')
======================
Jobs
======================
TriggerServerEvent('esx_joblisting:setJob', 'police')
TriggerServerEvent('NB:recruterplayer', 59, "mecano", 0)
======================
Util
======================
TriggerServerEvent('esx_ambulancejob:revive', ID)
TriggerEvent('esx:spawnVehicle', "vehiclename")
TriggerEvent('es_admin:noclip')
Set jail time 0 TriggerServerEvent('esx_jailer:unjailTime', -1)
======================
Trolling
======================
TriggerServerEvent('esx_jail:sendPlayerToJail', playerId, jailTime * 60)
TriggerServerEvent('esx_license:removeLicense', GetPlayerServerId(player), data.current.type)
TriggerEvent('es_admin_ban', )
TriggerServerEvent( 'mellotrainer:adminTempBan', id )
TriggerServerEvent( 'mellotrainer:adminKick', id, "Kicked: You have been kicked from the server." )
TriggerServerEvent('mellotrainer:adminTempBan', GetPlayerServerId(PlayerId()))
TriggerServerEvent('esx_policejob:handcuff', playerId) to
TriggerServerEvent('esx_policejob:UCuffedBoi', playerId)
TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(player))
TriggerServerEvent('esx_policejob:drag', GetPlayerServerId(player))
TriggerClientEvent('es_admin:crash', player)
TriggerServerEvent("EasyAdmin:banPlayer", GetPlayerServerId( thePlayer ), BanReason, banLength[BanTime].time, GetPlayerName( thePlayer ))
======================
Menus
======================
TriggerEvent('esx_society:openBossMenu', 'police', function(data,menu) menu.close() end)
Opens bossmenu for EMS
Opens bossmenu for Mechanics
TriggerEvent('esx_society:openBossMenu', 'mechano', function(data,menu) menu.close() end)
Opens bossmenu for Car Dealer
TriggerEvent('esx_society:openBossMenu', 'cardealer', function(data, menu) menu.close() end)
Opens bossmenu for BankerJob
TriggerEvent('esx_society:openBossMenu', 'banker', function (data, menu) menu.close() end)
Opens bossmenu for Realestateagent
TriggerEvent('esx_society:openBossMenu', 'realestateagent', function(data, menu) menu.close() end)
======================
Licenses
======================
TriggerServerEvent('esx_weashopjob:addLicense', 'tazer')
TriggerServerEvent('esx_weashopjob:addLicense', 'ppa')
TriggerServerEvent('esx_weashopjob:addLicense', 'ppa2')
TriggerServerEvent('esx_weashopjob:addLicense', 'drive_bike')
TriggerServerEvent('esx_weashopjob:addLicense', 'drive_truck')
TriggerServerEvent('esx_dmvschool:addLicense', 'dmv')
TriggerServerEvent('esx_dmvschool:addLicense', 'drive')
TriggerServerEvent('esx_dmvschool:addLicense', 'drive_bike')
TriggerServerEvent('esx_dmvschool:addLicense', 'drive_truck')
TriggerServerEvent('esx_airlines:addLicense', 'helico')
TriggerServerEvent('esx_airlines:addLicense', 'avion')
======================
Alim
======================
TriggerServerEvent('esx_mecanojob:buyItem', "blowpipe", 1 , "Chalumeaux")
TriggerServerEvent('esx_pharmacienjob:buyItem', "paracetamol", 1 , "Paracetamol")
TriggerServerEvent('esx_foodtruck:buyItem', "whisky", 1 , "Whisky")
TriggerServerEvent('esx_shop:buyItem', "fixkit", 1 , "Kit Réparation")