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

require('templates')
require('helpers')

require 'common'
require 'ffxi.enums'
require 'timer'

----------------------------------------------------------------------------------------------------
-- Variables
----------------------------------------------------------------------------------------------------
local settings           = table.copy(defaultSettingsTemplate);
local state              = table.copy(stateTemplate);
local metrics            = {}
local window =
{
    width    = 240.0,
    height   = 475.0,
    paddingX = 5.0,
    paddingY = 5.0,
    spacingX = 5.0,
    spacingY = 5.0,
    scale    = 1.0
}

local gatherTypes =
{
    [1] = { name = "harvesting", short = "ha.", target = "Harvesting Point" },
    [2] = { name = "excavating", short = "ex.", target = "Excavation Point" },
    [3] = { name = "logging",    short = "lo.", target = "Logging Point" },
    [4] = { name = "mining",     short = "mi.", target = "Mining Point" },
    [5] = { name = "clamming",   short = "cl.", target = "Clamming Point" },
    [6] = { name = "fishing",    short = "fi.", target = nil },
    [7] = { name = "digging",    short = "di.", target = nil }
}

local settingsTypes =
{
    [1] = { name = "general" },
    [2] = { name = "setPrices" },
    [3] = { name = "setAlerts" },
    [4] = { name = "about" }
}

local helpTable =
{
    commands =
    {
        helpSeparator('=', 26),
        helpTitle('Commands'),
        helpSeparator('=', 26),
        helpCommandEntry('unload', 'Unload Yield.'),
        helpCommandEntry('reload', 'Reload Yield.'),
        helpCommandEntry('about', 'Display information about Yield.'),
        helpCommandEntry('help', 'Display Yield commands.'),
        helpSeparator('=', 26),
    },

    about =
    {
        helpSeparator('=', 23),
        helpTitle('About'),
        helpSeparator('=', 23),
        helpTypeEntry('Name', _addon.name),
        helpTypeEntry('Description', _addon.description),
        helpTypeEntry('Author', _addon.author),
        helpTypeEntry('Version', _addon.version),
        helpTypeEntry('Support/Donate', "https://Paypal.me/Sjshovan"),
        helpSeparator('=', 23),
    }
}

local metricsTotalsToolTips =
{
    lost     = "Total number of yields lost.",
    breaks   = "Total number of broken tools.",
    yields   = "Total successful gathers.",
    attempts = "Total attempts at gathering.",
}

----------------------------------------------------------------------------------------------------
-- UI Variables
---------------------------------------------------------------------------------------------------
local uiVariables =
{
    -- User Set
    ["var_TargetValue"]           = { nil, ImGuiVar_UINT32, 0 },
    ["var_ShowToolTips"]          = { nil, ImGuiVar_BOOLCPP, true },
    ["var_WindowOpacity"]         = { nil, ImGuiVar_FLOAT, 1.0 },
    ["var_YieldPlotLabelVisible"] = { nil, ImGuiVar_BOOLCPP, true },
    -- Internal
    ['var_WindowVisible']         = { nil, ImGuiVar_BOOLCPP, true },
}

----------------------------------------------------------------------------------------------------
-- func: loadUiVariables
-- desc: Loads the ui variables from the Yield settings file.
----------------------------------------------------------------------------------------------------
function loadUiVariables()
    -- Load the UI variables..
    imgui.SetVarValue(uiVariables["var_WindowOpacity"][1], settings.general.opacity);
    imgui.SetVarValue(uiVariables["var_TargetValue"][1], settings.general.targetValue);
    imgui.SetVarValue(uiVariables["var_ShowToolTips"][1], settings.general.showToolTips);

    for k, v in pairs(settings.prices) do
        for yield, price in pairs(v) do
            imgui.SetVarValue(uiVariables[string.format("var_%s_%s", k, string.clean(yield))][1], price)
        end
    end
end

