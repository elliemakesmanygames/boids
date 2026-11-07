-- Implement mode type that tests sanity checks and grid rigorousity. Use numbers instead of string types if possible.
type mode = "none" | "light" | "heavy"

export type grid_boid = buffer -- { id: u16, p: (f32, f32), r: u16 } -- 12 bytes
export type world_boid = buffer -- { p: (f32, f32), r: u16 } -- 10 bytes

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
	boid_size = vector.one,

	-- Parameters will be u8s calculated with continuous functions.
	boid_speed = 10, -- in studs/sec
	boid_force = 5,

	-- Grounding distance for what's considered "nearby"
	nearby_dist = 30, -- in studs
	focal_sight = 100, -- in studs
	focal_angle = math.pi, -- in radians

	-- Weights are u8 counters that are used to determine steering during:
	-- Separation, alignment and cohesion.
	separation_weight = 51,
	alignment_weight = 23,
	cohesion_weight = 13,
	target_bias = 17,
	seek_weight = 22,
	flee_weight = 32,
	pursuit_weight = 10,
	wander_weight = 5,
	-- Will not implement arrival yet
}
