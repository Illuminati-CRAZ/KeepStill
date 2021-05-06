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

    local AVG_SV = state.GetValue("AVG_SV") or 1 --What SV to normalize to
    local INCREMENT = state.GetValue("INCREMENT") or 2^-6 --powers of 2 are your friend, small number also bad, but small number funny and make playfield go teleport, numbers smaller than this may cause rounding errors
    local INT_SV = state.GetValue("INT_SV") or 0 --all selected objects will still move with this speed
    local reverse = state.GetValue("reverse") or false --sets option to reverse the order of the note. visually will be upside down and has to be read from above to bottom.

    _, AVG_SV = imgui.InputFloat("Average SV", AVG_SV, .05)
    _, INCREMENT = imgui.InputFloat("Teleport Duration", INCREMENT, 2^-6)
    _, INT_SV = imgui.InputFloat("Intermediate SV", INT_SV, .05)
    _, reverse = imgui.Checkbox("reverse order", reverse)

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

        if reverse then
            --processes in reverse order
            table.insert(svs, utils.CreateScrollVelocity(starttimes[1] - INCREMENT, (starttimes[#starttimes] - starttimes[1]) / INCREMENT * (AVG_SV - INT_SV)))
            table.insert(svs, utils.CreateScrollVelocity(starttimes[1], INT_SV))
            for i=2,#starttimes-1,1 do
                 --moving calculation to one variable so it will only excecuted once and used twice. Intrepeters might already ahead of this so efficiency might not be significant.
                local num_sv = (starttimes[#starttimes-i+1] - starttimes[1]) / INCREMENT * (AVG_SV - INT_SV)
                table.insert(svs, utils.CreateScrollVelocity(starttimes[i] - INCREMENT, num_sv))
                table.insert(svs, utils.CreateScrollVelocity(starttimes[i], -1 * num_sv))
                table.insert(svs, utils.CreateScrollVelocity(starttimes[i] + INCREMENT, INT_SV))
            end
            table.insert(svs, utils.CreateScrollVelocity(starttimes[#starttimes], (starttimes[#starttimes] - starttimes[1]) / INCREMENT * (AVG_SV - INT_SV)))
            table.insert(svs, utils.CreateScrollVelocity(starttimes[#starttimes] + INCREMENT, AVG_SV))
        else
            --processes in normal order
            table.insert(svs, utils.CreateScrollVelocity(starttimes[1], INT_SV))
            for i=2,#starttimes-1,1 do
                local num_sv = (starttimes[i] - starttimes[1]) / INCREMENT * (AVG_SV - INT_SV)
                table.insert(svs, utils.CreateScrollVelocity(starttimes[i] - INCREMENT, num_sv))
                table.insert(svs, utils.CreateScrollVelocity(starttimes[i], -1 * num_sv))
                table.insert(svs, utils.CreateScrollVelocity(starttimes[i] + INCREMENT, INT_SV))
            end
            table.insert(svs, utils.CreateScrollVelocity(starttimes[#starttimes] - INCREMENT, (starttimes[#starttimes] - starttimes[1]) / INCREMENT * (AVG_SV - INT_SV)))
            table.insert(svs, utils.CreateScrollVelocity(starttimes[#starttimes], AVG_SV))
        end
        
        -- old code --
        -- for i, starttime in pairs(starttimes) do
        --     --this is terrible
        --     if i == 1 then
        --         table.insert(svs, utils.CreateScrollVelocity(starttime, INT_SV))
        --     elseif i == #starttimes then
        --         table.insert(svs, utils.CreateScrollVelocity(starttime - INCREMENT, (starttimes[i] - starttimes[1]) / INCREMENT * (AVG_SV - INT_SV)))
        --         table.insert(svs, utils.CreateScrollVelocity(starttime, AVG_SV))
        --     else
        --         local num_increments
        --         if i == 2 then
        --             num_increments = 1
        --         else
        --             num_increments = 2
        --         end
        --         table.insert(svs, utils.CreateScrollVelocity(starttime - INCREMENT, (starttimes[i] - starttimes[1]) / INCREMENT * (AVG_SV - INT_SV * (starttimes[i] - starttimes[i-1] - num_increments * INCREMENT) / (starttimes[i] - starttimes[i-1]))))
        --         table.insert(svs, utils.CreateScrollVelocity(starttime, (starttimes[i] - starttimes[1]) / INCREMENT * (AVG_SV - INT_SV * (starttimes[i] - starttimes[i-1] - num_increments * INCREMENT) / (starttimes[i] - starttimes[i-1])) * -1))
        --         table.insert(svs, utils.CreateScrollVelocity(starttime + INCREMENT, INT_SV))
        --     end
        -- end
        actions.PlaceScrollVelocityBatch(svs)
    end

    state.SetValue("AVG_SV", AVG_SV)
    state.SetValue("INCREMENT", INCREMENT)
    state.SetValue("INT_SV", INT_SV)
    state.SetValue("reverse",reverse)

    imgui.End()
end
