extends Node
@onready var points_label_1 = %PointsLabel1
@onready var points_label_2 = %PointsLabel2
@onready var melon_2d = $"../GUI/Container/AnimatedSprite2D"
@onready var gold_melon_2d = $"../GUI/Container/AnimatedSprite2DGold"

var points = 0
var gold_points = 0

func add_point():
	points += 1
	print(points)
	melon_2d.play("collect")
	points_label_1.text = "x " + str(points)
	await melon_2d.animation_finished
	melon_2d.play("default")

func add_gold_point():
	gold_points += 1
	print(gold_points)
	gold_melon_2d.play("collect")
	points_label_2.text = "x " + str(gold_points)
	await gold_melon_2d.animation_finished
	gold_melon_2d.play("default")
