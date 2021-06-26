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

--[[ #TODOs & Notes
    - add ability to change window size
    - add sound alerts
    - sort yields by weights/alphabet
    - add yield coloring
    - update about
    - use key to exit modals, update modals with this info
    - add option to use stack prices
    - generate reports on zone change and reset (add option to opt out)
    - adjust value when prices update?
    - add other gathering data
    - add documentation
    - update ver
    - cleanup code
--]]

----------------------------------------------------------------------------------------------------
-- Variables
----------------------------------------------------------------------------------------------------
local settings = table.copy(defaultSettingsTemplate);
local state    = table.copy(stateTemplate);
local metrics  = {}
local window =
{
    height   = 500.0,
    width    = 250.0,
    padX     = 5.0,
    padY     = 5.0,
    scale    = 1.0
}

local gatherTypes =
{
    [1] = { name = "harvesting", short = "ha.", target = "Harvesting Point", tool = "sickle",        toolId = 1020 },
    [2] = { name = "excavating", short = "ex.", target = "Excavation Point", tool = "pickaxe",       toolId = 605 },
    [3] = { name = "logging",    short = "lo.", target = "Logging Point",    tool = "hatchet",       toolId = 1021 },
    [4] = { name = "mining",     short = "mi.", target = "Mining Point",     tool = "pickaxe",       toolId = 605 },
    [5] = { name = "clamming",   short = "cl.", target = "Clamming Point",   tool = "clamming kit",  toolId = 511 },
    [6] = { name = "fishing",    short = "fi.", target = nil,                tool = "bait",          toolId = 3 },
    [7] = { name = "digging",    short = "di.", target = nil,                tool = "gysahl green",  toolId = 4545 }
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

local playerStorage =
{
    available_pct = 100
};

local ashitaResourceManager = AshitaCore:GetResourceManager();
local ashitaChatManager     = AshitaCore:GetChatManager();
local ashitaDataManager     = AshitaCore:GetDataManager();
local ashitaParty           = ashitaDataManager:GetParty();
local ashitaPlayer          = ashitaDataManager:GetPlayer();
local ashitaInventory       = ashitaDataManager:GetInventory();
local ashitaTarget          = ashitaDataManager:GetTarget();
local ashitaEntity          = ashitaDataManager:GetEntity();

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
            imgui.SetVarValue(uiVariables[string.format("var_%s_%s", k, string.clean(yield))][1], price);
        end
    end

    for k, v in pairs(metrics) do
          imgui.SetVarValue(uiVariables[string.format("var_%s_estimatedValue", k)][1], v.estimatedValue);
    end
end

----------------------------------------------------------------------------------------------------
-- func: updatePlotPoints
-- desc: Update the display of all plots every second.
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
-- func: updatePlayerStorage
-- desc: Update the global playerStorage table with gathering tool counts and available inventory space every second.
----------------------------------------------------------------------------------------------------
function updatePlayerStorage()
    local storage = {};
    local containers =
    {
        inventory = 0,
        satchel   = 5,
        sack      = 6,
        case      = 7,
        wardrobe  = 8,
        wardrobe2 = 10,
        wardrobe3 = 11,
        wardrobe4 = 12
    }
    for _, v in ipairs(gatherTypes) do
        if v.name ~= "clamming" then
            local itemId = v.toolId;
            if v.name == "fishing" then -- check equipment (for fishing bait)
                local itemIndex = ashitaInventory:GetEquippedItem(v.toolId).ItemIndex;
                itemId = getItemIdFromContainers(itemIndex, containers);
            end
            storage[v.tool] = getItemCountFromContainers(itemId, containers);
        else -- clamming (key item)
            if (AshitaCore:GetDataManager():GetPlayer():HasKeyItem(v.toolId)) then
                storage[v.tool] = 1
            else
                storage[v.tool] = 0
            end
        end
    end
    storage["available"], storage["available_pct"] = getAvailableStorageFromContainers({0});
    playerStorage = storage;
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
        imgui.PushStyleColor(ImGuiCol_Button, 0.21, 0.47, 0.59, 1); -- info
    else
        imgui.PushStyleColor(ImGuiCol_Button, 0.25, 0.69, 1.0, 0.1); -- secondary
    end
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function getGatherTypeData()
    for _, v in ipairs(gatherTypes) do
        if v.name == state.gathering then
            return v;
        end
    end
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function getItemCountFromContainers(itemId, containers)
    itemCount = 0;
    for containerName, containerId in pairs(containers) do
        for i = 0, ashitaInventory:GetContainerMax(containerId), 1 do -- check containers
            local entry = ashitaInventory:GetItem(containerId, i);
            if entry.Id == itemId and entry.Id ~= 0 and entry.Id ~= 65535 then
                local item = ashitaResourceManager:GetItemById(entry.Id);
                if item then
                    local quantity = 1;
                    if entry.Count and item.StackSize > 1 then
                        quantity = entry.Count;
                    end
                    itemCount = itemCount + quantity;
                end
            end
        end
    end
    return itemCount;
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function getItemIdFromContainers(itemIndex, containers)
    itemId = nil;
    for containerName, containerId in pairs(containers) do
        for i = 0, ashitaInventory:GetContainerMax(containerId), 1 do -- check containers
            local entry = ashitaInventory:GetItem(containerId, i);
            if entry.Index == itemIndex then
               return entry.Id;
            end
        end
    end
    return itemId;
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function getAvailableStorageFromContainers(containers)
    total = 0;
    available = 0;
    for _, containerId in pairs(containers) do
        local max = ashitaInventory:GetContainerMax(containerId) - 1;
        local used = 0;
        total = total + max;
        for i = 0, max, 1 do
            local entry = ashitaInventory:GetItem(containerId, i);
            if entry.Id > 0 and entry.Id < 65535 then
                used = used + 1;
            end
        end
        available = available + (max - used);
    end
    return available, math.floor(available/total*100); -- pct
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

    for _, v in ipairs(gatherTypes) do
        metrics[v.name].estimatedValue = tonumber(imgui.GetVarValue(uiVariables[string.format("var_%s_estimatedValue", v.name)][1]))
    end

    -- Obtain the metrics..
    settings.metrics = table.copy(metrics);

    -- Obtain the state..
    settings.state.gathering = state.gathering;

    -- Save the configuration variables..
    ashita.settings.save(_addon.path .. 'settings/settings.json', settings);
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

    -- loop through gathering types..
    for _, v in ipairs(gatherTypes) do
        -- Populate the metrics table..
        if table.haskey(settings.metrics, v.name) then
            metrics[v.name] = table.copy(settings.metrics[v.name]);
        else
            metrics[v.name] = table.copy(metricsTemplate);
        end
        -- Initialize state timers..
        state.timers[v.name] = false;
        -- Add estimated value ui variables...
        uiVariables[string.format("var_%s_estimatedValue", v.name)] = { nil, ImGuiVar_UINT32, 0 }
    end

    -- Update saved gathering state..
    state.gathering = settings.state.gathering;

    -- Add price ui variables from settings..
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

    -- Create timers..
    if ashita.timer.create_timer("updatePlotPoints") then
        ashita.timer.adjust_timer("updatePlotPoints", 1, 0, updatePlotPoints)
        ashita.timer.start_timer("updatePlotPoints")
    end
    if ashita.timer.create_timer("updatePlayerStorage") then
        ashita.timer.adjust_timer("updatePlayerStorage", 1, 0, updatePlayerStorage)
        ashita.timer.start_timer("updatePlayerStorage")
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
        imgui.SetVarValue(uiVariables[string.format("var_%s_estimatedValue", state.gathering)][1], metrics[state.gathering].estimatedValue);
    end
    return false;
end);


