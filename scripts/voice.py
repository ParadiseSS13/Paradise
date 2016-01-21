#!/usr/bin/env python2
'''
WINDOWS ONLY!
You need espeak: http://sourceforge.net/projects/espeak/files/espeak/espeak-1.47/espeak-1.47.11-win.zip/download
SOund eXchange (sox): http://sourceforge.net/projects/sox/files/sox/14.4.1/sox-14.4.1a-win32.zip/download
and WinVorbis for OggEnc: http://winvorbis.stationplaylist.com/WinVorbisSetup.exe
'''
import sys, os, re, string
from subprocess import call
accent = sys.argv[1]
voice = sys.argv[2]
pitch = sys.argv[3]
echo = sys.argv[4]
speed = sys.argv[5]
text = sys.argv[6]
ckey = sys.argv[7]
espeakpath = "C:/Program Files (x86)/eSpeak/command_line/"
playervoicespath = "Z:/Git/Space Station 13/Baystation12/sound/playervoices/"
soxpath = "C:/Program Files (x86)/sox-14-4-1/"
oggencpath = "C:/Program Files (x86)/WinVorbis/"
text = string.replace(text, "39", "'")
command = "\""+espeakpath+"espeak.exe\" -w \""+playervoicespath+""+ckey+"u.wav\" -v"+accent+""+voice+" \""+text+"\" -p "+pitch+" -s "+speed+" -a 100"
# First we make the voice file, sounds/playervoice/keyu.wav
print(command)
call(command, shell=True)
command2 = "\""+soxpath+"sox.exe\" \""+playervoicespath+""+ckey+"u.wav\" \""+playervoicespath+""+ckey+".wav\" echo 1 0.5 "+echo+" .5"
print(command2)
# Now we apply effects to it, like echo (there's lots of other effects too)
call(command2, shell=True)
command3 = "\""+oggencpath+"OggEnc.exe\" \""+playervoicespath+""+ckey+".wav\""
#Now we turn key.wav into key.ogg to reduce bandwidth
call(command3, shell=True)
#delete the wav
os.remove(playervoicespath+""+ckey+"u.wav")
os.remove(playervoicespath+""+ckey+".wav")
sys.exit()