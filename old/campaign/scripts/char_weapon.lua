-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	onLinkChanged();

	local node = getDatabaseNode();
	DB.addHandler(node.getNodeName(), "onChildUpdate", onDataChanged);
	DB.addHandler(DB.getPath(DB.getChild(node, "..."), "abilities.*.score"), "onUpdate", onDataChanged);
	onDataChanged();
end

function onClose()
	local node = getDatabaseNode();
	DB.removeHandler(node.getNodeName(), "onChildUpdate", onDataChanged);
	DB.removeHandler(DB.getPath(DB.getChild(node, "..."), "abilities.*.score"), "onUpdate", onDataChanged);
end

function onLinkChanged()
	local node = getDatabaseNode();
	local sClass, sRecord = DB.getValue(node, "shortcut", "", "");
	if (sRecord or "") ~= "" then
		local sInvList = DB.getPath(DB.getChild(node, "..."), "inventorylist") .. ".";
		if sRecord:sub(1, #sInvList) == sInvList then
			carried.setLink(DB.findNode(DB.getPath(sRecord, "carried")));
		end
	end
end

function onDataChanged()
	onAttackChanged();
	onDamageChanged();
	
	local bRanged = (type.getValue() ~= 0);
	label_ammo.setVisible(bRanged);
	maxammo.setVisible(bRanged);
	ammocounter.setVisible(bRanged);
end

function highlightAttack(bOnControl)
	if bOnControl then
		attackshade.setFrame("rowshade");
	else
		attackshade.setFrame(nil);
	end
end
			
function onAttackAction(draginfo)
	local nodeWeapon = getDatabaseNode();
	local nodeChar = nodeWeapon.getChild("...")
	local rActor = ActorManager.getActor("pc", nodeChar);
	local rAction = {};
	
	local aWeaponProps = StringManager.split(DB.getValue(nodeWeapon, "properties", ""):lower(), ",", true);
	
	rAction.label = name.getValue();
	rAction.stat = DB.getValue(nodeWeapon, "attackstat", "");
	if type.getValue() == 2 then
		rAction.range = "R";
		if rAction.stat == "" then
			rAction.stat = "strength";
		end
	elseif type.getValue() == 1 then
		rAction.range = "R";
		if rAction.stat == "" then
			rAction.stat = "dexterity";
		end
	else
		rAction.range = "M";
		if rAction.stat == "" then
			rAction.stat = "strength";
		end
	end
	rAction.modifier = DB.getValue(nodeWeapon, "attackbonus", 0) + ActorManager2.getAbilityBonus(rActor, rAction.stat);
	
	if prof.getValue() == 1 then
		rAction.modifier = rAction.modifier + DB.getValue(nodeChar, "profbonus", 0);
	end
	rAction.bWeapon = true;
	
	-- Decrement ammo
	local nMaxAmmo = DB.getValue(nodeWeapon, "maxammo", 0);
	if nMaxAmmo > 0 then
		local nUsedAmmo = DB.getValue(nodeWeapon, "ammo", 0);
		if nUsedAmmo >= nMaxAmmo then
			ChatManager.Message(Interface.getString("char_message_atkwithnoammo"), true, rActor);
		else
			DB.setValue(nodeWeapon, "ammo", "number", nUsedAmmo + 1);
		end
	end
	
	-- Determine crit range
	local nCritThreshold = 20;
	if sAttackType == "R" then
		nCritThreshold = DB.getValue(nodeChar, "weapon.critrange.ranged", 20);
	else
		nCritThreshold = DB.getValue(nodeChar, "weapon.critrange.melee", 20);
	end
	for _,vProperty in ipairs(aWeaponProps) do
		local nPropCritRange = tonumber(vProperty:match("crit range (%d+)")) or 20;
		if nPropCritRange < nCritThreshold then
			nCritThreshold = nPropCritRange;
		end
	end
	if nCritThreshold > 1 and nCritThreshold < 20 then
		rAction.nCritRange = nCritThreshold;
	end
	
	ActionAttack.performRoll(draginfo, rActor, rAction);
	return true;
end

function onDamageAction(draginfo)
	local nodeWeapon = getDatabaseNode();
	local nodeChar = nodeWeapon.getChild("...")
	local rActor = ActorManager.getActor("pc", nodeChar);

	local aWeaponProps = StringManager.split(DB.getValue(nodeWeapon, "properties", ""):lower(), ",", true);
	
	local rAction = {};
	rAction.bWeapon = true;
	rAction.label = DB.getValue(nodeWeapon, "name", "");
	if type.getValue() == 0 then
		rAction.range = "M";
	else
		rAction.range = "R";
	end

	local sBaseAbility = "strength";
	if type.getValue() == 1 then
		sBaseAbility = "dexterity";
	end
	
	rAction.clauses = {};
	local aDamageNodes = UtilityManager.getSortedTable(DB.getChildren(nodeWeapon, "damagelist"));
	for _,v in ipairs(aDamageNodes) do
		local sDmgAbility = DB.getValue(v, "stat", "");
		if sDmgAbility == "base" then
			sDmgAbility = sBaseAbility;
		end
		local aDmgDice = DB.getValue(v, "dice", {});
		local nDmgMod = DB.getValue(v, "bonus", 0) + ActorManager2.getAbilityBonus(rActor, sDmgAbility);
		local sDmgType = DB.getValue(v, "type", "");
		
		table.insert(rAction.clauses, { dice = aDmgDice, stat = sDmgAbility, modifier = nDmgMod, dmgtype = sDmgType });
	end
	
	-- Check for reroll tag
	local nReroll = 0;
	for _,vProperty in ipairs(aWeaponProps) do
		local nPropReroll = tonumber(vProperty:match("reroll (%d+)")) or 0;
		if nPropReroll > nReroll then
			nReroll = nPropReroll;
		end
	end
	if nReroll > 0 then
		rAction.label = rAction.label .. " [REROLL " .. nReroll .. "]";
	end
	
	ActionDamage.performRoll(draginfo, rActor, rAction);
	return true;
end

function onAttackChanged()
	local nodeWeapon = getDatabaseNode();
	local nodeChar = nodeWeapon.getChild("...")
	local rActor = ActorManager.getActor("pc", nodeChar);

	local sAbility = DB.getValue(nodeWeapon, "attackstat", "");
	if sAbility == "" then
		if type.getValue() == 1 then
			sAbility = "dexterity";
		else
			sAbility = "strength";
		end
	end
	local nMod = DB.getValue(nodeWeapon, "attackbonus", 0) + ActorManager2.getAbilityBonus(rActor, sAbility);

	if prof.getValue() ~= 0 then
		nMod = nMod + DB.getValue(nodeChar, "profbonus", 0);
	end
	
	attackview.setValue(nMod);
end

function onDamageChanged()
	local nodeWeapon = getDatabaseNode();
	local nodeChar = nodeWeapon.getChild("...")
	local rActor = ActorManager.getActor("pc", nodeChar);
	
	local sBaseAbility = "strength";
	if type.getValue() == 1 then
		sBaseAbility = "dexterity";
	end
	
	local aDamage = {};
	local aDamageNodes = UtilityManager.getSortedTable(DB.getChildren(nodeWeapon, "damagelist"));
	for _,v in ipairs(aDamageNodes) do
		local nMod = DB.getValue(v, "bonus", 0);
		local sAbility = DB.getValue(v, "stat", "");
		if sAbility == "base" then
			sAbility = sBaseAbility;
		end
		if sAbility ~= "" then
			nMod = nMod + ActorManager2.getAbilityBonus(rActor, sAbility);
		end
		
		local aDice = DB.getValue(v, "dice", {});
		if #aDice > 0 or nMod ~= 0 then
			local sDamage = StringManager.convertDiceToString(DB.getValue(v, "dice", {}), nMod);
			local sType = DB.getValue(v, "type", "");
			if sType ~= "" then
				sDamage = sDamage .. " " .. sType;
			end
			table.insert(aDamage, sDamage);
		end
	end

	damageview.setValue(table.concat(aDamage, "\n"));
end

