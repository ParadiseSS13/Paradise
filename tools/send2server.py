#
# This is now deprecated as of 2021-05-15
#
# Script to send world/Topic announcements to a server via automated tooling
# Author: AffectedArc07
# Takes a message as command line argument
# Example: python send2server.py "This is a message that will be sent to the server"
import socket, struct, urllib.parse, sys

message = sys.argv[1]
commskey = "YOURKEYHERE"

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
cmd = "?hostannounce&key={}&message={}".format(urllib.parse.quote(commskey), urllib.parse.quote(message))
query = b"\x00\x83" + struct.pack('>H', len(cmd) + 6) + b"\x00\x00\x00\x00\x00" + cmd.encode() + b"\x00"
sock.connect(("localhost", 6666))
sock.sendall(query)
