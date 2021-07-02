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

-- Template for Yield metrics.
metricsTemplate =
{
    totals =
    {
        lost     = 0,
        yields   = 0,
        breaks   = 0,
        attempts = 0
    },
    secondsPassed  = 0,
    estimatedValue = 0,
    yields         = {},
    points =
    {
        yields = {0},
        values  = {0}
    }
}

-- Template for Yield state.
stateTemplate =
{
    window       = {},
    initializing = true,
    attempting   = false,
    attemptType  = "harvesting",
    gathering    = "harvesting",
    settings =
    {
        activeIndex = 1,
        setPrices   = { gathering = "harvesting" },
        setColors   = { gathering = "harvesting" },
        setAlerts   = { gathering = "harvesting" },
        alerts      = { gathering = "harvesting" }
    },
    timers = {},
    values =
    {
        btnStartTimer        = "Start",
        modalConfirmPrompt   = "Are you sure?",
        modalConfirmHelp     = "",
        modalConfirmDanger   = false,
        yieldsLabelIndex     = 1, -- Full
        valuesLabelIndex     = 1, -- Full
        yieldSortIndex       = 3, -- Count (DESC)
        yieldListBtnsHovered = false,
        yieldListHovered     = false,
        yieldListClicked     = false,
        inactivitySeconds    = 0,
        btnTextureFailure    = false,
        targetAlertReady     = false,
    },
    actions =
    {
        modalConfirmAction = function() end,
        modalCancelAction  = function() end
    }
}

