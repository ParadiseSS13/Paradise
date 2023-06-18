import argparse
import ctypes
import socket
import selectors
import lz4.stream

# file protocol
FileSignature = 0x6D64796361727475
FileVersion = 2
FileEventZoneBegin =15
FileEventZoneEnd = 17
FileEventZoneColor = 62
FileEventFrameMark = 64

class FileHeader(ctypes.Structure):
	_fields_ = (
		("signature", ctypes.c_ulonglong),
		("version", ctypes.c_uint),
		("multiplier", ctypes.c_double),
		("init_begin", ctypes.c_longlong),
		("init_end", ctypes.c_longlong),
		("delay", ctypes.c_longlong),
		("resolution", ctypes.c_longlong),
		("epoch", ctypes.c_longlong),
		("exec_time", ctypes.c_longlong),
		("pid", ctypes.c_longlong),
		("sampling_period", ctypes.c_longlong),
		("flags", ctypes.c_byte),
		("cpu_arch", ctypes.c_byte),
		("cpu_manufacturer", ctypes.c_char * 12),
		("cpu_id", ctypes.c_uint),
		("program_name", ctypes.c_char * 64),
		("host_info", ctypes.c_char * 1024)
	)

class FileZoneBegin(ctypes.Structure):
	_fields_ = (
		("tid", ctypes.c_uint32),
		("srcloc", ctypes.c_uint32),
		("timestamp", ctypes.c_int64)
	)

class FileZoneEnd(ctypes.Structure):
	_fields_ = (
		("tid", ctypes.c_uint32),
		("timestamp", ctypes.c_int64)
	)

class FileZoneColor(ctypes.Structure):
	_fields_ = (
		("tid", ctypes.c_uint32),
		("color", ctypes.c_uint32)
	)

class FileFrameMark(ctypes.Structure):
	_fields_ = (
		("name", ctypes.c_uint32),
		("timestamp", ctypes.c_int64)
	)

class FileEvent(ctypes.Structure):
	class Events(ctypes.Union):
		_fields_ = (
			("zone_begin", FileZoneBegin),
			("zone_end", FileZoneEnd),
			("zone_color", FileZoneColor),
			("frame_mark", FileFrameMark),
		)

	_anonymous_ = ("event",)
	_fields_ = (
		("type", ctypes.c_byte),
		("event", Events)
	)

# network protocol
NetworkMaxFrameSize = 256 * 1024
NetworkHandshakeWelcome = b"\x01"
NetworkHandshakeProtocolMismatch = b"\x02"
NetworkEventZoneBegin = 15
NetworkEventZoneEnd = 17
NetworkEventTerminate = 55
NetworkEventThreadContext = 57
NetworkEventZoneColor = 62
NetworkEventFrameMark = 64
NetworkEventSrcloc = 67
NetworkResponseServerQueryNoop = 87
NetworkResponseSourceCodeNotAvailable = 88
NetworkResponseSymbolCodeNotAvailable = 89
NetworkResponseStringData = 94
NetworkResponseThreadName = 95
NetworkQueryTerminate = 0
NetworkQueryString = 1
NetworkQueryThreadString = 2
NetworkQuerySrcloc = 3
NetworkQueryPlotName = 4
NetworkQueryFrameName = 5
NetworkQueryParameter = 6
NetworkQueryFiberName = 7
NetworkQueryDisconnect = 8
NetworkQueryCallstackFrame = 9
NetworkQueryExternalName = 10
NetworkQuerySymbol = 11
NetworkQuerySymbolCode = 12
NetworkQueryCodeLocation = 13
NetworkQuerySourceCode = 14
NetworkQueryDataTransfer = 15
NetworkQueryDataTransferPart = 16


class NetworkHeader(ctypes.Structure):
	_pack_ = 1
	_fields_ = (
		("multiplier", ctypes.c_double),
		("init_begin", ctypes.c_longlong),
		("init_end", ctypes.c_longlong),
		("delay", ctypes.c_longlong),
		("resolution", ctypes.c_longlong),
		("epoch", ctypes.c_longlong),
		("exec_time", ctypes.c_longlong),
		("pid", ctypes.c_longlong),
		("sampling_period", ctypes.c_longlong),
		("flags", ctypes.c_uint8),
		("cpu_arch", ctypes.c_uint8),
		("cpu_manufacturer", ctypes.c_char * 12),
		("cpu_id", ctypes.c_uint),
		("program_name", ctypes.c_char * 64),
		("host_info", ctypes.c_char * 1024)
	)

