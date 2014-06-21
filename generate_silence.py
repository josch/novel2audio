#!/usr/bin/python

from struct import pack
from sys import stdout

duration = 1    # seconds of silence
channels = 1    # number of channels
bps = 16        # bits per sample
sample = 44100  # sample rate
ExtraParamSize = 0
Subchunk1Size = 16+2+ExtraParamSize
Subchunk2Size = duration*sample*channels*bps/8
ChunkSize = 4 + (8 + Subchunk1Size) + (8 + Subchunk2Size)

stdout.write("".join([
    'RIFF',                                # ChunkID (magic)      # 0x00
    pack('<I', ChunkSize),                 # ChunkSize            # 0x04
    'WAVE',                                # Format               # 0x08
    'fmt ',                                # Subchunk1ID          # 0x0c
    pack('<I', Subchunk1Size),             # Subchunk1Size        # 0x10
    pack('<H', 1),                         # AudioFormat (1=PCM)  # 0x14
    pack('<H', channels),                  # NumChannels          # 0x16
    pack('<I', sample),                    # SampleRate           # 0x18
    pack('<I', bps/8 * channels * sample), # ByteRate             # 0x1c
    pack('<H', bps/8 * channels),          # BlockAlign           # 0x20
    pack('<H', bps),                       # BitsPerSample        # 0x22
    pack('<H', ExtraParamSize),            # ExtraParamSize       # 0x22
    'data',                                # Subchunk2ID          # 0x24
    pack('<I', Subchunk2Size),             # Subchunk2Size        # 0x28
    '\0'*Subchunk2Size
]))
