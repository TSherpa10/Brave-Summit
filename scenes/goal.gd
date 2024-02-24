extends Area2D
@onready var game_manager = %GameManager
@onready var animation = $AnimatedSprite2D




func _on_body_entered(body):
	if (body.name == "CharacterBody2D"):
		animation.play("goal")
		# do more logic later, ie cutscene to next level or main screen?