-- Template for Yield settings.
defaultSettingsTemplate =
{
    general =
    {
        opacity             = 1.0,
        targetValue         = 0,
        showToolTips        = true,
        windowScaleIndex    = 0,
        showDetailedYields  = true,
        yieldDetailsColor   = -3877684,
        useImageButtons     = true,
        enableSoundAlerts   = true,
        targetSoundFile     = "",
    },
    state =
    {
        gathering  = "harvesting"
    },
    priceModes = -- 0 - stack price, 1 - single price, 2 - npc price.
    {
        harvesting = 0,
        excavating = 0,
        logging    = 0,
        mining     = 0,
        clamming   = 0,
        fishing    = 0,
        digging    = 0
    },
    yields =
    {
        harvesting = 
        {
            ["Mohbwa Grass"]           = { id = 2295, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Fresh Marjoram"]         = { id = 1522, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Pephredo Hive Chip"]     = { id = 2164, short = "Pep. Hive Chip", singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Simsim"]                 = { id = 2236, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Imperial Tea Leaves"]    = { id = 2156, short = "Imp. Tea Leaves", singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Coffee Cherries"]        = { id = 2270, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Eggplant"]               = { id = 4388, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Red Moko Grass"]         = { id = 1845, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Fresh Mugwort"]          = { id = 1524, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Wijnruit"]               = { id = 951,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Eastern Ginger"]         = { id = 2645, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Moko Grass"]             = { id = 833,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Saruta Cotton"]          = { id = 834,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Flax Flower"]            = { id = 835,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Dyer's Woad"]            = { id = 2713, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Gysahl Greens"]          = { id = 4545, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 99, color = -3877684, soundFile = "" },
            ["Windurstian Tea Leaves"] = { id = 635,   short = "Win. Tea Leaves", singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Skull Locust"]           = { id = 1981, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Vegetable Seeds"]        = { id = 573,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Herb Seeds"]             = { id = 572,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Grain Seeds"]            = { id = 575,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Crawler Cocoon"]         = { id = 839,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["King Locust"]            = { id = 1982, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Burdock"]                = { id = 5651, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Lesser Chigoe"]          = { id = 2155, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Winterflower"]           = { id = 5907, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Woozyshroom"]            = { id = 4373, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Danceshroom"]            = { id = 4375, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Sleepshroom"]            = { id = 4374, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Scream Fungus"]          = { id = 4447, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Coral Fungus"]           = { id = 4450, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Reishi Mushroom"]        = { id = 4449, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Mushroom Locust"]        = { id = 1983, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Grauberg Greens"]        = { id = 5444, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Puffball"]               = { id = 4448, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["King Truffle"]           = { id = 4386, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
        },
        excavating =
        {
            ["Bone Chip"]                   = { id = 880,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Chicken Bone"]                = { id = 898,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Giant Femur"]                 = { id = 893,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Little Worm"]                 = { id = 17396, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Bat Fang"]                    = { id = 891,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Scorpion Claw"]               = { id = 897,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Scorpion Shell"]              = { id = 896,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Turtle Shell"]                = { id = 885,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Silica"]                      = { id = 1888,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Red Rock"]                    = { id = 769,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Yellow Rock"]                 = { id = 771,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Blue Rock"]                   = { id = 770,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Green Rock"]                  = { id = 772,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Translucent Rock"]            = { id = 773,   short = "Trans. Rock", singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Purple Rock"]                 = { id = 774,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["White Rock"]                  = { id = 776,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Black Rock"]                  = { id = 775,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Rock Salt"]                   = { id = 936,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Seashell"]                    = { id = 888,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Shell Bug"]                   = { id = 17397, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Fish Scales"]                 = { id = 864,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Lugworm"]                     = { id = 17395, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Crab Shell"]                  = { id = 881,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Helmet Mole"]                 = { id = 1985,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Coral Fragment"]              = { id = 887,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Petrified Log"]               = { id = 703,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Antlion Jaw"]                 = { id = 2503,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Cactus Stems"]                = { id = 1236,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Almonds"]                     = { id = 2503,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["High-Quality Scorpion Shell"] = { id = 1473,  short = "HQ Scorpion Shell", singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },

        },
        logging =
        {
            ["Lauan Log"]         = { id = 689,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Arrowwood Log"]     = { id = 688,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Yagudo Cherry"]     = { id = 4445, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Buburimu Grape"]    = { id = 4503, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Dryad Root"]        = { id = 923,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Fruit Seeds"]       = { id = 574,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Holly Log"]         = { id = 697,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Ebony Log"]         = { id = 702,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Mahogany Log"]      = { id = 700,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Rosewood Log"]      = { id = 701,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Ash Log"]           = { id = 698,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Maple Log"]         = { id = 691,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Willow Log"]        = { id = 695,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Elm Log"]           = { id = 690,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Acorn"]             = { id = 4504, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Walnut Log"]        = { id = 693,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Oak Log"]           = { id = 699,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Yew Log"]           = { id = 696,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Faerie Apple"]      = { id = 4363, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Pine Nuts"]         = { id = 2213, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Almonds"]           = { id = 2503, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Date"]              = { id = 5566, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Chestnut Log"]      = { id = 694,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Bloodwood Log"]     = { id = 729,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Walnut"]            = { id = 5661, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Ronfaure Chestnut"] = { id = 639,  short = "Ron. Chestnut", singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Jacaranda Log"]     = { id = 2534, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Teak Log"]          = { id = 2532, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Rattan Lumber"]     = { id = 721,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Revival Root"]      = { id = 940,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Aquilaria Log"]     = { id = 731,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Beehive Chip"]      = { id = 912,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Tree Cuttings"]     = { id = 1237, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Dragon Fruit"]      = { id = 5662, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Holy Water"]        = { id = 4154, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Nopales"]           = { id = 5650, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Bird Feather"]      = { id = 847,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Bird Egg"]          = { id = 4570, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Cactus Stems"]      = { id = 1236, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Butterpear"]        = { id = 5908, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Kapor Log"]         = { id = 732,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
        },
        mining =
        {
            ["Copper Ore"]       = { id = 640,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Zinc Ore"]         = { id = 642,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Tin Ore"]          = { id = 641,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Iron Ore"]         = { id = 643,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Silver Ore"]       = { id = 736,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Darksteel Ore"]    = { id = 645,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Gold Ore"]         = { id = 737,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Mythril Ore"]      = { id = 644,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Platium Ore"]      = { id = 738,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Aluminum Ore"]     = { id = 678,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Adaman Ore"]       = { id = 646,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Khroma Ore"]       = { id = 685,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Luminium Ore"]     = { id = 2228,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Orichalcum Ore"]   = { id = 739,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Pebble"]           = { id = 17296, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 99, color = -3877684, soundFile = "" },
            ["Flint Stone"]      = { id = 768,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Igneous Rock"]     = { id = 1654,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Red Rock"]         = { id = 769,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Yellow Rock"]      = { id = 771,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Blue Rock"]        = { id = 770,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Green Rock"]       = { id = 772,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Translucent Rock"] = { id = 773,   short = "Trans. Rock", singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Purple Rock"]      = { id = 774,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["White Rock"]       = { id = 776,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Black Rock"]       = { id = 775,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Sulfur"]           = { id = 1108,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Iron Sand"]        = { id = 1155,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Bomb Ash"]         = { id = 928,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Goblin Die"]       = { id = 568,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Demon Horn"]       = { id = 902,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Aht Urhgan Brass"] = { id = 2417,  short = "Aht Urh. Brass", singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Orpiment"]         = { id = 2126,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Snapping Mole"]    = { id = 1984,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Troll Pauldron"]   = { id = 2160,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Troll Vambrace"]   = { id = 2161,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Moblin Mask"]      = { id = 1638,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Moblin Helm"]      = { id = 1625,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Moblin Mail"]      = { id = 1632,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Moblin Armor"]     = { id = 1631,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Plumbago"]         = { id = 2860,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Mine Gravel"]      = { id = 597,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 1, color = -3877684, soundFile = "" },
        },
        clamming =
        {
            ["Oxblood"]                  = { id = 1311,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Turtle Shell"]             = { id = 885,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["HQ Crab Shell"]            = { id = 1193,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Lacquer Tree Log"]         = { id = 1446,  short = "Lacq. Tree Log", singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Bibiki Urchin"]            = { id = 4318,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Titanictus Shell"]         = { id = 1586,  short = "Titan. Shell", singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Tropical Clam"]            = { id = 5124,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Elm Log"]                  = { id = 690,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Coral Fragment"]           = { id = 887,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Petrified Log"]            = { id = 703,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Maple Log"]                = { id = 691,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Pamamas"]                  = { id = 4468,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["High-Quality Pugil Scale"] = { id = 3270,  short = "HQ Pugil Scale", singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Seashell"]                 = { id = 888,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Hobgoblin Bread"]          = { id = 4328,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Broken Willow Rod"]        = { id = 485,   short = "Bkn. Willow Rod", singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Goblin Armor"]             = { id = 510,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Elshimo Coconut"]          = { id = 5187,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Goblin Mail"]              = { id = 507,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Crab Shell"]               = { id = 881,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Hobgoblin Pie"]            = { id = 4325,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Rock Salt"]                = { id = 936,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Nebimonite"]               = { id = 4361,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Fish Scales"]              = { id = 864,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Shall Shell"]              = { id = 4484,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Pamtam Kelp"]              = { id = 624,   short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Igneous Rock"]             = { id = 1654,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Pebble"]                   = { id = 17296, short = nil, singlePrice = 0, stackPrice = 0, stackSize = 99, color = -3877684, soundFile = "" },
            ["Jacknife"]                 = { id = 5123,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Bibiki Slug"]              = { id = 5122,  short = nil, singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
        },
        fishing =
        {

        },
        digging =
        {

        }
    },
    metrics = {}
}

return {
    defaultSettingsTemplate = defaultSettingsTemplate,
    stateTemplate = stateTemplate,
    metricsTemplate = metricsTemplate
}