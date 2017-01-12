local alignvalue = "center";

local updating = false;

local sourcenode = nil;
local sourcelabel = nil;

function onInit()

	-- get the source node
	local sourcenodename;
	if sourcename then
		sourcenodename = sourcename[1];
	else
		sourcenodename = getName();
	end
	if window.getDatabaseNode().isOwner() then
		sourcenode = window.getDatabaseNode().createChild(sourcenodename, "string");
	else
		sourcenode = window.getDatabaseNode().getChild(sourcenodename);
	end
	
	-- if the source node exists
	if sourcenode then
	
		-- get the default values
		if align then
			alignvalue = align[1];
		end
	
		-- set the sourcenode default value
		if sourcenode.getValue() == "" then
			sourcenode.setValue("STR");
		end
	
		-- subscribe to the sourcenode update event
		sourcenode.onUpdate = onUpdate;
		
		-- and trigger an update
		update();
	end
	
end

function onUpdate(source)
	update();
end

function update()
	DebugManager.logMessage("characteristicselector.update");
	if not updating then
		updating = true;
		if sourcenode then
		
			-- create the source label if required
			if not sourcelabel then
				sourcelabel = addTextWidget("sheetlabel", sourcenode.getValue());
			else
				sourcelabel.setText(sourcenode.getValue());
			end
			
			-- get the control size
			local controlw, controlh = sourcelabel.getSize();
			
			-- position the label
			if string.lower(alignvalue) == "left" then
				sourcelabel.setPosition("left", (controlw/2), 0);
			elseif string.lower(alignvalue) == "right" then
				sourcelabel.setPosition("right", -(controlw/2), 0);
			else
				sourcelabel.setPosition("",0,0);			
			end
		end
		updating = false;
	end
end

function onClickDown(button, x, y)
	if not disabled then
		if sourcenode then
			if not sourcenode.isStatic() then
				if sourcenode.isOwner() then
					local value = sourcenode.getValue();
					if value == "STR" then
						sourcenode.setValue("DEX");
					elseif value == "DEX" then
						sourcenode.setValue("END");
					elseif value == "END" then
						sourcenode.setValue("INT");
					elseif value == "INT" then
						sourcenode.setValue("EDU");
					elseif value == "EDU" then
						sourcenode.setValue("SOC");
					elseif value == "SOC" then
						sourcenode.setValue("STR");
					else
						sourcenode.setValue("STR");
					end
				end
			end
		end
	end
end

function onDoubleClick(x, y)
	onClickDown(1, x, y);
	return true;
end