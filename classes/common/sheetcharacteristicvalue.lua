local dragging = false;
local dicewidget = nil;

function onInit()
	--super.onInit();
	setHoverCursor("hand");
	dicewidget = addBitmapWidget("textentry_die");
	dicewidget.setPosition("bottomleft", 0, -4);
	
	--Add handlers to deal with DB changes.
	local dbNode = getDatabaseNode();
	
	-- Characteristic Update
	DB.addHandler(DB.getPath(dbNode), "onUpdate", onCharacteristicUpdate);	
	super.onInit();
end

function onDragStart(button, x, y, draginfo)
	dragging = false;
	return onDrag(button, x, y, draginfo);
end

function onDrag(button, x, y, draginfo)
	if not dragging then
		local sourcenode = getDatabaseNode();
		if sourcenode then
			local sourcename = sourcenode.getNodeName();
		
			-- build the description
			local description = "";
			if string.find(sourcename, string.lower(LanguageManager.getString("Strength")), 1, true) then
				description = LanguageManager.getString("Strength");
			elseif string.find(sourcename, string.lower(LanguageManager.getString("Dexterity")), 1, true) then
				description = LanguageManager.getString("Dexterity");
			elseif string.find(sourcename, string.lower(LanguageManager.getString("Endurance")), 1, true) then
				description = LanguageManager.getString("Endurance");
			elseif string.find(sourcename, string.lower(LanguageManager.getString("Intellect")), 1, true) then
				description = LanguageManager.getString("Intellect");
			elseif string.find(sourcename, string.lower(LanguageManager.getString("Education")), 1, true) then
				description = LanguageManager.getString("Education");
			elseif string.find(sourcename, string.lower(LanguageManager.getString("Social")), 1, true) then
				description = LanguageManager.getString("Social");
			elseif string.find(sourcename, string.lower(LanguageManager.getString("Psionics")), 1, true) then
				description = LanguageManager.getString("Psionics");
			end
			
			-- build the dice pool
			local dice = {};
			--DicePoolManager.addCharacteristicDice(sourcenode, dice);
				
			-- complete the drag information
			if table.getn(dice) > 0 then						
				draginfo.setType("characteristic");
				draginfo.setDescription(description);
				draginfo.setDieList(dice);
				draginfo.setDatabaseNode(sourcenode);
				dragging = true;
				return true;								
			end
		end
	end
	return false;
end

function onDragEnd(draginfo)
	dragging = false;
end

-- Allows population of the dice pool by a double-click on the dice button by the skill
function onDoubleClick()
	--local sourcenode = window.getDatabaseNode();
	local sourcenode = getDatabaseNode();
	--Debug.console("Characteristic roll databasenode = " .. sourcenode.getNodeName());
	
	if sourcenode then
		local sourcename = sourcenode.getNodeName();
		local description = "";
	
		-- build the description
		if string.find(sourcename, string.lower(LanguageManager.getString("Strength")), 1, true) then
				description = LanguageManager.getString("Strength");
			elseif string.find(sourcename, string.lower(LanguageManager.getString("Dexterity")), 1, true) then
				description = LanguageManager.getString("Dexterity");
			elseif string.find(sourcename, string.lower(LanguageManager.getString("Endurance")), 1, true) then
				description = LanguageManager.getString("Endurance");
			elseif string.find(sourcename, string.lower(LanguageManager.getString("Intellect")), 1, true) then
				description = LanguageManager.getString("Intellect");
			elseif string.find(sourcename, string.lower(LanguageManager.getString("Education")), 1, true) then
				description = LanguageManager.getString("Education");
			elseif string.find(sourcename, string.lower(LanguageManager.getString("Social")), 1, true) then
				description = LanguageManager.getString("Social");
			elseif string.find(sourcename, string.lower(LanguageManager.getString("Psionics")), 1, true) then
				description = LanguageManager.getString("Psionics");
			end
			
		local dice = {};
		local msgidentity = DB.getValue(sourcenode, "..name", "");
		--DicePoolManager.addCharacteristicDice(sourcenode, dice);
		if table.getn(dice) > 0 then
			DieBoxManager.addCharacteristicDice(description, dice, sourcenode, msgidentity);
		end
	end
end

function onCharacteristicUpdate()
	local dbNode = getDatabaseNode();
	--Debug.console(DB.getPath(dbNode))
	
	updateCharacteristicBonus(dbNode);
end

function updateCharacteristicBonus(dbNode)
	--Should be abilityname.current
	local newCharacteristicValue = DB.getValue(dbNode,"");
	--Go up one node, then to bonus value
	local bonusValue = dbNode.getParent().getChild("bonus");
	
	if (newCharacteristicValue) == 0 then 
		bonusValue = -3
	elseif (newCharacteristicValue) >= 1 and (newCharacteristicValue) <= 2 then 
		bonusValue = -2
	elseif (newCharacteristicValue) >= 3 and (newCharacteristicValue) <= 5 then 
		bonusValue = -1 
	elseif (newCharacteristicValue) >= 6 and (newCharacteristicValue) <= 8 then 
		bonusValue = 0
	elseif (newCharacteristicValue) >= 9 and (newCharacteristicValue) <= 11 then 
		bonusValue = 1
	elseif (newCharacteristicValue) >= 12 and (newCharacteristicValue) <= 14 then
		bonusValue = 2
	elseif (newCharacteristicValue) >= 15 then 
		bonusValue = 3
	end	
end