----------------------------------------------------------------------------------------------------
-- func: render
-- desc: Called when the addon is rendering.
----------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    --imgui.SetWindowFontScale(scale)
    imgui.SetNextWindowSize(window.width, window.height, ImGuiSetCond_Always);
    --print(fontSize);
    imgui.PushStyleVar(ImGuiStyleVar_WindowRounding, 5.0);
    imgui.PushStyleVar(ImGuiStyleVar_Alpha, settings.general.opacity);
    imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, window.padX, window.padY);
    -- MAIN
    imgui.Begin(string.format("%s - v%s", _addon.name, _addon.version), imgui.GetVarValue(uiVariables['var_WindowVisible'][1]), imgui.bor(ImGuiWindowFlags_MenuBar, ImGuiWindowFlags_NoResize))
    imgui.SetWindowFontScale(window.scale)
    --print(imgui.GetContentRegionAvailWidth() .." ".. imgui.GetWindowWidth())
    --print(imgui.CalcItemWidth());
    --imgui.PushStyleVar(ImGuiStyleVar_WindowMinSize, width, height);
    --imgui.PushStyleColor(ImGuiCol_Button, 0.25, 0.69, 0.87, 1); -- primary

    -- MAIN_MENU
    imgui.BeginMenuBar()
    for _, v in ipairs(gatherTypes) do
        if v.name == state.gathering then
            imgui.PushStyleColor(ImGuiCol_Button, 0.21, 0.47, 0.59, 1); -- info
            if imgui.SmallButton(string.upperfirst(v.short)) then state.gathering = v.name; state.settings.setPrices.gathering = state.gathering; end
            imgui.PopStyleColor();
        else
            if imgui.SmallButton(string.upperfirst(v.short)) then state.gathering = v.name; state.settings.setPrices.gathering = state.gathering; end
        end
        if imgui.IsItemHovered() then
            imgui.SetTooltip(string.upperfirst(v.name));
        end
        imgui.SameLine(0.0, 6.5);
    end
    imgui.EndMenuBar();
    -- /MAIN_MENU
    imguiHalfSep();

    -- MAIN_HEADER
    imgui.BeginChild("Header", -1, 15)
    if imguiShowToolTip(string.format("Progress towards your target value (adjusted within settings)."), settings.general.showToolTips) then
        imgui.SameLine(24.0)
    end

    local progress = calcTargetProgress()
    imgui.PushStyleColor(ImGuiCol_Text, 1, 1, 0.54, 1); -- warn
    imgui.ProgressBar(progress, -1, 15, string.format("%s/%s", metrics[state.gathering].estimatedValue, settings.general.targetValue))
    imgui.PopStyleColor();
    imgui.EndChild();
    -- /MAIN_HEADER

    imguiHalfSep(true);

    for total, metric in pairs(table.sortKeysByLength(metrics[state.gathering].totals, true)) do
        if imguiShowToolTip(metricsTotalsToolTips[metric], settings.general.showToolTips) then
            imgui.SameLine(30.0);
        end
        imgui.Text(string.format("%s: ", string.upperfirst(metric)));
        imgui.SameLine();
        imgui.Text(metrics[state.gathering].totals[metric])
    end

    if imguiShowToolTip("Total gathering tools on hand.", settings.general.showToolTips) then
        imgui.SameLine(30.0);
    end

    local gatherData = getGatherTypeData();
    local toolName = string.lowerToTitle(gatherData.tool)
    if gatherData.name ~= "fishing" then
        toolName = toolName.."s"
    end
    imgui.Text(toolName..":");
    imgui.SameLine();
    imgui.Text(playerStorage[gatherData.tool] or 0);

    if imguiShowToolTip("Total inventory slots available (main inventory only).", settings.general.showToolTips) then
        imgui.SameLine(30.0);
    end

    local availPct = playerStorage['available_pct'];
    if availPct < 50 and availPct >= 25 then
        imgui.PushStyleColor(ImGuiCol_Text, 1, 1, 0.54, 1); -- warn
    elseif availPct < 25 then
        imgui.PushStyleColor(ImGuiCol_Text, 1, 0.615, 0.615, 1); -- danger
    else
        imgui.PushStyleColor(ImGuiCol_Text, 0.77, 0.83, 0.80, 1); -- plain
    end

    imgui.Text("Inventory:")
    imgui.SameLine();
    imgui.Text(playerStorage['available'] or 0);
    imgui.PopStyleColor();

    if imguiShowToolTip(string.format("Time passed since your first %s attempt or when the timer was manually started.", string.upperfirst(state.gathering)), settings.general.showToolTips) then
        imgui.SameLine(30.0);
    end
    imgui.Text("Time Passed: ");
    imgui.SameLine();

    local r, g, b, a = 1, 0.615, 0.615, 1 -- danger
    if state.timers[state.gathering] then
        r, g, b, a = 0.77, 0.83, 0.80, 1 -- plain
    end
    imgui.TextColored(r, g, b, a, os.date("!%X", (metrics[state.gathering].secondsPassed)))

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

    imgui.PushStyleColor(ImGuiCol_Text, 0.39, 0.96, 0.13, 1); -- success
    if imguiShowToolTip(string.format("Editable estimated value of all %s yields (yield prices adjusted within settings).", string.upperfirst(state.gathering)), settings.general.showToolTips) then
        imgui.SameLine(30.0);
    end
    imgui.Text("Value:")
    if settings.general.showToolTips then
        imgui.SameLine(80);
    else
        imgui.SameLine();
    end
    if (imgui.InputInt('', uiVariables[string.format("var_%s_estimatedValue", state.gathering)][1])) then
        metrics[state.gathering].estimatedValue = imgui.GetVarValue(uiVariables[string.format("var_%s_estimatedValue", state.gathering)][1]);
    end
    imgui.PopStyleColor();
    imguiFullSep();
    local plotWidth = window.width-window.padX*2;
    if settings.general.showToolTips then plotWidth = plotWidth - 25 end
    local plotYields = metrics[state.gathering].points.yields;
    local yieldsLabelMap =
    {
        [1] = string.format("Yields/HR (%.2f)", metrics[state.gathering].points.yields[#metrics[state.gathering].points.yields]),
        [2] = string.format("%.2f/HR", metrics[state.gathering].points.yields[#metrics[state.gathering].points.yields]),
        [3] = ""
    }
    local plotYieldsLabel = yieldsLabelMap[state.values.yieldsLabelIndex];
    if imguiShowToolTip(string.format("Plot histogram of %s yields per hour (click the on plot to cycle its label displays).", string.upperfirst(state.gathering)), settings.general.showToolTips) then
        imgui.SameLine(30.0);
    end
    imgui.PushStyleColor(ImGuiCol_Text, 1, 1, 0.54, 1); -- warn
    imgui.PlotHistogram("", plotYields, #plotYields, 0, plotYieldsLabel, FLT_MIN, FLT_MAX, plotWidth, 30);
    imgui.PopStyleColor()
    if imgui.IsItemClicked() then
        state.values.yieldsLabelIndex = cycleIndex(state.values.yieldsLabelIndex, 1, 3);
    end
    if imgui.IsItemHovered() then
        if plotYieldsLabel == "" then
            imgui.SetTooltip(string.format("Yields/HR (%.2f)", metrics[state.gathering].points.yields[#metrics[state.gathering].points.yields]));
        else
            imgui.SetTooltip("");
        end
    end
    local plotValues = metrics[state.gathering].points.values;
    local valuesLabelMap =
    {
        [1] = string.format("Value/HR (%.2f)", metrics[state.gathering].points.values[#metrics[state.gathering].points.values]),
        [2] = string.format("%.2f/HR", metrics[state.gathering].points.values[#metrics[state.gathering].points.values]),
        [3] = ""
    }
    local plotValuesLabel = valuesLabelMap[state.values.valuesLabelIndex];
    if imguiShowToolTip("Plot lines of the estimated value per hour (Click on the plot to cycle its label displays).", settings.general.showToolTips) then
        imgui.SameLine(30.0);
    end
    imgui.PushStyleColor(ImGuiCol_Text, 1, 1, 0.54, 1); -- warn
    imgui.PlotLines("", plotValues, #plotValues, 0, plotValuesLabel, FLT_MIN, FLT_MAX, plotWidth, 30);
    imgui.PopStyleColor()
    if imgui.IsItemClicked() then
         state.values.valuesLabelIndex = cycleIndex(state.values.valuesLabelIndex, 1, 3);
    end
    if imgui.IsItemHovered() then
        if plotValuesLabel == "" then
            imgui.SetTooltip(string.format("Value/HR (%.2f)", metrics[state.gathering].points.values[#metrics[state.gathering].points.values]));
        else
            imgui.SetTooltip("");
        end
    end

    imguiFullSep();

    if imguiShowToolTip(string.format("Scrollable List of current %s yields and their amounts (click on the list to cycle its sorting methods).", string.upperfirst(state.gathering)), settings.general.showToolTips) then
        imgui.SameLine(30.0);
    end

    -- MAIN_SCROLLING
    imgui.BeginChild("Scrolling", plotWidth, 112, true);
    yieldsSortMap =
    {
        [1] = { table.sortKeysByAlphabet(metrics[state.gathering].yields, false), "Alphabetical (DESC)" },
        [2] = { table.sortKeysByAlphabet(metrics[state.gathering].yields, true), "Alphabetical (ASC)" },
        [3] = { table.sortbykey(metrics[state.gathering].yields, false), "Count (DESC)" },
        [4] = { table.sortbykey(metrics[state.gathering].yields, true), "Count (ASC)" }
    }
    for _, item in pairs(yieldsSortMap[state.values.yieldSortIndex][1]) do
        imgui.Text(item..": ");
        imgui.SameLine();
        imgui.Text(metrics[state.gathering].yields[item]);
    end
    imgui.EndChild();
    if imgui.IsItemClicked() then
        state.values.yieldSortIndex = cycleIndex(state.values.yieldSortIndex, 1, 4);
    end
    if imgui.IsItemHovered() then
        imgui.SetTooltip(string.format("Sort Type: %s", yieldsSortMap[state.values.yieldSortIndex][2]));
    end
    -- /MAIN_SCROLLING

    imguiFullSep();

    local modalConfirmPromptTemplate = "Are you sure you want to %s?";

    if imgui.Button("Exit") then
        state.actions.modalConfirmAction = function() AshitaCore:GetChatManager():QueueCommand('/addon unload yield', 1); end
        state.values.modalConfirmPrompt = string.format(modalConfirmPromptTemplate, "Exit");
        state.values.modalConfirmHelp = "(All gathering data will be saved.)";
        imgui.OpenPopup("Yield Confirm")
    end

    imgui.SameLine(0.0, 4.0);

    if imgui.Button("Reload") then
        state.actions.modalConfirmAction = function() AshitaCore:GetChatManager():QueueCommand('/addon reload yield', 1); end
        state.values.modalConfirmPrompt = string.format(modalConfirmPromptTemplate, "Reload");
        state.values.modalConfirmHelp = "(All gathering data will be saved.)";
        imgui.OpenPopup("Yield Confirm")
    end

    imgui.SameLine(0.0, 4.0);

    if imgui.Button("Reset") then
        state.actions.modalConfirmAction = function()
            -- Reset the metrics..
            metrics[state.gathering] = table.copy(metricsTemplate);
            -- Reset the timers..
            for k, v in pairs(state.timers) do
                state.timers[k] = false
            end
            -- Reset ui variables..
            imgui.SetVarValue(uiVariables[string.format("var_%s_estimatedValue", state.gathering)][1], metrics[state.gathering].estimatedValue);
        end
        state.values.modalConfirmPrompt = string.format(modalConfirmPromptTemplate, "Reset");
        state.values.modalConfirmHelp = string.format("(Current %s data will be lost.)", string.upperfirst(state.gathering));
        state.values.modalConfirmDanger = true;
        imgui.OpenPopup("Yield Confirm")
    end

    imgui.SameLine(0.0, 4.0);

    if imgui.Button("Settings") then
        imgui.OpenPopup("Yield Settings");
    end

    imgui.SameLine(0.0, 4.0);
    if imgui.Button("Help") then
    end

    --table.insert(metrics[state.gathering]["points"], math.random(-10000, 10000))
    imgui.SetNextWindowSize(window.width*2, 445, ImGuiSetCond_Always);

    -- SETTINGS
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

        -- render settings pages..
        imgui.BeginGroup();
        switch(state.settings.activeIndex) : caseof
        {
            [1] = function() renderSettingsGeneral() end,
            [2] = function() renderSettingsSetPrices() end,
            [3] = function() renderSettingsSetAlerts() end,
            [4] = function() renderSettingsAbout() end,
        };
        imgui.EndGroup();

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
    -- /SETTINGS

    -- CONFIRM
    imgui.SetNextWindowSize(window.width*1.25, 93, ImGuiSetCond_Always);
    if imgui.BeginPopupModal("Yield Confirm", imgui.GetVarValue(uiVariables['var_WindowVisible'][1]), imgui.bor(ImGuiWindowFlags_NoResize)) then
        imgui.Text(state.values.modalConfirmPrompt);
        if state.values.modalConfirmHelp then
            local r, g, b, a = 0.39, 0.96, 0.13, 1
            if state.values.modalConfirmDanger then
                r, g, b, a =  1, 0.615, 0.615, 1
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
    -- /CONFIRM
    imgui.End();
    state.initializing = false
    -- /MAIN
end);

ashita.register_event('outgoing_packet', function(id, size, packet, packet_modified, blocked)
    if id == 0x36 then -- Ha., Ex., Lo., Mi., Cl.
        for k, v in pairs(gatherTypes) do
            if v.target == ashitaTarget:GetTargetName() then
                state.attempting = true;
                state.attemptType = v.name;
                state.gathering = v.name;
            end
        end
    --TODO: elseif Fi., Di.
    end
    return false;
end);

----------------------------------------------------------------------------------------------------
-- func: renderSettingsGeneral
-- desc: Renders the General settings.
----------------------------------------------------------------------------------------------------
function renderSettingsGeneral()
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
end

----------------------------------------------------------------------------------------------------
-- func: renderSettingsSetPrices
-- desc: Renders the Set Prices settings.
----------------------------------------------------------------------------------------------------
function renderSettingsSetPrices()
    local currentPrices = state.settings.setPrices.gathering
    imgui.BeginChild("Set Prices", -1, 365, imgui.GetVarValue(uiVariables['var_WindowVisible'][1]), imgui.bor(ImGuiWindowFlags_MenuBar, ImGuiWindowFlags_NoResize))
    imgui.BeginMenuBar()
    for _, v in ipairs(gatherTypes) do
        if v.name == state.settings.setPrices.gathering then
            imgui.PushStyleColor(ImGuiCol_Button, 0.21, 0.47, 0.59, 1); -- info
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
end

----------------------------------------------------------------------------------------------------
-- func: renderSettingsSetAlerts
-- desc: Renders the Set Alerts settings.
----------------------------------------------------------------------------------------------------
function renderSettingsSetAlerts()
    imgui.BeginChild("Set Alerts", -1, 365, true);
    imgui.Text("Set sound alerts for specific yields.");
    imgui.Spacing();
    imgui.Text("Comming Soon..");
    imgui.EndChild();
end

----------------------------------------------------------------------------------------------------
-- func: renderSettingsAbout
-- desc: Renders the About section in settings.
----------------------------------------------------------------------------------------------------
function renderSettingsAbout()
    imgui.BeginChild("About", -1, 365, true);
    imgui.PushTextWrapPos((window.width-window.padX*2)*2)
    for _, v in ipairs(helpTable.about) do
        imgui.Text(string.strip_colors(v));
        imgui.Spacing();
    end
    imgui.Spacing();
    imgui.Text("Special thanks to Narpt (https://www.twitch.tv/narpt) for his awesome streams and the idea to make this!");
    imgui.PopTextWrapPos()
    imgui.EndChild();
end