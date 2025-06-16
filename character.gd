extends CharacterBody3D

class_name Character

# Character stats
@export var max_health: int = 100
@export var attack_damage: int = 10
@export var move_speed: float = 5.0

# Current state
var current_health: int
var is_attacking: bool = false
var is_dead: bool = false
var current_state: String = "idle"

# Animation
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Signals
signal health_changed(new_health)
signal character_died()
signal attack_performed(damage)

func _ready():
	current_health = max_health
	emit_signal("health_changed", current_health)
	
	# Start with idle animation
	play_animation("idle")

func _physics_process(delta):
	if is_dead:
		return
		
	# Movement logic will be implemented in child classes
	move_and_slide()

func take_damage(damage_amount: int):
	if is_dead:
		return
		
	current_health -= damage_amount
	emit_signal("health_changed", current_health)
	
	if current_health <= 0:
		die()
	else:
		# Play hit reaction
		flash_damage()

func flash_damage():
	# Visual feedback for taking damage
	var body_mesh = get_node_or_null("CharacterMesh/Body")
	if body_mesh and body_mesh is MeshInstance3D:
		# Store the original material
		var original_material = body_mesh.get_surface_override_material(0)
		if not original_material:
			original_material = body_mesh.mesh.surface_get_material(0)
			
		# Create a red flash material
		var flash_material = original_material.duplicate()
		flash_material.albedo_color = Color(1, 0.3, 0.3)
		
		# Apply the flash material
		body_mesh.set_surface_override_material(0, flash_material)
		
		# Reset after a short time
		await get_tree().create_timer(0.2).timeout
		
		# Restore original material if character still exists and isn't dead
		if is_instance_valid(body_mesh) and not is_dead:
			if original_material:
				body_mesh.set_surface_override_material(0, original_material)
			else:
				body_mesh.set_surface_override_material(0, null)

func die():
	is_dead = true
	current_health = 0
	emit_signal("character_died")
	
	# Play death animation
	current_state = "dead"
	play_animation("die")
	
	# Make the character fall
	var collision_shape = get_node_or_null("CollisionShape3D")
	if collision_shape:
		collision_shape.disabled = true

func attack():
	if is_dead or is_attacking:
		return
		
	is_attacking = true
	current_state = "attack"
	
	# Play attack animation
	play_animation("attack")
	
	# Wait for animation to finish
	if animation_player and animation_player.has_animation("attack"):
		await animation_player.animation_finished
	else:
		await get_tree().create_timer(0.5).timeout
	
	is_attacking = false
	
	# Return to idle if not moving
	if current_state == "attack":
		current_state = "idle"
		play_animation("idle")

func play_animation(anim_name: String):
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
	elif animation_player:
		# If the specific animation doesn't exist, try to play a fallback
		match anim_name:
			"die":
				# Fall to the ground
				var tween = create_tween()
				tween.tween_property(self, "rotation_degrees:x", 90, 1.0)
				animation_player.play("idle")
			"attack":
				# Simple attack animation if none exists
				animation_player.play("attack")
			_:
				animation_player.play("idle")
