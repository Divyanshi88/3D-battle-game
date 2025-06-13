extends CharacterBody3D

# Enemy properties
@export var move_speed: float = 3.0
@export var attack_range: float = 2.0
@export var detection_range: float = 8.0
@export var health: int = 100
@export var attack_damage: int = 10

# Animation variables
var player: Node3D = null
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var can_attack: bool = true
var is_dead: bool = false

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Find the player
	player = get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player").size() > 0 else null
	
	if player:
		print("Enemy found player")
	else:
		print("Enemy couldn't find player")

func _physics_process(delta):
	if is_dead:
		return
		
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Attack cooldown
	if attack_cooldown > 0:
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			can_attack = true
	
	if player:
		var distance = global_position.distance_to(player.global_position)
		
		# If player is within detection range but outside attack range, move towards player
		if distance < detection_range and distance > attack_range:
			var direction = (player.global_position - global_position).normalized()
			direction.y = 0  # Keep movement on the horizontal plane
			
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
			
			# Face the player
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))
			
			# Debug
			if randf() < 0.01:  # Only print occasionally to avoid spam
				print("Enemy moving towards player. Distance: ", distance)
		
		# If player is within attack range, attack
		elif distance <= attack_range and can_attack:
			attack()
		else:
			# If player is out of range, idle
			velocity.x = 0
			velocity.z = 0
	
	# Apply movement
	move_and_slide()

func attack():
	if is_attacking or not can_attack:
		return
		
	is_attacking = true
	can_attack = false
	attack_cooldown = 1.5  # Set cooldown time
	
	print("Enemy attacking")
		
	# Deal damage to player after a short delay
	await get_tree().create_timer(0.5).timeout
	
	# Check if player is still in range
	if player and global_position.distance_to(player.global_position) <= attack_range:
		# Call the take_damage function on the player
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)
			print("Enemy hit player for ", attack_damage, " damage")
	
	# Reset attacking state after animation
	await get_tree().create_timer(0.5).timeout
	is_attacking = false

func take_damage(damage):
	health -= damage
	print("Enemy took ", damage, " damage. Health: ", health)
	
	if health <= 0 and not is_dead:
		die()

func die():
	is_dead = true
	print("Enemy died")
	
	# Disable collision
	$CollisionShape3D.disabled = true
	
	# Increase player score
	if player and player.has_method("increase_score"):
		player.increase_score(10)
	
	# Remove enemy after delay
	await get_tree().create_timer(1.0).timeout
	queue_free()