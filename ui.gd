extends Control

onready var label = $speed
onready var needle = $speedometer/needle

var player = null

func _physics_process(_delta):
    if player == null:
        player = get_node_or_null("../player")
        if player == null:
            return

    needle.rotation_degrees = -180 + (90 * player.speed_percent)
    
    label.text = "SPD: " + String(stepify(player.velocity.length(), 0.1)) + "\n" + "ACC: " + String(stepify(player.acceleration.length(), 0.01))
    if player.is_drifting:
        label.text += "\nDRIFTING"
