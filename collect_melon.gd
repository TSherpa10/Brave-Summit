extends Area2D
@onready var game_manager = %GameManager
@onready var animation = $AnimatedSprite2D

func _on_body_entered(body):
	if (body.name == "CharacterBody2D"):
		animation.play("collect") # non-looping collect animation.
		game_manager.add_point()
		await animation.animation_finished
		queue_free()
