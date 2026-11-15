--!strict
--!optimize 2
-- World will be the single source of truth of the program.
-- Use Euler's integration alongside delta time.
-- p is the pursuer position, tp is target's position, v is velocity, rv is the displacement vector.
const Settings = require("./Settings")
const Grid = require("./Grid")

const GridSize = Settings.hash_grid_size
const CellSize = Settings.cell_size
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
const PursuitWeight = Settings.pursuit_weight
const EvasionWeight = Settings.evasion_weight
const WanderWeight = Settings.wander_weight

const function predict(p: vector, tp: vector, tv: vector): vector
    const T = (tp - p) / MaxSpeed
    return tp + (tv * T)
end

const function neighborhood(p: vector, v: vector, predicate: (p: vector, bp: vector, bv: vector) -> vector): vector
    return vector.zero
end

const function seek(p: vector, t: vector, v: vector): vector
	return (vector.normalize(t - p) * MaxSpeed) - v
end

const function flee(p: vector, t: vector, v: vector): vector
	return (vector.normalize(p - t) * MaxSpeed) - v
end

const function pursue(p: vector, tp: vector, v: vector): vector
    const prediction = predict(p, tp, v)
    return seek(p, prediction, v)
end

const function evade(p: vector, tp: vector, v: vector): vector
    const prediction = predict(p, tp, v)
    return flee(p, prediction, v)
end

const function wander(p: vector, v: vector, rv: vector): (vector, vector)    
    const displacement = vector.create(math.random(-1, 1), math.random(-1, 1)) * WanderRate
    const center = p + (vector.normalize(v) * WanderOffset)
    const new_rv = vector.normalize(rv + displacement) * WanderRadius
    const world_rv = center + new_rv

    return world_rv - p, new_rv
end

const function repulse(p: vector): vector
    return neighborhood(p, function(p: vector, bp: vector)
        const dir = p - bp
        const r = vector.magnitude(dir)
                
        return (r == 0) and vector.zero or vector.normalize(dir) / r 
    end)
end

const function cohere(p: vector, v: vector): vector
    local count = 0
    const total_position = neighborhood(p, function(p: vector, bp: vector)
        count += 1
        return bp
    end)

    return (count == 0) and vector.zero or seek(p, total_position / count, v)
end

const function align(p: vector, v: vector): vector
    local count = 0
    const total_velocity = neighborhood(p, function(p: vector, bp: vector, bv: vector)
        count += 1
        return bv
    end)

    return (count == 0) and vector.zero or total_velocity / count - v
end

const function steer(p: vector, v: vector, tp: vector, rv: vector): vector
    const cohere_steer = cohere(p, v)
    const align_steer = align(p, v)
    const separation_steer = repulse(p)
    const pursue_steer = pursue(p, tp, v)
    const evade_steer = evade(p, tp, v)

    return (cohere_steer * CohesionWeight)
           + (align_steer * AlignmentWeight)
           + (separation_steer * SeparationWeight)
           + (pursue_steer * PursuitWeight)
           + (evade_steer * EvasionWeight)
end

return {
    steer = steer
}
