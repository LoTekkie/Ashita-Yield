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
        setPrices   = { gathering = "harvesting", priceModeChanged = false, priceEntryChanged = false },
        setColors   = { gathering = "harvesting" },
        setAlerts   = { gathering = "harvesting" },
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
        yieldSortIndex     = 3, -- Count (DESC)
        windowScaleIndex   = 1, -- Default
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
    },
    state =
    {
        gathering  = "harvesting"
    },
    priceModes = -- stack price by default (true).
    {
        harvesting = true,
        excavating = true,
        logging    = true,
        mining     = true,
        clamming   = true,
        fishing    = true,
        digging    = true
    },
    yields =
    {
        harvesting = {},
        excavating = {},
        logging = {},
        mining =
        {
            ["Copper Ore"]       = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Zinc Ore"]         = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Tin Ore"]          = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Iron Ore"]         = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Silver Ore"]       = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Darksteel Ore"]    = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Gold Ore"]         = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Mythril Ore"]      = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Platium Ore"]      = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Aluminum Ore"]     = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Elemental Ore"]    = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Adaman Ore"]       = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Khroma Ore"]       = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Luminium Ore"]     = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Orichalcum Ore"]   = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Pebble"]           = { price = 0, stackSize = 99, color = -3877684, soundFile = "" },
            ["Flint Stone"]      = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Igneous Rock"]     = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Red Rock"]         = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Yellow Rock"]      = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Blue Rock"]        = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Green Rock"]       = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Translucent Rock"] = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Purple Rock"]      = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["White Rock"]       = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Black Rock"]       = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Pinch of Sulfur"]  = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Iron Sand"]        = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Bomb Ash"]         = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Goblin Die"]       = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Demon Horn"]       = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Aht Urhgan Brass"] = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Orpiment"]         = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Snapping Mole"]    = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Troll Pauldron"]   = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Troll Vambrace"]   = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Moblin Mask"]      = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Moblin Helm"]      = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Moblin Mail"]      = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Moblin Armor"]     = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Slab of Plumbago"] = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Mine Gravel"]      = { price = 0, stackSize = 12, color = -3877684, soundFile = "" },
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