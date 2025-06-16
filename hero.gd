extends Character

class_name Hero

# Reference to the enemy
var enemy: Character = null

# Input controls
@export var move_forward_key: String = "move_forward"
@export var move_backward_key: String = "move_backward"
@export var move_left_key: String = "move_left"
@export var move_right_key: String = "move_right"
@export var attack_key: String = "attack"

# Footstep timer
var footstep_timer: float = 0.0
var footstep_interval: float = 0.3

func _ready():
	super._ready()
	max_health = 120  # Hero has more health
	current_health = max_health
	attack_damage = 15
	
	# Set up input actions if they don't exist
	_setup_input_actions()

func _setup_input_actions():
	if not InputMap.has_action(move_forward_key):
		InputMap.add_action(move_forward_key)
		var event = InputEventKey.new()
		event.keycode = KEY_W
		InputMap.action_add_event(move_forward_key, event)
	
	if not InputMap.has_action(move_backward_key):
		InputMap.add_action(move_backward_key)
		var event = InputEventKey.new()
		event.keycode = KEY_S
		InputMap.action_add_event(move_backward_key, event)
	
	if not InputMap.has_action(move_left_key):
		InputMap.add_action(move_left_key)
		var event = InputEventKey.new()
		event.keycode = KEY_A
		InputMap.action_add_event(move_left_key, event)
	
	if not InputMap.has_action(move_right_key):
		InputMap.add_action(move_right_key)
		var event = InputEventKey.new()
		event.keycode = KEY_D
		InputMap.action_add_event(move_right_key, event)
	
	if not InputMap.has_action(attack_key):
		InputMap.add_action(attack_key)
		var event = InputEventKey.new()
		event.keycode = KEY_SPACE
		InputMap.action_add_event(attack_key, event)

func _physics_process(delta):
	if is_dead:
		return
	
	# Handle movement input
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed(move_forward_key):
		direction.z -= 1
	if Input.is_action_pressed(move_backward_key):
		direction.z += 1
	if Input.is_action_pressed(move_left_key):
		direction.x -= 1
	if Input.is_action_pressed(move_right_key):
		direction.x += 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Look in the direction of movement
		look_at(global_position - direction, Vector3.UP)
		
		# Play walk animation if not already playing
		if not is_attacking and current_state != "walk":
			current_state = "walk"
			play_animation("walk")
			
		# Footstep sounds
		footstep_timer += delta
		if footstep_timer >= footstep_interval:
			footstep_timer = 0
			# Play footstep sound (would be implemented with AudioStreamPlayer)
	else:
		# Play idle animation if not moving or attacking
		if not is_attacking and current_state != "idle":
			current_state = "idle"
			play_animation("idle")
	
	# Set velocity and move
	velocity = direction * move_speed
	super._physics_process(delta)
	
	# Handle attack input
	if Input.is_action_just_pressed(attack_key) and not is_attacking:
		perform_attack()

func perform_attack():
	if is_dead or is_attacking:
		return
	
	# Start the attack animation
	attack()
	
	# Check if enemy is in range
	if enemy and not enemy.is_dead:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < 2.0:  # Attack range
			# Wait a small delay for the animation to reach the hit point
			await get_tree().create_timer(0.2).timeout
			
			# Only deal damage if we're still attacking and not dead
			if is_attacking and not is_dead and not enemy.is_dead:
				# Deal damage to enemy
				enemy.take_damage(attack_damage)
				emit_signal("attack_performed", attack_damage)
				
				# Add some knockback to the enemy
				var knockback_dir = (enemy.global_position - global_position).normalized()
				enemy.velocity = knockback_dir * 10
				
				# Print debug message to confirm hit
				print("Hero hit enemy for ", attack_damage, " damage!")

func set_enemy(new_enemy: Character):
	enemy = new_enemy
