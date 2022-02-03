local LockPortOptions_DefaultSettings = {
	whisper = true,
	zone = true,
	zone = true,
	sound = true,
	soul = true,
	doom = false
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
end

local s = CreateFrame("Frame", nil, UIParent)
s:RegisterEvent("PLAYER_LOGIN")
s:RegisterEvent("PLAYER_ENTERING_WORLD")
s:SetScript("OnEvent", function(self, event)
	LockPortStoneCross:Show()
	LockPortStoneCheck:Hide()

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
    
	SlashCmdList["LockPort"] = LockPort_SlashCommand
	SLASH_LockPort1 = "/LockPort"
	
	MSG_PREFIX_ADD	= "LPAdd"
	MSG_PREFIX_REMOVE	= "LPRemove"
	LockPortDB = {}

	--localization
	LockPortLoc_Header = "|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r"
end

function LockPort_EventFrame_OnEvent()

	if (event == "PLAYER_ENTERING_WORLD") then
		LockPort_Shards()
	end
	if (event == "BAG_UPDATE") then
		LockPort_Shards()
	end

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
		if string.find(arg1, "^456") then
			SendAddonMessage(MSG_PREFIX_ADD, arg2, "RAID")
		end
		-- if string.find(text, "^I am saving (%w+)'s soul in a soulstone.") then
			-- LockPortStoneCheck:Show()
			-- LockPortStoneCross:Hide()
		-- end

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
		DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r usage:")
		DEFAULT_CHAT_FRAME:AddMessage("/LockPort { help | show | zone | whisper | sound | curse | cursebolt | doom }")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9help|r: prints out this help")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9show|r: shows the current summon list")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9zone|r: toggles zoneinfo in /ra and /w")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9whisper|r: toggles the usage of /w")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9sound|r: toggles the sound")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9curse|r: Cast curse based on priority and if already exists. \n    Macro: |cfB34DFFf/LockPort curse|r")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9cursebolt|r: Casts Shadow Bolt if all curses are present. \n    Macro: |cfB34DFFf/LockPort curse cursebolt|r")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9doom|r: toggles doom on and off for curse rotations")
		DEFAULT_CHAT_FRAME:AddMessage("To drag the frame use shift + left mouse button")
	elseif msg == "show" then
		for i, v in ipairs(LockPortDB) do
			DEFAULT_CHAT_FRAME:AddMessage(tostring(v))
		end
	elseif msg == "zone" then
		if LockPortOptions["zone"] == true then
			LockPortOptions["zone"] = false
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - zoneinfo: |cffff0000disabled|r")
		elseif LockPortOptions["zone"] == false then
			LockPortOptions["zone"] = true
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - zoneinfo: |cff00ff00enabled|r")
		end
	elseif msg == "whisper" then
		if LockPortOptions["whisper"] == true then
			LockPortOptions["whisper"] = false
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - whisper: |cffff0000disabled|r")
		elseif LockPortOptions["whisper"] == false then
			LockPortOptions["whisper"] = true
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - whisper: |cff00ff00enabled|r")
		end
	elseif msg == "sound" then
		if LockPortOptions["sound"] == true then
			LockPortOptions["sound"] = false
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - sound: |cffff0000disabled|r")
		elseif LockPortOptions["sound"] == false then
			LockPortOptions["sound"] = true
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - sound: |cff00ff00enabled|r")
		end
	elseif msg == "soul" then
		if LockPortOptions["soul"] == true then
			LockPortOptions["soul"] = false
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - soul: |cffff0000disabled|r")
		elseif LockPortOptions["soul"] == false then
			LockPortOptions["soul"] = true
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - soul: |cff00ff00enabled|r")
		end
	elseif msg == "curse" then
		LockPort:Curse()
	elseif msg == "cursebolt" then
		LockPort:CurseOrShadowbolt()
	elseif msg == "doom" then
		if LockPortOptions["doom"] == true then
			LockPortOptions["doom"] = false
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - doom: |cffff0000disabled|r")
		elseif LockPortOptions["doom"] == false then
			LockPortOptions["doom"] = true
			DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r - doom: |cff00ff00enabled|r")
		end
	elseif msg == "stone" then
		if LockPort_SoulFrame:IsVisible() then
			LockPort_SoulFrame:Hide()
		else
			ShowUIPanel(LockPort_SoulFrame, 1)
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

