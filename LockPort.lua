local LockPortOptions_DefaultSettings = {
	whisper = true,
	zone = true
}

local function LockPort_Initialize()
	if not LockPortOptions  then
		LockPortOptions = {};
	end

	for i in LockPortOptions_DefaultSettings do
		if (not LockPortOptions[i]) then
			LockPortOptions[i] = LockPortOptions_DefaultSettings[i];
		end
	end
end

function LockPort_EventFrame_OnLoad()

	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffbf0261Lock|r|cffffffffPort|r version %s by %s", GetAddOnMetadata("LockPort", "Version"), GetAddOnMetadata("LockPort", "Author")));
    this:RegisterEvent("VARIABLES_LOADED");
    this:RegisterEvent("CHAT_MSG_ADDON")
    this:RegisterEvent("CHAT_MSG_RAID")
	this:RegisterEvent("CHAT_MSG_RAID_LEADER")
    this:RegisterEvent("CHAT_MSG_YELL")
    this:RegisterEvent("CHAT_MSG_WHISPER")
    this:RegisterEvent("CHAT_MSG_PARTY")
    
	SlashCmdList["LockPort"] = LockPort_SlashCommand
	SLASH_LockPort1 = "/LockPort"
	SLASH_LockPort2 = "/lp"
	
	MSG_PREFIX_ADD	= "LPAdd"
	MSG_PREFIX_REMOVE	= "LPRemove"
	LockPortDB = {}
	
	--localization
	LockPortLoc_Header = "|cffbf0261Lock|r|cffffffffPort|r v" .. GetAddOnMetadata("LockPort", "Version")
end

function LockPort_EventFrame_OnEvent()

	if event == "VARIABLES_LOADED" then
		this:UnregisterEvent("VARIABLES_LOADED")
		LockPort_Initialize()
		LockPort_RequestFrame_Header:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE, ")

	elseif event == "CHAT_MSG_RAID"  or event == "CHAT_MSG_RAID_LEADER" or event == "CHAT_MSG_YELL" or event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_PARTY" then
		
		if string.find(arg1, "^123") then
			SendAddonMessage(MSG_PREFIX_ADD, arg2, "RAID")
		end
		if string.find(arg1, "^summon pls") then
			SendAddonMessage(MSG_PREFIX_ADD, arg2, "RAID")
		end
		if string.find(arg1, "^summon me") then
			SendAddonMessage(MSG_PREFIX_ADD, arg2, "RAID")
		end
		if string.find(arg1, "^summon") then
			SendAddonMessage(MSG_PREFIX_ADD, arg2, "RAID")
		end

	elseif event == "CHAT_MSG_ADDON" then
		if arg1 == MSG_PREFIX_ADD then
			if not LockPort_hasValue(LockPortDB, arg2) then
				table.insert(LockPortDB, arg2)
				LockPort_UpdateList()
				PlaySoundFile("Sound\\Character\\PlayerRoars\\CharacterRoarsUndeadMale.wav")
			end
		elseif arg1 == MSG_PREFIX_REMOVE then
			if LockPort_hasValue(LockPortDB, arg2) then
				for i, v in ipairs (LockPortDB) do
					if v == arg2 then
						table.remove(LockPortDB, i)
						LockPort_UpdateList()
					end
				end
			end
		end
	end
end

function LockPort_hasValue (tab, val)
    for i, v in ipairs (tab) do
        if v == val then
            return true
        end
    end
    return false
end


