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
    ["var_WindowOpacity"] = { nil, ImGuiVar_FLOAT, 1.0 },
    ["var_TargetValue"] = { nil, ImGuiVar_UINT32, 0 }
}

local help = {
    commands = {
        buildHelpSeperator('=', 26),
        buildHelpTitle('Commands'),
        buildHelpSeperator('=', 26),
        buildHelpCommandEntry('unload', 'Unload Yield.'),
        buildHelpCommandEntry('reload', 'Reload Yield.'),
        buildHelpCommandEntry('about', 'Display information about Yield.'),
        buildHelpCommandEntry('help', 'Display Yield commands.'),
        buildHelpSeperator('=', 26),
    },
    about = {
        buildHelpSeperator('=', 23),
        buildHelpTitle('About'),
        buildHelpSeperator('=', 23),
        buildHelpTypeEntry('Name', _addon.name),
        buildHelpTypeEntry('Description', _addon.description),
        buildHelpTypeEntry('Author', _addon.author),
        buildHelpTypeEntry('Version', _addon.version),
        buildHelpTypeEntry('Support/Donate', "https://Paypal.me/Sjshovan"),
        buildHelpSeperator('=', 23),
    },
    aliases = {}
}

local state = {
    active = true,
    initializing = true,
    settings = {
        general = {active = true},
        setPrices = {active = false, gathering = strings.gathering.mining.name },
        setAlerts = {active = false, default = ""},
        about = {active = false},
    },
    gathering = strings.gathering.mining.name,
    gatheringShort = strings.gathering.mining.short,
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
    strings.gathering.mining,
    strings.gathering.harvesting,
    strings.gathering.logging,
    strings.gathering.excavating,
    strings.gathering.clamming
}

