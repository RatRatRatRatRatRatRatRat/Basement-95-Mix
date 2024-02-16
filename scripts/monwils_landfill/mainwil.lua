local path = "scripts.monwils_landfill."

DynamicCallbacks = include(path .. "dynamic_callbacks")(Basement95MIX)

for directory, files in pairs({
    passive = {
        "scroll_of_power",
        "glitched_miner",
        "less_than_slash_three",
    },
    trinket = {
        "reroll_trinket",
    },
    active = {
        "red_roulette",
        "fast_forward",
        "black_eyed_pea",
    },
})do
    for _, file in ipairs(files) do
        include(path .. directory .. "." .. file)
    end
end

DynamicCallbacks = nil