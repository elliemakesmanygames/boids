--!strict
--!optimize 2
--[[
    Spatial hashing using Morton encoding.
    Made specifically for a design where a node cannot be bigger than a cell size.
    This is a 2D implementation, but it can be expanded into 3D.
    All inputted positions must equate to the center of said shape.
]]

--const AssetService = game:GetService("AssetService")

const Settings = require("./Settings")
const Grid = {} :: Settings.grid

const CellSize = Settings.cell_size
const MaxGridSize = Settings.max_grid_size

const function round(p: Vector2): Vector2
    return Vector2.new(
        p.X // CellSize.X,
        p.Y // CellSize.Y
    )
end

const function rotated(p: Vector2, theta: number): Vector2
    return Vector2.new(
        p.X * math.cos(theta) - p.Y * math.sin(theta),
        p.X * math.sin(theta) + p.Y * math.cos(theta) 
    )
end

const function morton(p: Vector2): number
    local n = 0
    
    for i = 0, 15 do
        const xbit, ybit = bit32.extract(p.X, i), bit32.extract(p.Y, i)
        n = bit32.bor(n, bit32.lshift(xbit, i*2), bit32.lshift(ybit, i*2+1))
    end

    return n
end

const function get(p: Vector2): { Settings.boid }?
    const code = morton(round(p))
    return Grid[code]
end

const function add(id: number, p: Vector2, r: number): ()
    const b = buffer.create(12)
    const rounded = round(rotated(p,r))
    const code = morton(rounded)

    buffer.writeu16(b, 0, id)
    buffer.writeu16(b, 2, r)
    buffer.writef32(b, 4, p.X)
    buffer.writef32(b, 8, p.Y)

    Grid[code] = Grid[code] or {}
    table.insert(Grid[code], b)
end

const function remove(id: number, p: Vector2, r: number): ()
    const rounded = round(rotated(p,r))
    const code = morton(rounded)
    const cell = Grid[code]
    
    for i, v in cell do 
        const b = buffer.readu16(v, 0)
        if b==id then cell[i] = nil end
    end
end

return {
    add = add,
    get = get,
    remove = remove,
}