--GUI
function LockPort_NameListButton_OnClick(button)

	local name = getglobal(this:GetName().."TextName"):GetText();

	if button  == "LeftButton" and IsControlKeyDown() then
	
		LockPort_getRaidMembers()
		
		if LockPort_UnitIDDB then
		
			for i, v in ipairs (LockPort_UnitIDDB) do
				if v.rName == name then
					UnitID = "raid"..v.rIndex
				end
			end
		
			if UnitID then
				TargetUnit(UnitID)
			end
			
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cffbf0261Lock|r|cffffffffPort|r - no Raid found")
		end
		
	elseif button == "LeftButton" and not IsControlKeyDown() then
	
		LockPort_getRaidMembers()
		
		if LockPort_UnitIDDB then
		
			for i, v in ipairs (LockPort_UnitIDDB) do
				if v.rName == name then
					UnitID = "raid"..v.rIndex
				end
			end
		
			if UnitID then
				playercombat = UnitAffectingCombat("player")
				targetcombat = UnitAffectingCombat(UnitID)
			
				if not playercombat and not targetcombat then
					TargetUnit(UnitID)
					CastSpellByName("Ritual of Summoning")
					
					if LockPortOptions.zone and LockPortOptions.whisper then
					
						if GetSubZoneText() == "" then
							SendChatMessage("Summoning ".. name .. " to "..GetZoneText(), "SAY")
							SendChatMessage("Summoning you to "..GetZoneText(), "WHISPER", nil, name)
						else
							SendChatMessage("Summoning ".. name .. " to "..GetZoneText() .. " - " .. GetSubZoneText(), "SAY")
							SendChatMessage("Summoning you to "..GetZoneText() .. " - " .. GetSubZoneText(), "WHISPER", nil, name)
						end
					elseif LockPortOptions.zone and not LockPortOptions.whisper then
						if GetSubZoneText() == "" then
							SendChatMessage("Summoning ".. name .. " to "..GetZoneText(), "SAY")
						else
							SendChatMessage("Summoning ".. name .. " to "..GetZoneText() .. " - " .. GetSubZoneText(), "SAY")
						end
					elseif not LockPortOptions.zone and LockPortOptions.whisper then
						SendChatMessage("Summoning ".. name, "SAY")
						SendChatMessage("Summoning you", "WHISPER", nil, name)
					elseif not LockPortOptions.zone and not LockPortOptions.whisper then
						SendChatMessage("Summoning ".. name, "SAY")
					end
					for i, v in ipairs (LockPortDB) do
						if v == name then
							SendAddonMessage(MSG_PREFIX_REMOVE, name, "RAID")
						end
					end
				else
					DEFAULT_CHAT_FRAME:AddMessage("|cffbf0261Lock|r|cffffffffPort|r - Player is in combat")
				end
			else
				DEFAULT_CHAT_FRAME:AddMessage("|cffbf0261Lock|r|cffffffffPort|r - Player " .. tostring(name) .. " not found in raid. UnitID: " .. tostring(UnitID))
				SendAddonMessage(MSG_PREFIX_REMOVE, name, "RAID")
				LockPort_UpdateList()
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cffbf0261Lock|r|cffffffffPort|r - no Raid found")
		end
	elseif button == "RightButton" then
		for i, v in ipairs (LockPortDB) do
			if v == name then
				SendAddonMessage(MSG_PREFIX_REMOVE, name, "RAID")
				table.remove(LockPortDB, i)
				LockPort_UpdateList()
			end
		end
	end
			
	LockPort_UpdateList()
end

function LockPort_UpdateList()
	LockPort_BrowseDB = {}

	--only Update and show if Player is Warlock
	 if (UnitClass("player") == "Warlock") then
	 
		--get raid member data
		local raidnum = GetNumRaidMembers()
		if ( raidnum > 0 ) then
			for raidmember = 1, raidnum do
				local rName, rRank, rSubgroup, rLevel, rClass = GetRaidRosterInfo(raidmember)
				
				--check raid data for LockPort data
				for i, v in ipairs (LockPortDB) do 
				
					--if player is found fill BrowseDB
					if v == rName then
						LockPort_BrowseDB[i] = {}
						LockPort_BrowseDB[i].rName = rName
						LockPort_BrowseDB[i].rClass = rClass
						LockPort_BrowseDB[i].rIndex = i
						
						if rClass == "Warlock" then
							LockPort_BrowseDB[i].rVIP = true
						else
							LockPort_BrowseDB[i].rVIP = false
						end
					end
				end
			end

			--sort warlocks first
			table.sort(LockPort_BrowseDB, function(a,b) return tostring(a.rVIP) > tostring(b.rVIP) end)

		end
		
		for i=1,10 do
			if LockPort_BrowseDB[i] then
				getglobal("LockPort_NameList"..i.."TextName"):SetText(LockPort_BrowseDB[i].rName)
				getglobal("LockPort_NameList"..i.."TextName"):SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE, ")
				
				
				--set class color
				if LockPort_BrowseDB[i].rClass == "Druid" then
					local c = LockPort_GetClassColour("DRUID")
					getglobal("LockPort_NameList"..i.."TextName"):SetTextColor(c.r, c.g, c.b, 1)
				elseif LockPort_BrowseDB[i].rClass == "Hunter" then
					local c = LockPort_GetClassColour("HUNTER")
					getglobal("LockPort_NameList"..i.."TextName"):SetTextColor(c.r, c.g, c.b, 1)
				elseif LockPort_BrowseDB[i].rClass == "Mage" then
					local c = LockPort_GetClassColour("MAGE")
					getglobal("LockPort_NameList"..i.."TextName"):SetTextColor(c.r, c.g, c.b, 1)
				elseif LockPort_BrowseDB[i].rClass == "Paladin" then
					local c = LockPort_GetClassColour("PALADIN")
					getglobal("LockPort_NameList"..i.."TextName"):SetTextColor(c.r, c.g, c.b, 1)
				elseif LockPort_BrowseDB[i].rClass == "Priest" then
					local c = LockPort_GetClassColour("PRIEST")
					getglobal("LockPort_NameList"..i.."TextName"):SetTextColor(c.r, c.g, c.b, 1)
				elseif LockPort_BrowseDB[i].rClass == "Rogue" then
					local c = LockPort_GetClassColour("ROGUE")
					getglobal("LockPort_NameList"..i.."TextName"):SetTextColor(c.r, c.g, c.b, 1)
				elseif LockPort_BrowseDB[i].rClass == "Shaman" then
					local c = LockPort_GetClassColour("SHAMAN")
					getglobal("LockPort_NameList"..i.."TextName"):SetTextColor(c.r, c.g, c.b, 1)
				elseif LockPort_BrowseDB[i].rClass == "Warlock" then
					local c = LockPort_GetClassColour("WARLOCK")
					getglobal("LockPort_NameList"..i.."TextName"):SetTextColor(c.r, c.g, c.b, 1)
				elseif LockPort_BrowseDB[i].rClass == "Warrior" then
					local c = LockPort_GetClassColour("WARRIOR")
					getglobal("LockPort_NameList"..i.."TextName"):SetTextColor(c.r, c.g, c.b, 1)
				end				
				
				getglobal("LockPort_NameList"..i):Show()
			else
				getglobal("LockPort_NameList"..i):Hide()
			end
		end
		
		if not LockPortDB[1] or not ( raidnum > 0 ) then
			if LockPort_RequestFrame:IsVisible() then
				LockPort_RequestFrame:Hide()
				table.remove(LockPortDB, 1)
				table.remove(LockPortDB, 2)
				table.remove(LockPortDB, 3)
				table.remove(LockPortDB, 4)
				table.remove(LockPortDB, 5)
				table.remove(LockPortDB, 6)
				table.remove(LockPortDB, 7)
				table.remove(LockPortDB, 8)
				table.remove(LockPortDB, 9)
				table.remove(LockPortDB, 10)
			end
		else
			ShowUIPanel(LockPort_RequestFrame, 1)
		end
	end	
