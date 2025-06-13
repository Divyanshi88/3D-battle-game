extends Node

@export var enemy_scene: PackedScene
@export var max_enemies: int = 6
@export var spawn_interval: float = 30.0

var spawn_points = []
var timer: Timer

func _ready():
	# Get the spawn points
	var spawn_points_node = $SpawnPoints
	if spawn_points_node:
		for child in spawn_points_node.get_children():
			spawn_points.append(child)
	
	# Set up the timer
	timer = $EnemySpawnTimer
	if timer:
		timer.wait_time = spawn_interval
		timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
		timer.start()

func _on_spawn_timer_timeout():
	spawn_enemy()

func spawn_enemy():
	# Check if we've reached the maximum number of enemies
	var current_enemies = get_tree().get_nodes_in_group("enemy")
	if current_enemies.size() >= max_enemies:
		return
	
	# Create a new enemy instance
	if enemy_scene and spawn_points.size() > 0:
		var enemy_instance = enemy_scene.instantiate()
		
		# Choose a random spawn point
		var spawn_point = spawn_points[randi() % spawn_points.size()]
		
		# Set the enemy position
		enemy_instance.global_transform = spawn_point.global_transform
		
		# Add the enemy to the scene
		add_child(enemy_instance)