extends PanelContainer

var property
var _frames_per_second: String

@onready var property_container = %VBoxContainer

func _ready():
	visible = false
	
	_add_debug_property("FPS", _frames_per_second)

func _input(event):
	if event.is_action_pressed("debug"):
		visible = !visible

func _add_debug_property(title: String, value):
	property = Label.new() #Create new Label Node
	property_container.add_child(property) # Add new node as child to VBox container
	property.name = title # Set name to title
	property.text = property.name + value

func _process(delta):
	_frames_per_second = "%.2f" % (1.0/delta)
	property.text = property.name + ":" + _frames_per_second
	
	