----------------------------------------------------------------------------------------------------
-- func: saveSettings
-- desc: Saves the Yield settings file.
----------------------------------------------------------------------------------------------------
function saveSettings()
    -- Obtain the configuration variables..
    settings.general.opacity      = imgui.GetVarValue(uiVariables["var_WindowOpacity"][1]);
    settings.general.targetValue  = imgui.GetVarValue(uiVariables["var_TargetValue"][1]);
    settings.general.showToolTips = imgui.GetVarValue(uiVariables["var_ShowToolTips"][1]);

    for k, v in pairs(settings.prices) do
        for yield, price in pairs(v) do
            settings.prices[k][yield] = tonumber(imgui.GetVarValue(uiVariables[string.format("var_%s_%s", k, string.clean(yield))][1]));
        end
    end

    -- Obtain the metrics..
    settings.metrics = table.copy(metrics);

    -- Obtain the state..
    settings.state.gathering = state.gathering;

    -- Save the configuration variables..
    ashita.settings.save(_addon.path .. 'settings/settings.json', settings);
end

----------------------------------------------------------------------------------------------------
-- func: updatePlotPoints
-- desc: Updates the display of all plots every second.
----------------------------------------------------------------------------------------------------
function updatePlotPoints()
    if state.timers[state.gathering] then
        totalSecs = metrics[state.gathering].secondsPassed
        metrics[state.gathering].secondsPassed = totalSecs + 1
        local timeSpan = 3600 -- one hour
        local timePassed = metrics[state.gathering].secondsPassed
        local pointsWindowMax = 300
        local yieldsOverTime = metrics[state.gathering].totals.yields * (timeSpan / timePassed)
        local valueOverTime =  metrics[state.gathering].estimatedValue * (timeSpan / timePassed)
        if totalSecs >= pointsWindowMax then
            table.remove(metrics[state.gathering].points.yields, 1)
            table.remove(metrics[state.gathering].points.values, 1)
        end
        table.insert(metrics[state.gathering].points.yields, yieldsOverTime)
        table.insert(metrics[state.gathering].points.values, valueOverTime)
    end
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function getPrice(itemName)
    return settings.prices[state.gathering][itemName] or 0
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function adjTotal(metricName, val)
    local total = metrics[state.gathering].totals[metricName]
    if total == nil then total = 0 end
    metrics[state.gathering].totals[metricName] = total + val
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function adjYield(yieldName, val)
    local yield = metrics[state.gathering].yields[yieldName]
    if yield == nil then yield = 0 end
    metrics[state.gathering].yields[yieldName] = yield + val
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function calcTargetProgress()
    local progress = metrics[state.gathering].estimatedValue/settings.general.targetValue
    if progress == math.huge or progress ~= progress then progress = 0.0 end
    if progress < 0 then progress = 0.0 end
    if progress > 1.0 then progress = 1.0 end
    return progress
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function pushSettingsBtnColor(index)
    if state.settings.activeIndex == index then
        imgui.PushStyleColor(ImGuiCol_Button, 0.21, 0.47, 0.59, 1);
    else
        imgui.PushStyleColor(ImGuiCol_Button, 0.25, 0.69, 1.0, 0.1);
    end
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

    -- Populate the metrics table..
    for _, v in ipairs(gatherTypes) do
        if table.haskey(settings.metrics, v.name) then
            metrics[v.name] = table.copy(settings.metrics[v.name]);
        else
            metrics[v.name] = table.copy(metricsTemplate);
        end
    end

    -- Initialize state timers..
    for _, v in ipairs(gatherTypes) do
        state.timers[v.name] = false;
    end

    -- Update saved gathering state..
    state.gathering = settings.state.gathering;

    -- Add price uiVariables from settings..
    for k, v in pairs(settings.prices) do
        for yield, price in pairs(v) do
            uiVariables[string.format("var_%s_%s", k, string.clean(yield))] = { nil, ImGuiVar_UINT32, 0 }
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

    -- Create plots timer..
    if ashita.timer.create_timer("updatePlotPoints") then
        ashita.timer.adjust_timer("updatePlotPoints", 1, 0, updatePlotPoints)
        ashita.timer.start_timer("updatePlotPoints")
    end

    -- Load ui variables from the settings file..
    loadUiVariables();
end)

