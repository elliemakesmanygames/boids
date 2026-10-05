--[[
    Spatial hashing using Morton encoding.
    Made specifically for a design where a node cannot be bigger than a cell size.
    This is a 2D implementation, but it can be expanded into 3D.
]]

--!strict
--!optimize 2
const Settings = require("./Settings")
const Grid = {} :: Settings.grid

const function round(p: Vector2): Vector2
    -- Make this world-space system instead of cell-space system if needed.
    --[[
    return Vector2.new(
        p.X // Settings.cell_size.X * Settings.cell_size.X,
        p.Y // Settings.cell_size.Y * Settings.cell_size.Y,
    )
    ]]                
    return Vector2.new(
        p.X // Settings.cell_size.X,
        p.Y // Settings.cell_size.Y
    )
end

-- Expects rounded vector2
const function morton(p: Vector2): number
    local n = 0

    for i = 0, 15 do
        const xbit, ybit = bit32.extract(p.X, i), bit32.extract(p.Y, i)
        n = bit32.bor(n, bit32.lshift(xbit, i*2), bit32.lshift(ybit, i*2+1))
    end
    
    return n
end

const function add(p: Vector2, id: number): ()
    if p.X < Settings.cell_size.X and p.Y < Settings.cell_size.Y then return end

    const rounded = round(p)
    const code = morton(rounded)
    Grid[code] = { id = id, p = p }
end

const function remove(p: Vector2, id: number): ()
    const code = morton(round(p))
    const cell = Grid[code]
    for i, boid in cell do 
        if boid.id == id then 
            cell[i] = nil 
        end
    end
end

const function get(p: Vector2): ({ Settings.cell })?
    const code = morton(round(p))
    return Grid[code]
end

return {
    morton = morton,
    add = add,
    remove = remove,
    get = get,
}