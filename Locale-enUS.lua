local L = AceLibrary("AceLocale-2.2"):new("LockPort")

L:RegisterTranslations("enUS", 
	function()
		return {
			["Shadow Bolt"] = true,
			["Flamewaker Priest"] = true,
			["Giant Eye Tentacle"] = true,
			["There are still curses missing but you already casted a more important curse"] = true,
			["All curses are present."] = true,
			["Your Curse of (.+) was resisted by (.+)."] = true,
			["Your Curse of %s was |cffff0000resisted|r by %s."] = true,
			["^Curse of (.+) fades from ([%w%s:]+)."] = true,
			["Your curse has faded."] = true,
			["You have slain %s!"] = true,
			["Curse of"] = true,
			["You fail to cast Summon Dreadsteed: You can't mount here."] = true,
		}
	end
)
