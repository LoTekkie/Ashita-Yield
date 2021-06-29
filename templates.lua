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
        harvesting = 
        {
            ["Mohbwa Grass"]           = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Fresh Marjoram"]         = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Pephredo Hive Chip"]     = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Simsim"]                 = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Imperial Tea Leaves"]    = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Coffee Cherries"]        = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Eggplant"]               = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Red Moko Grass"]         = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Fresh Mugwort"]          = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Wijnruit"]               = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Eastern Ginger"]         = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Moko Grass"]             = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Saruta Cotton"]          = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Flax Flower"]            = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Dyer's Woad"]            = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Gysahl Greens"]          = { singlePrice = 0, stackPrice = 0, stackSize = 99, color = -3877684, soundFile = "" },
            ["Windurstian Tea Leaves"] = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Skull Locust"]           = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Vegetable Seeds"]        = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Herb Seeds"]             = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Grain Seeds"]            = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Crawler Cocoon"]         = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["King Locust"]            = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Burdock"]                = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Lesser Chigoe"]          = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Winterflower"]           = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Woozyshroom"]            = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Danceshroom"]            = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Sleepshroom"]            = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Scream Fungus"]          = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Coral Fungus"]           = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Reishi Mushroom"]        = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Mushroom Locust"]        = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Grauberg Greens"]        = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Puffball"]               = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["King Truffle"]           = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
        },
        excavating = {},
        logging =
        {
            ["Lauan Log"]         = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Arrowwood Log"]     = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Yagudo Cherry"]     = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Buburimu Grape"]    = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Dryad Root"]        = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Fruit Seeds"]       = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Holly Log"]         = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Ebony Log"]         = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Mahogany Log"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Rosewood Log"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Ash Log"]           = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Maple Log"]         = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Willow Log"]        = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Elm Log"]           = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Deadwood Log"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Acorn"]             = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Walnut Log"]        = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Oak Log"]           = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Yew Log"]           = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Faerie Apple"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Pine Nuts"]         = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Almond"]            = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Date"]              = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Chestnut Log"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Bloodwood Log"]     = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Walnut"]            = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Ronfaure Chestnut"] = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Jacaranda Log"]     = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Teak Log"]          = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Rattan Lumber"]     = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Revival Root"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Aquilaria Log"]     = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Beehive Chip"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Tree Cuttings"]     = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Dragon Fruit"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Holy Water"]        = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Nopales"]           = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Bird Feather"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Bird Egg"]          = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Cactus Stems"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Butterpear"]        = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Kapor Log"]         = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
        },
        mining =
        {
            ["Copper Ore"]       = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Zinc Ore"]         = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Tin Ore"]          = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Iron Ore"]         = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Silver Ore"]       = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Darksteel Ore"]    = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Gold Ore"]         = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Mythril Ore"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Platium Ore"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Aluminum Ore"]     = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Elemental Ore"]    = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Adaman Ore"]       = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Khroma Ore"]       = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Luminium Ore"]     = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Orichalcum Ore"]   = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Pebble"]           = { singlePrice = 0, stackPrice = 0, stackSize = 99, color = -3877684, soundFile = "" },
            ["Flint Stone"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Igneous Rock"]     = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Red Rock"]         = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Yellow Rock"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Blue Rock"]        = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Green Rock"]       = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Translucent Rock"] = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Purple Rock"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["White Rock"]       = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Black Rock"]       = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Pinch of Sulfur"]  = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Iron Sand"]        = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Bomb Ash"]         = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Goblin Die"]       = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Demon Horn"]       = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Aht Urhgan Brass"] = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Orpiment"]         = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Snapping Mole"]    = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Troll Pauldron"]   = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Troll Vambrace"]   = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Moblin Mask"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Moblin Helm"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Moblin Mail"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Moblin Armor"]     = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Slab of Plumbago"] = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
            ["Mine Gravel"]      = { singlePrice = 0, stackPrice = 0, stackSize = 12, color = -3877684, soundFile = "" },
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