class NetworkThreadContext(ctypes.Structure):
	_pack_ = 1
	_fields_ = (
		("type", ctypes.c_uint8),
		("tid", ctypes.c_uint32)
	)

class NetworkZoneBegin(ctypes.Structure):
	_pack_ = 1
	_fields_ = (
		("type", ctypes.c_uint8),
		("timestamp", ctypes.c_int64),
		("srcloc", ctypes.c_uint64)
	)

class NetworkZoneEnd(ctypes.Structure):
	_pack_ = 1
	_fields_ = (
		("type", ctypes.c_uint8),
		("timestamp", ctypes.c_int64)
	)

class NetworkZoneColor(ctypes.Structure):
	_pack_ = 1
	_fields_ = (
		("type", ctypes.c_uint8),
		("r", ctypes.c_uint8),
		("g", ctypes.c_uint8),
		("b", ctypes.c_uint8)
	)

class NetworkFrameMark(ctypes.Structure):
	_pack_ = 1
	_fields_ = (
		("type", ctypes.c_uint8),
		("timestamp", ctypes.c_int64),
		("name", ctypes.c_uint64)
	)

class NetworkSrcloc(ctypes.Structure):
	_pack_ = 1
	_fields_ = (
		("type", ctypes.c_uint8),
		("name", ctypes.c_int64),
		("function", ctypes.c_int64),
		("file", ctypes.c_int64),
		("line", ctypes.c_uint32),
		("r", ctypes.c_uint8),
		("g", ctypes.c_uint8),
		("b", ctypes.c_uint8)
	)

class NetworkRequest(ctypes.Structure):
	_pack_ = 1
	_fields_ = (
		("type", ctypes.c_uint8),
		("ptr", ctypes.c_int64),
		("extra", ctypes.c_uint32)
	)

