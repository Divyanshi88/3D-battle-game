extends CanvasLayer

var stats = {}

func _ready():
	# Create debug label
	var label = Label.new()
	label.name = "DebugLabel"
	label.position = Vector2(10, 100)
	label.size = Vector2(500, 300)
	add_child(label)
	
	# Update every frame
	set_process(true)

func _process(_delta):
	# Update player position
	var player = get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player").size() > 0 else null
	if player:
		stats["Player Position"] = str(player.global_position)
		stats["Player Velocity"] = str(player.velocity)
		stats["Player Grounded"] = str(player.is_on_floor())
	
	# Update enemy count and positions
	var enemies = get_tree().get_nodes_in_group("enemy")
	stats["Enemy Count"] = str(enemies.size())
	
	if enemies.size() > 0:
		stats["Enemy 1 Position"] = str(enemies[0].global_position)
		stats["Enemy 1 Health"] = str(enemies[0].health)
	
	# Update debug text
	var debug_text = ""
	for key in stats:
		debug_text += key + ": " + stats[key] + "\n"
	
	$DebugLabel.text = debug_text