--!strict
--!optimize 2
--[[
    Spatial hashing using Morton encoding.
    Made specifically for a design where a node cannot be bigger than a cell size.
    This is a 2D implementation, but it can be expanded into 3D.
]]

--const AssetService = game:GetService("AssetService")

const Settings = require("./Settings")
const Grid = {} :: Settings.grid
const CellSize = Settings.cell_size

--[[const EditableGrid = AssetService:CreateEditableImage({ Size = CellSize })
const FlushBuffer = buffer.create(4) -- rgba

const function draw(p: Vector2): ()
    
end]]

const function round(p: Vector2): Vector2  
    return Vector2.new(
        p.X // CellSize.X,
        p.Y // CellSize.Y
    )
end

const function rotated(p: Vector2, theta: number): Vector2
    return Vector2.new(
        p.X * math.cos(theta) + p.Y * math.sin(theta),
        p.X * math.sin(theta) - p.Y * math.cos(theta) 
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

const function overlap(p: Vector2): { Vector2 }
    const cells: { Vector2 } = {}
    const hs = Settings.boid_size / 2
    const min_cell = round(Vector2.new(p.X - hs.X, p.Y - hs.Y))
    const max_cell = round(Vector2.new(p.X + hs.X, p.Y + hs.Y))

    if min_cell == max_cell then return { min_cell } end
    for cx = min_cell.X, max_cell.X do
        for cy = min_cell.Y, max_cell.Y do
            table.insert(cells, Vector2.new(cx, cy))
        end
    end

    return cells
end

const function owner(p: Vector2, r: number, d: Vector2): Vector2
    const rp = rotated(p, r)
    const cells = overlap(rp)
    if #cells == 1 then return cells[1] end

    local sx, sy = 0, 0
    local count = 0

    for _, c in cells do
        const boids = get(c)

        if boids then
            for _, b in boids do
                sx = buffer.readf32(b, 2)
                sy = buffer.readf32(b, 6)
                count += 1
            end
        end
    end

    if count > 0 then return round(Vector2.new(sx / count, sy / count)) end

    local best_cell = cells[1]
    local best_dot = -math.huge

    for _, c in cells do
        const center = Vector2.new(c.X * CellSize.X, c.Y * CellSize.Y)
        const vectorized = (center - p).Unit
        const dot = vectorized:Dot(d.Unit)

        if dot > best_dot then
            best_dot = dot
            best_cell = c
        end
    end

    return best_cell
end

const function add(id: number, p: Vector2, r: number, d: Vector2): ()
    const b = buffer.create(12)
    const cell = owner(p, r, d)
    const code = morton(cell)

    buffer.writeu16(b, 0, id)
    buffer.writef32(b, 2, p.X)
    buffer.writef32(b, 6, p.Y)
    buffer.writeu16(b, 10, r)
    buffer.writef32(b, 12, d.X)
    buffer.writef32(b, 16, d.Y)

    Grid[code] = Grid[code] or {}
    table.insert(Grid[code], b)
end

const function remove(id: number, p: Vector2, r: number, d: Vector2): ()
    const code = morton(owner(p, r, d))
    const cell = Grid[code]
    
    for i, b in cell do 
        const bid = buffer.readu16(b, 0)
        if bid==id then cell[i] = nil end
    end
end

return {
    add = add,
    get = get,
    remove = remove,
    morton = morton,
}