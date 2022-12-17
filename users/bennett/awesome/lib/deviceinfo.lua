local awful = require "awful"
local gears = require "gears"

local ram_script = [[ free -m | grep 'Mem:' | awk '{printf "%d@@%d@", $7, $2}' ]]
local disk_script = [[ df -kh -B 1MB /dev/nvme0n1p5 | tail -1 | awk '{printf "%d@%d", $4, $3}' ]]
local cpu_script = [[ vmstat 1 2 | tail -1 | awk '{printf "%d", $15}' ]]
local temp_script = [[ sensors | grep Tctl | grep -Po "\d+\.\d" ]]
local battery_script = [[ upower -i /org/freedesktop/UPower/devices/battery_BAT0 | sed -nr "s/percentage: +([0-9]+)%/\1/p" ]]

local times = 0
local timer = gears.timer { timeout = 5 }
timer:connect_signal("timeout", function()
	awful.spawn.easy_async_with_shell(ram_script, function(stdout)
		local available = stdout:match('(.*)@@')
		local total = stdout:match('@@(.*)@')
		local used = tonumber(total) - tonumber(available)
		awesome.emit_signal("signal::ram", used, total)
	end)
	if times % 6 == 0 then awful.spawn.easy_async_with_shell(disk_script, function(stdout)
		local available = tonumber(stdout:match('^(.*)@')) / 1000
		local used = tonumber(stdout:match('@(.*)$')) / 1000
		awesome.emit_signal("signal::disk", used, available + used)
	end) end
	awful.spawn.easy_async_with_shell(cpu_script, function(stdout)
		local cpu_idle = string.gsub(stdout, '^%s*(.-)%s*$', '%1')
		awesome.emit_signal("signal::cpu", 100 - tonumber(cpu_idle))
	end)
	awful.spawn.easy_async_with_shell(temp_script, function(stdout)
		awesome.emit_signal("signal::temp", tonumber(stdout))
	end)
	awful.spawn.easy_async_with_shell(battery_script, function(stdout)
		awesome.emit_signal("signal::battery", string.gsub(stdout, '^%s*(.-)%s*$', '%1'))
	end)

	times = times + 1
	timer:again()
end)
timer:start()
