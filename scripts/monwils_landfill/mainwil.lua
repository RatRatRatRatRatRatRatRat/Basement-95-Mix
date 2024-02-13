local path = "scripts.monwils_landfill."

DynamicCallbacks = include(path .. "dynamic_callbacks")(Basement95MIX)

for directory, files in pairs({
    passive = {
        "scroll_of_power",
    },
    trinket = {
        "reroll_trinket",
    },
    active = {
        "red_roulette",
    },
})do
    for _, file in ipairs(files) do
        include(path .. directory .. "." .. file)
    end
end

DynamicCallbacks = nil