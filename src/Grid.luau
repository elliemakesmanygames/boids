--!strict
--!optimize 2
--[[
    Spatial hashing using Morton encoding.
    Made specifically for a design where a node cannot be bigger than a cell size.
    This is a 2D implementation, but it can be expanded into 3D.
    All inputted positions must equate to the center of said shape.
    Limitations of 65,535 by 65,535 stud grid. (each coordinate is a u16)
]]

const Settings = require("./Settings")
const Grid = {} :: Settings.grid
const CellSize = Settings.cell_size
const MaxBoidsPerCell = Settings.max_boids_per_cell

const function round(p: vector): vector
	return vector.create(p.x // CellSize.x, p.y // CellSize.y)
end

const function morton(p: vector): number
	local x = bit32.band(p.X, 0xFFFF)
	local y = bit32.band(p.Y, 0xFFFF)

	x = bit32.band(bit32.bor(x, bit32.lshift(x, 8)), 0x00FF00FF)
	x = bit32.band(bit32.bor(x, bit32.lshift(x, 4)), 0x0F0F0F0F)
	x = bit32.band(bit32.bor(x, bit32.lshift(x, 2)), 0x33333333)
	x = bit32.band(bit32.bor(x, bit32.lshift(x, 1)), 0x55555555)
	y = bit32.band(bit32.bor(y, bit32.lshift(y, 8)), 0x00FF00FF)
	y = bit32.band(bit32.bor(y, bit32.lshift(y, 4)), 0x0F0F0F0F)
	y = bit32.band(bit32.bor(y, bit32.lshift(y, 2)), 0x33333333)
	y = bit32.band(bit32.bor(y, bit32.lshift(y, 1)), 0x55555555)

	return bit32.bor(x, bit32.lshift(y, 1)) + 1
end

const function fetch(p: vector): number
	return morton(round(p))
end

const function get(p: vector): { Settings.grid_boid }?
	const code = fetch(p)
	return Grid[code]
end

const function add(id: number, p: vector, v: vector): ()
	const b = buffer.create(12)
	const code = fetch(p)

	buffer.writeu16(b, 0, id)
	buffer.writef32(b, 2, p.x)
	buffer.writef32(b, 6, p.y)
	buffer.writef32(b, 10, v.x)
	buffer.writef32(b, 14, v.y)

	Grid[code] = Grid[code] or {}
	table.insert(Grid[code], b)
end

const function remove(id: number, p: vector): ()
	const code = fetch(p)
	const cell = Grid[code]
	if not cell then return end

	const s = #cell
	for i = 1, s do
		const b = buffer.readu16(cell[i], 0)
		if b ~= id then continue end

		cell[i] = cell[s]
		cell[s] = nil
	end
end

return {
	add = add,
	get = get,
	remove = remove,
}
