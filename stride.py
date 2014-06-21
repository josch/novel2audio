from sys import stdin, stdout

i = 0
while True:
    data = stdin.read(2)
    if not data:
        break

    if i%2 == 0:
        stdout.write(data)

    i+=1
