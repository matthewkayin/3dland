extends Control

onready var label = $speed

var player = null

func _physics_process(_delta):
    if player == null:
        player = get_node_or_null("../player")
        if player == null:
            return
    
    label.text = "SPD: " + String(stepify(player.velocity.length(), 0.1)) + "\n" + "ACC: " + String(stepify(player.acceleration.length(), 0.01))