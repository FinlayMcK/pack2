extends Control

@export var card_image: Texture2D
@export var card_rarity: String
var card_level: int = 1
var card_count: int = 0
@export var card_id: String
@export var card_elixir: String

@onready var image = $Image
@onready var level_label = $Level
@onready var elixir_label = $Elixir

func _ready() -> void:
	if image:
		image.texture = card_image
	if elixir_label:
		elixir_label.text = card_elixir
