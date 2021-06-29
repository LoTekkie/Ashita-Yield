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
_addon.version = '0.9.0b'
_addon.commands = {'/yield', '/yld'}

require('templates')
require('helpers')

require 'common'
require 'ffxi.enums'
require 'timer'

--[[ #TODOs & Notes
    - add sound alerts
    - update about
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

local gatherTypes =
{
    [1] = { name = "harvesting", short = "ha.", target = "Harvesting Point", tool = "sickle",        toolId = 1020, action = "harvest" },
    [2] = { name = "excavating", short = "ex.", target = "Excavation Point", tool = "pickaxe",       toolId = 605,  action = "" },
    [3] = { name = "logging",    short = "lo.", target = "Logging Point",    tool = "hatchet",       toolId = 1021, action = "" },
    [4] = { name = "mining",     short = "mi.", target = "Mining Point",     tool = "pickaxe",       toolId = 605,  action = "dig up" },
    [5] = { name = "clamming",   short = "cl.", target = "Clamming Point",   tool = "clamming kit",  toolId = 511,  action = "" },
    [6] = { name = "fishing",    short = "fi.", target = nil,                tool = "bait",          toolId = 3,    action = "" },
    [7] = { name = "digging",    short = "di.", target = nil,                tool = "gysahl green",  toolId = 4545, action = "" }
}

local settingsTypes =
{
    [1] = { name = "general" },
    [2] = { name = "setPrices" },
    [3] = { name = "setColors" },
    [4] = { name = "setAlerts" },
    [5] = { name = "reports" },
    [6] = { name = "feedback" },
    [7] = { name = "about" }
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
        helpTypeEntry('Support/Donate', "https://Paypal.me/Sjshovan OR For Gil donations: I play on Wings private server! (https://www.wingsxi.com/wings/) My in-game name is LoTekkie."),
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

local windowScales =
{
    [0] = 1.0;
    [1] = 1.15;
    [2] = 1.30;
}

local playerStorage =
{
    available_pct = 100
};

local ashitaResourceManager      = AshitaCore:GetResourceManager();
local ashitaChatManager          = AshitaCore:GetChatManager();
local ashitaDataManager          = AshitaCore:GetDataManager();
local ashitaParty                = ashitaDataManager:GetParty();
local ashitaPlayer               = ashitaDataManager:GetPlayer();
local ashitaInventory            = ashitaDataManager:GetInventory();
local ashitaTarget               = ashitaDataManager:GetTarget();
local ashitaEntity               = ashitaDataManager:GetEntity();

local modalConfirmPromptTemplate = "Are you sure you want to %s?";
local defaultFontSize            = imgui.GetFontSize();

----------------------------------------------------------------------------------------------------
-- UI Variables
---------------------------------------------------------------------------------------------------
local uiVariables =
{
    -- User Set
    ["var_WindowOpacity"]         = { nil, ImGuiVar_FLOAT, 1.0 },
    ["var_ShowToolTips"]          = { nil, ImGuiVar_BOOLCPP, true },
    ["var_TargetValue"]           = { nil, ImGuiVar_UINT32, 0 },
    ["var_WindowScaleIndex"]      = { nil, ImGuiVar_UINT32, 0 },
    ["var_UseStackPrices"]        = { nil, ImGuiVar_BOOLCPP, true },
    ["var_ShowDetailedYields"]    = { nil, ImGuiVar_BOOLCPP, true },
    ["var_YieldDetailsColor"]     = { nil, ImGuiVar_FLOATARRAY, 4 };
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
    imgui.SetVarValue(uiVariables["var_WindowScaleIndex"][1], settings.general.windowScaleIndex);
    imgui.SetVarValue(uiVariables["var_ShowDetailedYields"][1], settings.general.showDetailedYields);
    local r, g, b, a = colorToRGBA(settings.general.yieldDetailsColor);
    imgui.SetVarValue(uiVariables["var_YieldDetailsColor"][1], r/255, g/255, b/255, a/255);

    for gathering, yields in pairs(settings.yields) do
        for yield, data in pairs(yields) do
            imgui.SetVarValue(uiVariables[string.format("var_%s_%s", gathering, string.clean(yield))][1], data.price);
            local r, g, b, a = colorToRGBA(data.color);
            imgui.SetVarValue(uiVariables[string.format("var_%s_%s_color", gathering, string.clean(yield))][1], r/255, g/255, b/255, a/255);
            imgui.SetVarValue(uiVariables[string.format("var_%s_%s_soundFile", gathering, string.clean(yield))][1], data.soundFile);
        end
    end

    for gathering, data in pairs(metrics) do
        imgui.SetVarValue(uiVariables[string.format("var_%s_estimatedValue", gathering)][1], data.estimatedValue);
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
    for _, data in ipairs(gatherTypes) do
        if data.name ~= "clamming" then
            local itemId = data.toolId;
            if data.name == "fishing" then -- check equipment (for fishing bait)
                local itemIndex = ashitaInventory:GetEquippedItem(data.toolId).ItemIndex;
                itemId = getItemIdFromContainers(itemIndex, containers);
            end
            storage[data.tool] = getItemCountFromContainers(itemId, containers);
        else -- clamming (key item)
            if (AshitaCore:GetDataManager():GetPlayer():HasKeyItem(data.toolId)) then
                storage[data.tool] = 1
            else
                storage[data.tool] = 0
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
    local price = settings.yields[state.gathering][itemName].price or 0;
    if price > 0 and settings.priceModes[state.gathering] then
        price = price / settings.yields[state.gathering][itemName].stackSize;
    end
    return math.floor(price);
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
    for _, data in ipairs(gatherTypes) do
        if data.name == state.gathering then
            return data;
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
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function table.sortKeysByTotalValue(t, desc)
    local ret = {}
    for k, v in pairs(t) do
        table.insert(ret, k)
    end
    local totalA = function(a, b) return math.floor(getPrice(a) * metrics[state.gathering].yields[a]); end;
    local totalB = function(a, b) return math.floor(getPrice(b) * metrics[state.gathering].yields[b]); end;
    if (desc) then
        table.sort(ret, function(a, b) return totalA(a, b) < totalB(a, b); end);
    else
        table.sort(ret, function(a, b) return totalA(a, b) > totalB(a, b); end);
    end
    return ret;
end

----------------------------------------------------------------------------------------------------
-- func: saveSettings
-- desc: Saves the Yield settings file.
----------------------------------------------------------------------------------------------------
function saveSettings()
    -- Obtain the configuration variables..
    settings.general.opacity           = imgui.GetVarValue(uiVariables["var_WindowOpacity"][1]);
    settings.general.targetValue       = imgui.GetVarValue(uiVariables["var_TargetValue"][1]);
    settings.general.showToolTips      = imgui.GetVarValue(uiVariables["var_ShowToolTips"][1]);
    settings.general.windowScaleIndex  = imgui.GetVarValue(uiVariables["var_WindowScaleIndex"][1]);
    settings.general.yieldDetailsColor = colorTableToInt(imgui.GetVarValue(uiVariables["var_YieldDetailsColor"][1]));

    for gathering, yields in pairs(settings.yields) do
        for yield, data in pairs(yields) do
            settings.yields[gathering][yield].price     = tonumber(imgui.GetVarValue(uiVariables[string.format("var_%s_%s", gathering, string.clean(yield))][1]));
            settings.yields[gathering][yield].color     = colorTableToInt(imgui.GetVarValue(uiVariables[string.format("var_%s_%s_color", gathering, string.clean(yield))][1]));
            settings.yields[gathering][yield].soundFile = imgui.GetVarValue(uiVariables[string.format("var_%s_%s_soundFile", gathering, string.clean(yield))][1]);
        end
    end

    for _, data in ipairs(gatherTypes) do
        metrics[data.name].estimatedValue = tonumber(imgui.GetVarValue(uiVariables[string.format("var_%s_estimatedValue", data.name)][1]))
    end

    -- Obtain the metrics..
    settings.metrics = table.copy(metrics);

    -- Obtain the state..
    settings.state.gathering  = state.gathering;

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
    for _, data in ipairs(gatherTypes) do
        -- Populate the metrics table..
        if table.haskey(settings.metrics, data.name) then
            metrics[data.name] = table.copy(settings.metrics[data.name]);
        else
            metrics[data.name] = table.copy(metricsTemplate);
        end
        -- Initialize state timers..
        state.timers[data.name] = false;
        -- Add estimated value ui variables...
        uiVariables[string.format("var_%s_estimatedValue", data.name)] = { nil, ImGuiVar_UINT32, 0 }
    end

    -- Update saved gathering state..
    state.gathering = settings.state.gathering;
    state.settings.setPrices.gathering = state.gathering;
    state.settings.setColors.gathering = state.gathering;

    -- Add price ui variables from settings..
    for gathering, yields in pairs(settings.yields) do
        for yield, data in pairs(yields) do
            uiVariables[string.format("var_%s_%s", gathering, string.clean(yield))] = { nil, ImGuiVar_UINT32, 0 };
            uiVariables[string.format("var_%s_%s_color", gathering, string.clean(yield))] = { nil, ImGuiVar_FLOATARRAY, 4 };
            uiVariables[string.format("var_%s_%s_soundFile", gathering, string.clean(yield))] = { nil, ImGuiVar_CDSTRING, 64 };
        end
        uiVariables[string.format("var_%s_useStackPrice", gathering)] = { nil, ImGuiVar_BOOLCPP, true };
    end

    -- Initialize custom variables..
    for varName, data in pairs(uiVariables) do
        if (data[2] >= ImGuiVar_CDSTRING) then
            uiVariables[varName][1] = imgui.CreateVar(uiVariables[varName][2], uiVariables[varName][3]);
        else
            uiVariables[varName][1] = imgui.CreateVar(uiVariables[varName][2]);
        end
        if (#data > 2 and data[2] < ImGuiVar_CDSTRING) then
            imgui.SetVarValue(uiVariables[varName][1], uiVariables[varName][3]);
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
    ashita.timer.remove_timer("updatePlayerStorage");

    -- Cleanup the custom variables..
    for varName, data in pairs(uiVariables) do
        if (uiVariables[varName][1] ~= nil) then
            imgui.DeleteVar(uiVariables[varName][1]);
        end
        uiVariables[varName][1] = nil;
    end
end)

---------------------------------------------------------------------------------------------------
-- func: command
-- desc: Called when the addon is handling a command.
---------------------------------------------------------------------------------------------------
ashita.register_event('command', function(command, ntype)
    local commandArgs = command:lower():args();

    if not table.hasvalue(_addon.commands, commandArgs[1]) then
        return false;
    end

    local responseMessage = "";
    local success = true;

    if commandArgs[2] == 'reload' or commandArgs[2] == 'r' then
        AshitaCore:GetChatManager():QueueCommand('/addon reload yield', 1);

    elseif commandArgs[2] == 'unload' or commandArgs[2] == 'u' then
        response_message = 'Thank you for using Yield. Goodbye.';
        AshitaCore:GetChatManager():QueueCommand('/addon unload yield', 1);

    elseif commandArgs[2] == 'about' or commandArgs[2] == 'a' then
        displayHelp(helpTable.about);

    elseif commandArgs[2] == 'help' or commandArgs[2] == 'h' then
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

        local gatherData = getGatherTypeData(state.gathering);
        successBreak = string.match(message, string.format("You %s a (.*), but your %s .*", gatherData.action, gatherData.tool));
        success = string.match(message, string.format("^You successfully %s a (.*)!", gatherData.action)) or successBreak
        unable = message == string.format("You are unable to %s anything.", gatherData.action);
        broken = string.match(message, "Your (.*) breaks!");
        full = string.contains(message, "You cannot carry any more items.");
        print(success);
        print(successBreak);
        if success then
            local of = string.match(success, "of (.*)");
            if of then success = of end;
        end
        if success then
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

        if successful or unable or broken or full then
            state.attempting = false;
        end

        curVal = metrics[state.gathering].estimatedValue;
        metrics[state.gathering].estimatedValue = curVal + val;
        imgui.SetVarValue(uiVariables[string.format("var_%s_estimatedValue", state.gathering)][1], metrics[state.gathering].estimatedValue);
    end
    return false;
end);

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
ashita.register_event('outgoing_packet', function(id, size, packet, packet_modified, blocked)
    if id == 0x36 then -- Ha., Ex., Lo., Mi., Cl.
        for gathering, data in pairs(gatherTypes) do
            if data.target == ashitaTarget:GetTargetName() then
                state.attempting = true;
                state.attemptType = data.name;
                state.gathering = data.name;
            end
        end
    --TODO: elseif Fi., Di.
    end
    return false;
end);

----------------------------------------------------------------------------------------------------
-- func: render
-- desc: Called when the addon is rendering.
----------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    local windowScale           = windowScales[settings.general.windowScaleIndex];
    local scaledFontSize        = windowScale*defaultFontSize;

    local scaledHeightReduction = 0;
    if windowScale == 1.15 then scaledHeightReduction = 34 elseif windowScale == 1.30 then scaledHeightReduction = 55 end;

    imgui.PushStyleVar(ImGuiStyleVar_WindowRounding, 5.0);
    imgui.PushStyleVar(ImGuiStyleVar_Alpha, settings.general.opacity);
    imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, scaledFontSize*5/defaultFontSize, scaledFontSize*5/defaultFontSize);
    imgui.PushStyleColor(ImGuiCol_Border, 0.21, 0.47, 0.59, 0.5);

    -- MAIN
    imgui.SetNextWindowSize(scaledFontSize*250/defaultFontSize, scaledFontSize*500/defaultFontSize - scaledHeightReduction, ImGuiSetCond_Always);
    if not imgui.Begin(string.format("%s - v%s", _addon.name, _addon.version), imgui.GetVarValue(uiVariables['var_WindowVisible'][1]), imgui.bor(ImGuiWindowFlags_MenuBar, ImGuiWindowFlags_NoResize)) then
        imgui.End();
        return
    end

    imgui.SetWindowFontScale(windowScale);

    state.window =
    {
        scale                 = windowScale,
        height                = scaledFontSize * 500.0 / defaultFontSize,
        width                 = scaledFontSize * 250.0 / defaultFontSize,
        padX                  = scaledFontSize * 5.0   / defaultFontSize,
        padY                  = scaledFontSize * 5.0   / defaultFontSize,
        spaceGatherBtn        = scaledFontSize * 6.5   / defaultFontSize * windowScale + (windowScale - 1.0) * 2,
        heightHeaderMain      = scaledFontSize * 15.0  / defaultFontSize,
        heightPlot            = scaledFontSize * 25.0  / defaultFontSize,
        heightYields          = scaledFontSize * 130.0 / defaultFontSize,
        spaceToolTip          = scaledFontSize * 4.0   / defaultFontSize,
        spaceFooterBtn        = scaledFontSize * 4.0   / defaultFontSize * windowScale + (windowScale - 1.0) * 2,
        widthSettings         = scaledFontSize * 500.0 / defaultFontSize,
        heightSettings        = scaledFontSize * 450.0 / defaultFontSize,
        heightSettingsContent = scaledFontSize * 367.0 / defaultFontSize,
        heightSettingsScroll  = scaledFontSize * 343.0 / defaultFontSize,
        spaceStackModeRadio   = scaledFontSize * 115.0 / defaultFontSize,
        spaceEstimatedValue   = scaledFontSize * 12.0  / defaultFontSize * windowScale + (windowScale - 1.0) * 2,
        widthModalConfirm     = scaledFontSize * 350.0 / defaultFontSize,
        heightModalConfirm    = scaledFontSize * 102.0 / defaultFontSize,
        spaceColorDefaults    = scaledFontSize * 179.0 / defaultFontSize,
        widthWidgetDefault    = scaledFontSize * 275.0 / defaultFontSize,
        spaceSettingsBtn      = scaledFontSize * 6.0   / defaultFontSize * windowScale + (windowScale - 1.0) * 2,
        spaceSettingsDefaults = scaledFontSize * 377.0 / defaultFontSize,
    }

    -- MAIN_MENU
    if imgui.BeginMenuBar() then
        for _, data in ipairs(gatherTypes) do
            if data.name == state.gathering then
                imgui.PushStyleColor(ImGuiCol_Button, 0.21, 0.47, 0.59, 1); -- info
                if imgui.SmallButton(string.upperfirst(data.short)) then
                    state.gathering = data.name;
                    state.settings.setPrices.gathering = state.gathering;
                    state.settings.setColors.gathering = state.gathering;
                end
                imgui.PopStyleColor();
            else
                if imgui.SmallButton(string.upperfirst(data.short)) then
                    state.gathering = data.name;
                    state.settings.setPrices.gathering = state.gathering;
                    state.settings.setColors.gathering = state.gathering;
                end
            end
            if imgui.IsItemHovered() then
                imgui.SetTooltip(string.upperfirst(data.name));
            end
            imgui.SameLine(0.0, state.window.spaceGatherBtn);
        end
        imgui.EndMenuBar();
    end
    -- /MAIN_MENU

    imguiHalfSep();

    -- MAIN_HEADER
    if imguiShowToolTip(string.format("Progress towards your target value (adjusted within settings)."), settings.general.showToolTips) then
        imgui.SameLine(0.0, state.window.spaceToolTip)
    end
    if imgui.BeginChild("Header", -1, state.window.heightHeaderMain) then

        local progress = calcTargetProgress()
        imgui.PushStyleColor(ImGuiCol_Text, 1, 1, 0.54, 1); -- warn
        imgui.ProgressBar(progress, -1, state.window.heightHeaderMain, string.format("%s/%s", metrics[state.gathering].estimatedValue, settings.general.targetValue))
        imgui.PopStyleColor();
        imgui.EndChild();
    end
    -- /MAIN_HEADER

    imguiHalfSep(true);

    -- totals metrics
    for total, metric in pairs(table.sortKeysByLength(metrics[state.gathering].totals, true)) do
        if imguiShowToolTip(metricsTotalsToolTips[metric], settings.general.showToolTips) then
            imgui.SameLine(0.0, state.window.spaceToolTip);
        end
        imgui.Text(string.format("%s:", string.upperfirst(metric)));
        imgui.SameLine();
        imgui.Text(metrics[state.gathering].totals[metric])
    end
    -- totals metrics

    -- gathering tools
    if imguiShowToolTip("Total gathering tools on hand.", settings.general.showToolTips) then
        imgui.SameLine(0.0, state.window.spaceToolTip);
    end
    local gatherData = getGatherTypeData();
    local toolName = string.lowerToTitle(gatherData.tool)
    if gatherData.name ~= "fishing" then
        toolName = toolName.."s"
    end
    imgui.Text(toolName..":");
    imgui.SameLine();
    imgui.Text(playerStorage[gatherData.tool] or 0);
    -- /gathering tools

    -- inventory
    if imguiShowToolTip("Total inventory slots available (main inventory only).", settings.general.showToolTips) then
        imgui.SameLine(0.0, state.window.spaceToolTip);
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
    -- /inventory

    -- time passed
    if imguiShowToolTip(string.format("Time passed since your first %s attempt or when the timer was manually started.", string.upperfirst(state.gathering)), settings.general.showToolTips) then
        imgui.SameLine(0.0, state.window.spaceToolTip);
    end
    imgui.Text("Time Passed:");
    imgui.SameLine();
    local r, g, b, a = 1, 0.615, 0.615, 1 -- danger
    if state.timers[state.gathering] then
        r, g, b, a = 0.77, 0.83, 0.80, 1 -- plain
    end
    imgui.TextColored(r, g, b, a, os.date("!%X", (metrics[state.gathering].secondsPassed)))
    -- /time passed

    imgui.Spacing();

    -- timer
    if imguiShowToolTip(string.format("Start, stop, or clear the %s timer.", string.upperfirst(state.gathering)), settings.general.showToolTips) then
        imgui.SameLine(0.0, state.window.spaceToolTip);
    end
    imgui.Text("Timer:")
    imgui.SameLine();
    if imgui.SmallButton(state.values.btnStartTimer) then
        state.timers[state.gathering] = not state.timers[state.gathering];
    end
    if state.timers[state.gathering] then
        state.values.btnStartTimer = "Stop";
    else
        state.values.btnStartTimer = "Start";
    end
    imgui.SameLine();
    if imgui.SmallButton("Clear") then
        state.timers[state.gathering] = false;
        metrics[state.gathering].secondsPassed = 0;
    end
    -- /timer

    imguiHalfSep();

    -- value
    imgui.PushStyleColor(ImGuiCol_Text, 0.39, 0.96, 0.13, 1); -- success
    if imguiShowToolTip(string.format("Editable estimated value of all %s yields (yield prices adjusted within settings).", string.upperfirst(state.gathering)), settings.general.showToolTips) then
        imgui.SameLine(0.0, state.window.spaceToolTip);
    end
    imgui.Text("Value:")
    if settings.general.showToolTips then
        imgui.SameLine(0.0, state.window.spaceToolTip);
    else
        imgui.SameLine();
    end
    if (imgui.InputInt('', uiVariables[string.format("var_%s_estimatedValue", state.gathering)][1])) then
        metrics[state.gathering].estimatedValue = imgui.GetVarValue(uiVariables[string.format("var_%s_estimatedValue", state.gathering)][1]);
    end
    imgui.PopStyleColor();
    -- /value

    imguiHalfSep(true);

    -- plot yields
    local plotWidth = imgui.GetContentRegionAvailWidth();
    if settings.general.showToolTips then plotWidth = plotWidth - ( imgui.GetFontSize() * 24 / defaultFontSize ) end
    local plotYields = metrics[state.gathering].points.yields;
    local yieldsLabelMap =
    {
        [1] = string.format("Yields/HR (%.2f)", metrics[state.gathering].points.yields[#metrics[state.gathering].points.yields]),
        [2] = string.format("%.2f/HR", metrics[state.gathering].points.yields[#metrics[state.gathering].points.yields]),
        [3] = ""
    }
    local plotYieldsLabel = yieldsLabelMap[state.values.yieldsLabelIndex];
    if imguiShowToolTip(string.format("Plot histogram of %s yields per hour (click the on plot to cycle its label displays).", string.upperfirst(state.gathering)), settings.general.showToolTips) then
        imgui.SameLine(0.0, state.window.spaceToolTip);
    end
    imgui.PushStyleColor(ImGuiCol_Text, 1, 1, 0.54, 1); -- warn
    imgui.PlotHistogram("", plotYields, #plotYields, 0, plotYieldsLabel, FLT_MIN, FLT_MAX, plotWidth, state.window.heightPlot);
    imgui.PopStyleColor()
    if imgui.IsItemClicked() then
        state.values.yieldsLabelIndex = cycleIndex(state.values.yieldsLabelIndex, 1, 3);
    end
    if imgui.IsItemClicked(1) then
         state.values.yieldsLabelIndex = cycleIndex(state.values.yieldsLabelIndex, 1, 3, -1);
    end
    if imgui.IsItemHovered() then
        if plotYieldsLabel == "" then
            imgui.SetTooltip(string.format("Yields/HR (%.2f)", metrics[state.gathering].points.yields[#metrics[state.gathering].points.yields]));
        else
            imgui.SetTooltip("");
        end
    end
    -- /plot yields

    -- plot values
    local plotValues = metrics[state.gathering].points.values;
    local valuesLabelMap =
    {
        [1] = string.format("Value/HR (%.2f)", metrics[state.gathering].points.values[#metrics[state.gathering].points.values]),
        [2] = string.format("%.2f/HR", metrics[state.gathering].points.values[#metrics[state.gathering].points.values]),
        [3] = ""
    }
    local plotValuesLabel = valuesLabelMap[state.values.valuesLabelIndex];
    if imguiShowToolTip("Plot lines of the estimated value per hour (L/R click on the plot to cycle its label displays).", settings.general.showToolTips) then
        imgui.SameLine(0.0, state.window.spaceToolTip);
    end
    imgui.PushStyleColor(ImGuiCol_Text, 1, 1, 0.54, 1); -- warn
    imgui.PlotLines("", plotValues, #plotValues, 0, plotValuesLabel, FLT_MIN, FLT_MAX, plotWidth, state.window.heightPlot);
    imgui.PopStyleColor()
    if imgui.IsItemClicked() then
         state.values.valuesLabelIndex = cycleIndex(state.values.valuesLabelIndex, 1, 3);
    end
    if imgui.IsItemClicked(1) then
         state.values.valuesLabelIndex = cycleIndex(state.values.valuesLabelIndex, 1, 3, -1);
    end
    if imgui.IsItemHovered() then
        if plotValuesLabel == "" then
            imgui.SetTooltip(string.format("Value/HR (%.2f)", metrics[state.gathering].points.values[#metrics[state.gathering].points.values]));
        else
            imgui.SetTooltip("");
        end
    end
    -- /plot values

    imguiFullSep();

    -- MAIN_SCROLLING
    if imguiShowToolTip(string.format("Scrollable List of current %s yields and their amounts (L/R click on the list to cycle its sorting methods).", string.upperfirst(state.gathering)), settings.general.showToolTips) then
        imgui.SameLine(0.0, state.window.spaceToolTip);
    end
    if imgui.BeginChild("Scrolling", -1, state.window.heightYields, true) then
        imgui.SetWindowFontScale(state.window.scale);
        -- yields
        yieldsSortMap =
        {
            [1] = { table.sortKeysByAlphabet(metrics[state.gathering].yields, false), "Alphabetical (DESC)" },
            [2] = { table.sortKeysByAlphabet(metrics[state.gathering].yields, true), "Alphabetical (ASC)" },
            [3] = { table.sortbykey(metrics[state.gathering].yields, false), "Count (DESC)" },
            [4] = { table.sortbykey(metrics[state.gathering].yields, true), "Count (ASC)" },
            [5] = { table.sortKeysByTotalValue(metrics[state.gathering].yields, false), "Value (DESC)" },
            [6] = { table.sortKeysByTotalValue(metrics[state.gathering].yields, true), "Value (ASC)"}
        }
        for _, item in pairs(yieldsSortMap[state.values.yieldSortIndex][1]) do
            local r, g, b, a = colorToRGBA(settings.yields[state.gathering][item].color);
            imgui.TextColored(r/255, g/255, b/255, a/255, item..":");
            imgui.SameLine(0.0, state.window.spaceToolTip);
            imgui.Text(metrics[state.gathering].yields[item]);
            if settings.general.showDetailedYields then
                local pricePer = getPrice(item);
                local r, g, b, a = colorToRGBA(settings.general.yieldDetailsColor);
                imgui.TextColored(r/255, g/255, b/255, a/255, string.format("  @%dea.=(%s)", getPrice(item), math.floor(getPrice(item) * metrics[state.gathering].yields[item])));
            end
        end
        imgui.EndChild();
        if imgui.IsItemClicked() then
            state.values.yieldSortIndex = cycleIndex(state.values.yieldSortIndex, 1, 6);
        end
        if imgui.IsItemClicked(1) then
            state.values.yieldSortIndex = cycleIndex(state.values.yieldSortIndex, 1, 6, -1);
        end
        if imgui.IsItemHovered() then
            imgui.SetTooltip(string.format("Sort Type: %s", yieldsSortMap[state.values.yieldSortIndex][2]));
        end
        -- /yields
    end
    -- /MAIN_SCROLLING

    imguiFullSep();

    if imgui.Button("Exit") then
        state.actions.modalConfirmAction = function() AshitaCore:GetChatManager():QueueCommand('/addon unload yield', 1); end
        state.values.modalConfirmPrompt = string.format(modalConfirmPromptTemplate, "Exit");
        state.values.modalConfirmHelp = "(All gathering data will be saved.)";
        imgui.OpenPopup("Yield Confirm")
    end

    imgui.SameLine(0.0, state.window.spaceFooterBtn);

    if imgui.Button("Reload") then
        state.actions.modalConfirmAction = function() AshitaCore:GetChatManager():QueueCommand('/addon reload yield', 1); end
        state.values.modalConfirmPrompt = string.format(modalConfirmPromptTemplate, "Reload");
        state.values.modalConfirmHelp = "(All gathering data will be saved.)";
        imgui.OpenPopup("Yield Confirm")
    end

    imgui.SameLine(0.0, state.window.spaceFooterBtn);

    if imgui.Button("Reset") then
        state.actions.modalConfirmAction = function()
            -- Reset the metrics..
            metrics[state.gathering] = table.copy(metricsTemplate);
            -- Reset the timers..
            for timerName, running in pairs(state.timers) do
                state.timers[timerName] = false
            end
            -- Reset ui variables..
            imgui.SetVarValue(uiVariables[string.format("var_%s_estimatedValue", state.gathering)][1], metrics[state.gathering].estimatedValue);
        end
        state.values.modalConfirmPrompt = string.format(modalConfirmPromptTemplate, "Reset");
        state.values.modalConfirmHelp = string.format("(Current %s data will be lost.)", string.upperfirst(state.gathering));
        state.values.modalConfirmDanger = true;
        imgui.OpenPopup("Yield Confirm")
    end

    imgui.SameLine(0.0, state.window.spaceFooterBtn);

    if imgui.Button("Settings") then
        imgui.OpenPopup("Yield Settings");
    end

    imgui.SameLine(0.0, state.window.spaceFooterBtn);
    if imgui.Button("Help") then
        print("Sorry, not yet implemented..")
    end

    -- SETTINGS
    local scaledHeightReduction = 0;
    if windowScale == 1.15 then scaledHeightReduction = 7 elseif windowScale == 1.30 then scaledHeightReduction = 12 end;
    local modalSaveAction = function()
        imgui.CloseCurrentPopup();
        state.settings.setPrices.gathering = state.gathering;
        state.settings.setColors.gathering = state.gathering;
        state.settings.setPrices.priceModeChanged = false;
        state.settings.setPrices.priceEntryChanged = false;
        saveSettings();
    end
    imgui.SetNextWindowSize(state.window.widthSettings, state.window.heightSettings - scaledHeightReduction, ImGuiSetCond_Always);
    if imgui.BeginPopupModal("Yield Settings", imgui.GetVarValue(uiVariables['var_WindowVisible'][1]), imgui.bor(ImGuiWindowFlags_MenuBar, ImGuiWindowFlags_NoResize)) then
        imgui.SetWindowFontScale(state.window.scale);
        -- SETTINGS_MENU
        if imgui.BeginMenuBar() then
            for i, data in ipairs(settingsTypes) do
                local btnName = string.camelToTitle(data.name);
                pushSettingsBtnColor(i);
                if imgui.Button(btnName) then
                    state.settings.activeIndex = i;
                end
                imgui.PopStyleColor();
                imgui.SameLine(0.0, state.window.spaceSettingsBtn);
            end
            imgui.EndMenuBar();
        end
        -- /SETTINGS_MENU

        -- render settings pages..
        imgui.BeginGroup();
        imgui.Spacing();
        switch(state.settings.activeIndex) : caseof
        {
            [1] = function() renderSettingsGeneral() end,
            [2] = function() renderSettingsSetPrices() end,
            [3] = function() renderSettingsSetColors() end,
            [4] = function() renderSettingsSetAlerts() end,
            [5] = function() renderSettingsReports() end,
            [6] = function() renderSettingsFeedback() end,
            [7] = function() renderSettingsAbout() end,
        };
        imgui.EndGroup();

        imgui.Spacing();
        --imgui.SetCursorPosX(imgui.GetWindowWidth() - 40);
        if imgui.Button("Done") then
            modalSaveAction();
        end

        imgui.SameLine();
        imgui.Text("OR click away OR press Escape to save.");
        if (imgui.IsKeyPressed(imgui.GetKeyIndex(ImGuiKey_Escape))) then
            modalSaveAction();
        end
        if (not imgui.IsMouseHoveringAnyWindow() and imgui.IsMouseClicked()) then
            modalSaveAction();
        end

        --imgui.SameLine(0.0, 30);
        --[[ TODO: come up with better solution..
        if state.settings.setPrices.priceModeChanged or state.settings.setPrices.priceEntryChanged then
            if table.count(metrics[state.settings.setPrices.gathering].yields) > 0 then
                if imguiShowToolTip(string.format("Choose to update the current estimated value with any pricing changes.", string.upperfirst(state.gathering)), settings.general.showToolTips) then
                    imgui.SameLine(0.0, state.window.spaceToolTip);
                end
                imgui.PushStyleColor(ImGuiCol_Button, 0.21, 0.47, 0.59, 1); -- info
                if imgui.Button("Update Est. Value") then
                    print("Sorry, not yet implemented..")
                    state.settings.setPrices.priceModeChanged = false;
                    state.settings.setPrices.priceEntryChanged = false;
                end
                imgui.PopStyleColor();
            end
        end
        --]]

        if state.initializing then
            imgui.CloseCurrentPopup();
        end

        imgui.EndPopup();
        imgui.PopStyleVar();
    end
    -- /SETTINGS

    -- CONFIRM
    local scaledHeightReduction = 0;
    if windowScale == 1.15 then scaledHeightReduction = 10 elseif windowScale == 1.30 then scaledHeightReduction = 16 end;
    imgui.SetNextWindowSize(state.window.widthModalConfirm, state.window.heightModalConfirm - scaledHeightReduction, ImGuiSetCond_Always)
    if imgui.BeginPopupModal("Yield Confirm", imgui.GetVarValue(uiVariables['var_WindowVisible'][1]), imgui.bor(ImGuiWindowFlags_NoResize)) then
        imgui.SetWindowFontScale(state.window.scale);
        imgui.Text(state.values.modalConfirmPrompt);
        imgui.Spacing();
        if state.values.modalConfirmHelp then
            local r, g, b, a = 0.39, 0.96, 0.13, 1
            if state.values.modalConfirmDanger then
                r, g, b, a =  1, 0.615, 0.615, 1
            end
            imgui.TextColored(r, g, b, a, state.values.modalConfirmHelp);
        end
        imguiFullSep();
        if imgui.Button("Yes") or state.initializing then
            imgui.CloseCurrentPopup();
            state.actions.modalCancelAction = function() end
            state.actions.modalConfirmAction();
        end
        imgui.SameLine(0.0, 10);
        if imgui.Button("No") then
            imgui.CloseCurrentPopup();
            state.actions.modalConfirmAction = function() end
            state.actions.modalCancelAction();
        end
        imgui.SameLine();
        imgui.Text("OR click away OR press Escape to exit.");
        if (imgui.IsKeyPressed(imgui.GetKeyIndex(ImGuiKey_Escape))) then
            modalSaveAction();
        end
        if (not imgui.IsMouseHoveringAnyWindow() and imgui.IsMouseClicked()) then
            modalSaveAction();
        end

        if state.initializing then
            imgui.CloseCurrentPopup();
        end

        imgui.EndPopup();
    else
        state.values.modalConfirmPrompt = ""
        state.values.modalConfirmHelp   = ""
        state.values.modalConfirmDanger = false
    end
    -- /CONFIRM

    state.initializing = false
    -- /MAIN
    imgui.End();
end);

----------------------------------------------------------------------------------------------------
-- func: renderSettingsGeneral
-- desc: Renders the General settings.
----------------------------------------------------------------------------------------------------
function renderSettingsGeneral()
    if imgui.BeginChild("General", -1, state.window.heightSettingsContent, imgui.GetVarValue(uiVariables['var_WindowVisible'][1])) then
        imgui.SetWindowFontScale(state.window.scale);
        imgui.PushItemWidth(state.window.widthWidgetDefault);
        imgui.Spacing();

        imgui.TextColored(1, 1, 0.54, 1, "Window");

        local spaceSettingsDefaults = state.window.spaceSettingsDefaults;
        if settings.general.showToolTips then spaceSettingsDefaults = spaceSettingsDefaults - ( imgui.GetFontSize() * 24 / defaultFontSize ) end
        imgui.SameLine(0.0, spaceSettingsDefaults);
        if imguiShowToolTip("Set all general settings to their defaults.", settings.general.showToolTips) then
            imgui.SameLine(0.0, state.window.spaceToolTip);
        end
        imgui.PushStyleColor(ImGuiCol_Button, 0.21, 0.47, 0.59, 1); -- info
        if imgui.Button("Defaults") then
            settings.general = table.copy(defaultSettingsTemplate.general);
            imgui.SetVarValue(uiVariables["var_WindowOpacity"][1], settings.general.opacity);
            imgui.SetVarValue(uiVariables["var_TargetValue"][1], settings.general.targetValue);
            imgui.SetVarValue(uiVariables["var_ShowToolTips"][1], settings.general.showToolTips);
            imgui.SetVarValue(uiVariables["var_WindowScaleIndex"][1], settings.general.windowScaleIndex);
            imgui.SetVarValue(uiVariables["var_ShowDetailedYields"][1], settings.general.showDetailedYields);
            local r, g, b, a = colorToRGBA(settings.general.yieldDetailsColor);
            imgui.SetVarValue(uiVariables["var_YieldDetailsColor"][1], r/255, g/255, b/255, a/255);
        end
        imgui.PopStyleColor();

        imguiFullSep();

        -- Opacity
        if imguiShowToolTip("Current alpha channel value of all Yield windows.", settings.general.showToolTips) then
            imgui.SameLine(0.0, state.window.spaceToolTip);
        end
        if (imgui.SliderFloat("Window Opacity", uiVariables['var_WindowOpacity'][1], 0.25, 1.0, "%1.2f")) then
            settings.general.opacity = imgui.GetVarValue(uiVariables['var_WindowOpacity'][1])
        end
        -- /Opacity

        imgui.Spacing();

        -- Scale
        if imguiShowToolTip("Current size for all Yield windows.", settings.general.showToolTips) then
            imgui.SameLine(0.0, state.window.spaceToolTip);
        end
        if imgui.Combo("Window Size", uiVariables['var_WindowScaleIndex'][1], "Small\0Medium\0Large\0\0") then
            settings.general.windowScaleIndex = imgui.GetVarValue(uiVariables['var_WindowScaleIndex'][1]);
        end
        -- /Scale

        imguiFullSep();

        imgui.TextColored(1, 1, 0.54, 1, "Gathering")

        imguiFullSep();

        -- Target Value
        if imguiShowToolTip("Amount you would like to earn this session (affects progress bar).", settings.general.showToolTips) then
            imgui.SameLine(0.0, state.window.spaceToolTip);
        end
        if (imgui.InputInt("Target Value", uiVariables['var_TargetValue'][1])) then
            settings.general.targetValue = imgui.GetVarValue(uiVariables['var_TargetValue'][1]);
        end
        -- /Target Value

        imgui.Spacing();

        -- Detailed Yields
        if imguiShowToolTip("Toggles the display of the math breakdown in the scrollable yields list.", settings.general.showToolTips) then
            imgui.SameLine(0.0 , state.window.spaceToolTip);
        end
        if (imgui.Checkbox("Show Detailed Yields", uiVariables['var_ShowDetailedYields'][1])) then
            settings.general.showDetailedYields = imgui.GetVarValue(uiVariables['var_ShowDetailedYields'][1]);
        end
        -- /Detailed Yields

        imgui.Spacing();

        -- Yield Details Color
        if imguiShowToolTip("Set the color of the math breakdown in the scrollable yields list.", settings.general.showToolTips) then
            imgui.SameLine(0.0, state.window.spaceToolTip);
        end
        local r, g, b, a = colorToRGBA(settings.general.yieldDetailsColor);

        if imgui.ColorEdit4("Yield Details Color", uiVariables["var_YieldDetailsColor"][1]) then
            settings.general.yieldDetailsColor = colorTableToInt(imgui.GetVarValue(uiVariables["var_YieldDetailsColor"][1]));
        end
        -- /Yield Details Color

        imguiFullSep();

        imgui.TextColored(1, 1, 0.54, 1, "Misc") -- warn

        imguiFullSep();

        -- Tooltips
        if imguiShowToolTip("Toggles the display of (?)s and their tooltips.", settings.general.showToolTips) then
            imgui.SameLine(0.0, state.window.spaceToolTip);
        end
        if (imgui.Checkbox('Show (?) Tooltips', uiVariables['var_ShowToolTips'][1])) then
            settings.general.showToolTips = imgui.GetVarValue(uiVariables['var_ShowToolTips'][1]);
        end
        -- /Tooltips
        imgui.PopItemWidth();
        imgui.EndChild()
    end
end

----------------------------------------------------------------------------------------------------
-- func: renderSettingsSetPrices
-- desc: Renders the Set Prices settings.
----------------------------------------------------------------------------------------------------
function renderSettingsSetPrices()
    local currentPrices = state.settings.setPrices.gathering

    if imgui.BeginChild("Set Prices", -1, state.window.heightSettingsContent, imgui.GetVarValue(uiVariables['var_WindowVisible'][1]), imgui.bor(ImGuiWindowFlags_MenuBar, ImGuiWindowFlags_NoResize)) then
        imgui.SetWindowFontScale(state.window.scale);
        if imgui.BeginMenuBar() then
            for _, data in ipairs(gatherTypes) do
                if data.name == state.settings.setPrices.gathering then
                    imgui.PushStyleColor(ImGuiCol_Button, 0.21, 0.47, 0.59, 1); -- info
                    if imgui.SmallButton(string.upperfirst(data.short)) then state.settings.setPrices.gathering = data.name end
                    imgui.PopStyleColor();
                else
                    if imgui.SmallButton(string.upperfirst(data.short)) then state.settings.setPrices.gathering = data.name end
                end
                if imgui.IsItemHovered() then
                    imgui.SetTooltip(string.upperfirst(data.name));
                end
                imgui.SameLine(0.0, state.window.spaceGatherBtn);
            end

            -- Price Mode
            local spaceStackMode = state.window.spaceStackModeRadio;
            if settings.general.showToolTips then spaceStackMode = spaceStackMode - ( imgui.GetFontSize() * 24 / defaultFontSize ) end
            imgui.SameLine(0.0, spaceStackMode);
            if imguiShowToolTip(string.format("Set %s yield prices based on the current market stack price. Otherwise, use the individual price.", string.upperfirst(state.settings.setPrices.gathering)), settings.general.showToolTips) then
                imgui.SameLine(0.0, state.window.spaceToolTip);
            end
            if imgui.RadioButton("Use Stack Price", settings.priceModes[state.settings.setPrices.gathering]) then
                settings.priceModes[state.settings.setPrices.gathering] = not settings.priceModes[state.settings.setPrices.gathering];
                -- TODO: come up with better solution..
                state.settings.setPrices.priceModeChanged = not state.settings.setPrices.priceModeChanged;
            end
            -- /Price Mode

            imgui.EndMenuBar();
        end


        local scaledHeightAddition = 0;
        if state.window.scale > 1.00 then scaledHeightAddition = 2 end;
        if imgui.BeginChild("Scrolling", imgui.GetContentRegionAvailWidth(), state.window.heightSettingsScroll + scaledHeightAddition) then
            imgui.SetWindowFontScale(state.window.scale);
            for data, yield in pairs(table.sortKeysByAlphabet(settings.yields[state.settings.setPrices.gathering], true)) do
                local yieldTip = string.format("Set the current market price for a single %s.", yield);
                if settings.priceModes[state.settings.setPrices.gathering] then
                    yieldTip = string.format("Set the current market price for a stack of %ss (Yield will do the math for you).", yield);
                end
                if imguiShowToolTip(yieldTip, settings.general.showToolTips) then
                    imgui.SameLine(0.0, state.window.spaceToolTip);
                end
                imgui.PushItemWidth(state.window.widthWidgetDefault);
                if (imgui.InputInt(yield, uiVariables[string.format("var_%s_%s", state.settings.setPrices.gathering, string.clean(yield))][1])) then
                    settings.yields[state.settings.setPrices.gathering][yield].price = imgui.GetVarValue(uiVariables[string.format("var_%s_%s", state.settings.setPrices.gathering, string.clean(yield))][1]);
                end
                imgui.PopItemWidth();
            end

            imgui.EndChild()
        end
        imgui.EndChild()
    end
end

----------------------------------------------------------------------------------------------------
-- func: renderSettingsSetColors
-- desc: Renders the Set Colors settings.
----------------------------------------------------------------------------------------------------
function renderSettingsSetColors()
    if imgui.BeginChild("Set Colors", -1, state.window.heightSettingsContent, imgui.GetVarValue(uiVariables['var_WindowVisible'][1]), imgui.bor(ImGuiWindowFlags_MenuBar, ImGuiWindowFlags_NoResize)) then
        imgui.SetWindowFontScale(state.window.scale);
        if imgui.BeginMenuBar() then
            for _, data in ipairs(gatherTypes) do
                if data.name == state.settings.setColors.gathering then
                    imgui.PushStyleColor(ImGuiCol_Button, 0.21, 0.47, 0.59, 1); -- info
                    if imgui.SmallButton(string.upperfirst(data.short)) then state.settings.setColors.gathering = data.name end
                    imgui.PopStyleColor();
                else
                    if imgui.SmallButton(string.upperfirst(data.short)) then state.settings.setColors.gathering = data.name end
                end
                if imgui.IsItemHovered() then
                    imgui.SetTooltip(string.upperfirst(data.name));
                end
                imgui.SameLine(0.0, state.window.spaceGatherBtn);
            end

            -- Defaults
            local spaceColorDefaults = state.window.spaceColorDefaults;
            if settings.general.showToolTips then spaceColorDefaults = spaceColorDefaults - ( imgui.GetFontSize() * 24 / defaultFontSize ) end
            imgui.SameLine(0.0, spaceColorDefaults);
            if imguiShowToolTip(string.format("Set all %s yield colors to their defaults.", string.upperfirst(state.settings.setColors.gathering)), settings.general.showToolTips) then
                imgui.SameLine(0.0, state.window.spaceToolTip);
            end
            imgui.PushStyleColor(ImGuiCol_Button, 0.21, 0.47, 0.59, 1); -- info
            if imgui.SmallButton("Defaults") then
                for yield, data in pairs(settings.yields[state.settings.setColors.gathering]) do
                    settings.yields[state.settings.setColors.gathering][yield].color = -3877684 -- plain
                    local r, g, b, a = colorToRGBA(-3877684);
                    imgui.SetVarValue(uiVariables[string.format("var_%s_%s_color", state.settings.setColors.gathering, string.clean(yield))][1], r/255, g/255, b/255, a/255);
                end
            end
            imgui.PopStyleColor();
            -- /Defaults

            imgui.EndMenuBar();
        end
        local scaledHeightAddition = 0;
        if state.window.scale > 1.00 then scaledHeightAddition = 2 end;
        if imgui.BeginChild("Scrolling", imgui.GetContentRegionAvailWidth(), state.window.heightSettingsScroll + scaledHeightAddition) then
            imgui.SetWindowFontScale(state.window.scale);
            for data, yield in pairs(table.sortKeysByAlphabet(settings.yields[state.settings.setColors.gathering], true)) do
                if imguiShowToolTip(string.format("Set the text color for %s when its displayed in the yield list.", yield), settings.general.showToolTips) then
                    imgui.SameLine(0.0, state.window.spaceToolTip);
                end
                local r, g, b, a = colorToRGBA(settings.yields[state.settings.setColors.gathering][yield].color);
                imgui.PushStyleColor(ImGuiCol_Text, r/255, g/255, b/255, a/255);
                imgui.PushItemWidth(state.window.widthWidgetDefault);
                if (imgui.ColorEdit4(yield, uiVariables[string.format("var_%s_%s_color", state.settings.setColors.gathering, string.clean(yield))][1])) then
                    settings.yields[state.settings.setColors.gathering][yield].color = colorTableToInt(imgui.GetVarValue(uiVariables[string.format("var_%s_%s_color", state.settings.setColors.gathering, string.clean(yield))][1]));
                end
                imgui.PopStyleColor();
                imgui.PopItemWidth();
            end
            imgui.EndChild()
        end
        imgui.EndChild()
    end
end

----------------------------------------------------------------------------------------------------
-- func: renderSettingsSetAlerts
-- desc: Renders the Set Alerts settings.
----------------------------------------------------------------------------------------------------
function renderSettingsSetAlerts()
    if imgui.BeginChild("Set Alerts", -1, state.window.heightSettingsContent, true) then
        imgui.SetWindowFontScale(state.window.scale);
        imgui.Text("Set sound alerts for specific yields.");
        imgui.Spacing();
        imgui.Text("Comming Soon..");
        imgui.EndChild();
    end
end

----------------------------------------------------------------------------------------------------
-- func: renderSettingsReports
-- desc: Renders the Reports section in settings.
----------------------------------------------------------------------------------------------------
function renderSettingsReports()
    if imgui.BeginChild("Set Alerts", -1, state.window.heightSettingsContent, true) then
        imgui.SetWindowFontScale(state.window.scale);
        imgui.Text("Manage generated yield reports.");
        imgui.Spacing();
        imgui.Text("Comming Soon..");
        imgui.EndChild();
    end
end

----------------------------------------------------------------------------------------------------
-- func: renderSettingsFeedback
-- desc: Renders the Reports section in settings.
----------------------------------------------------------------------------------------------------
function renderSettingsFeedback()
    if imgui.BeginChild("Set Alerts", -1, state.window.heightSettingsContent, true) then
        imgui.SetWindowFontScale(state.window.scale);
        imgui.Text("Provide general feedback or report and issue.");
        imgui.Spacing();
        imgui.Text("Comming Soon..");
        imgui.EndChild();
    end
end

----------------------------------------------------------------------------------------------------
-- func: renderSettingsAbout
-- desc: Renders the About section in settings.
----------------------------------------------------------------------------------------------------
function renderSettingsAbout()
    if imgui.BeginChild("About", -1, state.window.heightSettingsContent, true) then
        imgui.SetWindowFontScale(state.window.scale);
        imgui.PushTextWrapPos(imgui.GetContentRegionAvailWidth());
        for _, v in ipairs(helpTable.about) do
            imgui.Text(string.strip_colors(v));
            imgui.Spacing();
        end
        imgui.Text("Special Thanks:");
        imguiFullSep();
        imgui.Text("To Narpt: (https://www.twitch.tv/narpt) for his awesome streams and the idea to make this!");
        imgui.Spacing();
        imgui.Text("To Hughesyourdaddy: (https://www.omega-ffxi.com) for granting me the freedom to create this within the Omega private server.");
        imgui.Spacing();
        imgui.Text("To the Ashita team: (https://www.ashitaxi.com/) for making this possible.");
        imgui.EndChild();
    end
end
