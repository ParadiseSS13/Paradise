import time, threading, redis

sent_messages = 0
received_messages = 0

R = redis.Redis("10.0.0.10")

def recieve_loop():
    print("Running rloop")
    global R, received_messages
    PS = R.pubsub()
    PS.subscribe("aa07.debug.in")

    while True:
        message = PS.get_message()
        if message is not None:
            received_messages += 1
            print(message)
        time.sleep(1)

def send_loop():
    print("Running sloop")
    global R, sent_messages
    while True:
        R.publish("aa07.debug.out", "Ping")
        sent_messages += 1
        time.sleep(30)

def record_counters():
    print("Running lloop")
    global sent_messages, received_messages
    while True:
        print("Sent: {}".format(sent_messages))
        print("Receievd: {}".format(received_messages))
        time.sleep(300)

# Main
if __name__ == "__main__":
    rthread = threading.Thread(target=recieve_loop, daemon=True)
    sthread = threading.Thread(target=send_loop, daemon=True)
    lthread = threading.Thread(target=record_counters, daemon=True)
    rthread.start()
    sthread.start()
    lthread.start()
    input("Press enter to kill")
