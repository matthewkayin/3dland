extends KinematicBody

onready var camera = get_node("../camera")
onready var sprite = $sprite
onready var arrow = $arrow
onready var arrow2 = $arrow2
onready var arrow3 = $arrow3

const MAX_SPEED = 10
const ACCELERATION_MAGNITUDE = 2
const MAX_ACCELERATION_ANGLE = 3
const MIN_ACCELERATION_ANGLE = 0.5
const MAX_DECELERATION = 1

var velocity = Vector3.ZERO
var direction = Vector3.BACK
var acceleration = Vector3.ZERO
var acceleration_magnitude = 0

func _ready():
    pass 

func _physics_process(delta):
    var speed_percent = (velocity.length() / MAX_SPEED)

    var rotation_speed = 0.1 + ((1 - speed_percent) * MAX_ACCELERATION_ANGLE)
    # var rotation_speed = MAX_ACCELERATION_ANGLE
    if Input.is_action_pressed("left"):
        direction = direction.rotated(Vector3.UP, deg2rad(rotation_speed))
    if Input.is_action_pressed("right"):
        direction = direction.rotated(Vector3.UP, deg2rad(-rotation_speed))

    if Input.is_action_pressed("forward"):
        if speed_percent < 0.3:
            acceleration_magnitude = ACCELERATION_MAGNITUDE * 0.5
        elif speed_percent < 0.8:
            acceleration_magnitude = ACCELERATION_MAGNITUDE
        else:
            acceleration_magnitude = ACCELERATION_MAGNITUDE * 0.5
    else:
        acceleration_magnitude = 0
    acceleration_magnitude = clamp(acceleration_magnitude, 0, ACCELERATION_MAGNITUDE)
    acceleration = direction * acceleration_magnitude

    var deceleration = velocity.normalized().rotated(Vector3.UP, PI) * (speed_percent * MAX_DECELERATION)

    # arrow.look_at(transform.origin - direction, Vector3.UP)
    # arrow2.look_at(transform.origin - velocity.normalized(), Vector3.UP)

    velocity += (acceleration + deceleration) * delta

    var drift_angle = direction.angle_to(velocity)
    var drift_percent = (drift_angle / (PI / 2))
    var drift_magnitude = velocity.dot(direction.rotated(Vector3.UP, -PI / 2))
    var traction = direction.rotated(Vector3.UP, PI / 2) * drift_magnitude * drift_percent
    velocity += traction * delta
    # arrow3.look_at(transform.origin - traction.normalized(), Vector3.UP)

    if velocity.length() > MAX_SPEED:
        velocity = velocity.normalized() * MAX_SPEED

    var _ret_val = move_and_slide(velocity)

    var angle = rad2deg(camera.look_direction.signed_angle_to(direction, Vector3.UP))
    sprite.flip_h = angle > 0
    sprite.frame = int(abs(angle) / 15) 
    if abs(angle) > 5 and sprite.frame == 0:
        sprite.frame = 1
