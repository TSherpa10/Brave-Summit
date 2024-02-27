extends Node
@onready var points_label = %PointsLabel
@onready var melon_2d = $"../GUI/Container/AnimatedSprite2D"

var points = 0

func add_point():
	points += 1
	print(points)
	melon_2d.play("collect")
	points_label.text = "x " + str(points)
	await melon_2d.animation_finished
	melon_2d.play("default")
