
function onInit()
	-- Used to auto populate skills before the skills tab has been opened.
	Debug.console("charsheet_init.lua: onInit");
	local skillsnode = window.getDatabaseNode().createChild("skills");
	if skillsnode then
		local skillautocreated = skillsnode.createChild("..skillsautogenerated", "number");
		if skillautocreated.getValue() ~= 1 then
			Debug.console("charsheet_init.lua: Skills haven't been created - creating...");
			for k,v in pairs(DataCommon.basicskilldata) do
				local skillnode = skillsnode.createChild();
				Debug.console("charsheet_init.lua: Creating: " .. k);
				skillnode.createChild("name","string").setValue(k);
				skillnode.createChild("description","formattedtext").setValue(v.description);
				skillnode.createChild("canaddspecialities","number").setValue(v.canaddspecialities);
				if v.specialities == true then
					Debug.console("Creating Specialities");
					for k2,v2 in pairs(getSpeciality(k)) do
						local specialitynode = skillnode.createChild();
						Debug.console("charsheet_init.lua: Creating: " .. k2);
						specialitynode.createChild("name","string").setValue(k2);
						specialitynode.createChild("description","formattedtext").setValue(v2.description);
					end					
				end
			end
			skillsnode.getChild("..skillsautogenerated").setValue(1);
		else
			Debug.console("charsheet_init.lua: Skills already created.");
		end
	end	
end

function getSpeciality(skill)
	local specialitiesnode = DataCommon.specialities[skill];
	return specialitiesnode;
end

function DeepPrint (e)
    -- if e is a table, we should iterate over its elements
    if type(e) == "table" then
        for k,v in pairs(e) do -- for every element in the table
            print(k)
            DeepPrint(v)       -- recursively repeat the same procedure
        end
    else -- if not, we can just print it
        print(e)
    end
end