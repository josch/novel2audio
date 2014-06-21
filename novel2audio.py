#!/usr/bin/python
# -*- coding: utf-8 -*-

from re import split, sub
from sys import argv
from os import getcwd

f = open(argv[1], "r")

stuff = list()

pagenum = 1

for line in f:
    if line == "%d\n"%pagenum:
        pagenum+=1
    elif line.strip() != "":
        stuff.append(line.strip()) # replace newlines with spaces

stuff = " ".join(stuff)
stuff = sub(r"(\d)\s(\d)", r"\1\2", stuff) # remove whitespaces between digits
stuff = stuff.replace("'", "'\"'\"'")

stuff = split(r"(».+?«)", stuff)
if len(stuff) == 1:
    stuff = split(r"(„.+?“)", stuff[0])
    if len(stuff) == 1:
        stuff = split(r"(\".+?\")", stuff[0])
        if len(stuff) == 1:
            print "can't split"
            exit(1)

processes = list()

tempdir="/dev/shm"
cwd=getcwd()

i = 0
for s in stuff:
    s = s.strip(', ')

    if len(s) == 0:
        continue

    if s.startswith('»') and s.endswith('«') or s.startswith('„') and s.endswith('“') or s.startswith('"') and s.endswith('"'):
        print "wine sapi2wav.exe %s/%04d.wav 3 -t '%s'"%(tempdir, i, s)
    else:
        print "wine sapi2wav.exe %s/%04d.wav 2 -t '%s'"%(tempdir, i, s)

    i+=1
    print "ln -s %s/silence.wav %s/%04d.wav"%(cwd,tempdir,i)
    i+=1


#python novel2audio.py novel.txt | ./parallel.sh
#./concatenate_wav.sh [0-9]*.wav | python stride.py | oggenc --quality 0 --raw --raw-bits 16 --raw-chan 1 --raw-rate 22050 - > out.ogg
#./concatenate_wav.sh [0-9]*.wav | python stride.py | sox --type raw --rate 22050 --encoding signed-integer --bits 16 --channels 1 - --rate 22050 --comment "" --compression 0 out.ogg tempo -s 2.0

# the stride of 2 is used because the bytes in the input wav
# files are of the form ABABCDCDEFEFGHGH
# since the input is 44100Hz, remove every 2nd byte tuple and output 22050Hz
# sox can also downsample but it easily converts
# 00000000 to 0100 or to FFFF
# using ./stride is also twice as fast as having sox do the downsampling

#sudo mount -o remount,size=1200M /dev/shm
#rm -rf /dev/shm/[0-9]*.wav
#for f in ../Perry\ Rhodan\ Ebook\ Sammlung\ Komplett/txt/Perry\ Rhodan\ -\ Romanzyklus\ -\ 0300-0399\ -\ M\ 87/<365-399>*; do
#   cat "$f" | tr '»' '"' | tr '«' '"' | tr "'" '"' > /tmp/out
#   python novel2audio.py "/tmp/out" | /usr/bin/time xargs --delimiter='\n' --max-args=1 --max-procs=4 -I '{}' sh -c '{} > /dev/null'
#   ./concatenate_wav /dev/shm/[0-9]*.wav | ./stride | sox --show-progress --type raw --rate 22050 --encoding signed-integer --bits 16 --channels 1 - --rate 22050 --comment "" --compression 0 "`basename \"$f\" .txt`.ogg" tempo -s 2.0
#   rm /dev/shm/[0-9]*.wav
#done
