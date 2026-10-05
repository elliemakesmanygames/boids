export type cell = { id: number, p: Vector2 }
export type grid = { [number]: { cell } }

return {
    focal_radius = 10,
    -- Dictates a maximum of the amount of boids to be evaluated in a focal radius.
    max_evaluated_boids = 5,
    -- The goal is to make a dynamic velocity and increment it based on the needs of cohesion and separation
    boid_default_velocity = 3,
    -- The goal will be to expand this into 3D, so there will be a hash grid structure for 2D.
    cell_size = Vector2.one,
}