--Soul Stone
function SoulMonitor_OnEvent(event, arg1, arg2) 
   if (LockPortOptions.soul and (event == "SPELLCAST_START")) then
     if ((arg1 == "Soulstone Resurrection") and LockPortOptions.soul) then
		SendChatMessage("I am saving %t's soul in a soulstone.", "SAY")
		SendChatMessage("You have been Soul Stoned.", "WHISPER", nil, GetUnitName("target"))
	   end
   end
end

-- Curses


-- Initialization

local L = AceLibrary("AceLocale-2.2"):new("LockPort")
local BB = AceLibrary("Babble-Boss-2.2")
local BS = AceLibrary("Babble-Spell-2.2")


LockPort = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceModuleCore-2.0", "AceDB-2.0", "AceDebug-2.0")
LockPort.revision = 2

LockPort.defaultDB = {
	posx = nil,
	posy = nil,
	visible = nil,
}

function LockPort:OnInitialize()

end

function LockPort:OnEnable()
	self:RegisterEvent("SpellStatus_SpellCastInstant")
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function LockPort:OnDisable()

end

-- Variables

-- targets where curse of tongues should be used
local tongueTarget = {
	[L["Flamewaker Priest"]] = true,
	[BB["The Prophet Skeram"]] = true,
	[L["Giant Eye Tentacle"]] = true
}

-- targets where curse of recklessness should not be used
local recklessnessException = {
	[BB["Battleguard Sartura"]] = true,
	[BB["Patchwerk"]] = true,
}

local cursePriority = {
	[BS["Curse of Tongues"]] = 0,
	[BS["Curse of Shadow"]] = 3,
	[BS["Curse of the Elements"]] = 2,
	[BS["Curse of Recklessness"]] = 1,
	[BS["Curse of Weakness"]] = 0,
	[BS["Curse of Agony"]] = 0,
	[BS["Curse of Doom"]] = 0,
	[BS["Curse of Exhaustion"]] = 0,
}

local curseTarget = nil
local curseTime = nil
local curseCasted = nil

-- Slashcommand Handlers
function LockPort:Curse()
		local spell = self:GetMostImportantMissingCurse()

		if spell then
			if not (curseCasted and cursePriority[curseCasted] < cursePriority[spell]) then
				CastSpellByName(spell)
			else
				self:Print(L["There are still curses missing but you already casted a more important curse"])
			end
		else
			self:Print(L["All curses are present."])
		end
	end

function LockPort:CurseOrShadowbolt()
		local spell = self:GetMostImportantMissingCurse()

		if spell then
			if not (curseCasted and cursePriority[curseCasted] < cursePriority[spell]) then
				CastSpellByName(spell)
			else
				--self:Print(L["There are still curses missing but you already casted a more important curse"])
				CastSpellByName(BS["Shadow Bolt"])
			end
		else
			CastSpellByName(BS["Shadow Bolt"])
		end
	end

-- Event Handlers
function LockPort:CHAT_MSG_SPELL_SELF_DAMAGE(msg)
	local start, ending, userspell, target = string.find(msg, L["Your Curse of (.+) was resisted by (.+)."])
	if userspell and target then
		curseTarget = nil
		curseTime = nil
		curseCasted = nil
		self:Print(string.format(L["Your Curse of %s was |cffff0000resisted|r by %s."], userspell, target))
		--PlaySound("igQuestFailed" ,"master")
		PlaySoundFile("Interface\\Addons\\LockPort\\img\\toasty.mp3")
    end
	
	local start, ending, curse, target = string.find(msg, L["^Curse of (.+) fades from ([%w%s:]+)."])
    if target and target == curseTarget and curseCasted == BS[string.format("Curse of %s", curse)] then
        curseTarget = nil
		curseTime = nil
		curseCasted = nil
		
		self:Print(L["Your curse has faded."])
    end
end

function LockPort:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if curseTarget and (msg == string.format(UNITDIESOTHER, curseTarget) or msg == string.format(L["You have slain %s!"], curseTarget)) then
		curseTarget = nil
		curseTime = nil
		curseCasted = nil
	end
end

-- Utility Functions
function LockPort:CastedCurse(curse)
	if curse then		
		curseTarget = UnitName("target")
		curseTime = GetTime()
		curseCasted = curse
	end
end

