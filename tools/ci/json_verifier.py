import sys
if sys.argv[1:2] == ["-5"]:
    import json5 as json
    sys.argv.pop(1)
else:
    import json

if len(sys.argv) <= 1:
    exit(1)

status = 0

for file in sys.argv[1:]:
    with open(file, encoding="ISO-8859-1") as f:
        try:
            json.load(f)
        except ValueError as exception:
            print("JSON error in {}".format(file))
            print(exception)
            status = 1
        else:
            print("Valid {}".format(file))

exit(status)
