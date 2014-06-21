#!/bin/sh

[ $(dd if=$1 skip=0 bs=1 count=4 2>/dev/null) = "RIFF" ] && \
[ $(dd if=$1 skip=8 bs=1 count=4 2>/dev/null) = "WAVE" ] && \
[ "$((0x$(xxd -plain -s 0x14 -l 2 $1 | sed 's/\(..\)\(..\)/\2\1/')))" -eq 1 ] && \
echo valid || echo invalid

echo start of data: $((0x$(xxd -plain -s 0x10 -l 4 $1 | sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/')+28))
echo number of channels: $((0x$(xxd -plain -s 0x16 -l 2 $1 | sed 's/\(..\)\(..\)/\2\1/')))
echo sample rate: $((0x$(xxd -plain -s 0x18 -l 4 $1 | sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/')))
echo bits per sample: $((0x$(xxd -plain -s 0x22 -l 2 $1 | sed 's/\(..\)\(..\)/\2\1/')))