function LockPort:HasDebuff(iconPath)
	for i = 1, 16 do
		local debuff = UnitDebuff("target", i)
		if debuff and debuff == iconPath then
			return true
		end
	end
	
	return false
end

function LockPort:HasTongues()
	return LockPort:HasDebuff("Interface\\Icons\\Spell_Shadow_CurseOfTounges")
end
function LockPort:HasShadows()
	return LockPort:HasDebuff("Interface\\Icons\\Spell_Shadow_CurseOfAchimonde")
end
function LockPort:HasElements()
	return LockPort:HasDebuff("Interface\\Icons\\Spell_Shadow_ChillTouch")
end
function LockPort:HasRecklessness()
	return LockPort:HasDebuff("Interface\\Icons\\Spell_Shadow_UnholyStrength")
end
function LockPort:HasDoom()
	return LockPort:HasDebuff("Interface\\Icons\\Spell_Shadow_Auraofdarkness")
end

function LockPort:WarlocksAreMoreImportant()
	local result = true
	local warlocks = 0
	local mages = 0
	
	for i = 1, GetNumRaidMembers(), 1 do
		local _, playerClass = UnitClass("Raid" .. i)
		
		if playerClass == "WARLOCK" then
			warlocks = warlocks + 1
		elseif playerClass == "MAGE" then
			mages = mages + 1
		end
	end
	
	if mages > warlocks then
		result = false -- there are more stupid mages than warlocks
	end
	return result
end

