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
    initializing = true,
    attempting   = false,
    attemptType  = "harvesting",
    gathering    = "harvesting",
    settings =
    {
        activeIndex = 1,
        setPrices   = { gathering = "harvesting" },
        alerts      = { gathering = "harvesting" }
    },
    timers = {},
    values =
    {
        btnStartTimer      = "Start",
        modalConfirmPrompt = "Are you sure?",
        modalConfirmHelp   = "",
        modalConfirmDanger = false,
        yieldsLabelIndex   = 1, -- Full
        valuesLabelIndex   = 1, -- Full
        yieldSortIndex     = 3  -- Count (DESC)
    },
    actions =
    {
        modalConfirmAction = function() end,
    }
}

-- Template for Yield settings.
defaultSettingsTemplate =
{
    general =
    {
        opacity         = 0.62,
        targetValue     = 0,
        showToolTips    = true
    },
    state =
    {
        gathering  = "harvesting"
    },
    prices =
    {
        harvesting = {},
        excavating = {},
        logging = {},
        mining =
        {
            ["Copper Ore"]       = 0,
            ["Zinc Ore"]         = 0,
            ["Tin Ore"]          = 0,
            ["Iron Ore"]         = 0,
            ["Silver Ore"]       = 0,
            ["Darksteel Ore"]    = 0,
            ["Gold Ore"]         = 0,
            ["Mythril Ore"]      = 0,
            ["Platium Ore"]      = 0,
            ["Aluminum Ore"]     = 0,
            ["Elemental Ore"]    = 0,
            ["Adaman Ore"]       = 0,
            ["Khroma Ore"]       = 0,
            ["Luminium Ore"]     = 0,
            ["Orichalcum Ore"]   = 0,
            ["Pebble"]           = 0,
            ["Flint Stone"]      = 0,
            ["Igneous Rock"]     = 0,
            ["Colored Rock"]     = 0,
            ["Sulfur"]           = 0,
            ["Pinch of Sulfur"]  = 0,
            ["Iron Sand"]        = 0,
            ["Bomb Ash"]         = 0,
            ["Goblin Die"]       = 0,
            ["Demon Horn"]       = 0,
            ["Aht Urhgan Brass"] = 0,
            ["Orpiment"]         = 0,
            ["Snapping Mole"]    = 0,
            ["Troll Pauldron"]   = 0,
            ["Troll Vambrace"]   = 0,
            ["Moblin Mask"]      = 0,
            ["Moblin Helm"]      = 0,
            ["Moblin Mail"]      = 0,
            ["Moblin Armor"]     = 0,
            ["Unknown"]          = 0,
        },
        clamming = {},
        fishing = {},
        digging = {}
    },
    metrics = {}
}

return {
    defaultSettingsTemplate = defaultSettingsTemplate,
    stateTemplate = stateTemplate,
    metricsTemplate = metricsTemplate
}