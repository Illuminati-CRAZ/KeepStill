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
    local INCREMENT = state.GetValue("INCREMENT") or 2^-6 --powers of 2 are your friend, small number also bad, but small number funny and make playfield go teleport, numbers smaller than this may cause rounding errors
    local INT_SV = state.GetValue("INT_SV") or 0

    _, AVG_SV = imgui.InputFloat("Average SV", AVG_SV, .05)
    _, INCREMENT = imgui.InputFloat("Teleport Duration", INCREMENT, 2^-6)
    _, INT_SV = imgui.InputFloat("Intermediate SV", INT_SV, .05)

    if INCREMENT <= 0 then
        INCREMENT = 2^-6
    end

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

        for i, starttime in pairs(starttimes) do
            --this is terrible
            if i == 1 then
                table.insert(svs, utils.CreateScrollVelocity(starttime, INT_SV))
            elseif i == #starttimes then
                table.insert(svs, utils.CreateScrollVelocity(starttime - INCREMENT, (starttimes[i] - starttimes[1]) / INCREMENT * (AVG_SV - INT_SV)))
                table.insert(svs, utils.CreateScrollVelocity(starttime, AVG_SV))
            else
                local num_increments
                if i == 2 then
                    num_increments = 1
                else
                    num_increments = 2
                end
                table.insert(svs, utils.CreateScrollVelocity(starttime - INCREMENT, (starttimes[i] - starttimes[1]) / INCREMENT * (AVG_SV - INT_SV * (starttimes[i] - starttimes[i-1] - num_increments * INCREMENT) / (starttimes[i] - starttimes[i-1]))))
                table.insert(svs, utils.CreateScrollVelocity(starttime, (starttimes[i] - starttimes[1]) / INCREMENT * (AVG_SV - INT_SV * (starttimes[i] - starttimes[i-1] - num_increments * INCREMENT) / (starttimes[i] - starttimes[i-1])) * -1))
                table.insert(svs, utils.CreateScrollVelocity(starttime + INCREMENT, INT_SV))
            end
        end

        actions.PlaceScrollVelocityBatch(svs)
    end

    state.SetValue("AVG_SV", AVG_SV)
    state.SetValue("INCREMENT", INCREMENT)
    state.SetValue("INT_SV", INT_SV)

    imgui.End()
end
