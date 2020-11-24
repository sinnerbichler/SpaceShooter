extends Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	get_viewport().warp_mouse(get_viewport().size / 2)



func _process(_delta):
	if Input.is_action_pressed("pause"):
		get_tree().quit()
	if Input.is_action_pressed("ui_down"):
		pass
