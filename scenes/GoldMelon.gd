extends Area2D
@onready var game_manager = %GameManager
@onready var gold_melon_sprite = $GoldMelonSprite

func _on_body_entered(body):
	if (body.name == "CharacterBody2D"):
		gold_melon_sprite.play("collect")
		game_manager.add_gold_point()
		await gold_melon_sprite.animation_finished
		queue_free()
