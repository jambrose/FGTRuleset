-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	onLockChanged();
	DB.addHandler(DB.getPath(getDatabaseNode(), "locked"), "onUpdate", onLockChanged);
end

function onClose()
	DB.removeHandler(DB.getPath(getDatabaseNode(), "locked"), "onUpdate", onLockChanged);
end

function onLockChanged()
	StateChanged();
end

function StateChanged()
	if header.subwindow then
		header.subwindow.update();
	end
	if main.subwindow then
		main.subwindow.update();
	end
end
