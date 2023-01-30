extends KinematicBody

onready var camera = get_node("../camera")
onready var sprite = $sprite
onready var arrow = $arrow
onready var arrow2 = $arrow2
onready var arrow3 = $arrow3
onready var gas_tap_timer = $gas_tap_timer

const MAX_ROTATE_SPEED = 2
const MIN_ROTATE_SPEED = 0.1
const MAX_DECELERATION = 1
const DRIFT_GAS_TAP_WINDOW = 0.5
const MIN_DRIFT_PERCENT = 0.25

var MAX_ACCELERATION = 2
var TOP_SPEED = 10

var velocity = Vector3.ZERO
var direction = Vector3.BACK
var acceleration = Vector3.ZERO
var acceleration_magnitude = 0
var is_drifting = false
var drift_percent = 0
var speed_percent = 0 

func _ready():
    pass 

func curve_acceleration():
    if speed_percent < 0.3:
        return (MAX_ACCELERATION * 0.5) + (MAX_ACCELERATION * 0.5 * (speed_percent / 0.3))
    elif speed_percent < 0.6:
        return MAX_ACCELERATION
    else:
        return MAX_ACCELERATION - (MAX_ACCELERATION * 0.5 * ((speed_percent - 0.6) / 0.4))

func _physics_process(delta):
    speed_percent = (velocity.length() / TOP_SPEED)

    # Drift Input
    if Input.is_action_just_released("forward"):
        gas_tap_timer.start(DRIFT_GAS_TAP_WINDOW)
    if ((Input.is_action_just_pressed("forward") and not gas_tap_timer.is_stopped()) or Input.is_action_just_pressed("back")) and drift_percent > MIN_DRIFT_PERCENT:
        is_drifting = true
        gas_tap_timer.stop()

    # Rotation
    var rotation_speed = MIN_ROTATE_SPEED + ((1 - speed_percent) * MAX_ROTATE_SPEED)
    if not Input.is_action_pressed("forward") or Input.is_action_pressed("back") or is_drifting: 
        rotation_speed += MAX_ROTATE_SPEED
    if Input.is_action_pressed("left"):
        direction = direction.rotated(Vector3.UP, deg2rad(rotation_speed))
    if Input.is_action_pressed("right"):
        direction = direction.rotated(Vector3.UP, deg2rad(-rotation_speed))

    # Traction and Grip Force
    var turn_angle = direction.angle_to(velocity)
    if turn_angle > PI / 2:
        turn_angle -= PI / 2
    drift_percent = (turn_angle / (PI / 2))
    if drift_percent < MIN_DRIFT_PERCENT:
        is_drifting = false
    var drift_magnitude = velocity.dot(direction.rotated(Vector3.UP, -PI / 2))
    var traction = direction.rotated(Vector3.UP, PI / 2) * drift_magnitude * drift_percent
    if is_drifting:
        traction *= 0.25
    var made_up_traction = direction * traction.length()
    if not is_drifting:
        made_up_traction *= (1 - drift_percent)

    # Acceleration
    acceleration_magnitude = 0
    if Input.is_action_pressed("forward"):
        acceleration_magnitude = curve_acceleration()
    if Input.is_action_pressed("back"):
        acceleration_magnitude = -MAX_ACCELERATION * 2
    acceleration_magnitude = clamp(acceleration_magnitude, MAX_ACCELERATION * -0.5, MAX_ACCELERATION)
    acceleration = direction * acceleration_magnitude

    # Deceleration
    var deceleration = velocity.normalized().rotated(Vector3.UP, PI) * (speed_percent * MAX_DECELERATION)

    # Compute velocity
    velocity += (acceleration + deceleration + traction + made_up_traction) * delta
    if velocity.length() > TOP_SPEED:
        velocity = velocity.normalized() * TOP_SPEED
    var _ret_val = move_and_slide(velocity)

    # Determine sprite angle
    var angle = rad2deg(camera.look_direction.signed_angle_to(direction, Vector3.UP))
    sprite.flip_h = angle > 0
    sprite.frame = int(abs(angle) / 15) 
    if abs(angle) > 5 and sprite.frame == 0:
        sprite.frame = 1
