extends Control

@onready var systemLog := %systemLog
@onready var chatLog := %chatLog
@onready var inputPanel := %inputPanel
@onready var channelLabel := %channelLabel
@onready var inputField := %inputField

var groups = [
	{'channel': 'Global', 'color': '#ffb050'},
	{'channel': 'Whisper', 'color': '#ac69c8'}
]
var group_index = 0

func _ready() -> void:
	Conn.connect("system_chat", receive_system)
	Conn.connect("tcp_data", receive_chat)
	inputField.connect("text_submitted", send_message)
	change_group(0)

func _physics_process(_delta: float) -> void:
	await get_tree().process_frame
	chatLog.get_v_scroll_bar().visible = false

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER and %Chat.visible == false:
			%Chat.show()
			inputField.call_deferred('grab_focus')
		elif event.keycode == KEY_ENTER and %Chat.visible == true and inputField.text == '':
			inputField.call_deferred('release_focus')
			%Chat.hide()
		elif event.keycode == KEY_TAB:
			change_group(1)

func change_group(value):
	group_index += value
	if group_index > (groups.size() - 1):
		group_index = 0
	channelLabel.text = '[' + groups[group_index]['channel'] + ']:'
	channelLabel.add_theme_color_override("font_color", Color(groups[group_index]['color']))

func receive_system(data: String) -> void:
	chatLog.push_color('ffec6e')
	chatLog.append_text(data + '\n')
	chatLog.pop()

func receive_chat(data: PackedByteArray) -> void:
	var msg = data.get_string_from_utf8()
	chatLog.append_text(msg + '\n')

func send_message(text):
	Conn.send_data(text)
	inputField.text = ''
