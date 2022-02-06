local LockPortOptions_DefaultSettings = {
	whisper = true,
	zone = true,
	zone = true,
	sound = true,
	soul = true,
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
	LockPort_Shards()
	LockPort_NotStoned()
	soulName = nil
end

local s = CreateFrame("Frame", nil, UIParent)
s:RegisterEvent("PLAYER_LOGIN")
s:RegisterEvent("PLAYER_ENTERING_WORLD")
s:SetScript("OnEvent", function(self, event)


	CreateFrame("frame"):SetScript("OnUpdate", PopUpMenu_Load)
end)

function LockPort_EventFrame_OnLoad()

	DEFAULT_CHAT_FRAME:AddMessage(string.format("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r version %s by %s", GetAddOnMetadata("LockPort", "Version"), GetAddOnMetadata("LockPort", "Author")));
    this:RegisterEvent("VARIABLES_LOADED");
    this:RegisterEvent("CHAT_MSG_ADDON")
    this:RegisterEvent("CHAT_MSG_RAID")
	this:RegisterEvent("CHAT_MSG_RAID_LEADER")
    this:RegisterEvent("CHAT_MSG_YELL")
    this:RegisterEvent("CHAT_MSG_WHISPER")
    this:RegisterEvent("CHAT_MSG_PARTY")
    this:RegisterEvent("CHAT_MSG_SAY")
    this:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
    this:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
    this:RegisterEvent("UNITDIESOTHER")
    this:RegisterEvent("UNITDIESSELF")
    
	SlashCmdList["LockPort"] = LockPort_SlashCommand
	SLASH_LockPort1 = "/LockPort"
	
	MSG_PREFIX_ADD	= "LPAdd"
	MSG_PREFIX_REMOVE	= "LPRemove"
	MSG_PREFIX_STONE_ADD	= "LPStoneAdd"
	MSG_PREFIX_STONE_REMOVE	= "LPStoneRemove"
	LockPortDB = {}
	LockPortStoneDB = {}

	--localization
	LockPortLoc_Header = "|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r"
end

function LockPort_EventFrame_OnEvent()

	if (event == "PLAYER_LOGIN") then
		LockPort_Shards()
		LockPort_NotStoned()
		LockPortStoneNAME:SetText("")
	end
	if (event == "PLAYER_ENTERING_WORLD") then
		LockPort_Shards()
		LockPort_NotStoned()
		LockPortStoneNAME:SetText("")
	end
	if (event == "BAG_UPDATE") then
		LockPort_Shards()
	end

	if event == "VARIABLES_LOADED" then
		this:UnregisterEvent("VARIABLES_LOADED")
		LockPort_Initialize()
		LockPort_RequestFrame_Header:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE, ")
		

	elseif event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" or event == "CHAT_MSG_YELL" or event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_PARTY" then
		
		if string.find(arg1, "123") then
			SendAddonMessage(MSG_PREFIX_ADD, arg2, "RAID")
		end
		if string.find(arg1, "summon") then
			SendAddonMessage(MSG_PREFIX_ADD, arg2, "RAID")
		end
		if string.find(arg1, "456") then
			SendAddonMessage(MSG_PREFIX_ADD, arg2, "RAID")
		end
	elseif event == "CHAT_MSG_ADDON" then
		if arg1 == MSG_PREFIX_ADD and LockPortOptions.sound then
			if not LockPort_hasValue(LockPortDB, arg2) then
				table.insert(LockPortDB, arg2)
				LockPort_UpdateList()
				PlaySoundFile("Sound\\Creature\\Necromancer\\NecromancerReady1.wav")
			end
		elseif arg1 == MSG_PREFIX_ADD and not LockPortOptions.sound then
			if not LockPort_hasValue(LockPortDB, arg2) then
				table.insert(LockPortDB, arg2)
				LockPort_UpdateList()
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
		elseif arg1 == MSG_PREFIX_STONE_ADD then -- Stone Add
			if strfind(arg2,"LP Character %a+ Soulstoned") then
				local _,_,soulName =  strfind(arg2,"LP Character (%a+) Soulstoned")
				LockPort_Stoned()
				LockPortStoneNAME:SetText(soulName)
				LPPrint(""..LockPortStoneNAME:GetText().." has been Soulstoned")
			end
		elseif arg1 == MSG_PREFIX_STONE_REMOVE then -- Stone Remove
			if strfind(arg2,"LP Character %a+ Soulstone faded") then
				local _,_,soulfadedName =  strfind(arg2,"LP Character (%a+) Soulstone faded")
				LockPort_NotStoned()
				LockPortStonefadedNAME:SetText(soulfadedName)
				LockPortStoneNAME:SetText("")
				LPPrint(""..LockPortStonefadedNAME:GetText().." no longer has a Soulstone.")
			end
		end
		elseif event == "CHAT_MSG_SPELL_AURA_GONE_OTHER" or event == "CHAT_MSG_SPELL_AURA_GONE_SELF" then -- Stone Fade
			if string.find(arg1, "Soulstone Resurrection fades from "..LockPortStoneNAME:GetText()..".") then
				--LPPrint("LockPortStoneNAME:GetText()") --debug
				SendAddonMessage(MSG_PREFIX_STONE_REMOVE, "LP Character "..LockPortStoneNAME:GetText().." Soulstone faded", "RAID")
			end
		--elseif event == "UNITDIESOTHER" or event == "UNITDIESSELF" then -- Stone Fades Player Died
			--if string.find(arg1, ""..LockPortStoneNAME:GetText().." dies.") then
				--LPPrint(LockPortStoneNAME:GetText()) --debug
				--SendAddonMessage(MSG_PREFIX_STONE_REMOVE, "LP Character "..LockPortStoneNAME:GetText().." Soulstone faded", "RAID")
			--end
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

function LPPrint(msg)
	if not msg then msg = "" end
	DEFAULT_CHAT_FRAME:AddMessage(RED_FONT_COLOR_CODE.."LockPort: "..NORMAL_FONT_COLOR_CODE..msg)
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
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - no Raid found")
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
					DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - Player is in combat")
				end
			else
				DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - Player " .. tostring(name) .. " not found in raid. UnitID: " .. tostring(UnitID))
				SendAddonMessage(MSG_PREFIX_REMOVE, name, "RAID")
				LockPort_UpdateList()
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - no Raid found")
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

function LockPort_Stoned()
		LockPortStoneCross:Hide()
		LockPortStoneCheck:Show()
end

function LockPort_NotStoned()
		LockPortStoneCross:Show()
		LockPortStoneCheck:Hide()
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
				
				if LockPort_BrowseDB[i].rClass == "Druid" then --set class color
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

function LockPort_SlashCommand( msg ) --Slash Handler

	if msg == "help" then
		DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r usage:")
		DEFAULT_CHAT_FRAME:AddMessage("/LockPort { help | show | zone | whisper | sound }")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9help|r: prints out this help")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9show|r: shows/hides the current summon list")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9zone|r: toggles zoneinfo in /ra and /w")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9whisper|r: toggles the usage of /w")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9sound|r: toggles the sound")
		DEFAULT_CHAT_FRAME:AddMessage("To drag the frame use shift + left mouse button")
	elseif msg == "show" then -- Show Toggle (/lockport show)
		if LockPort_RequestFrame:IsVisible() then
			LockPort_RequestFrame:Hide()
		else
			LockPort_UpdateList()
			ShowUIPanel(LockPort_RequestFrame, 1)
		end
	elseif msg == "zone" then
		if LockPortOptions["zone"] == true then -- Zone Toggle (/lockport zone)
			LockPortOptions["zone"] = false
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - zoneinfo: |cffff0000disabled|r")
		elseif LockPortOptions["zone"] == false then
			LockPortOptions["zone"] = true
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - zoneinfo: |cff00ff00enabled|r")
		end
	elseif msg == "whisper" then  -- Whisper Toggle (/lockport whisper)
		if LockPortOptions["whisper"] == true then
			LockPortOptions["whisper"] = false
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - whisper: |cffff0000disabled|r")
		elseif LockPortOptions["whisper"] == false then
			LockPortOptions["whisper"] = true
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - whisper: |cff00ff00enabled|r")
		end
	elseif msg == "sound" then -- Sound Toggle (/lockport sound)
		if LockPortOptions["sound"] == true then
			LockPortOptions["sound"] = false
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - sound: |cffff0000disabled|r")
		elseif LockPortOptions["sound"] == false then
			LockPortOptions["sound"] = true
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - sound: |cff00ff00enabled|r")
		end
	elseif msg == "soul" then -- SoulStone Toggle (/lockport soul) Recommended on
		if LockPortOptions["soul"] == true then
			LockPortOptions["soul"] = false
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - soul: |cffff0000disabled|r")
		elseif LockPortOptions["soul"] == false then
			LockPortOptions["soul"] = true
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - soul: |cff00ff00enabled|r")
		end
	elseif msg == "stone" then -- Stone Frame Toggle (/lockport stone)
		if LockPort_SoulFrame:IsVisible() then
			LockPort_SoulFrame:Hide()
		else
			ShowUIPanel(LockPort_SoulFrame, 1)
		end
	else
		if LockPort_RequestFrame:IsVisible() then -- LockPort Frame Toggle (/lockport)
			LockPort_RequestFrame:Hide()
		else
			LockPort_UpdateList()
			ShowUIPanel(LockPort_RequestFrame, 1)
		end
	
	end
	
