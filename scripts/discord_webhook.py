try:
    import requests # Make sure requests is installed
except Exception:
    log = open("ERROR.txt", "w")
    log.write("Requests is not installed, and is required to send discord webhook messages")
    log.close()
    exit()
import sys

# Arg 0 is the script name itself (discord_webhook.py)
scriptname = sys.argv[0] # This exists so that the script name wont get sent in the final
url = sys.argv[1] # First entry
message = ""
for item in sys.argv:
    if item == scriptname or item == url:
        pass
    else:
        message += str(item) + " "

requests.post(url, ("{\"content\": \""+str(message)+"\"}"), headers={"Content-Type": "application/json"})
