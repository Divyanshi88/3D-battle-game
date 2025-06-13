extends CharacterBody3D

# Player movement properties
@export var move_speed: float = 5.0
@export var jump_force: float = 5.0
@export var health: int = 100
@export var max_health: int = 100
@export var attack_damage: int = 20
@export var attack_range: float = 2.0

# Animation variables
var is_grounded: bool = false
var is_attacking: bool = false
var score: int = 0
var is_dead: bool = false

# Platform boundaries
var platform_size: Vector2 = Vector2(20, 20)  # X and Z size of the platform

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Add player to the player group for enemy targeting
	add_to_group("player")
	
	# Initialize UI
	update_health_display()
	update_score_display()
	
	print("Player initialized")

func _physics_process(delta):
	if is_dead:
		return
		
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		is_grounded = true
	
	# Only process movement if not attacking
	if not is_attacking:
		# Handle horizontal movement
		var input_dir_x = Input.get_axis("ui_left", "ui_right")
		var input_dir_z = Input.get_axis("ui_up", "ui_down")
		var direction = Vector3(input_dir_x, 0, input_dir_z).normalized()
		
		if direction:
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
			
			# Face the direction of movement
			if direction.length() > 0:
				look_at(global_position + Vector3(direction.x, 0, direction.z), Vector3.UP)
			
			print("Moving: ", direction)
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
		
		# Handle jumping
		if Input.is_action_just_pressed("ui_accept") and is_grounded:
			velocity.y = jump_force
			is_grounded = false
			print("Jumping")
		
		# Handle attack
		if Input.is_action_just_pressed("attack"):
			attack()
	
	# Apply movement
	move_and_slide()
	
	# Check platform boundaries
	enforce_platform_boundaries()
	
	# Check for enemies to attack
	check_for_enemies()

# Keep player within platform boundaries
func enforce_platform_boundaries():
	var half_size_x = platform_size.x / 2
	var half_size_z = platform_size.y / 2
	
	if global_position.x < -half_size_x:
		global_position.x = -half_size_x
		velocity.x = 0
	elif global_position.x > half_size_x:
		global_position.x = half_size_x
		velocity.x = 0
		
	if global_position.z < -half_size_z:
		global_position.z = -half_size_z
		velocity.z = 0
	elif global_position.z > half_size_z:
		global_position.z = half_size_z
		velocity.z = 0

# Attack function
func attack():
	if is_attacking:
		return
		
	is_attacking = true
	print("Attacking")
	
	# Wait for animation to reach the hit point
	await get_tree().create_timer(0.5).timeout
	
	# Check for enemies in range
	check_for_enemies(true)
	
	# Reset attacking state after animation
	await get_tree().create_timer(0.5).timeout
	is_attacking = false

# Check for enemies in attack range
func check_for_enemies(deal_damage = false):
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		
		if distance <= attack_range and deal_damage:
			# Face the enemy
			look_at(Vector3(enemy.global_position.x, global_position.y, enemy.global_position.z), Vector3.UP)
			
			# Deal damage
			if enemy.has_method("take_damage"):
				enemy.take_damage(attack_damage)
				print("Hit enemy for ", attack_damage, " damage")

# Take damage from enemies
func take_damage(damage):
	if is_dead:
		return
		
	health -= damage
	update_health_display()
	print("Player took ", damage, " damage. Health: ", health)
	
	if health <= 0:
		die()

# Die function
func die():
	is_dead = true
	print("Player died")
	
	# Disable collision
	$CollisionShape3D.disabled = true
	
	# Show game over message
	var game_over_label = $"../UI/GameOverLabel" if has_node("../UI/GameOverLabel") else null
	if game_over_label:
		game_over_label.visible = true
	
	# Restart game after delay
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()

# Increase score
func increase_score(points):
	score += points
	update_score_display()
	print("Score increased by ", points, ". Total: ", score)

# Update health display
func update_health_display():
	var health_label = $"../UI/HealthLabel" if has_node("../UI/HealthLabel") else null
	if health_label:
		health_label.text = "Health: " + str(health) + "/" + str(max_health)

# Update score display
func update_score_display():
	var score_label = $"../UI/ScoreLabel" if has_node("../UI/ScoreLabel") else null
	if score_label:
		score_label.text = "Score: " + str(score)