def main(stream):
	def file_read_uint():
		ctype = ctypes.c_uint()
		stream.readinto(ctype)
		return ctype.value

	def file_read_chars(size):
		if 0 == size:
			return None
		ctype = (ctypes.c_char * size)()
		stream.readinto(ctype)
		return ctype.value

	header = FileHeader()
	stream.readinto(header)
	if header.signature != FileSignature:
		print("incorrect signature")
		return

	if header.version != FileVersion:
		print("incorrect version")
		return

	srclocs_len = file_read_uint()
	strings = {}
	srclocs = [None] * srclocs_len

	for i in range(srclocs_len):
		name_len = file_read_uint()
		name = file_read_chars(name_len)
		function_len = file_read_uint()
		function = file_read_chars(function_len)
		file_len = file_read_uint()
		file = file_read_chars(file_len)
		line = file_read_uint()
		color = file_read_uint()

		if name != None:
			digest = hash(name)
			strings[digest] = name
			name = digest
		else:
			name = 0

		if function != None:
			digest = hash(function)
			strings[digest] = function
			function = digest
		else:
			function = 0

		if file != None:
			digest = hash(file)
			strings[digest] = file
			file = digest
		else:
			file = 0

		srclocs[i] = (name, function, file, line, color)

	server = socket.create_server(("127.0.0.1", 8086))
	server.listen(1)
	print("listening on 127.0.0.1:8086...")
	client, addr = server.accept()

	if client.recv(8) != b"TracyPrf":
		print("bad client")
		client.close()
		return

	protocol = ctypes.c_uint()
	client.recv_into(protocol)

	if protocol.value not in (56, 57):
		print("bad protocol")
		client.sendall(NetworkHandshakeProtocolMismatch)
		client.close()
		return

	print(f"client accepted from {addr}")
	client.sendall(NetworkHandshakeWelcome)

	client.sendall(NetworkHeader(
		multiplier = header.multiplier,
		init_begin = header.init_begin,
		init_end = header.init_end,
		delay = header.delay,
		resolution = header.resolution,
		epoch = header.epoch,
		exec_time = header.exec_time,
		pid = header.pid,
		sampling_period = header.sampling_period,
		flags = header.flags,
		cpu_arch = header.cpu_arch,
		cpu_manufacturer = header.cpu_manufacturer,
		cpu_id = header.cpu_id,
		program_name = header.program_name,
		host_info = header.host_info
	))

	event = FileEvent()
	event_sz = ctypes.sizeof(event)
	timestamp = 0
	tid = None
	buffer = bytearray(NetworkMaxFrameSize // event_sz)
	offset = 0
	compressor = lz4.stream.LZ4StreamCompressor(
		"double_buffer",
		NetworkMaxFrameSize,
		store_comp_size = 4
	)

	def commit():
		nonlocal offset
		if offset > 0:
			block = compressor.compress(buffer[:offset])
			client.sendall(block)
			offset = 0

	def write_msg(msg):
		nonlocal offset, buffer
		sz = ctypes.sizeof(msg)
		if offset + sz > len(buffer):
			commit()

		buffer[offset : offset + sz] = msg
		offset += sz

	def thread_context(event):
		nonlocal tid, timestamp
		if event.zone_begin.tid != tid:
			tid = event.zone_begin.tid
			timestamp = 0
			write_msg(NetworkThreadContext(
				type = NetworkEventThreadContext,
				tid = tid
			))

	while event_sz == stream.readinto(event):
		if event.type == FileEventZoneBegin:
			thread_context(event)
			write_msg(NetworkZoneBegin(
				type = NetworkEventZoneBegin,
				timestamp = event.zone_begin.timestamp - timestamp,
				srcloc = event.zone_begin.srcloc
			))
			timestamp = event.zone_begin.timestamp

		elif event.type == FileEventZoneEnd:
			thread_context(event)
			write_msg(NetworkZoneEnd(
				type = NetworkEventZoneEnd,
				timestamp = event.zone_end.timestamp - timestamp
			))
			timestamp = event.zone_end.timestamp

		elif event.type == FileEventZoneColor:
			thread_context(event)
			write_msg(NetworkZoneColor(
				type = NetworkEventZoneColor,
				r = (event.zone_color.color >> 0x00) & 0xFF,
				g = (event.zone_color.color >> 0x08) & 0xFF,
				b = (event.zone_color.color >> 0x10) & 0xFF
			))

		elif event.type == FileEventFrameMark:
			write_msg(NetworkFrameMark(
				type = NetworkEventFrameMark,
				name = 0,
				timestamp = event.frame_mark.timestamp
			))

	commit()

	def respond_string(string, ptr, type):
		string_sz = len(string)

		class NetworkStringData(ctypes.Structure):
			_pack_ = 1
			_fields_ = (
				("type", ctypes.c_uint8),
				("ptr", ctypes.c_uint64),
				("len", ctypes.c_uint16),
				("str", ctypes.c_char * string_sz)
			)

		write_msg(NetworkStringData(
			type = type,
			ptr = req.ptr,
			len = string_sz,
			str = string
		))

	req = NetworkRequest()
	client.settimeout(1)

	try:
		while ctypes.sizeof(req) == client.recv_into(req):
			if req.type == NetworkQuerySrcloc:
				srcloc = srclocs[req.ptr]
				write_msg(NetworkSrcloc(
					type = NetworkEventSrcloc,
					name = srcloc[0],
					function = srcloc[1],
					file = srcloc[2],
					line = srcloc[3],
					r = (srcloc[4] >> 0x00) & 0xFF,
					g = (srcloc[4] >> 0x08) & 0xFF,
					b = (srcloc[4] >> 0x10) & 0xFF
				))

			elif req.type == NetworkQueryString:
				respond_string(strings[req.ptr], req.ptr, NetworkResponseStringData)

			elif req.type == NetworkQuerySymbolCode:
				write_msg(ctypes.c_uint8(NetworkResponseSymbolCodeNotAvailable))

			elif req.type == NetworkQuerySourceCode:
				write_msg(ctypes.c_uint8(NetworkResponseSourceCodeNotAvailable))

			elif req.type == NetworkQueryDataTransfer:
				write_msg(ctypes.c_uint8(NetworkResponseServerQueryNoop))

			elif req.type == NetworkQueryDataTransferPart:
				write_msg(ctypes.c_uint8(NetworkResponseServerQueryNoop))

			elif req.type == NetworkQueryThreadString:
				respond_string(b"main", req.ptr, NetworkResponseThreadName)

			else:
				print("unknown req:", req.type)

			commit()

	except socket.timeout:
		pass

if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument("file", type=argparse.FileType("rb"))
	args = parser.parse_args()
	main(args.file)
