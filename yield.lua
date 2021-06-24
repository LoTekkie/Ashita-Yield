--[[
Copyright © 2021, Sjshovan (LoTekkie)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met=

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Yield nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sjshovan (LoTekkie) BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

_addon.name = 'Yield'
_addon.description = 'Track and edit a variety of metrics related to gathering within a simple GUI.'
_addon.author = 'Sjshovan (LoTekkie) Sjshovan@Gmail.com'
_addon.version = '0.9.0a'
_addon.commands = {'/yield', '/yld'}

require('constants')
require('helpers')

require 'common'
require 'ffxi.enums'
require 'timer'

local default_settings = {
    window = {
        opacity = 0.62,
    },
    targetValue = 0,
    prices = {
        mining = {
            ["Copper Ore"] = 0,
            ["Zinc Ore"] = 0,
            ["Tin Ore"] = 0,
            ["Iron Ore"] = 0,
            ["Silver Ore"] = 0,
            ["Darksteel Ore"] = 0,
            ["Gold Ore"] = 0,
            ["Mythril Ore"] = 0,
            ["Platium Ore"] = 0,
            ["Aluminum Ore"] = 0,
            ["Elemental Ore"] = 0,
            ["Adaman Ore"] = 0,
            ["Khroma Ore"] = 0,
            ["Luminium Ore"] = 0,
            ["Orichalcum Ore"] = 0,

            ["Pebble"] = 0,
            ["Flint Stone"] = 0,

            ["Igneous Rock"] = 0,
            ["Colored Rock"] = 0,
            ["Sulfur"] = 0,
            ["Pinch of Sulfur"] = 0,
            ["Iron Sand"] = 0,
            ["Bomb Ash"] = 0,
            ["Goblin Die"] = 0,
            ["Demon Horn"] = 0,
            ["Aht Urhgan Brass"] = 0,
            ["Orpiment"] = 0,
            ["Snapping Mole"] = 0,

            ["Troll Pauldron"] = 0,
            ["Troll Vambrace"] = 0,

            ["Moblin Mask"] = 0,
            ["Moblin Helm"] = 0,
            ["Moblin Mail"] = 0,
            ["Moblin Armor"] = 0
        },
        harvesting = {

        },
        logging = {},
        excavating = {},
        clamming = {}
    }
}

local settings = default_settings;

local uiVariables = {
    ["var_WindowOpacity"]    = { nil, ImGuiVar_FLOAT, 1.0 },
    ["var_TargetValue"]      = { nil, ImGuiVar_UINT32, 0 },
    ["var_YieldPlotVisible"] = { nil, ImGuiVar_BOOLCPP, true }
}

local help = {
    commands = {
        helpSeparator('=', 26),
        helpTitle('Commands'),
        helpSeparator('=', 26),
        helpCommandEntry('unload', 'Unload Yield.'),
        helpCommandEntry('reload', 'Reload Yield.'),
        helpCommandEntry('about', 'Display information about Yield.'),
        helpCommandEntry('help', 'Display Yield commands.'),
        helpSeparator('=', 26),
    },
    about = {
        helpSeparator('=', 23),
        helpTitle('About'),
        helpSeparator('=', 23),
        helpTypeEntry('Name', _addon.name),
        helpTypeEntry('Description', _addon.description),
        helpTypeEntry('Author', _addon.author),
        helpTypeEntry('Version', _addon.version),
        helpTypeEntry('Support/Donate', "https://Paypal.me/Sjshovan"),
        helpSeparator('=', 23),
    },
    aliases = {}
}

local state = {
    active = true,
    initializing = true,
    settings = {
        general = {active = true},
        setPrices = {active = false, gathering = "mining" },
        setAlerts = {active = false, default = ""},
        about = {active = false},
    },
    gathering = "mining",
    gatheringShort = "Min.",
    firstAttempts = {
        mining = false,
        logging = false,
        harvesting = false,
        excavating = false,
        clamming = false
    },
    attempting = false,
    confirmAction = function() end,
    confirmPrompt = "Are you sure?"
}

local gatherBtnsOrder = {
    [1] = {"mining", "Min."},
    [2] = {"harvesting", "Har."},
    [3] = {"logging", "Log."},
    [4] = {"excavating", "Exc."},
    [5] = {"clamming", "Cla."}
}

local settingBtnsOrder = {
    [1] = "general",
    [2] = "setPrices",
    [3] = "setAlerts",
    [4] = "about"
}

local metrics = {}
local metricsTemplate = {
    totals = {
        lost = 0,
        breaks = 0,
        yields = 0,
        attempts = 0
    },
    totalsOrder = {
        attempts,
        yields,
        breaks,
        lost
    },
    estimatedValue = 0,
    secondsPassed = 0,
    yields = {},
    points = {
        yields = {0},
        value = {0}
    }
}

for _, v in ipairs(gatherBtnsOrder) do
    metrics[v[1]] = table.copy(metricsTemplate);
end

function loadSettings()
    imgui.SetVarValue(uiVariables["var_WindowOpacity"][1], settings.window.opacity);
    imgui.SetVarValue(uiVariables["var_TargetValue"][1], settings.targetValue);
    for k, v in pairs(settings.prices) do
        if #v then
            for yield, price in pairs(v) do
                imgui.SetVarValue(uiVariables[string.format("var_%s_%s", k, string.clean(yield))][1], price)
            end
        end
    end
end

function saveSettings()
    settings.window.opacity = imgui.GetVarValue(uiVariables["var_WindowOpacity"][1]);
    settings.targetValue = imgui.GetVarValue(uiVariables["var_TargetValue"][1]);
    for k, v in pairs(settings.prices) do
        if #v then
            for yield, price in pairs(v) do
                settings.prices[k][yield] = tonumber(imgui.GetVarValue(uiVariables[string.format("var_%s_%s", k, string.clean(yield))][1]));
            end
        end
    end

    ashita.settings.save(_addon.path .. 'settings/settings.json', settings);
end

function updatePlotPoints()
    if state.firstAttempts[state.gathering] then
        totalSecs = metrics[state.gathering].secondsPassed
        metrics[state.gathering].secondsPassed = totalSecs + 1
        local timeSpan = 3600 -- one hour
        local timePassed = metrics[state.gathering].secondsPassed
        local pointsLimit = 300
        local yieldsOverTime = metrics[state.gathering].totals.yields * (timeSpan / timePassed)
        local valueOverTime =  metrics[state.gathering].estimatedValue * (timeSpan / timePassed)
        if totalSecs >= pointsLimit then
            table.remove(metrics[state.gathering].points.yields, 1)
            table.remove(metrics[state.gathering].points.value, 1)
        end
        table.insert(metrics[state.gathering].points.yields, yieldsOverTime)
        table.insert(metrics[state.gathering].points.value, valueOverTime)
    end
end

local plotTimer = "updatePlotPoints"
if ashita.timer.create_timer(plotTimer) then
    ashita.timer.adjust_timer(plotTimer, 1, 0, updatePlotPoints)
    ashita.timer.start_timer(plotTimer)
end

function display_help(helpTable)
    for index, command in pairs(helpTable) do
        displayResponse(command)
    end
end

function getPrice(itemName)
    return settings.prices[state.gathering][itemName] or 0
end

function adjTotal(metricName, val)
    local total = metrics[state.gathering].totals[metricName]
    if total == nil then total = 0 end
    metrics[state.gathering].totals[metricName] = total + val
end

function adjYield(yieldName, val)
    local yield = metrics[state.gathering].yields[yieldName]
    if yield == nil then yield = 0 end
    metrics[state.gathering].yields[yieldName] = yield + val
end

function calcTargetProgress()
    local progress = metrics[state.gathering].estimatedValue/settings.targetValue
    if progress == math.huge or progress ~= progress then progress = 0.0 end
    if progress < 0 then progress = 0.0 end
    if progress > 1.0 then progress = 1.0 end
    return progress
end

function table.sortKeysByAlphabet(t, desc)
    local ret = {}
    for k, v in pairs(t) do
        table.insert(ret, k)
    end
    if (desc) then
        table.sort(ret, function(a, b) return a:lower() < b:lower() end);
    else
        table.sort(ret, function(a, b) return a:lower() > b:lower() end);
    end
    return ret;
end

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Called when the addon is loaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    state.initializing = true

    -- Ensure the settings folder exists..
    ashita.file.create_dir(_addon.path .. '/settings/');

    -- Load and merge the users settings..
    settings = ashita.settings.load_merged(
        _addon.path .. '/settings/settings.json', settings
    )

    -- Add price uiVariables from settings..
    for k, v in pairs(settings.prices) do
        if #v then
            for yield, price in pairs(v) do
                uiVariables[string.format("var_%s_%s", k, string.clean(yield))] = { nil, ImGuiVar_UINT32, 0 }
            end
        end
    end

    -- Initialize custom variables..
    for k, v in pairs(uiVariables) do
        if (v[2] >= ImGuiVar_CDSTRING) then
            uiVariables[k][1] = imgui.CreateVar(uiVariables[k][2], uiVariables[k][3]);
        else
            uiVariables[k][1] = imgui.CreateVar(uiVariables[k][2]);
        end
        if (#v > 2 and v[2] < ImGuiVar_CDSTRING) then
            imgui.SetVarValue(uiVariables[k][1], uiVariables[k][3]);
        end
    end

    -- Load the settings file..
    loadSettings();
end)

----------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when the addon is unloaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    -- Save the settings file..
    saveSettings();

    -- Cleanup the custom variables..
    for k, v in pairs(uiVariables) do
        if (uiVariables[k][1] ~= nil) then
            imgui.DeleteVar(uiVariables[k][1]);
        end
        uiVariables[k][1] = nil;
    end
end)

---------------------------------------------------------------------------------------------------
-- func: command
-- desc: Called when the addon is handling a command.
---------------------------------------------------------------------------------------------------
ashita.register_event('command', function(command, ntype)
    local command_args = command:lower():args();

    if not table.haskey(_addon.commands, command_args[1]) then
        return false;
    end

    local responseMessage = "";
    local success = true;

    if command_args[2] == 'reload' or command_args[2] == 'r' then
        AshitaCore:GetChatManager():QueueCommand('/addon reload yield', 1);

    elseif command_args[2] == 'unload' or command_args[2] == 'u' then
        response_message = 'Thank you for using Yield. Goodbye.';
        AshitaCore:GetChatManager():QueueCommand('/addon unload yield', 1);

    elseif command_args[2] == 'about' or command_args[2] == 'a' then
        display_help(help.about);

    elseif command_args[2] == 'help' or command_args[2] == 'h' then
        display_help(help.commands);

    else
        display_help(help.commands);
    end

    if responseMessage ~= "" then
        displayResponse(
            commandResponse(response_message, success)
        );
    end

    return false;
end)

---------------------------------------------------------------------------------------------------
-- func: incoming_text
-- desc: Event called when the addon is asked to handle an incoming chat line.
---------------------------------------------------------------------------------------------------
ashita.register_event('incoming_text', function(mode, message, modifiedmode, modifiedmessage, blocked)
    -- ensure proper chat modes.
    if (mode ~= 919 or blocked or message:startswith(string.char(0x1E, 0x01))) then return false; end

    -- Handle the modified message if its set.
    if (modifiedmessage ~= nil and #modifiedmessage > 0) then
        message = modifiedmessage;
    end

    -- Remove colors form message.
    message = string.strip_colors(message);

    if state.attempting then
        adjTotal("attempts",  1);

        if not state.firstAttempts[state.gathering] then
            state.firstAttempts[state.gathering] = true
        end

        local val = 0;
        local success = false;
        local successBreak = false;
        local unable = false;
        local broken = false;
        local full = false;

         switch(state.gathering) : caseof
        {
            ["harvesting"] = function()
                success = string.match(message, "") or string.match(message, "");
                successBreak = string.match(message, "");
                unable = message == "";
                broken = string.match(message, "");
                full = string.contains(message, "");
            end,
            ["mining"] = function()
                success = string.match(message, "^You successfully dig up a (.*)!") or string.match(message, "You dig up a (.*), but your pickaxe breaks in the process.");
                successBreak = string.match(message, "You dig up a (.*), but your pickaxe breaks in the process.");
                unable = message == "You are unable to mine anything.";
                broken = string.match(message, "Your (.*) breaks!");
                full = string.contains(message, "You cannot carry any more items.");
            end,
            ["default"] = function() end
        }

        if success then
            switch(state.gathering) : caseof
            {
                ["mining"] = function()
                    local chunk = string.match(success, "chunk of (.*)");
                    if chunk then success = chunk end
                end,
            }
            success = string.gsub(" "..success, "%W%l", string.upper):sub(2);
            val = getPrice(success);
            adjYield(success, 1);
            if successBreak then adjTotal("breaks", 1); end
            adjTotal("yields", 1);
        elseif broken then
            adjTotal("breaks", 1);
        elseif full then
            adjTotal("lost", 1);
        end
        --TODO: set attempting to false when conditions met
        curVal = metrics[state.gathering].estimatedValue;
        metrics[state.gathering].estimatedValue = curVal + val;
    end
    return false;
end);

local timerButtonOneText = "Start"
----------------------------------------------------------------------------------------------------
-- func: render
-- desc: Called when the addon is rendering.
----------------------------------------------------------------------------------------------------
local var = imgui.CreateVar(1.0, 1.0)
ashita.register_event('render', function()
    local height =  470.0;
    local width = 210.0;
    local paddingX = 5.0;
    local paddingY = 5.0;
    local spacing = 5.0;
    local scale = 1.0;

    imgui.SetWindowFontScale(scale)
    imgui.SetNextWindowSize(width, height, ImGuiSetCond_Always);
    --print(fontSize);
    imgui.PushStyleVar(ImGuiStyleVar_WindowRounding, 5.0);
    imgui.PushStyleVar(ImGuiStyleVar_Alpha, settings.window.opacity);
    imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, paddingX, paddingY);
    imgui.Begin(string.format("%s - v%s", _addon.name, _addon.version), state.active, ImGuiWindowFlags_MenuBar+ImGuiWindowFlags_NoResize)
    imgui.SetWindowFontScale(scale)
    --print(imgui.GetContentRegionAvailWidth() .." ".. imgui.GetWindowWidth())
    --print(imgui.CalcItemWidth());
    --imgui.PushStyleVar(ImGuiStyleVar_WindowMinSize, width, height);
    imgui.BeginMenuBar()
    for _, v in ipairs(gatherBtnsOrder) do
        if v[1] == state.gathering then
            imgui.PushStyleColor(ImGuiCol_Button, 0.21, 0.47, 0.59, 1);
            if imgui.SmallButton(v[2]) then state.gathering = v[1]; state.settings.setPrices.gathering = state.gathering; end
            imgui.PopStyleColor();
        else
            if imgui.SmallButton(v[2]) then state.gathering = v[1]; state.settings.setPrices.gathering = state.gathering; end
        end
        if imgui.IsItemHovered() then
            imgui.BeginTooltip();
            imgui.SetTooltip(string.upperfirst(v[1]));
            imgui.EndTooltip();
        end
        imgui.SameLine(0.0, spacing);
    end
    imgui.EndMenuBar();

    imgui.Spacing();
    imgui.Separator();

    imgui.BeginChild("Header", -1, 15)
    imgui.Text("(?)")
    if imgui.IsItemHovered() then
        imgui.BeginTooltip();
        imgui.SetTooltip(string.format("Progress towards target value (%s/%s).", metrics[state.gathering].estimatedValue, settings.targetValue));
        imgui.EndTooltip();
    end
    imgui.SameLine(21.0)
    imgui.PushStyleColor(ImGuiCol_Text, 1, 1, 0.54, settings.window.opacity);
    local progress = calcTargetProgress()
    imgui.ProgressBar(progress, -1, 15, string.format("%s/%s", metrics[state.gathering].estimatedValue, settings.targetValue))
    imgui.PopStyleColor();
    imgui.EndChild();
    imgui.Separator();
    imgui.Spacing();

    local metricToolTips = {
        lost = "Total number of items lost.",
        attempts = "Total attempts at gathering.",
        yields = "Total successful gathers.",
        breaks = "Total number of broken tools.",
    }

    for metric, total in pairs(metrics[state.gathering].totals) do
        imgui.Text("(?)")
        if imgui.IsItemHovered() then
            imgui.BeginTooltip();
            imgui.SetTooltip(metricToolTips[metric]);
            imgui.EndTooltip();
        end
        imgui.SameLine(28.0)
        imgui.Text(string.format("%s: ", string.upperfirst(metric)));
        imgui.SameLine();
        imgui.Text(total)
    end
    imgui.Text("(?)")
    if imgui.IsItemHovered() then
        imgui.BeginTooltip();
        imgui.SetTooltip(string.format("Total time passed since your first %s attempt.", state.gathering));
        imgui.EndTooltip();
    end
    imgui.SameLine(28.0);
    imgui.Text("Time Passed: ");
    imgui.SameLine();
    imgui.Text(os.date("!%X", (metrics[state.gathering].secondsPassed)))

    imgui.Spacing();

    imgui.Text("(?)")
    if imgui.IsItemHovered() then
        imgui.BeginTooltip();
        imgui.SetTooltip(string.format("Start/Pause/Resume/Reset the %s timer.", string.upperfirst(state.gathering)));
        imgui.EndTooltip();
    end
    imgui.SameLine(28.0);
    imgui.Text("Timer: ")
    imgui.SameLine(75.0);
    if imgui.SmallButton(timerButtonOneText) then
    end
    imgui.SameLine()
    if imgui.SmallButton("Reset") then
    end

    imgui.Spacing();
    imgui.Separator();
    imgui.Spacing();

    imgui.PushStyleColor(ImGuiCol_Text, 0.39, 0.96, 0.13, settings.window.opacity);
    imgui.Text("(?)")
    if imgui.IsItemHovered() then
       imgui.BeginTooltip();
       imgui.SetTooltip("Estimated value of all yields.");
       imgui.EndTooltip();
    end
    imgui.SameLine(28.0);

    imgui.Text("Value (estd.): ");

    imgui.SameLine();
    imgui.Text(metrics[state.gathering]["estimatedValue"]);
    imgui.PopStyleColor();

    imgui.Spacing();
    imgui.Separator();
    imgui.Spacing();

    local plotYields = metrics[state.gathering].points.yields;
    imgui.PushStyleColor(ImGuiCol_Text, 1, 1, 0.54, settings.window.opacity);
    imgui.PlotHistogram("", plotYields, #plotYields, 0, "(?) Yields/HR", FLT_MIN, FLT_MAX, width-paddingX*2, 30);
    imgui.PopStyleColor()
    if imgui.IsItemHovered() then
        imgui.BeginTooltip();
        imgui.SetTooltip(string.format("%0.2f/HR (Click to toggle label).", metrics[state.gathering].points.yields[#metrics[state.gathering].points.yields] or 0));
        imgui.EndTooltip();
    end


    local plotValue = metrics[state.gathering].points.value;
    imgui.PushStyleColor(ImGuiCol_Text, 1, 1, 0.54, settings.window.opacity);
    imgui.PlotLines("", plotValue, #plotValue, 0, "(?) Value/HR", FLT_MIN, FLT_MAX, width-paddingX*2, 30);
    imgui.PopStyleColor()
    if imgui.IsItemHovered() then
        imgui.BeginTooltip();
        imgui.SetTooltip(string.format("%0.2f/HR (Click to toggle label).", metrics[state.gathering].points.value[#metrics[state.gathering].points.value] or 0));
        imgui.EndTooltip();
    end
    imgui.SameLine(0.0, spacing);
    if (imgui.Checkbox('', uiVariables['var_YieldPlotVisible'][1])) then

    end

    imgui.Spacing();
    imgui.BeginChild("Scrolling", width-paddingX*2, 140, true);

    for item, total in pairs(metrics[state.gathering]["yields"]) do
        imgui.Text(item..": ");
        imgui.SameLine();
        imgui.Text(total);
    end

    imgui.EndChild();

    imgui.Spacing();

    spacing = 4.0;
    local confirmPromptTemplate = "Are you sure you want to %s?"
    local confirmModal = "Yield Confirm"
    if imgui.Button("Exit") then
        state.confirmAction = function() AshitaCore:GetChatManager():QueueCommand('/addon unload yield', 1); end
        state.confirmPrompt = string.format(confirmPromptTemplate, "Exit");
        imgui.OpenPopup(confirmModal)
    end

    imgui.SameLine(0.0, spacing);

    if imgui.Button("Reload") then
        state.confirmAction = function() AshitaCore:GetChatManager():QueueCommand('/addon reload yield', 1); end
        state.confirmPrompt = string.format(confirmPromptTemplate, "Reload");
        imgui.OpenPopup(confirmModal)
    end


    imgui.SameLine(0.0, spacing);

    if imgui.Button("Reset") then
        state.confirmAction = function()
            metrics[state.gathering] = table.copy(metricsTemplate);
            for k, v in pairs(state.firstAttempts) do
                state.firstAttempts[k] = false
            end
        end
        state.confirmPrompt = string.format(confirmPromptTemplate, "Reset");
        imgui.OpenPopup(confirmModal)
    end


    imgui.SameLine(0.0, spacing);

    if imgui.Button("Settings") then
        imgui.OpenPopup("Yield Settings");
    end
    --table.insert(metrics[state.gathering]["points"], math.random(-10000, 10000))
    height = 505.0;
    imgui.SetNextWindowSize(width*2, height-60, ImGuiSetCond_Always);
    if imgui.BeginPopupModal("Yield Settings", state.active, ImGuiWindowFlags_MenuBar+ImGuiWindowFlags_NoResize) then
        imgui.BeginMenuBar()
        spacing = 5.0;
        for _, v in ipairs(settingBtnsOrder) do
            local btnName = string.gsub(" "..v, "%W%l", string.upper):sub(2);
            if btnName == "SetPrices" then btnName = "Set Prices" end
            if btnName == "SetAlerts" then btnName = "Set Alerts" end
            if state.settings[v].active then
                imgui.PushStyleColor(ImGuiCol_Button, 0.21, 0.47, 0.59, 1);
            if imgui.SmallButton(btnName) then
                for k, v in pairs(state.settings) do
                    state.settings[k].active = false
                end
                state.settings[v].active = true
            end
            imgui.PopStyleColor()
            else
                if imgui.SmallButton(btnName) then
                    for k, v in pairs(state.settings) do
                        state.settings[k].active = false
                    end
                    state.settings[v].active = true
                end
            end
            imgui.SameLine(0.0, spacing)
        end
        imgui.EndMenuBar();

        if state.settings.general.active then
            imgui.BeginChild("General", -1, height-140, state.active)
            imgui.Spacing();
            if (imgui.SliderFloat("Window Opacity", uiVariables['var_WindowOpacity'][1], 0.25, 1.0, "%1.2f")) then
                settings.window.opacity = imgui.GetVarValue(uiVariables['var_WindowOpacity'][1])
            end
            imgui.SameLine(0.0, 4.0);
            imgui.Text("(?)")
            if imgui.IsItemHovered() then
                imgui.BeginTooltip();
                imgui.SetTooltip("Current alpha channel value of all Yield windows.");
                imgui.EndTooltip();
            end
            imgui.Spacing();
            if (imgui.InputInt("Target Value", uiVariables['var_TargetValue'][1])) then
                settings.targetValue = imgui.GetVarValue(uiVariables['var_TargetValue'][1]);
            end
            imgui.SameLine(0.0, 4.0);
            imgui.Text("(?)")
            if imgui.IsItemHovered() then
                imgui.BeginTooltip();
                imgui.SetTooltip("Amount you would like to earn this session.");
                imgui.EndTooltip();
            end
            imgui.EndChild()
        elseif state.settings.setPrices.active then
            local currentPrices = state.settings.setPrices.gathering
            local title = ">>> "..string.upper(currentPrices).." PRICES <<<"
            local fontSize = (imgui.GetFontSize() * title:len()) / 2
            imgui.BeginChild("Set Prices", -1, height-140, state.active, ImGuiWindowFlags_MenuBar+ImGuiWindowFlags_NoResize)
            imgui.BeginMenuBar()
            for _, v in ipairs(gatherBtnsOrder) do
                if v[1] == state.settings.setPrices.gathering then
                    imgui.PushStyleColor(ImGuiCol_Button, 0.21, 0.47, 0.59, 1);
                    if imgui.SmallButton(v[2]) then state.settings.setPrices.gathering = v[1] end
                    imgui.PopStyleColor();
                else
                    if imgui.SmallButton(v[2]) then state.settings.setPrices.gathering = v[1] end
                end
                imgui.SameLine(0.0, spacing);
            end
            imgui.EndMenuBar()
            imgui.Spacing()
            imgui.Separator()

            imgui.BeginChild("Scrolling", -1, 330)
            for v, k in pairs(table.sortKeysByAlphabet(settings.prices[state.settings.setPrices.gathering], true)) do
                local var = string.format("var_%s_%s", state.settings.setPrices.gathering, string.clean(k))
                if (imgui.InputInt(k, uiVariables[var][1])) then
                    settings.prices[state.settings.setPrices.gathering][k] = imgui.GetVarValue(uiVariables[string.format("var_%s_%s", state.settings.setPrices.gathering, string.clean(k))][1]);
                end
            end
            imgui.EndChild()
            imgui.EndChild()
        elseif state.settings.setAlerts.active then
            imgui.BeginChild("Set Alerts", -1, height, true);
            imgui.Text("Set sound alerts for specific yields.");
            imgui.Spacing();
            imgui.Text("Comming Soon..");
            imgui.EndChild();
        elseif state.settings.about.active then
            imgui.BeginChild("About", -1, height, true);
            imgui.PushTextWrapPos((width-paddingX*2)*2)
            for _, v in ipairs(help.about) do
                imgui.Text(string.strip_colors(v));
                imgui.Spacing();
            end
            imgui.Spacing();
            imgui.Text("Special thanks to Narpt (https://www.twitch.tv/narpt) for his awesome streams and the idea to make this!");
            imgui.PopTextWrapPos()
            imgui.EndChild();
        end
        imgui.Spacing();
        imgui.SetCursorPosX(imgui.GetWindowWidth() - 40);
        if imgui.Button("Done") or state.initializing then
            imgui.CloseCurrentPopup();
            state.settings.setPrices.gathering = state.gathering;
            saveSettings();
        end
        imgui.EndPopup();
        imgui.PopStyleVar();
    end

    imgui.SetNextWindowSize(width*1.25, 75, ImGuiSetCond_Always);
    if imgui.BeginPopupModal("Yield Confirm", state.active, ImGuiWindowFlags_NoResize) then
        imgui.Text(state.confirmPrompt);
        imgui.Separator();
        imgui.Spacing();
        if imgui.Button("Yes") or state.initializing then
            imgui.CloseCurrentPopup();
            state.confirmAction();
        end
        imgui.SameLine(0.0, 10);
        if imgui.Button("No") or state.initializing then
            imgui.CloseCurrentPopup();
            state.confirmAction = function() end
        end
         imgui.EndPopup();
    end
    imgui.End();
    state.initializing = false
end);

ashita.register_event('outgoing_packet', function(id, size, packet, packet_modified, blocked)
    local gatheringTargets = {"Mining Point"}
    if id == 0x36 and table.hasKey(gatheringTargets, AshitaCore:GetDataManager():GetTarget():GetTargetName()) then
        state.attempting = true;
    end
    return false;
end);