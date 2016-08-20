#!/usr/bin/env python

import random
import socket
import sys
import time

sentences = ["the cow jumped over the moon",
             "an apple a day keeps the doctor away",
             "four score and seven years ago",
             "snow white and the seven dwarfs",
             "i am at two with nature"]

delay = float(sys.argv[1])
hostname = sys.argv[2]
port = int(sys.argv[3])

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind((hostname, port))
s.listen(1)
conn, addr = s.accept()
while True:
    sentence = random.choice(sentences)
    conn.send(sentence + '\n')
    #print sentence
    time.sleep(delay)
s.close()