end

function LockPort_GetClassColour(class) -- class color
	if (class) then
		local color = RAID_CLASS_COLORS[class]
		if (color) then
			return color
		end
	end
	return {r = 0.5, g = 0.5, b = 1}
end

function LockPort_getRaidMembers() -- raid member
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
-------------
--Soul Stone
-------------
function SoulMonitor_OnEvent(event, arg1, arg2) -- Soul Stone Casted
   if (LockPortOptions.soul and (event == "SPELLCAST_START")) then
     if ((arg1 == "Soulstone Resurrection") and LockPortOptions.soul) then
		SendChatMessage("I am saving %t's soul in a soulstone.", "SAY")
		SendChatMessage("You have been Soul Stoned.", "WHISPER", nil, GetUnitName("target"))
		SendAddonMessage(MSG_PREFIX_STONE_ADD, "LP Character "..GetUnitName("target").." Soulstoned", "RAID")
	   end
   end
end

function LockPort_Shards() -- Shard Counter
	i=1; 
	for bag = 0,4,1 do 
		for slot = 1, GetContainerNumSlots(bag), 1 do 
			local name = GetContainerItemLink(bag,slot); 
			if name and string.find(name,"Soul Shard") then 
				LockPortShardCount:SetText(i);
				LockPortShardCount:SetTextColor(1.0, 0.55, 0.0);
				LockPortShardCount:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE, ")
				i=i+1; 
			end
		end
	end
end

local f = CreateFrame'Frame' -- Events to listen for:
f:RegisterEvent'BAG_UPDATE'
f:RegisterEvent'PLAYER_REGEN_ENABLED'
f:RegisterEvent("PLAYER_LOGIN")

local combat, bag = nil, nil -- Check if something is in the bags and check if player exited combat.
f:SetScript('OnEvent', function()
	if event == "BAG_UPDATE" then
		bag = true
	elseif event == "PLAYER_REGEN_ENABLED" then
		combat = true
	end

	if bag and combat then
		bag, combat = nil, nil
		LockPort_Shards();
	end
end)