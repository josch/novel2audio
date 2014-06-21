turn a perry rhodan epub from beam-ebooks into an audio file using ivona voices

install wine and set the windows version to windows 98

install sapi 5.1:

	$ wine start sapi51.msi

install vc2005

	$ ./winetricks vcrun2005

install voices

	$ wine ivona2_installer_pak_hans_marlene.exe

run epub2audio

	epub2audio.py Perry_Rhodan-Paket_12_Der_Schwarm_Teil_2__Die_Altmutanten_12.epub 0570
