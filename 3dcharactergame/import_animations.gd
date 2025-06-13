extends Node

# This script helps import animations from separate FBX files
# Attach this to a node in your scene and call it from _ready()

func import_animations():
	var animation_player = $AnimationPlayer
	if not animation_player:
		print("Animation player not found")
		return
		
	# Import idle animation
	var idle_scene = load("res://assets/characters/hero/Hero_Idle.fbx")
	if idle_scene:
		var idle_anim_player = idle_scene.instance().get_node("AnimationPlayer")
		if idle_anim_player and idle_anim_player.has_animation("idle"):
			var idle_anim = idle_anim_player.get_animation("idle")
			animation_player.add_animation("idle", idle_anim)
	
	# Import walk animation
	var walk_scene = load("res://assets/characters/hero/Hero_Walk.fbx")
	if walk_scene:
		var walk_anim_player = walk_scene.instance().get_node("AnimationPlayer")
		if walk_anim_player and walk_anim_player.has_animation("walk"):
			var walk_anim = walk_anim_player.get_animation("walk")
			animation_player.add_animation("walk", walk_anim)
	
	# Import attack animation
	var attack_scene = load("res://assets/characters/hero/Hero_Attack.fbx")
	if attack_scene:
		var attack_anim_player = attack_scene.instance().get_node("AnimationPlayer")
		if attack_anim_player and attack_anim_player.has_animation("attack"):
			var attack_anim = attack_anim_player.get_animation("attack")
			animation_player.add_animation("attack", attack_anim)