local function not_has(table, val)
    for _, value in pairs(table) do
        if value == val then
            return false
        end
    end

    return true
end

function draw()
    imgui.Begin("Keep Still")

    state.IsWindowHovered = imgui.IsWindowHovered()

    --I'll implement some way to input numbers if/when I feel like it
    local AVG_SV = state.GetValue("AVG_SV") or 1 --What SV to normalize to
    local INCREMENT = 2^-6 --powers of 2 are your friend, small number also bad, but small number funny and make playfield go teleport, numbers smaller than this may cause rounding errors

    _, AVG_SV = imgui.InputFloat("Average SV", AVG_SV, .05)

    if imgui.Button("click me") then
        local notes = state.SelectedHitObjects --should check to see if there are enough objects selected but I don't care

        --maybe jank way of removing redundant notes idk
        local starttimes = {}

        for _,note in pairs(notes) do
            if not_has(starttimes, note.StartTime) then
                table.insert(starttimes, note.StartTime)
            end
        end

        local svs = {}

        for i,starttime in pairs(starttimes) do
            if i == 1 then
                table.insert(svs, utils.CreateScrollVelocity(starttime, 0))
            elseif i == #starttimes then
                table.insert(svs, utils.CreateScrollVelocity(starttime - INCREMENT, (starttimes[i] - starttimes[1]) / INCREMENT * AVG_SV))
                table.insert(svs, utils.CreateScrollVelocity(starttime, AVG_SV))
            else
                table.insert(svs, utils.CreateScrollVelocity(starttime - INCREMENT, (starttimes[i] - starttimes[1]) / INCREMENT * AVG_SV))
                table.insert(svs, utils.CreateScrollVelocity(starttime, (starttimes[i] - starttimes[1]) / INCREMENT * AVG_SV * -1))
                table.insert(svs, utils.CreateScrollVelocity(starttime + INCREMENT, 0))
            end
        end

        actions.PlaceScrollVelocityBatch(svs)
    end

    state.SetValue("AVG_SV", AVG_SV)

    imgui.End()
end
