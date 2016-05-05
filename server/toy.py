import json
import gevent
import random
from gevent.event import Event
from gevent.server import StreamServer

        
    
class User(object):
    name = "Unknown"
    last_user_id = 1
    
    def __init__(self, sock):
        self.sock = sock
        self.opponent = None
        self.user_id = User.last_user_id
        self.ready = False
        User.last_user_id += 1
        
    def serve(self):
        self.send_msg("info", self.user_id)
        self.find_opponent()
        
        packets = ""
        while True:
            data = self.sock.recv(1024)
            if (data == ""):
                self.sock.close()
                users.remove(self)
                print "Disconnected"
                break
            packets += data
            packets = packets.strip("\n\r")
            if packets.endswith("}"):
                self.process_packets(packets)
                packets = ""
    
    def send(self, msg):
        packet = json.dumps(msg)
        print "%s -> %s" % (self.user_id, packet)
        self.sock.send(packet + "\n\n")
        
    def send_msg(self, msg, *args):
        self.send({"err":None, "msg": msg, "args": args})
    
    def send_err(self, err):
        self.send({"err":err})
        
    def process_packets(self, packets):
        for packet in packets.split("\n\n"):
	    "%s <- %s" % (self.user_id, packet)
            try:
                msg = json.loads(packet)
                action = "handle_" + msg["msg"]
                print "[debug] executing action " + action 
                if "args" not in msg:
                    msg["args"] = []
                args = msg["args"]
                if "broadcast" in msg:
                    if self.opponent != None:
                        self.opponent.send_msg(msg["msg"], *msg["args"])
                else:
                    getattr(self, action)(*args)
            except Exception as e:
                self.send_err(repr(e))
                
    def find_opponent(self):
        for user in users:
            if user == self:
                continue
            if user.opponent == None:
                user.opponent = self
                self.opponent = user
                self.send_msg("opponent_info", user.user_id)
                user.send_msg("opponent_info", self.user_id)               
        
    def handle_ready(self):
        self.ready = True
        if self.opponent.ready:
            self.side = random.choice(["Radiant", "Dire"])
            if self.side == "Radiant":
                self.opponent.side = "Dire"
            else:
                self.opponent.side = "Radiant"

            self.send_msg("start_game", self.side)
            self.opponent.send_msg("start_game", self.opponent.side)
        
        

       
    
        
def handle(sock, addr):
    user = User(sock)
    users.append(user)
    user.serve()
    
    

users = []
rooms = []
server = StreamServer(('0.0.0.0', 1234), handle)
server.serve_forever()

