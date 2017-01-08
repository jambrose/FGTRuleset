--Mods: Trenloe, Nov 2013.  Added onInit function to write intro message to chat window.
local dragging = false;

function onInit()
	--local msg = {sender = "", font = "emotefont", icon="SW_logo"};
	-- Chat window message moved the base.xml <properties>
	--local msg = {sender = "", font = "emotefont"};
	-- Launch Message to chat window
    --Comm.addChatMessage(msg);
	
	-- Display message of the day to the GM if the MOTD preference is enabled (by default in a new campaign).
	if User.isHost() and PreferenceManager.getValue("interface_motd") then
		local msg = {sender = "", font = "chatbolditalicfont", icon=""};
		-- Display Message of the Day to chat window
		msg.text = "Message of the Day: Mongoose Traveller 2e Development Ruleset. Not for public distribution!"
		Comm.addChatMessage(msg);
	end
	
end

function onDrop(x, y, draginfo)
	Debug.console("draginfo.getType = " .. draginfo.getType());
	if draginfo.isType("chit") then
		Debug.console("Customdata = " .. draginfo.getCustomData());
		if draginfo.getCustomData() == "critical" then
			return addCritical();
		elseif draginfo.getCustomData() == "criticalvehicle" then
			return addCriticalVehicle();	
		end
	end
	if draginfo.getType() == "number" then
		ModifierStack.applyModifierStackToRoll(draginfo);
	end
end

function onDiceLanded(draginfo)
	local handler = ChatManager.getDiceHandler(draginfo);
	if handler then
		return handler(draginfo);
	end
end

function addCritical()
	
		Debug.console("Running addCritical dropped in chat window")
	
		local modifier = 0;
		
		-- Set the description
		local description = "[CRITICAL]"
		
		-- build the dice table
		local dice = {};
		table.insert(dice, "d100");
		table.insert(dice, "d10");
		
		-- throw the dice - need to handle the result in the chatmanager handler.
		ChatManager.throwDice("dice", dice, modifier, description, {"", msgidentity, gmonly});

	
	-- and return
	return true;
		

end

function addCriticalVehicle()
	
	Debug.console("Running addCriticalVehicle dropped in chat window.")

	local modifier = 0;
	
	-- Set the description
	local description = "[CRITVEHICLE]"
	
	-- build the dice table
	local dice = {};
	table.insert(dice, "d100");
	table.insert(dice, "d10");

	-- throw the dice - need to handle the result in the chatmanager handler.
	ChatManager.throwDice("dice", dice, modifier, description, {npcnodename, msgidentity, gmonly});
	
	-- and return
	return true;

end