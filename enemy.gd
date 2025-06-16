extends Character

class_name Enemy

# Reference to the hero
var hero: Character = null

# AI settings
@export var detection_range: float = 8.0
@export var attack_range: float = 1.5
@export var attack_cooldown: float = 2.0
@export var wander_radius: float = 5.0
@export var wander_interval: float = 3.0

# State tracking
var can_attack: bool = true
var timer: Timer
var wander_timer: Timer
var wander_target: Vector3 = Vector3.ZERO
var initial_position: Vector3

# Zombie sounds
var groan_interval: float = 5.0
var groan_timer: float = 0.0

func _ready():
	super._ready()
	max_health = 80
	current_health = max_health
	attack_damage = 10
	move_speed = 3.0  # Zombies are slower
	
	# Create timer for attack cooldown
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = attack_cooldown
	timer.timeout.connect(_on_attack_cooldown_timeout)
	add_child(timer)
	
	# Create timer for wandering
	wander_timer = Timer.new()
	wander_timer.one_shot = true
	wander_timer.wait_time = wander_interval
	wander_timer.timeout.connect(_on_wander_timer_timeout)
	add_child(wander_timer)
	
	# Start wandering
	initial_position = global_position
	_on_wander_timer_timeout()

func _physics_process(delta):
	if is_dead:
		return
	
	# Update groan timer
	groan_timer += delta
	if groan_timer >= groan_interval:
		groan_timer = 0
		# Play zombie groan sound (would be implemented with AudioStreamPlayer)
	
	if hero == null or hero.is_dead:
		# Wander around if no hero or hero is dead
		_wander(delta)
		return
	
	var distance_to_hero = global_position.distance_to(hero.global_position)
	
	if distance_to_hero <= attack_range:
		# In attack range
		if can_attack and not is_attacking:
			perform_attack()
		elif not is_attacking:
			# Face the hero while waiting to attack
			look_at(hero.global_position, Vector3.UP)
			if current_state != "idle":
				current_state = "idle"
				play_animation("idle")
				
		# Stop moving
		velocity = Vector3.ZERO
	elif distance_to_hero <= detection_range:
		# In detection range but not in attack range, move towards hero
		var direction = (hero.global_position - global_position).normalized()
		direction.y = 0  # Keep movement on the horizontal plane
		
		# Look at hero
		look_at(hero.global_position, Vector3.UP)
		
		# Move towards hero
		velocity = direction * move_speed
		
		# Play walk animation
		if not is_attacking and current_state != "walk":
			current_state = "walk"
			play_animation("walk")
	else:
		# Out of range, wander around
		_wander(delta)
	
	super._physics_process(delta)

func _wander(delta):
	if is_attacking:
		return
		
	if wander_target == Vector3.ZERO or global_position.distance_to(wander_target) < 0.5:
		if wander_timer.is_stopped():
			wander_timer.start()
		
		# Just idle while waiting for new wander target
		if current_state != "idle":
			current_state = "idle"
			play_animation("idle")
			
		velocity = Vector3.ZERO
	else:
		# Move towards wander target
		var direction = (wander_target - global_position).normalized()
		direction.y = 0
		
		look_at(wander_target, Vector3.UP)
		velocity = direction * (move_speed * 0.5)  # Wander slower
		
		if current_state != "walk":
			current_state = "walk"
			play_animation("walk")

func _on_wander_timer_timeout():
	# Pick a random point within wander radius of initial position
	var random_angle = randf() * 2.0 * PI
	var random_radius = randf() * wander_radius
	
	wander_target = initial_position + Vector3(
		cos(random_angle) * random_radius,
		0,
		sin(random_angle) * random_radius
	)

func perform_attack():
	if is_dead or is_attacking or not can_attack:
		return
	
	can_attack = false
	timer.start()
	
	# Start the attack animation
	attack()
	
	# Check if hero is in range
	if hero and not hero.is_dead:
		var distance = global_position.distance_to(hero.global_position)
		if distance <= attack_range:
			# Wait a small delay for the animation to reach the hit point
			await get_tree().create_timer(0.2).timeout
			
			# Only deal damage if we're still attacking and not dead
			if is_attacking and not is_dead and not hero.is_dead:
				# Deal damage to hero
				hero.take_damage(attack_damage)
				emit_signal("attack_performed", attack_damage)
				
				# Print debug message to confirm hit
				print("Zombie hit hero for ", attack_damage, " damage!")

func _on_attack_cooldown_timeout():
	can_attack = true

func set_hero(new_hero: Character):
	hero = new_hero
