#!/bin/sh

#data_offset=$((0x$(xxd -plain -s 0x10 -l 4 $1 | sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/')+28))
#channels=$((0x$(xxd -plain -s 0x16 -l 2 $1 | sed 's/\(..\)\(..\)/\2\1/')))
#samples=$((0x$(xxd -plain -s 0x18 -l 4 $1 | sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/')))
#bps=$((0x$(xxd -plain -s 0x22 -l 2 $1 | sed 's/\(..\)\(..\)/\2\1/')))

data=`xxd -plain -s 0x08 -l 28 $1`
offset=$((0x$(echo $data | sed 's/.\{16\}\(..\)\(..\)\(..\)\(..\).\{32\}/\4\3\2\1/')+28))
dd if=$1 skip=1 bs=$offset 2>/dev/null
shift

for f in $@; do
	tmpdata=`xxd -plain -s 0x08 -l 28 $f`
	if [ "$data" != "$tmpdata" ]; then
		echo not matching wav properties for $f >&2
		exit
	fi
	dd if=$f skip=1 bs=$offset 2>/dev/null
done
