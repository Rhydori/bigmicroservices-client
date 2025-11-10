extends Node

var tcp : StreamPeerTCP
const server_ip := "127.0.0.1"
const tcp_port := 8080

var bytes : PackedByteArray

var received_data : int

func _ready() -> void:
	connect_tcp()

func _physics_process(_delta: float) -> void:
	tcp_poll()
	receive_data()

func connect_tcp() -> void:
	tcp = StreamPeerTCP.new()
	tcp.connect_to_host(server_ip, tcp_port)
	if tcp.get_status() == tcp.STATUS_CONNECTED:
		print("Connected to %s", server_ip)

func tcp_poll() -> void:
	tcp.poll()
	if tcp.get_status() != tcp.STATUS_CONNECTED:
		connect_tcp()

func send_data(data) -> void:
	if tcp.get_status() == tcp.STATUS_CONNECTED:
		bytes = data.to_utf8_buffer()
		tcp.put_data(bytes)

func receive_data() -> void:
	if tcp.get_status() == tcp.STATUS_CONNECTED:
		while tcp.get_available_bytes() > 0:
			var data = tcp.get_data(tcp.get_available_bytes())[1]
			print(data.get_string_from_utf8())
