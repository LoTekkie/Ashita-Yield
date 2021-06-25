--[[
Copyright © 2021, Sjshovan (LoTekkie)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

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

require 'os'

----------------------------------------------------------------------------------------------------
-- Variables
----------------------------------------------------------------------------------------------------
local chatColors = {
    primary = "\31\200%s",
    secondary = "\31\207%s",
    info = "\31\1%s",
    warn = "\31\140%s",
    danger = "\31\167%s",
    success = "\31\158%s"
}

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function helpCommandEntry(command, description)
    local short_name = strColor("yld", chatColors.primary)
    local command = strColor(command, chatColors.secondary)
    local sep = strColor("=>", chatColors.primary)
    local description = strColor(description, chatColors.info)
    return string.format("%s %s %s %s", short_name, command, sep, description)
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function helpTypeEntry(name, description)
    local name = strColor(name, chatColors.secondary)
    local sep = strColor("=>", chatColors.primary)
    local description = strColor(description, chatColors.info)
    return string.format("%s %s %s", name, sep, description)
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function helpTitle(context)
    local context = strColor(context, chatColors.danger)
    return string.format("%s Help: %s", _addon.name, context)
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function helpSeparator(character, count)
    local sep = ''
    for i = 1, count do
        sep = sep .. character
    end
    return strColor(sep, chatColors.warn)
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function commandResponse(message, success)
    local responseColor = chatColors.success
    local responseType = 'Success'
    if not success then
        responseType = 'Error'
        responseColor = chatColors.danger
    end
    return string.format("%s: %s", 
        strColor(responseType, responseColor), strColor(message, chatColors.info)
    )
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function displayResponse(response, color)
    color = color or chatColors.info
    print(strColor(response, color))
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
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
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function table.sortKeysByLength(t, desc)
    local ret = {}
    for k, v in pairs(t) do
        table.insert(ret, k)
    end
    if (desc) then
        table.sort(ret, function(a, b) return a:len() < b:len() end);
    else
        table.sort(ret, function(a, b) return a:len() > b:len() end);
    end
    return ret;
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function string.camelToTitle(s)
    return string.gsub(string.upperfirst(s), "([A-Z][a-z]?)", " %1"):sub(2);
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function string.lowerToTitle(s)
    return string.gsub(" "..s, "%W%l", string.upper):sub(2);
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function strColor(str, color) 
    return string.format(color, str)
end

----------------------------------------------------------------------------------------------------
-- func: showToolTip
-- desc: Shows a tooltip with imgui.
----------------------------------------------------------------------------------------------------
function imguiShowToolTip(text, enabled)
    if enabled then
        imgui.TextDisabled('(?)');
        if (imgui.IsItemHovered()) then
            imgui.SetTooltip(text);
        end
    end
    return enabled
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function imguiFullSep()
    imgui.Spacing();
    imgui.Separator();
    imgui.Spacing();
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function imguiHalfSep(flip)
    if not flip then
        imgui.Spacing();
        imgui.Separator();
    else
        imgui.Separator();
        imgui.Spacing();
    end
end

----------------------------------------------------------------------------------------------------
-- func:
-- desc: .
----------------------------------------------------------------------------------------------------
function cycleIndex(index, min, max)
    local newIndex = index + 1;
    if newIndex > max then
        newIndex = min
    end
    return newIndex;
end
