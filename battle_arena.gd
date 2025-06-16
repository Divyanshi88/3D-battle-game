extends Node3D

@onready var hero = $Hero
@onready var enemy = $Enemy
@onready var hero_health_label = $UI/HeroHealth
@onready var enemy_health_label = $UI/EnemyHealth
@onready var game_over_panel = $UI/GameOverPanel
@onready var result_label = $UI/GameOverPanel/ResultLabel
@onready var restart_button = $UI/GameOverPanel/RestartButton

# Spawn points for multiple enemies
var enemy_spawn_points = [
	Vector3(8, 0, 8),
	Vector3(-8, 0, 8),
	Vector3(8, 0, -8),
	Vector3(-8, 0, -8)
]

# Game state
var game_over = false
var score = 0
var wave = 1
var enemies_defeated = 0

func _ready():
	# Connect characters to each other
	hero.set_enemy(enemy)
	enemy.set_hero(hero)
	
	# Connect health change signals
	hero.health_changed.connect(_on_hero_health_changed)
	enemy.health_changed.connect(_on_enemy_health_changed)
	
	# Connect death signals
	hero.character_died.connect(_on_hero_died)
	enemy.character_died.connect(_on_enemy_died)
	
	# Connect restart button
	restart_button.pressed.connect(_on_restart_pressed)
	
	# Update initial health displays
	_on_hero_health_changed(hero.current_health)
	_on_enemy_health_changed(enemy.current_health)

func _process(delta):
	# Add some camera follow logic
	if hero and not hero.is_dead:
		var target_pos = hero.global_position
		$Camera3D.global_position = Vector3(target_pos.x * 0.3, 8, target_pos.z * 0.3 + 12)

func _on_hero_health_changed(new_health):
	hero_health_label.text = "Human: %d/%d" % [new_health, hero.max_health]

func _on_enemy_health_changed(new_health):
	enemy_health_label.text = "Zombie: %d/%d" % [new_health, enemy.max_health]

func _on_hero_died():
	if game_over:
		return
		
	game_over = true
	result_label.text = "Game Over!\nYou were defeated by the zombie!"
	game_over_panel.visible = true

func _on_enemy_died():
	enemies_defeated += 1
	score += 100 * wave
	
	# Respawn a new enemy after a delay
	await get_tree().create_timer(2.0).timeout
	
	if hero.is_dead or game_over:
		return
	
	if enemies_defeated >= wave * 2:
		# Next wave
		wave += 1
		enemies_defeated = 0
		
		# Heal the hero a bit
		hero.current_health = min(hero.max_health, hero.current_health + 30)
		_on_hero_health_changed(hero.current_health)
		
		result_label.text = "Wave %d Completed!\nScore: %d" % [wave, score]
		game_over_panel.visible = true
		await get_tree().create_timer(2.0).timeout
		
		if not hero.is_dead:
			game_over_panel.visible = false
	
	# Spawn a new enemy
	var spawn_point = enemy_spawn_points[randi() % enemy_spawn_points.size()]
	enemy.global_position = spawn_point
	enemy.current_health = enemy.max_health + (wave * 10)  # Enemies get stronger each wave
	enemy.attack_damage = 10 + (wave * 2)
	enemy.is_dead = false
	
	# Re-enable collision
	var collision_shape = enemy.get_node_or_null("CollisionShape3D")
	if collision_shape:
		collision_shape.disabled = false
	
	# Reset animation
	enemy.current_state = "idle"
	enemy.play_animation("idle")
	
	# Update enemy health display
	_on_enemy_health_changed(enemy.current_health)
	
	# Reconnect signals
	if not enemy.character_died.is_connected(_on_enemy_died):
		enemy.character_died.connect(_on_enemy_died)
	if not enemy.health_changed.is_connected(_on_enemy_health_changed):
		enemy.health_changed.connect(_on_enemy_health_changed)

func _on_restart_pressed():
	# Reload the current scene
	get_tree().reload_current_scene()