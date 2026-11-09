-- World will be the single source of truth of the program.
-- Use Euler's integration alongside delta time.
-- p is the pursuer position, tp is target's position, v is velocity, rv is the displacement vector.
const Settings = require("./Settings")
const Grid = require("./Grid")

const MaxSpeed = Settings.max_speed
const MaxAcceleration = Settings.max_acceleration
const Sight = Settings.focal_sight
const Angle = Settings.focal_angle
const StartingVector = Settings.starting_vector
const WanderOffset = Settings.wander_offset
const WanderRate = Settings.wander_rate
const WanderRadius = Settings.wander_radius
const MaxEvaluatedBoids = Settings.max_evaluated_boids

const SeparationWeight = Settings.separation_weight
const AlignmentWeight = Settings.alignment_weight
const CohesionWeight = Settings.cohesion_weight
const TargetBias = Settings.target_bias
const SeekWeight = Settings.seek_weight
const FleeWeight = Settings.flee_weight
const PursuitWeight = Settings.pursuit_weight
const EvasionWeight = Settings.evasion_weight
const WanderWeight = Settings.wander_weight

const function predict(p: vector, tp: vector, v: vector): vector
    const T = (tp - p) / MaxSpeed
    return tp + (v * T)
end

const function neighborhood(p: vector, v: vector): {{ vector, number }}
    const sight_vector = vector.normalize(p) * Sight
end

const function seek(p: vector, t: vector, v: vector): vector
	return (vector.normalize(t - p) * MaxSpeed) - v
end

const function flee(p: vector, t: vector, v: vector): vector
	return (vector.normalize(p - t) * MaxSpeed) - v
end

const function pursue(p: vector, tp: vector, v: vector): vector
    const prediction = predict(p, tp, v)
    return seek(prediction)
end

const function evade(p: vector, tp: vector, v: vector): vector
    const prediction = predict(p, tp, v)
    return flee(prediction)
end

const function wander(p: vector, v: vector, rv: vector): (vector, vector)
    if v == vector.zero then v = StartingVector end
    const displacement = vector.create(math.random(-1, 1), math.random(-1, 1)) * WanderRate
    const center = p + (vector.normalize(v) * WanderOffset)
    const new_rv = vector.normalize(rv + displacement) * WanderRadius
    const world_rv = center + new_rv
    return world_rv - p, new_rv
end

const function cohere(): vector
end

const function align(): vector
end

const function repulsion(): vector
end

return {}
