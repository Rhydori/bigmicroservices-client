extends Node

var tcp : StreamPeerTCP
const server_ip := "127.0.0.1"
const tcp_port := 2121

var last_status = null
signal tcp_data(data)
signal system_chat(system)

func _ready() -> void:
	connect_tcp()

func _physics_process(_delta: float) -> void:
	tcp_status()
	receive_data()

func connect_tcp() -> void:
	tcp = StreamPeerTCP.new()
	tcp.connect_to_host(server_ip, tcp_port)

func tcp_status() -> void:
	tcp.poll()
	var current_status = tcp.get_status()
	if current_status != last_status:
		last_status = current_status
		match current_status:
			tcp.STATUS_NONE:
				emit_signal("system_chat", "Disconnected from: %s:%s" % [server_ip, tcp_port])
			tcp.STATUS_CONNECTING:
				emit_signal("system_chat", "Connecting to: %s:%s" % [server_ip, tcp_port])
			tcp.STATUS_CONNECTED:
				emit_signal("system_chat", "Connected to: %s:%s" % [server_ip, tcp_port])
			tcp.STATUS_ERROR:
				emit_signal("system_chat", "Error connecting to: %s:%s" % [server_ip, tcp_port])

func send_data(data) -> void:
	if tcp.get_status() == tcp.STATUS_CONNECTED:
		tcp.put_data(data.to_utf8_buffer())

func receive_data() -> void:
	var data : PackedByteArray
	if tcp.get_status() == tcp.STATUS_CONNECTED:
		while tcp.get_available_bytes() > 0:
			var chunk = tcp.get_data(tcp.get_available_bytes())[1] 
			data.append_array(chunk)
			emit_signal("tcp_data", data)
