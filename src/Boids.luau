-- World will be the single source of truth of the program.
const Settings = require("./Settings")
const Grid = require("./Grid")
const World = {} :: Settings.world

const speed = Settings.boid_speed
const force = Settings.boid_force
const nearby = Settings.nearby_dist
const sight = Settings.focal_length
const angle = Settings.focal_angle

const separation_weight = Settings.separation_weight
const alignment_weight = Settings.alignment_weight
const cohesion_weight = Settings.cohesion_weight
const target_bias = Settings.target_bias
const seek_weight = Settings.seek_weight
const flee_weight = Settings.flee_weight
const pursuit_weight = Settings.pursuit_weight
const wander_weight = Settings.wander_weight

const function rotate(p: vector, r: number): vector
	return vector.create(p.x * math.cos(r) - p.y * math.sin(r), p.x * math.sin(r) + p.y * math.cos(r))
end

const function seek(p: vector, r: number, t: vector): vector
	return (vector.normalize(t - p) * speed) - rotate(vector.create(1, 0) * speed, r)
end

const function flee(p: vector, r: number, t: vector): vector
	return (vector.normalize(p - t) * speed) - rotate(vector.create(1, 0) * speed, r)
end

const function cohere(): vector
end

const function align(): vector
end

const function repulsion(): vector
end

return {}
