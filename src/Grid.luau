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

const function round(p: vector): vector
	return vector.create(p.x // CellSize.x, p.y // CellSize.y)
end

const function rotate(p: vector, r: number): vector
	return vector.create(p.x * math.cos(r) - p.y * math.sin(r), p.x * math.sin(r) + p.y * math.cos(r))
end

const function morton(p: vector): number
	local n = 0
	for i = 0, 15 do
		const xbit, ybit = bit32.extract(p.x, i), bit32.extract(p.y, i)
		n = bit32.bor(n, bit32.lshift(xbit, i * 2), bit32.lshift(ybit, i * 2 + 1))
	end
	return n + 1
end

const function fetch(p: vector, r: number): number
	return morton(round(rotate(p, r)))
end

const function get(p: vector): { Settings.grid_boid }?
	const code = morton(round(p))
	return Grid[code]
end

const function add(id: number, p: vector, r: number): ()
	const b = buffer.create(12)
	const code = fetch(p, r)

	buffer.writeu16(b, 0, id)
	buffer.writeu16(b, 2, r)
	buffer.writef32(b, 4, p.x)
	buffer.writef32(b, 8, p.y)

	Grid[code] = Grid[code] or {}
	table.insert(Grid[code], b)
end

const function remove(id: number, p: vector, r: number): ()
	const code = fetch(p, r)
	const cell = Grid[code]

	for i, v in cell do
		const b = buffer.readu16(v, 0)
		if b == id then
			cell[i], cell[#cell] = cell[#cell], cell[i]
			cell[#cell] = nil
		end
	end
end

return {
	add = add,
	get = get,
	remove = remove,
}
