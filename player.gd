extends KinematicBody

onready var camera = get_node("../camera")
onready var sprite = $sprite
onready var arrow = $arrow
onready var arrow2 = $arrow2
onready var arrow3 = $arrow3

const MAX_SPEED = 10
const ACCELERATION_MAGNITUDE = 2
const MAX_ACCELERATION_ANGLE = 2
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

    var rotation_angle = MIN_ACCELERATION_ANGLE + ((1 - speed_percent) * MAX_ACCELERATION_ANGLE)
    if Input.is_action_pressed("left"):
        direction = direction.rotated(Vector3.UP, deg2rad(rotation_angle))
    if Input.is_action_pressed("right"):
        direction = direction.rotated(Vector3.UP, deg2rad(-rotation_angle))

    if Input.is_action_pressed("forward"):
        acceleration_magnitude += 1.0 * delta
    else:
        acceleration_magnitude -= 1.0 * delta
    acceleration_magnitude = clamp(acceleration_magnitude, 0, ACCELERATION_MAGNITUDE)
    acceleration = direction * acceleration_magnitude
    print(acceleration_magnitude)

    var direction2d = Vector2(direction.x, direction.z)
    var velocity2d = Vector2(velocity.x, velocity.z)
    var opposite_car_direction_angle = PI / 2
    if velocity2d.angle_to(direction2d.rotated(PI / 2)) > velocity2d.angle_to(direction2d.rotated(-PI / 2)):
        opposite_car_direction_angle = -PI / 2
    var opposite_car_velocity = velocity2d.dot(direction2d.rotated(opposite_car_direction_angle)) / direction2d.length()
    var opposite_counter_force_2d = direction2d.rotated(opposite_car_direction_angle + PI) * (opposite_car_velocity * 1.0)
    var opposite_counter_force = Vector3(opposite_counter_force_2d.x, 0, opposite_counter_force_2d.y)

    arrow.look_at(transform.origin - direction, Vector3.UP)
    arrow2.look_at(transform.origin - velocity.normalized(), Vector3.UP)
    arrow3.look_at(transform.origin - opposite_counter_force.normalized(), Vector3.UP)

    var deceleration = velocity.normalized().rotated(Vector3.UP, PI) * (speed_percent * MAX_DECELERATION)

    var brake = Vector3.ZERO
    if Input.is_action_pressed("back"):
        brake = velocity.normalized().rotated(Vector3.UP, PI) * (speed_percent * 10)
    if velocity == Vector3.ZERO and Input.is_action_pressed("back"):
        acceleration = Vector3.ZERO

    velocity += (acceleration + deceleration + brake + opposite_counter_force) * delta

    if velocity.length() > MAX_SPEED:
        velocity = velocity.normalized() * MAX_SPEED

    var _ret_val = move_and_slide(velocity)

    var angle = rad2deg(camera.look_direction.signed_angle_to(direction, Vector3.UP))
    sprite.flip_h = angle > 0
    sprite.frame = int(abs(angle) / 15) 
