export type boid = buffer -- { id: u16, p: (f32,f32), r: u16, d: (f32,f32) } -- 20 bytes
export type grid = { [number]: { boid } }

--[[ Make a owner cell system
    If a boid is found in more than 1 cell at once,
    it will be defined to be in an owner cell. 
    This approach minimizes collision issues and facilitates detection.
]]
return {
    default_grid_size = Vector2.new(1024,1024),
    -- Dictates if multiple grids can overlap on a zone. TODO.
    allow_for_overlap = false,
    -- Boids will be by default a square.
    boid_size = Vector2.one,
    focal_radius = 10,
    -- Dictates a maximum of the amount of boids to be evaluated in a focal radius.
    max_evaluated_boids = 0xFF,
    -- The goal is to make a dynamic velocity and increment it based on the needs of cohesion and separation
    boid_default_velocity = 3,
    -- The goal will be to expand this into 3D, so there will be a hash grid structure for 2D.
    cell_size = Vector2.new(4,4),
}