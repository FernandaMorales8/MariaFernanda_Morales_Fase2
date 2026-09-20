extends Area2D
signal hit
signal invincibility_started
signal invincibility_ended
signal cooldown_updated(time_left: float, total_cooldown: float)

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var invincibility_duration: float = 2.0
@export var invincibility_cooldown: float = 15.0

var screen_size: Vector2 = Vector2(480, 720) # Size of the game window.
var is_invincible: bool = false
var invincibility_time_left: float = 0.0
var cooldown_time_left: float = 0.0
var is_alive: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"

	# Check for ability input (Space or shortcut)
	if Input.is_action_just_pressed("invincible"):
		activate_invincibility()

	# Handle invincibility timer and visual effect
	if is_invincible:
		invincibility_time_left -= delta
		# Visual blinking / pulsing effect: flashing alpha and cyan tint
		var flash = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.03)
		modulate = Color(0.6 + 0.4 * flash, 0.9 + 0.1 * flash, 1.0, 0.4 + 0.6 * flash)
		
		if invincibility_time_left <= 0.0:
			is_invincible = false
			invincibility_time_left = 0.0
			modulate = Color.WHITE
			cooldown_time_left = invincibility_cooldown
			invincibility_ended.emit()
			cooldown_updated.emit(cooldown_time_left, invincibility_cooldown)
			
			# If any mob is still overlapping when invincibility ends, player gets hit
			if is_alive:
				var overlapping = get_overlapping_bodies()
				if overlapping.size() > 0:
					_on_body_entered(overlapping[0])

	# Handle cooldown timer (runs after invincibility ends)
	elif cooldown_time_left > 0.0:
		cooldown_time_left = max(0.0, cooldown_time_left - delta)
		cooldown_updated.emit(cooldown_time_left, invincibility_cooldown)


func activate_invincibility() -> bool:
	if not is_alive or cooldown_time_left > 0.0 or is_invincible:
		return false
	is_invincible = true
	invincibility_time_left = invincibility_duration
	invincibility_started.emit()
	return true


func reset_invincibility() -> void:
	is_invincible = false
	invincibility_time_left = 0.0
	cooldown_time_left = 0.0
	modulate = Color.WHITE
	cooldown_updated.emit(0.0, invincibility_cooldown)
	invincibility_ended.emit()


func _on_body_entered(body: Node2D) -> void:
	if is_invincible:
		return
	is_alive = false
	is_invincible = false
	modulate = Color.WHITE
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	is_alive = true
	reset_invincibility()
