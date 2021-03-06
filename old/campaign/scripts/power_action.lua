-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	registerMenuItem(Interface.getString("power_menu_actiondelete"), "deletepointer", 4);
	registerMenuItem(Interface.getString("list_menu_deleteconfirm"), "delete", 4, 3);
	
	updateDisplay();
	
	local node = getDatabaseNode();
	windowlist.setOrder(node);

	local sNode = getDatabaseNode().getNodeName();
	DB.addHandler(sNode, "onChildUpdate", onDataChanged);
	onDataChanged();
end

function onClose()
	local sNode = getDatabaseNode().getNodeName();
	DB.removeHandler(sNode, "onChildUpdate", onDataChanged);
end

function onMenuSelection(selection, subselection)
	if selection == 4 and subselection == 3 then
		getDatabaseNode().delete();
	end
end

function highlight(bState)
	if bState then
		setFrame("rowshade");
	else
		setFrame(nil);
	end
end

function updateDisplay()
	local node = getDatabaseNode();
	
	local sType = DB.getValue(node, "type", "");
	
	local bShowCast = (sType == "cast");
	local bShowDamage = (sType == "damage");
	local bShowHeal = (sType == "heal");
	local bShowEffect = (sType == "effect");
	
	castbutton.setVisible(bShowCast);
	castlabel.setVisible(bShowCast);
	castbutton.setVisible(bShowCast);
	attackbutton.setVisible(bShowCast);
	attackviewlabel.setVisible(bShowCast);
	attackview.setVisible(bShowCast);
	savebutton.setVisible(bShowCast);
	saveviewlabel.setVisible(bShowCast);
	saveview.setVisible(bShowCast);
	castdetail.setVisible(bShowCast);
	
	damagebutton.setVisible(bShowDamage);
	damagelabel.setVisible(bShowDamage);
	damageview.setVisible(bShowDamage);
	damagedetail.setVisible(bShowDamage);

	healbutton.setVisible(bShowHeal);
	heallabel.setVisible(bShowHeal);
	healview.setVisible(bShowHeal);
	healdetail.setVisible(bShowHeal);

	effectbutton.setVisible(bShowEffect);
	effectlabel.setVisible(bShowEffect);
	effectview.setVisible(bShowEffect);
	durationview.setVisible(bShowEffect);
	effectdetail.setVisible(bShowEffect);
end

function updateViews()
	onDataChanged();
end

function onDataChanged()
	local sType = DB.getValue(getDatabaseNode(), "type", "");
	
	if sType == "cast" then
		onCastChanged();
	elseif sType == "damage" then
		onDamageChanged();
	elseif sType == "heal" then
		onHealChanged();
	elseif sType == "effect" then
		onEffectChanged();
	end
end

function onCastChanged()
	local nodeAction = getDatabaseNode();
	local nodeActor = nodeAction.getChild(".....")
	local rActor = ActorManager.getActor("", nodeActor);
	
	local sAttack = "";
	local sAttackType = DB.getValue(nodeAction, "atktype", "");
	if sAttackType == "melee" then
		sAttack = Interface.getString("melee");
	elseif sAttackType == "ranged" then
		sAttack = Interface.getString("ranged");
	end
	
	if sAttack ~= "" then
		local nGroupMod, sGroupStat = PowerManager.getGroupAttackBonus(rActor, nodeAction, "");
		
		local nAttackMod = 0;
		local sAttackBase = DB.getValue(nodeAction, "atkbase", "");
		if sAttackBase == "fixed" then
			nAttackMod = DB.getValue(nodeAction, "atkmod", 0);
		elseif sAttackBase == "ability" then
			local sAbility = DB.getValue(nodeAction, "atkstat", "");
			if sAbility == "base" then
				sAbility = sGroupStat;
			end
			local nAttackProf = DB.getValue(nodeAction, "atkprof", 1);
			
			nAttackMod = ActorManager2.getAbilityBonus(rActor, sAbility) + DB.getValue(nodeAction, "atkmod", 0);
			if nAttackProf == 1 then
				nAttackMod = nAttackMod + DB.getValue(ActorManager.getCreatureNode(rActor), "profbonus", 0);
			end
		else
			nAttackMod = nGroupMod + DB.getValue(nodeAction, "atkmod", 0);
		end

		if nAttackMod ~= 0 then
			sAttack = string.format("%s %+d", sAttack, nAttackMod);
		end
	end
	
	local sSave = "";
	local sSaveType = DB.getValue(nodeAction, "savetype", "");
	if sSaveType ~= "" then
		local nGroupDC, sGroupStat = PowerManager.getGroupSaveDC(rActor, nodeAction, sSaveType);
		if sSaveType == "base" then
			sSaveType = sGroupStat;
		end
		
		local nDC = 0;
		local sSaveBase = DB.getValue(nodeAction, "savedcbase", "");
		if sSaveBase == "fixed" then
			nDC = DB.getValue(nodeAction, "savedcmod", 0);
		elseif sSaveBase == "ability" then
			local sAbility = DB.getValue(nodeAction, "savedcstat", "");
			if sAbility == "base" then
				sAbility = sGroupStat;
			end
			local nSaveProf = DB.getValue(nodeAction, "savedcprof", 1);
			
			nDC = 8 + ActorManager2.getAbilityBonus(rActor, sAbility) + DB.getValue(nodeAction, "savedcmod", 0);
			if nSaveProf == 1 then
				nDC = nDC + DB.getValue(ActorManager.getCreatureNode(rActor), "profbonus", 0);
			end
		else
			nDC = nGroupDC + DB.getValue(nodeAction, "savedcmod", 0);
		end

		sSave = StringManager.capitalize(sSaveType:sub(1,3)) .. " DC " .. nDC;
		
		if DB.getValue(nodeAction, "onmissdamage", "") == "half" then
			sSave = sSave .. " (H)";
		end
	end

	attackview.setValue(sAttack);
	saveview.setValue(sSave);
end

function onDamageChanged()
	local sDamage = PowerManager.getActionDamageText(getDatabaseNode());
	damageview.setValue(sDamage);
end

function onHealChanged()
	local sHeal = PowerManager.getActionHealText(getDatabaseNode());
	healview.setValue(sHeal);
end

function onEffectChanged()
	local nodeAction = getDatabaseNode();
	
	local sLabel = DB.getValue(nodeAction, "label", "");
	
	local sApply = DB.getValue(nodeAction, "apply", "");
	if sApply == "action" then
		sLabel = sLabel .. "; [ACTION]";
	elseif sApply == "roll" then
		sLabel = sLabel .. "; [ROLL]";
	elseif sApply == "single" then
		sLabel = sLabel .. "; [SINGLES]";
	end
	
	local sTargeting = DB.getValue(nodeAction, "targeting", "");
	if sTargeting == "self" then
		sLabel = sLabel .. "; [SELF]";
	end

	local sDuration = "" .. DB.getValue(nodeAction, "durmod", 0);
	
	local sUnits = DB.getValue(nodeAction, "durunit", "");
	if sDuration ~= "" then
		if sUnits == "minute" then
			sDuration = sDuration .. " min";
		elseif sUnits == "hour" then
			sDuration = sDuration .. " hr";
		elseif sUnits == "day" then
			sDuration = sDuration .. " dy";
		else
			sDuration = sDuration .. " rd";
		end
	end
	
	effectview.setValue(sLabel);
	durationview.setValue(sDuration);
end