function LockPort:GetMostImportantMissingCurse()
	local target = UnitName("target")
	local curse = nil
	local priority = 0
	local magelock = true
	local warlocks = 0
	local mages = 0
	
	for i = 1, GetNumRaidMembers(), 1 do
		local _, playerClass = UnitClass("Raid" .. i)
		
		if playerClass == "WARLOCK" then
			warlocks = warlocks + 1
		elseif playerClass == "MAGE" then
			mages = mages + 1
		end
	end
	
	if mages > warlocks then
		magelock = false -- there are more stupid mages than warlocks
	end
	if not magelock then -- more mages cast elements before shadow
		if not recklessnessException[target] and not LockPort:HasRecklessness() then
			curse = BS["Curse of Recklessness"]
			priority = cursePriority[BS["Curse of Recklessness"]]
		end
		if LockPort:HasRecklessness() and not LockPort:HasElements() then
			curse = BS["Curse of the Elements"]
			priority = cursePriority[BS["Curse of the Elements"]]
		end
		if LockPort:HasRecklessness() and LockPort:HasElements() and not LockPort:HasShadows() then
			curse = BS["Curse of Shadow"]
			priority = cursePriority[BS["Curse of Shadow"]]
		end
		if LockPortOptions.doom then
			if LockPort:HasRecklessness() and LockPort:HasElements() and LockPort:HasShadows()  and not LockPort:HasDoom() then
				curse = BS["Curse of Doom"]
				priority = cursePriority[BS["Curse of Doom"]]
			end
		elseif not LockPortOptions.doom then
			if LockPort:HasRecklessness() and LockPort:HasElements() and LockPort:HasShadows()  and not LockPort:HasDoom() then
				self:Print(L["All curses are present and Doom is turned off."])
			end
		end
		if tongueTarget[target] and not LockPort:HasTongues() then
			curse = BS["Curse of Tongues"]
			priority = cursePriority[BS["Curse of Tongues"]]
		end
	elseif magelock then -- more locks cast shadow before elements
		if not recklessnessException[target] and not LockPort:HasRecklessness() then
			curse = BS["Curse of Recklessness"]
			priority = cursePriority[BS["Curse of Recklessness"]]
		end
		if LockPort:HasRecklessness() and not LockPort:HasShadows() then
			curse = BS["Curse of Shadow"]
			priority = cursePriority[BS["Curse of Shadow"]]
		end
		if LockPort:HasRecklessness() and LockPort:HasShadows() and not LockPort:HasElements() then
			curse = BS["Curse of the Elements"]
			priority = cursePriority[BS["Curse of the Elements"]]
		end
		if LockPortOptions.doom then
			if LockPort:HasRecklessness() and LockPort:HasElements() and LockPort:HasShadows()  and not LockPort:HasDoom() then
				curse = BS["Curse of Doom"]
				priority = cursePriority[BS["Curse of Doom"]]
			end
		elseif not LockPortOptions.doom then
			if LockPort:HasRecklessness() and LockPort:HasElements() and LockPort:HasShadows()  and not LockPort:HasDoom() then
				self:Print(L["All curses are present and Doom is turned off."])
			end
		end
		if tongueTarget[target] and not LockPort:HasTongues() then
			curse = BS["Curse of Tongues"]
			priority = cursePriority[BS["Curse of Tongues"]]
		end
	elseif recklessnessException[target] and magelock then -- if target doesnt get curse of recklessness and more locks than mages
		if not recklessnessException[target] and not LockPort:HasRecklessness() then
			curse = BS["Curse of Recklessness"]
			priority = cursePriority[BS["Curse of Recklessness"]]
		end
		if not LockPort:HasShadows() then
			curse = BS["Curse of Shadow"]
			priority = cursePriority[BS["Curse of Shadow"]]
		end
		if LockPort:HasShadows() and not LockPort:HasElements() then
			curse = BS["Curse of the Elements"]
			priority = cursePriority[BS["Curse of the Elements"]]
		end
		if LockPortOptions.doom then
			if LockPort:HasRecklessness() and LockPort:HasElements() and LockPort:HasShadows()  and not LockPort:HasDoom() then
				curse = BS["Curse of Doom"]
				priority = cursePriority[BS["Curse of Doom"]]
			end
		elseif not LockPortOptions.doom then
			if LockPort:HasRecklessness() and LockPort:HasElements() and LockPort:HasShadows()  and not LockPort:HasDoom() then
				self:Print(L["All curses are present and Doom is turned off."])
			end
		end
		if tongueTarget[target] and not LockPort:HasTongues() then
			curse = BS["Curse of Tongues"]
			priority = cursePriority[BS["Curse of Tongues"]]
		end
	elseif recklessnessException[target] and not magelock then -- if target doesnt get curse of recklessness and more mages than locks
		if not recklessnessException[target] and not LockPort:HasRecklessness() then
			curse = BS["Curse of Recklessness"]
			priority = cursePriority[BS["Curse of Recklessness"]]
		end
		if not LockPort:HasElements() then
			curse = BS["Curse of the Elements"]
			priority = cursePriority[BS["Curse of the Elements"]]
		end
		if LockPort:HasElements() and not LockPort:HasShadows() then
			curse = BS["Curse of Shadow"]
			priority = cursePriority[BS["Curse of Shadow"]]
		end
		if LockPortOptions.doom then
			if LockPort:HasRecklessness() and LockPort:HasElements() and LockPort:HasShadows()  and not LockPort:HasDoom() then
				curse = BS["Curse of Doom"]
				priority = cursePriority[BS["Curse of Doom"]]
			end
		elseif not LockPortOptions.doom then
			if LockPort:HasRecklessness() and LockPort:HasElements() and LockPort:HasShadows()  and not LockPort:HasDoom() then
			end
		end
		if tongueTarget[target] and not LockPort:HasTongues() then
			curse = BS["Curse of Tongues"]
			priority = cursePriority[BS["Curse of Tongues"]]
		end
	end
	return curse
end

local L = AceLibrary("AceLocale-2.2"):new("LockPort")
local module = LockPort
local frame = nil
local list = {}
local playerName = UnitName("player")
local BS = AceLibrary("Babble-Spell-2.2")
local BZ = AceLibrary("Babble-Zone-2.2")
local spellStatus = AceLibrary("SpellStatus-1.0")


-- Event module Handlers
function module:SpellStatus_SpellCastInstant(id, name, rank, fullName, startTime, stopTime, duration, delayTotal)
	if string.find(name, L["Curse of"]) then
		LockPort:CastedCurse(name)
	end
end

-- shards
function LockPort_Shards() -- Debugging
	icon = "Interface\\AddOns\\TitanCheckStone\\soulstone"
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

-- Events to listen for:
local f = CreateFrame'Frame'
f:RegisterEvent'BAG_UPDATE'
f:RegisterEvent'PLAYER_REGEN_ENABLED'
f:RegisterEvent("PLAYER_LOGIN")

-- Check if something is in the bags and check if player exited combat.
local combat, bag = nil, nil
f:SetScript('OnEvent', function()
	-- DEFAULT_CHAT_FRAME:AddMessage("registered")
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