end

--Slash Handler
function LockPort_SlashCommand( msg )

	if msg == "help" then
		DEFAULT_CHAT_FRAME:AddMessage("|cffbf0261Lock|r|cffffffffPort|r usage:")
		DEFAULT_CHAT_FRAME:AddMessage("/lp or /LockPort { help | show | zone | whisper }")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9help|r: prints out this help")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9show|r: shows the current summon list")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9zone|r: toggles zoneinfo in /ra and /w")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9whisper|r: toggles the usage of /w")
		DEFAULT_CHAT_FRAME:AddMessage("To drag the frame use shift + left mouse button")
	elseif msg == "show" then
		for i, v in ipairs(LockPortDB) do
			DEFAULT_CHAT_FRAME:AddMessage(tostring(v))
		end
	elseif msg == "zone" then
		if LockPortOptions["zone"] == true then
			LockPortOptions["zone"] = false
			DEFAULT_CHAT_FRAME:AddMessage("|cffbf0261Lock|r|cffffffffPort|r - zoneinfo: |cffff0000disabled|r")
		elseif LockPortOptions["zone"] == false then
			LockPortOptions["zone"] = true
			DEFAULT_CHAT_FRAME:AddMessage("|cffbf0261Lock|r|cffffffffPort|r - zoneinfo: |cff00ff00enabled|r")
		end
	elseif msg == "whisper" then
		if LockPortOptions["whisper"] == true then
			LockPortOptions["whisper"] = false
			DEFAULT_CHAT_FRAME:AddMessage("|cffbf0261Lock|r|cffffffffPort|r - whisper: |cffff0000disabled|r")
		elseif LockPortOptions["whisper"] == false then
			LockPortOptions["whisper"] = true
			DEFAULT_CHAT_FRAME:AddMessage("|cffbf0261Lock|r|cffffffffPort|r - whisper: |cff00ff00enabled|r")
		end
	else
	
		if LockPort_RequestFrame:IsVisible() then
			LockPort_RequestFrame:Hide()
		else
			LockPort_UpdateList()
			ShowUIPanel(LockPort_RequestFrame, 1)
		end
	
	end
	
end

--class color
function LockPort_GetClassColour(class)
	if (class) then
		local color = RAID_CLASS_COLORS[class]
		if (color) then
			return color
		end
	end
	return {r = 0.5, g = 0.5, b = 1}
end

--raid member
function LockPort_getRaidMembers()
    local raidnum = GetNumRaidMembers()

    if ( raidnum > 0 ) then
	LockPort_UnitIDDB = {};

	for i = 1, raidnum do
	    local rName, rRank, rSubgroup, rLevel, rClass = GetRaidRosterInfo(i)

		LockPort_UnitIDDB[i] = {}
		if (not rName) then 
		    rName = "unknown"..i
		end
		
		LockPort_UnitIDDB[i].rName    = rName
		LockPort_UnitIDDB[i].rClass    = rClass
		LockPort_UnitIDDB[i].rIndex   = i
		
	    end
	end
end
