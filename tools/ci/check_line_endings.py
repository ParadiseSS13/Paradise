
#!/usr/bin/env python

import os
import sys
import glob

WINDOWS_NEWLINE = b'\r\n'

FILES_TO_READ = []
FILES_TO_READ.extend(glob.glob(r"**/*.dm", recursive=True))
FILES_TO_READ.extend(glob.glob(r"**/*.dmm", recursive=True))
FILES_TO_READ.extend(glob.glob(r"*.dme"))
#for i in FILES_TO_READ:
#	if os.path.isdir(i):
#		FILES_TO_READ.remove(i)


def _reader(filepath):
	data = open(filepath, "rb")
	return data


def main():
	filelist = []
	foundfiles = False

	for file in FILES_TO_READ:
		data = _reader(file)
		lines = data.readlines()
		for line in lines:
			if line.endswith(WINDOWS_NEWLINE):
				filelist.append(file)
				foundfiles = True
				break
		data.close()

	if not foundfiles:
		print("No CRLF files found.")
		sys.exit(0)
	else:
		print("Found files with suspected CRLF type.")
		for i in filelist:
			print(i)
		sys.exit(1)


if __name__ == "__main__":
	main()
