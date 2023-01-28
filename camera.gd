extends Camera

const HEIGHT = 0.5
const DISTANCE = 1

var player = null

var look_direction = Vector3.BACK

func _ready():
    set_physics_process(true)
    set_as_toplevel(true)

func _physics_process(_delta):
    if player == null:
        player = get_node_or_null("../player")
        if player == null:
            return

    var target = player.get_global_transform().origin
    var position = get_global_transform().origin
    var offset = (position - target).normalized() * DISTANCE
    offset.y = HEIGHT

    look_at_from_position(target + offset, target, Vector3.UP)
    look_direction = (target - get_global_transform().origin).normalized()
    look_direction.y = 0