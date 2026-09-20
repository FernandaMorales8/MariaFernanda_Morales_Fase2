extends Node
@export var mob_scene: PackedScene
var score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD.invincible_pressed.connect($Player.activate_invincibility)
	$Player.cooldown_updated.connect(_on_player_cooldown_updated)
	$Player.invincibility_started.connect(_on_player_invincibility_started)
	$Player.invincibility_ended.connect(_on_player_invincibility_ended)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_cooldown_updated(time_left: float, total_cooldown: float) -> void:
	$HUD.update_invincible_status($Player.is_invincible, time_left, total_cooldown)


func _on_player_invincibility_started() -> void:
	$HUD.update_invincible_status(true, $Player.cooldown_time_left, $Player.invincibility_cooldown)


func _on_player_invincibility_ended() -> void:
	$HUD.update_invincible_status(false, $Player.cooldown_time_left, $Player.invincibility_cooldown)


func game_over() -> void:
	$DeathSound.play()
	$Music.stop()
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$HUD.hide_invincible_button()

func new_game():
	get_tree().call_group("mobs", "queue_free")
	$Music.play()
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$HUD.show_invincible_button()
	


func _on_mob_timer_timeout() -> void:
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	mob.add_to_group("mobs")


func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