----------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when the addon is unloaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    -- Save the settings file..
    saveSettings();

    -- Remove timers..
    ashita.timer.remove_timer("updatePlotPoints");

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
        displayHelp(helpTable.about);

    elseif command_args[2] == 'help' or command_args[2] == 'h' then
        displayHelp(helpTable.commands);

    else
        displayHelp(helpTable.commands);
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
    -- Ensure proper chat modes.
    if (mode ~= 919 or blocked or message:startswith(string.char(0x1E, 0x01))) then return false; end

    -- Remove colors form message.
    message = string.strip_colors(message);

    -- Ensure correct state.
    state.gathering = state.attemptType

    -- Check the attempt.
    if state.attempting then
        adjTotal("attempts",  1);

        if not state.timers[state.gathering] then
            state.timers[state.gathering] = true
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
                success = false;
                successBreak = false;
                unable = false;
                broken = false;
                full = false;
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
            success = string.lowerToTitle(success);
            val = getPrice(success);
            adjYield(success, 1);
            if successBreak then adjTotal("breaks", 1); end
            adjTotal("yields", 1);
        elseif broken then
            adjTotal("breaks", 1);
        elseif full then
            adjTotal("lost", 1);
        end
        state.attempting = false;
        curVal = metrics[state.gathering].estimatedValue;
        metrics[state.gathering].estimatedValue = curVal + val;
    end
    return false;
end);