local settingBtnsOrder = {
    "general",
    "setPrices",
    "setAlerts",
    "about"
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
    metrics[v.name] = table.copy(metricsTemplate);
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
        local pointsLimit = 3600
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

function getPrice(gatherType, itemName)
    return settings.prices[gatherType][itemName] or 0
end

function adjTotal(gatherType, metricName, val)
    local total = metrics[gatherType].totals[metricName]
    if total == nil then total = 0 end
    metrics[gatherType].totals[metricName] = total + val
end

function adjYield(gatherType, yieldName, val)
    local yield = metrics[gatherType].yields[yieldName]
    if yield == nil then yield = 0 end
    metrics[gatherType].yields[yieldName] = yield + val
end

function calcTargetProgress()
    local progress = metrics[state.gathering].estimatedValue/settings.targetValue
    if progress == math.huge or progress ~= progress then progress = 0.0 end
    if progress < 0 then progress = 0.0 end
    if progress > 1.0 then progress = 1.0 end
    return progress
end

function timeFormatSeconds(seconds)
    local s = tonumber(seconds)
    return string.format("%02d:%02d:%02d", math.floor(s/3600), math.floor(s/60), s%60);
end

ashita.register_event('load', function()
    state.initializing = true

    ashita.file.create_dir(_addon.path .. '/settings/');

    settings = ashita.settings.load_merged(
        _addon.path .. '/settings/settings.json', settings
    )

    -- Add price uivariables from settings
    for k, v in pairs(settings.prices) do
        if #v then
            for yield, price in pairs(v) do
                uiVariables[string.format("var_%s_%s", k, string.clean(yield))] = { nil, ImGuiVar_UINT32, 0 }
            end
        end
    end

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

    loadSettings();
end)

ashita.register_event('unload', function()
    saveSettings();
    -- Cleanup the custom variables..
    for k, v in pairs(uiVariables) do
        if (uiVariables[k][1] ~= nil) then
            imgui.DeleteVar(uiVariables[k][1]);
        end
        uiVariables[k][1] = nil;
    end
end)

ashita.register_event('command', function(command, ntype)
    local command_args = command:lower():args();

    if not tableContains(_addon.commands, command_args[1]) then
        return false;
    end 

    local respond = false;
    local response_message = '';
    local success = true;

    if command_args[2] == 'reload' or command_args[2] == 'r' then
        AshitaCore:GetChatManager():QueueCommand('/addon reload yield', 1);
    
    elseif command_args[2] == 'unload' or command_args[2] == 'u' then
        respond = true;
        response_message = 'Thank you for using Yield. Goodbye.';
        AshitaCore:GetChatManager():QueueCommand('/addon unload yield', 1);

    elseif command_args[2] == 'about' or command_args[2] == 'a' then
        display_help(help.about);
        
    elseif command_args[2] == 'help' or command_args[2] == 'h' then
        display_help(help.commands);

    else
        display_help(help.commands);
    end

    if respond then
        displayResponse(
            buildCommandResponse(response_message, success)
        );
    end

    return false;
end)

---------------------------------------------------------------------------------------------------
-- func: incoming_text
-- desc: Event called when the addon is asked to handle an incoming chat line.
---------------------------------------------------------------------------------------------------
ashita.register_event('incoming_text', function(mode, message, modifiedmode, modifiedmessage, blocked)
    -- Do nothing if the line is already blocked..
    if (blocked) then return false; end

    -- Handle the modified message if its set..
    if (modifiedmessage ~= nil and #modifiedmessage > 0) then
        message = modifiedmessage;
    end
        
    -- Check for double-chat lines (ie. npc chat)..
    if (message:startswith(string.char(0x1E, 0x01))) then
        return false;
    end
    -- Remove colors form message
    message = string.strip_colors(message);

    -- Start Mining --
    local patterns = strings.gathering[state.gathering].patterns;
    --TODO: can probably remove the check for mining specifically
    if state.attempting then
        adjTotal(state.gathering, "attempts",  1);
        if not state.firstAttempts[state.gathering] then
            state.firstAttempts[state.gathering] = true
        end
        local success = string.match(message, patterns.success) or string.match(message, patterns.successBreak);
        local successBreak = string.match(message, patterns.successBreak);
        local unable = message == patterns.unable;
        local broken = string.match(message, patterns.broken);
        local full = string.contains(message, patterns.full);
        local val = 0;
        if success then
            if state.gathering == strings.gathering.mining.name then
                local chunk = string.match(success, patterns.chunk);
                if chunk then success = chunk end
            end
            success = string.gsub(" "..success, "%W%l", string.upper):sub(2);
            adjYield(state.gathering, success, 1);
            val = getPrice(state.gathering, success);
            if successBreak then
                adjTotal(state.gathering, "breaks", 1);
            end
            adjTotal(state.gathering, "yields", 1);
        elseif broken then
            adjTotal(state.gathering, "breaks", 1);
        elseif unable then
        elseif full then
            adjTotal(state.gathering, "lost", 1);
        end
        if success or successBreak or unable or broken or full then
            state.attempting = false;
        end
        curVal = metrics[state.gathering].estimatedValue;
        metrics[state.gathering].estimatedValue = curVal + val;
    end
   -- End Mining --
    return false;
end);

----------------------------------------------------------------------------------------------------
-- func: render
-- desc: Called when the addon is rendering.
----------------------------------------------------------------------------------------------------
local var = imgui.CreateVar(1.0, 1.0)
ashita.register_event('render', function()

    --print(AshitaCore:GetDataManager():GetInventory():GetItem(Containers.Inventory, 605))
    local title = ">>> "..string.upper(state.gathering).." <<<";
    local fontSize = imgui.GetFontSize() * title:len() / 2;
    local height =  452.0;
    local width = 210.0;
    local paddingX = 5.0;
    local paddingY = 5.0;
    local spacing = 5.0;
    --imgui.PushStyleColor(ImGuiCol_WindowBg, 0, 0, 0, settings.window.opacity);
    --imgui.PushStyleColor(ImGuiCol_ChildWindowBg, 0, 0, 0, settings.window.opacity);
    --imgui.PushStyleColor(ImGuiCol_MenuBarBg, 0, 0, 0, settings.window.opacity);
    --imgui.PushStyleColor(ImGuiCol_ComboBg, 0, 0, 0, settings.window.opacity);
    imgui.SetNextWindowSize(width, height, ImGuiSetCond_Once);
    imgui.PushStyleVar(ImGuiStyleVar_WindowRounding, 5.0);
    imgui.PushStyleVar(ImGuiStyleVar_Alpha, settings.window.opacity);
    imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, paddingX, paddingY);
    imgui.Begin(string.format("%s - v%s", _addon.name, _addon.version), state.active, ImGuiWindowFlags_MenuBar+ImGuiWindowFlags_NoResize)
    --imgui.PushStyleVar(ImGuiStyleVar_WindowMinSize, width, height);
    imgui.BeginMenuBar()
    for _, v in ipairs(gatherBtnsOrder) do
        if v.name == state.gathering then
            imgui.PushStyleColor(ImGuiCol_Button, 0.21, 0.47, 0.59, 1);
            if imgui.SmallButton(v.short) then state.gathering = v.name; state.settings.setPrices.gathering = state.gathering; end
            imgui.PopStyleColor();
        else
            if imgui.SmallButton(v.short) then state.gathering = v.name; state.settings.setPrices.gathering = state.gathering; end
        end
        imgui.SameLine(0.0, spacing);
    end
    imgui.EndMenuBar();

    imgui.Spacing();
    imgui.Separator();

    imgui.BeginChild("Header", -1, 15)

    local progress = calcTargetProgress()
    imgui.PushStyleColor(ImGuiCol_Text, 1, 1, 0.54, settings.window.opacity);
    imgui.ProgressBar(progress, -1, 15, title)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip();
        imgui.SetTooltip(string.format(strings.tooltips.progress, metrics[state.gathering].estimatedValue, settings.targetValue));
        imgui.EndTooltip();
    end
    imgui.PopStyleColor();
    imgui.EndChild();
    imgui.Separator();
    imgui.Spacing();

    for metric, total in pairs(metrics[state.gathering].totals) do
        imgui.Text(string.upperfirst(metric)..": ");
        if imgui.IsItemHovered() then
            imgui.BeginTooltip();
            imgui.SetTooltip(strings.tooltips.totals[metric]);
            imgui.EndTooltip();
        end
        imgui.SameLine();
        imgui.Text(total)
    end
    imgui.Text("Time Passed: ");
    if imgui.IsItemHovered() then
        imgui.BeginTooltip();
        imgui.SetTooltip(string.format(strings.tooltips.secondsPassed, state.gathering));
        imgui.EndTooltip();
    end
    imgui.SameLine();
    imgui.Text(timeFormatSeconds(metrics[state.gathering].secondsPassed))

    imgui.Spacing();
    imgui.Separator();
    imgui.Spacing();

    imgui.PushStyleColor(ImGuiCol_Text, 0.39, 0.96, 0.13, settings.window.opacity);
    imgui.Text("Value (estd.): ");
    if imgui.IsItemHovered() then
       imgui.BeginTooltip();
       imgui.SetTooltip(strings.tooltips.estimatedValue);
       imgui.EndTooltip();
    end
    imgui.SameLine();
    imgui.Text(metrics[state.gathering]["estimatedValue"]);
    imgui.PopStyleColor();

    imgui.Spacing();
    imgui.Separator();
    imgui.Spacing();

    local plotYields = metrics[state.gathering].points.yields;
    imgui.PushStyleColor(ImGuiCol_Text, 1, 1, 0.54, settings.window.opacity);
    imgui.PlotHistogram("", plotYields, #plotYields, 0, "yields/hr", FLT_MIN, FLT_MAX, width-paddingX*2, 30);
    imgui.PopStyleColor()
    if imgui.IsItemHovered() then
        imgui.BeginTooltip();
        imgui.SetTooltip(string.format("%0.2f", metrics[state.gathering].points.yields[#metrics[state.gathering].points.yields] or 0));
        imgui.EndTooltip();
    end

    local plotValue = metrics[state.gathering].points.value;
    imgui.PushStyleColor(ImGuiCol_Text, 1, 1, 0.54, settings.window.opacity);
    imgui.PlotLines("", plotValue, #plotValue, 0, "value/hr", FLT_MIN, FLT_MAX, width-paddingX*2, 30);
    imgui.PopStyleColor()
    if imgui.IsItemHovered() then
        imgui.BeginTooltip();
        imgui.SetTooltip(string.format("%0.2f", metrics[state.gathering].points.value[#metrics[state.gathering].points.value] or 0));
        imgui.EndTooltip();
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
    imgui.SetNextWindowSize(width*2, height-60, ImGuiSetCond_Once);
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

        height = height-140
        if state.settings.general.active then
            imgui.BeginChild("General", -1, height, state.active)

            if (imgui.SliderFloat('Window Opacity', uiVariables['var_WindowOpacity'][1], 0.25, 1.0, "%1.2f")) then
                settings.window.opacity = imgui.GetVarValue(uiVariables['var_WindowOpacity'][1])
            end
            if imgui.IsItemHovered() then
                imgui.BeginTooltip();
                imgui.SetTooltip(strings.tooltips.settings.general.windowOpacity);
                imgui.EndTooltip();
            end
            imgui.Spacing()
            if (imgui.InputInt("Target Value", uiVariables['var_TargetValue'][1])) then
                settings.targetValue = imgui.GetVarValue(uiVariables['var_TargetValue'][1]);
            end
            if imgui.IsItemHovered() then
                imgui.BeginTooltip();
                imgui.SetTooltip(strings.tooltips.settings.general.targetValue);
                imgui.EndTooltip();
            end

            imgui.EndChild()
        elseif state.settings.setPrices.active then
            local currentPrices = state.settings.setPrices.gathering
            local title = ">>> "..string.upper(currentPrices).." PRICES <<<"
            local fontSize = (imgui.GetFontSize() * title:len()) / 2
            imgui.BeginChild("Set Prices", -1, height, state.active, ImGuiWindowFlags_MenuBar+ImGuiWindowFlags_NoResize)
            imgui.BeginMenuBar()
            for _, v in ipairs(gatherBtnsOrder) do
                if v.name == state.settings.setPrices.gathering then
                    imgui.PushStyleColor(ImGuiCol_Button, 0.21, 0.47, 0.59, 1);
                    if imgui.SmallButton(v.short) then state.settings.setPrices.gathering = v.name end
                    imgui.PopStyleColor();
                else
                    if imgui.SmallButton(v.short) then state.settings.setPrices.gathering = v.name end
                end
                imgui.SameLine(0.0, spacing);
            end
            imgui.EndMenuBar()

            imgui.Spacing()
            imgui.Separator()

            imgui.BeginChild("Header", -1, 15)
            imgui.SetCursorPosX((imgui.GetWindowWidth()) / 2 - (fontSize / 2))

            imgui.PushStyleColor(ImGuiCol_Text, 1, 1, 0.54, settings.window.opacity)
            imgui.Text(title)
            imgui.PopStyleColor()

            imgui.EndChild()

            imgui.Separator();
            imgui.Spacing();

            imgui.BeginChild("Scrolling", -1, 300)
            for k, v in pairs(settings.prices[state.settings.setPrices.gathering]) do
                local var = string.format("var_%s_%s", state.settings.setPrices.gathering, string.clean(k))
                if (imgui.InputInt(k, uiVariables[var][1])) then
                    settings.prices[state.settings.setPrices.gathering][k] = imgui.GetVarValue(uiVariables[string.format("var_%s_%s", state.settings.setPrices.gathering, string.clean(k))][1]);
                end
                --if imgui.IsItemHovered() then
                --    imgui.BeginTooltip();
                 --   imgui.SetTooltip(string.format(strings.tooltips.settings.setPrices.yield, k));
                 --   imgui.EndTooltip();
                --end
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

    width = width*1.25;
    height = 75;
    spacing = 10;
    imgui.SetNextWindowSize(width, height, ImGuiSetCond_Always);
    if imgui.BeginPopupModal("Yield Confirm", state.active, ImGuiWindowFlags_NoResize) then
        imgui.Text(state.confirmPrompt);
        imgui.Separator();
        imgui.Spacing();
        if imgui.Button("Yes") or state.initializing then
            imgui.CloseCurrentPopup();
            state.confirmAction();
        end
        imgui.SameLine(0.0, spacing);
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
    if id == packets.outbound.trade.id then
         if AshitaCore:GetDataManager():GetTarget():GetTargetName() == "Mining Point" then state.attempting = true; end
    end
    return false;
end);