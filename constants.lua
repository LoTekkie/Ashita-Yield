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

require 'common'

packets = {
    inbound = {
        music_change = {
            id = 0x05F,
            offsets = {
                type = 0x06
            }
        },
        zone_update = {
            id = 0x00A
        }
    },
    outbound = {
        action = {
            id = 0x1A,
            categories = {
                mount = 0x1A,
                unmount = 0x12
            }
        },
        trade = {
            id = 0x36,
            categories = {
                finished = 0x5B --TODO: find out what this is
            }
        }
    },
}

strings = {
    gathering = {
        mining = {name = "mining", short = "Min.", patterns = {
            success = "^You successfully dig up a (.*)!",
            successBreak = "You dig up a (.*), but your pickaxe breaks in the process.",
            chunk = "chunk of (.*)",
            unable = "You are unable to mine anything.",
            broken = "Your (.*) breaks!",
            full = "You cannot carry any more items."
        }},
        harvesting = {name = "harvesting", short = "Har.", patterns = {
        }},
        logging = {name = "logging", short = "Log.", patterns = {
        }},
        excavating = {name = "excavating", short = "Exc.", patterns = {
        }},
        clamming = {name = "clamming", short = "Cla.", patterns = {
        }}
    },
    tooltips = {
        totals = {
            lost = "Total number of items lost.",
            attempts = "Total attempts at gathering.",
            yields = "Total successful gathers.",
            breaks = "Total number of broken tools.",
        },
        secondsPassed = "Total time passed since your first %s attempt.",
        estimatedValue = "Estimated value of all yields.",
        progress = "Progress towards target value (%s/%s).",
        yields = "List of running totals for all current yields.",
        settings = {
            general = {
                windowOpacity = "Current alpha channel value of all Yield windows.",
                targetValue = "Amount you would like to earn this session."
            },
            setPrices = {
                yield = "Set the estimated value for a single %s."
            }
        }
    }
}

colors = {
    primary = "\31\200%s",
    secondary = "\31\207%s",
    info = "\31\1%s",
    warn = "\31\140%s",
    danger = "\31\167%s",
    success = "\31\158%s"
}

return {
    packets = packets,
    colors = colors,
    strings = strings
}