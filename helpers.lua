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

local colors = require("constants").colors

DT = {
    lastTime = 0
}

function DT.time()
    local dt = 0
    if DT.lastTime == 0 then
        DT.lastTime = os.time()
    else
        local curTime = os.time()
        dt = curTime - DT.lastTime
        lastTime = curTime
    end
    return dt
end

function buildHelpCommandEntry(command, description)
    local short_name = strColor("yld", colors.primary)
    local command = strColor(command, colors.secondary)
    local sep = strColor("=>", colors.primary)
    local description = strColor(description, colors.info)
    
    return string.format("%s %s %s %s", short_name, command, sep, description)
end

function buildHelpTypeEntry(name, description)
    local name = strColor(name, colors.secondary)
    local sep = strColor("=>", colors.primary)
    local description = strColor(description, colors.info)
    
    return string.format("%s %s %s", name, sep, description)
end

function buildHelpTitle(context)
    local context = strColor(context, colors.danger)
    
    return string.format("%s Help: %s", _addon.name, context)
end

function buildHelpSeperator(character, count)
    local sep = ''
    
    for i = 1, count do
        sep = sep .. character
    end
    
    return strColor(sep, colors.warn)
end

function buildCommandResponse(message, success)
    local response_color = colors.success
    local response_type = 'Success'
    
    if not success then
        response_type = 'Error'
        response_color = colors.danger
    end
    
    return string.format("%s: %s", 
        strColor(response_type, response_color), strColor(message, colors.info)
    )
end

function displayResponse(response, color)
    color = color or colors.info
    print(strColor(response, color))
end

function strColor(str, color) 
    return string.format(color, str)
end

function ucFirst(str)
    return str:gsub("^%l", string.upper)
end

function tableContains(tab, val)
    for index, value in pairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end