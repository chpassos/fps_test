extends PanelContainer

var _frames_per_second: String

@onready var property_container = %VBoxContainer

func _ready():
	
	# Set global reference to self in Global Autoload Singleton
	Global.debug = self
	
	visible = false

func _input(event):
	if event.is_action_pressed("debug"):
		visible = !visible


func add_property(title: String, value, order):
	var target
	target = property_container.find_child(title, true, false)
	if !target:
		target = Label.new()
		property_container.add_child(target)
		target.name = title
		target.text = target.name + ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value)
		property_container.move_child(target, order)

func _process(delta):
	_frames_per_second = "%.2f" % (1.0/delta)
	
	Global.debug.add_property("FPS", _frames_per_second, 1)
	#property.text = property.name + ":" + _frames_per_second
	
	