----------------------------------------------------------------------------------------------------
-- func: render
-- desc: Called when the addon is rendering.
----------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    local height = 487.0;
    local width = 242.0;
    local paddingX = 5.0;
    local paddingY = 5.0;
    local spacing = 5.0;
    local scale = 1.0;

    --imgui.SetWindowFontScale(scale)
    imgui.SetNextWindowSize(width, height, ImGuiSetCond_Always);
    --print(fontSize);
    imgui.PushStyleVar(ImGuiStyleVar_WindowRounding, 5.0);
    imgui.PushStyleVar(ImGuiStyleVar_Alpha, settings.general.opacity);
    imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, paddingX, paddingY);
    imgui.Begin(string.format("%s - v%s", _addon.name, _addon.version), imgui.GetVarValue(uiVariables['var_WindowVisible'][1]), imgui.bor(ImGuiWindowFlags_MenuBar, ImGuiWindowFlags_NoResize))
    imgui.SetWindowFontScale(scale)
    --print(imgui.GetContentRegionAvailWidth() .." ".. imgui.GetWindowWidth())
    --print(imgui.CalcItemWidth());
    --imgui.PushStyleVar(ImGuiStyleVar_WindowMinSize, width, height);
    imgui.BeginMenuBar()
    for _, v in ipairs(gatherTypes) do
        if v.name == state.gathering then
            imgui.PushStyleColor(ImGuiCol_Button, 0.21, 0.47, 0.59, 1);
            if imgui.SmallButton(string.upperfirst(v.short)) then state.gathering = v.name; state.settings.setPrices.gathering = state.gathering; end
            imgui.PopStyleColor();
        else
            if imgui.SmallButton(string.upperfirst(v.short)) then state.gathering = v.name; state.settings.setPrices.gathering = state.gathering; end
        end
        if imgui.IsItemHovered() then
            imgui.SetTooltip(string.upperfirst(v.name));
        end
        imgui.SameLine(0.0, spacing);
    end
    imgui.EndMenuBar();

    imguiHalfSep();

    imgui.BeginChild("Header", -1, 15)
    if imguiShowToolTip(string.format("Progress towards your target value (adjusted within settings)."), settings.general.showToolTips) then
        imgui.SameLine(24.0)
    end
    imgui.PushStyleColor(ImGuiCol_Text, 1, 1, 0.54, settings.general.opacity);
    local progress = calcTargetProgress()
    imgui.ProgressBar(progress, -1, 15, string.format("%s/%s", metrics[state.gathering].estimatedValue, settings.general.targetValue))
    imgui.PopStyleColor();
    imgui.EndChild();

    imguiHalfSep(true);

    for total, metric in pairs(table.sortKeysByLength(metrics[state.gathering].totals, true)) do
        if imguiShowToolTip(metricsTotalsToolTips[metric], settings.general.showToolTips) then
            imgui.SameLine(30.0);
        end
        imgui.Text(string.format("%s: ", string.upperfirst(metric)));
        imgui.SameLine();
        imgui.Text(metrics[state.gathering].totals[metric])
    end
    if imguiShowToolTip(string.format("Time passed since your first %s attempt or when the timer was manually started.", string.upperfirst(state.gathering)), settings.general.showToolTips) then
        imgui.SameLine(30.0);
    end
    imgui.Text("Time Passed: ");
    imgui.SameLine();
    imgui.Text(os.date("!%X", (metrics[state.gathering].secondsPassed)))

    imgui.Spacing();
    if imguiShowToolTip(string.format("Start, stop, or clear the %s timer.", string.upperfirst(state.gathering)), settings.general.showToolTips) then
        imgui.SameLine(30.0);
    end
    imgui.Text("Timer: ")
    imgui.SameLine();
    if imgui.SmallButton(state.values.btnStartTimer) then
        state.timers[state.gathering] = not state.timers[state.gathering];
    end
    if state.timers[state.gathering] then
        state.values.btnStartTimer = "Stop";
    else
        state.values.btnStartTimer = "Start";
    end

    imgui.SameLine()

    if imgui.SmallButton("Clear") then
        state.timers[state.gathering] = false;
        metrics[state.gathering].secondsPassed = 0;
    end

    imguiFullSep();

    imgui.PushStyleColor(ImGuiCol_Text, 0.39, 0.96, 0.13, settings.general.opacity);
    if imguiShowToolTip(string.format("Estimated value of all %s yields (yield prices adjusted within settings).", string.upperfirst(state.gathering)), settings.general.showToolTips) then
        imgui.SameLine(30.0);
    end
    imgui.Text("Value (estd.): ");

    imgui.SameLine();
    imgui.Text(metrics[state.gathering].estimatedValue);
    imgui.PopStyleColor();

    imguiFullSep();

    local plotWidth = width-paddingX*2;
    if settings.general.showToolTips then plotWidth = plotWidth - 25 end
    local plotYields = metrics[state.gathering].points.yields;
    switch(state.values.yieldsLabelIndex) : caseof
    {
        [1] = function() state.values.labelPlotYields = string.format("Yields/HR (%.2f)", metrics[state.gathering].points.yields[#metrics[state.gathering].points.yields]) end,
        [2] = function() state.values.labelPlotYields = string.format("%.2f/HR", metrics[state.gathering].points.yields[#metrics[state.gathering].points.yields]) end,
        ["default"] = function() state.values.labelPlotYields = "" end
    }
    if imguiShowToolTip(string.format("Plot histogram of %s yields per hour (click the on plot to cycle its label displays).", string.upperfirst(state.gathering)), settings.general.showToolTips) then
        imgui.SameLine(30.0);
    end
    imgui.PushStyleColor(ImGuiCol_Text, 1, 1, 0.54, 1);
    imgui.PlotHistogram("", plotYields, #plotYields, 0, state.values.labelPlotYields, FLT_MIN, FLT_MAX, plotWidth, 30);
    imgui.PopStyleColor()
    if imgui.IsItemClicked() then
        state.values.yieldsLabelIndex = cycleIndex(state.values.yieldsLabelIndex, 1, 3);
    end
    if imgui.IsItemHovered() then
        if state.values.labelPlotYields == "" then
            imgui.SetTooltip(string.format("Yields/HR (%.2f)", metrics[state.gathering].points.yields[#metrics[state.gathering].points.yields]));
        else
            imgui.SetTooltip("");
        end
    end
    local plotValues = metrics[state.gathering].points.values;
    switch(state.values.valuesLabelIndex) : caseof
    {
        [1] = function() state.values.labelPlotValues = string.format("Value/HR (%.2f)", metrics[state.gathering].points.values[#metrics[state.gathering].points.values]) end,
        [2] = function() state.values.labelPlotValues = string.format("%.2f/HR", metrics[state.gathering].points.values[#metrics[state.gathering].points.values]) end,
        ["default"] = function() state.values.labelPlotValues = "" end
    }
    if imguiShowToolTip("Plot lines of the estimated value per hour (Click on the plot to cycle its label displays).", settings.general.showToolTips) then
        imgui.SameLine(30.0);
    end
    imgui.PushStyleColor(ImGuiCol_Text, 1, 1, 0.54, 1);
    imgui.PlotLines("", plotValues, #plotValues, 0, state.values.labelPlotValues, FLT_MIN, FLT_MAX, plotWidth, 30);
    imgui.PopStyleColor()
    if imgui.IsItemClicked() then
         state.values.valuesLabelIndex = cycleIndex(state.values.valuesLabelIndex, 1, 3);
    end
    if imgui.IsItemHovered() then
        if state.values.labelPlotValues == "" then
            imgui.SetTooltip(string.format("Value/HR (%.2f)", metrics[state.gathering].points.values[#metrics[state.gathering].points.values]));
        else
            imgui.SetTooltip("");
        end
    end

    imguiFullSep();

    if imguiShowToolTip(string.format("Scrollable List of current %s yields and their amounts.", string.upperfirst(state.gathering)), settings.general.showToolTips) then
        imgui.SameLine(30.0);
    end

    imgui.BeginChild("Scrolling", plotWidth, 140, true);

    for item, total in pairs(metrics[state.gathering]["yields"]) do
        imgui.Text(item..": ");
        imgui.SameLine();
        imgui.Text(total);
    end

    imgui.EndChild();

    imguiFullSep();

    spacing = 2.0;
    local modalConfirmPromptTemplate = "Are you sure you want to %s?";
    if imgui.Button("Exit") then
        state.actions.modalConfirmAction = function() AshitaCore:GetChatManager():QueueCommand('/addon unload yield', 1); end
        state.values.modalConfirmPrompt = string.format(modalConfirmPromptTemplate, "Exit");
        state.values.modalConfirmHelp = "(All gathering data will be saved.)";
        imgui.OpenPopup("Yield Confirm")
    end

    imgui.SameLine(0.0, spacing);

    if imgui.Button("Reload") then
        state.actions.modalConfirmAction = function() AshitaCore:GetChatManager():QueueCommand('/addon reload yield', 1); end
        state.values.modalConfirmPrompt = string.format(modalConfirmPromptTemplate, "Reload");
        state.values.modalConfirmHelp = "(All gathering data will be saved.)";
        imgui.OpenPopup("Yield Confirm")
    end

    imgui.SameLine(0.0, spacing);

    if imgui.Button("Reset") then
        state.actions.modalConfirmAction = function()
            -- Reset the metrics..
            metrics[state.gathering] = table.copy(metricsTemplate);
            -- Reset the timers..
            for k, v in pairs(state.timers) do
                state.timers[k] = false
            end
        end
        state.values.modalConfirmPrompt = string.format(modalConfirmPromptTemplate, "Reset");
        state.values.modalConfirmHelp = string.format("(Current %s data will be lost.)", string.upperfirst(state.gathering));
        state.values.modalConfirmDanger = true;
        imgui.OpenPopup("Yield Confirm")
    end

    imgui.SameLine(0.0, spacing);

    if imgui.Button("Settings") then
        imgui.OpenPopup("Yield Settings");
    end

    imgui.SameLine(0.0, spacing);
    if imgui.Button("Help") then

    end

    --table.insert(metrics[state.gathering]["points"], math.random(-10000, 10000))
    height = 505.0;
    imgui.SetNextWindowSize(width*2, 445, ImGuiSetCond_Always);
    if imgui.BeginPopupModal("Yield Settings", imgui.GetVarValue(uiVariables['var_WindowVisible'][1]), imgui.bor(ImGuiWindowFlags_MenuBar, ImGuiWindowFlags_NoResize)) then
        imgui.BeginMenuBar()
        for i, v in ipairs(settingsTypes) do
            local btnName = string.camelToTitle(v.name);
            pushSettingsBtnColor(i);
            if imgui.SmallButton(btnName) then
                state.settings.activeIndex = i;
            end
            imgui.PopStyleColor()
            imgui.SameLine(0.0, 5.0)
        end
        imgui.EndMenuBar();

        if state.settings.activeIndex == 1 then
            imgui.BeginChild("General", -1, 365, imgui.GetVarValue(uiVariables['var_WindowVisible'][1]))
            imgui.Spacing();
            if imguiShowToolTip("Current alpha channel value of all Yield windows.", settings.general.showToolTips) then
                imgui.SameLine(33.0);
            end
            if (imgui.SliderFloat("Window Opacity", uiVariables['var_WindowOpacity'][1], 0.25, 1.0, "%1.2f")) then
                settings.general.opacity = imgui.GetVarValue(uiVariables['var_WindowOpacity'][1])
            end
            imgui.Spacing();
            if imguiShowToolTip("Amount you would like to earn this session (affects progress bar).", settings.general.showToolTips) then
                imgui.SameLine(33.0);
            end
            if (imgui.InputInt("Target Value", uiVariables['var_TargetValue'][1])) then
                settings.general.targetValue = imgui.GetVarValue(uiVariables['var_TargetValue'][1]);
            end
            imgui.Spacing();
             if imguiShowToolTip("Toggles the display of (?)s and their tooltips.", settings.general.showToolTips) then
                imgui.SameLine(33.0);
            end
            if (imgui.Checkbox('Show (?) Tooltips', uiVariables['var_ShowToolTips'][1])) then
                settings.general.showToolTips = imgui.GetVarValue(uiVariables['var_ShowToolTips'][1]);
            end
            imgui.EndChild()
        elseif state.settings.activeIndex == 2 then
            local currentPrices = state.settings.setPrices.gathering
            imgui.BeginChild("Set Prices", -1, 365, imgui.GetVarValue(uiVariables['var_WindowVisible'][1]), imgui.bor(ImGuiWindowFlags_MenuBar, ImGuiWindowFlags_NoResize))
            imgui.BeginMenuBar()
            for _, v in ipairs(gatherTypes) do
                if v.name == state.settings.setPrices.gathering then
                    imgui.PushStyleColor(ImGuiCol_Button, 0.21, 0.47, 0.59, 1);
                    if imgui.SmallButton(string.upperfirst(v.short)) then state.settings.setPrices.gathering = v.name end
                    imgui.PopStyleColor();
                else
                    if imgui.SmallButton(string.upperfirst(v.short)) then state.settings.setPrices.gathering = v.name end
                end
                if imgui.IsItemHovered() then
                    imgui.SetTooltip(string.upperfirst(v.name));
                end
                imgui.SameLine(0.0, 5.0);
            end
            imgui.EndMenuBar()

            imgui.Spacing();

            imgui.BeginChild("Scrolling", -1, 329)
            for v, k in pairs(table.sortKeysByAlphabet(settings.prices[state.settings.setPrices.gathering], true)) do
                local var = string.format("var_%s_%s", state.settings.setPrices.gathering, string.clean(k))
                if imguiShowToolTip(string.format("Set the current market price for a single %s.", k), settings.general.showToolTips) then
                    imgui.SameLine(30.0);
                end
                if (imgui.InputInt(k, uiVariables[var][1])) then
                    settings.prices[state.settings.setPrices.gathering][k] = imgui.GetVarValue(uiVariables[string.format("var_%s_%s", state.settings.setPrices.gathering, string.clean(k))][1]);
                end
            end
            imgui.EndChild()
            imgui.EndChild()
        elseif state.settings.activeIndex == 3 then
            imgui.BeginChild("Set Alerts", -1, 365, true);
            imgui.Text("Set sound alerts for specific yields.");
            imgui.Spacing();
            imgui.Text("Comming Soon..");
            imgui.EndChild();
        elseif state.settings.activeIndex == 4 then
            imgui.BeginChild("About", -1, 365, true);
            imgui.PushTextWrapPos((width-paddingX*2)*2)
            for _, v in ipairs(helpTable.about) do
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

    imgui.SetNextWindowSize(width*1.25, 93, ImGuiSetCond_Always);
    if imgui.BeginPopupModal("Yield Confirm", imgui.GetVarValue(uiVariables['var_WindowVisible'][1]), imgui.bor(ImGuiWindowFlags_NoResize)) then
        imgui.Text(state.values.modalConfirmPrompt);
        if state.values.modalConfirmHelp then
            local r, g, b, a = 0.39, 0.96, 0.13, 1
            if state.values.modalConfirmDanger then
                r, g, b, a = 0.7, 0, 0, 1
            end
            imgui.TextColored(r, g, b, a, state.values.modalConfirmHelp);
        end
        imguiHalfSep(true);
        if imgui.Button("Yes") or state.initializing then
            imgui.CloseCurrentPopup();
            state.actions.modalConfirmAction();
        end
        imgui.SameLine(0.0, 10);
        if imgui.Button("No") or state.initializing then
            imgui.CloseCurrentPopup();
            state.actions.modalConfirmAction = function() end
        end
        imgui.EndPopup();
    else
        state.values.modalConfirmPrompt = ""
        state.values.modalConfirmHelp   = ""
        state.values.modalConfirmDanger = false
    end
    imgui.End();
    state.initializing = false
end);

ashita.register_event('outgoing_packet', function(id, size, packet, packet_modified, blocked)
    if id == 0x36 then -- Ha., Ex., Lo., Mi., Cl.
        for k, v in pairs(gatherTypes) do
            if v.target == AshitaCore:GetDataManager():GetTarget():GetTargetName() then
                state.attempting = true;
                state.attemptType = v.name;
                state.gathering = v.name;
            end
        end
    --TODO: elseif Fi., Di.
    end
    return false;
end);