extends CanvasLayer
# Notifies `Main` node that the button has been pressed
signal start_game
signal invincible_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if has_node("InvincibleButton"):
		$InvincibleButton.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over():
	hide_invincible_button()
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Dodge the Slimes!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func update_score(score):
	$ScoreLabel.text = str(score)


func show_invincible_button():
	if has_node("InvincibleButton"):
		$InvincibleButton.show()
		$InvincibleButton.disabled = false
		$InvincibleButton.text = "SHIELD [Space]"


func hide_invincible_button():
	if has_node("InvincibleButton"):
		$InvincibleButton.hide()


func update_invincible_status(is_active: bool, cooldown_left: float, _total_cooldown: float = 15.0):
	if not has_node("InvincibleButton"):
		return
	if is_active:
		$InvincibleButton.disabled = true
		$InvincibleButton.text = "ACTIVE!"
	elif cooldown_left > 0.0:
		$InvincibleButton.disabled = true
		$InvincibleButton.text = "Cooldown: %d s" % int(ceil(cooldown_left))
	else:
		$InvincibleButton.disabled = false
		$InvincibleButton.text = "SHIELD [Space]"


func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()


func _on_invincible_button_pressed() -> void:
	invincible_pressed.emit()


func _on_message_timer_timeout() -> void:
	$Message.hide()
