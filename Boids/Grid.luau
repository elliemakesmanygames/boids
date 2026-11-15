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
const CellSize = Settings.cell_size
const MaxBoidsPerCell = Settings.max_boids_per_cell

const Grid = {} :: Settings.grid
const World = {} :: Settings.world

const function round(p: vector): vector
		return vector.create(p.x // CellSize.x, p.y // CellSize.y)
end

const function morton(p: vector): number
		local x = bit32.band(p.x, 0xFFFF)
		local y = bit32.band(p.y, 0xFFFF)

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

const function grid_spawn(id: number, p: vector, v: vector, code: number): ()
		const b = buffer.create(18)

		buffer.writeu16(b, 0, id)
		buffer.writef32(b, 2, p.x)
		buffer.writef32(b, 6, p.y)
		buffer.writef32(b, 10, v.x)
		buffer.writef32(b, 14, v.y)

		Grid[code] = Grid[code] or {}
		table.insert(Grid[code], b)
end

const function grid_remove(id: number, code: number): ()
		const cell = Grid[code]
		if not cell then return end

		const s = #cell
		for i = 1, s do
				const b = buffer.readu16(cell[i], 0)
				if b == id then
						cell[i] = cell[s]
						cell[s] = nil
				end
		end
end

const function grid_get(p: vector): { buffer }?
		const code = fetch(p)
		return Grid[code]
end

const function world_spawn(p: vector, v: vector): ()
		const wb = buffer.create(16)
		const id = #World + 1
		const code = fetch(p)

		buffer.writef32(wb, 0, p.x)
		buffer.writef32(wb, 4, p.y)
		buffer.writef32(wb, 8, v.x)
		buffer.writef32(wb, 12, v.y)

		World[id]	= { wb = wb, code = code }
		grid_spawn(id, p, v, code)
end

const function world_despawn(id: number): ()
		const world_boid = World[id]
		if not world_boid then return end

		grid_remove(id, world_boid.code)
end

const function world_update(id: number, np: vector, nv: vector): ()
		const world_boid = World[id]
		if not world_boid then error(`boid of id {id} does not exist.`) end

		const wb, code = world_boid.wb, world_boid.code
		const new_code = fetch(np)
		
		buffer.writef32(wb, 0, np.x)
		buffer.writef32(wb, 4, np.y)
		buffer.writef32(wb, 8, nv.x)
		buffer.writef32(wb, 12, nv.y)

		if new_code ~= code then
				grid_remove(id, code)
				grid_spawn(id, np, nv, new_code)
				world_boid.code = new_code
		end
end

const function world_get_boid(id: number): buffer?
		const world_boid = World[id]
	  if (world_boid == nil) then return end
		
		return world_boid.wb
end

return {
	spawn = world_spawn,
	despawn = world_despawn,
	update = world_update,
	get_boid = world_get_boid,
	get_cell = grid_get,
}
