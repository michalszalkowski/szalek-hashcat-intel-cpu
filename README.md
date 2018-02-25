--------------------------------

docker build -t szalek/hashcat-intel-cpu .

--------------------------------

docker run -it szalek/hashcat-intel-cpu

--------------------------------

# hashcat
- hashcat --help
- hashcat -O -a 0 -m 110 pass.txt /usr/share/wordlists/rockyou.txt --show


# pass.txt - hash:salt
41f26dc8435d1f633b1a3c4a30a0d882f645d5a6:szalek