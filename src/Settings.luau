-- Implement mode type that tests sanity checks and grid rigorousity. Use numbers instead of string types if possible.
type mode = "none" | "light" | "heavy"

-- Priority will be a u8.
-- This is planned for prioritized dithering.
export type priority = {
	steer: (p: vector, v: vector) -> vector,
	priority: number,
}

export type grid_boid = buffer -- { id: u16, p: (f32,f32), v: (f32, f32) } -- 18 bytes
export type world_boid = buffer -- { p: (f32,f32), v: (f32, f32) } -- 16 bytes

export type grid = { [number]: { grid_boid } }
export type world = { [number]: world_boid }

return {
	-- Mode will dictate stuff such as enforcing grid sizes, max input coordinates for morton code (<u16)
	-- Mode will enforce hash table sizes, make sure that the grid has at least (2 cells for light mode, 4 cells for heavy mode)
	-- Mode will enforce a maximum limit on boids in the entire grid instead of per cell.
	mode = "none" :: mode,

	-- Max hash grid size.
	max_hash_grid_size = vector.create(1024, 1024),
	-- Maximum quantity of boids boids per cell.
	-- Helps prevent expensive cells / dense cells = more frames to update.
	-- Optimal for maximum of 10,000 units in a grid.
	max_boids_per_cell = 8,
	-- Dictates a maximum of the amount of boids to be evaluated in a focal radius.
	max_evaluated_boids = 3,
	-- The goal will be to expand this into 3D, so there will be a hash grid structure for 2D.
	cell_size = vector.create(4, 4),
	-- Boids will be by default a square.
	boid_size = vector.create(1, 1),

	-- Parameters will be u8s calculated with continuous functions.
	max_speed = 20, -- in studs/sec
	max_acceleration = 10, -- in studs/sec^2
	-- Direction vector for which all boids spawn facing towards.
	starting_vector = vector.create(1, 0),

	-- Grounding distance for what's considered "nearby"
	focal_sight = 5, -- in studs, same as focal radius with an angle limit.
	focal_angle = math.pi/2, -- in radians.
	detection_radius = 40, -- in studs, intended for the Arrival steering behavior.
    -- Radius of the circle used for the wander steering behavior.
	wander_radius = 10, -- in studs
	-- Offset for which the circle is distanced from the boid.
	wander_offset = 4, -- in studs
	-- Magnitude of displacement vector.
	wander_rate = 2,

	-- Weights are counters in the range of 0 to 1 that are used to determine steering.
	separation_weight = 51 / 255,
	alignment_weight = 23 / 255,
	cohesion_weight = 15 / 255,
	pursuit_weight = 10 / 255,
	evasion_weight = 35 / 255,
	wander_weight = 5 / 255,
	-- Will not implement arrival yet
}
