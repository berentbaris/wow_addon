local _, SM = ...

function SM.AcquirePooledFrame(pool, index, factory, reset)
    if not pool or not index or not factory then return nil end

    local frame = pool[index]
    if not frame then
        frame = factory(index)
        pool[index] = frame
    end

    if reset then reset(frame, index) end
    return frame
end
