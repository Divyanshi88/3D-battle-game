extends Node3D

@export var enemy_scene: PackedScene
@export var max_enemies: int = 6
@export var spawn_interval: float = 30.0

func _ready():
	print("Main scene initialized")
	
	# Connect the enemy spawn timer
	var timer = $EnemySpawnTimer
	if timer:
		timer.wait_time = spawn_interval
		timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
		print("Enemy spawn timer connected")

func _on_spawn_timer_timeout():
	spawn_enemy()

func spawn_enemy():
	# Check if we've reached the maximum number of enemies
	var current_enemies = get_tree().get_nodes_in_group("enemy")
	if current_enemies.size() >= max_enemies:
		print("Maximum number of enemies reached")
		return
	
	# Create a new enemy instance
	if enemy_scene:
		var enemy_instance = enemy_scene.instantiate()
		
		# Choose a random spawn point
		var spawn_points = $SpawnPoints.get_children()
		if spawn_points.size() > 0:
			var spawn_point = spawn_points[randi() % spawn_points.size()]
			
			# Set the enemy position
			enemy_instance.global_transform = spawn_point.global_transform
			
			# Add the enemy to the scene
			add_child(enemy_instance)
			print("Spawned new enemy at ", spawn_point.global_transform.origin)
	else:
		print("Enemy scene not set")