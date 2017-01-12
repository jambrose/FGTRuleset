-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- Ruleset action types
actions = {
	["dice"] = { bUseModStack = "true" },
	["table"] = { },
	["effect"] = { sIcon = "action_effect", sTargeting = "all" },
	["attack"] = { sIcon = "action_attack", sTargeting = "each", bUseModStack = true },
	["damage"] = { sIcon = "action_damage", sTargeting = "each", bUseModStack = true },
	["heal"] = { sIcon = "action_heal", sTargeting = "all", bUseModStack = true },
	["skill"] = { bUseModStack = true },
	["init"] = { bUseModStack = true },
	["save"] = { bUseModStack = true },
	["ability"] = { bUseModStack = true },
	["death"] = { },	
	-- TRIGGERED
};

targetactions = {
	"effect",
	"attack",
	"damage",
	"heal",
	"effect"
};
currencies = { "MCr", "KCr", "Cr" };
currencyDefault = "Cr";

function onInit()	
	-- Languages
	languages = {
		-- Standard languages
		[Interface.getString("language_value_common")] = "",
		[Interface.getString("language_value_anglic")] = "Anglic",
		[Interface.getString("language_value_vilani")] = "Vilani",
		[Interface.getString("language_value_zdetl")] = "Zdetl",
		[Interface.getString("language_value_oynprith")] = "Oynprith",
		-- Exotic languages
	}
	languagefonts = {
		[Interface.getString("language_value_anglic")] = "Anglic",
		[Interface.getString("language_value_vilani")] = "Vilani",
		[Interface.getString("language_value_zdetl")] = "Zdetl",
		[Interface.getString("language_value_oynprith")] = "Oynprith"
	}
end

function getCharSelectDetailHost(nodeChar)
	return "";
end

function requestCharSelectDetailClient()
	return "name";
end

function receiveCharSelectDetailClient(vDetails)
	return vDetails, "";
end

function getCharSelectDetailLocal(nodeLocal)
	return DB.getValue(nodeLocal, "name", ""), "";
end

function getDistanceUnitsPerGrid()
	return 5;
end
