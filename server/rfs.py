import gevent
import os
import os.path
from struct import pack, unpack
from gevent.server import StreamServer

OK                          = 0
FAILED                      = 1 # Generic fail error
ERR_UNAVAILABLE             = 2 # What is requested is unsupported/unavailable
ERR_UNCONFIGURED            = 3 # The object being used hasnt been properly set up yet
ERR_UNAUTHORIZED            = 4 # Missing credentials for requested resource
ERR_PARAMETER_RANGE_ERRORi  = 5 # Parameter given out of range (5)
ERR_OUT_OF_MEMORY           = 6 # Out of memory
ERR_FILE_NOT_FOUND          = 7 
ERR_FILE_BAD_DRIVE          = 8
ERR_FILE_BAD_PATH           = 9
ERR_FILE_NO_PERMISSION      = 10
ERR_FILE_ALREADY_IN_USE     = 11
ERR_FILE_CANT_OPEN          = 12
ERR_FILE_CANT_WRITE         = 13
ERR_FILE_CANT_READ          = 14
ERR_FILE_UNRECOGNIZED       = 15
ERR_FILE_CORRUPT            = 16
ERR_FILE_MISSING_DEPENDENCIES = 17
ERR_FILE_EOF                = 18
ERR_CANT_OPEN               = 19 # Can't open a resource/socket/file
ERR_CANT_CREATE             = 20
ERROR_QUERY_FAILED          = 21
ERR_ALREADY_IN_USE          = 22
ERR_LOCKED                  = 23 # resource is locked
ERR_TIMEOUT                 = 24
ERR_CANT_CONNECT            = 25
ERR_CANT_RESOLVE            = 26
ERR_CONNECTION_ERROR        = 27
ERR_CANT_AQUIRE_RESOURCE    = 28
ERR_CANT_FORK               = 29
ERR_INVALID_DATA            = 30 # Data passed is invalid
ERR_INVALID_PARAMETER       = 31 # Parameter passed is invalid
ERR_ALREADY_EXISTS          = 32 # When adding, item already exists
ERR_DOES_NOT_EXIST          = 33 # When retrieving/erasing, it item does not exist
ERR_DATABASE_CANT_READ      = 34 # database is full
ERR_DATABASE_CANT_WRITE     = 35 # database is full
ERR_COMPILATION_FAILED      = 36
ERR_METHOD_NOT_FOUND        = 37
ERR_LINK_FAILED             = 38
ERR_SCRIPT_FAILED           = 39
ERR_CYCLIC_LINK             = 40
ERR_INVALID_DECLARATION     = 41
ERR_DUPLICATE_SYMBOL        = 42
ERR_PARSE_ERROR             = 43
ERR_BUSY                    = 44
ERR_SKIP                    = 45
ERR_HELP                    = 46 # user requested help!! (45)
ERR_BUG                     = 47 # a bug in the software certainly happened, due to a double check failing or unexpected behavior.
ERR_PRINTER_ON_FIRE         = 48 # the parallel port printer is engulfed in flames
ERR_OMFG_THIS_IS_VERY_VERY_BAD = 49 # shit happens, has never been used, though
ERR_WTF = ERR_OMFG_THIS_IS_VERY_VERY_BAD

COMMAND_OPEN_FILE = 0
COMMAND_READ_BLOCK = 1
COMMAND_CLOSE = 2
COMMAND_FILE_EXISTS = 3
COMMAND_GET_MODTIME = 4

RESPONSE_OPEN = 0
RESPONSE_DATA = 1
RESPONSE_FILE_EXISTS = 2
RESPONSE_GET_MODTIME = 3

class Disconnected(Exception):
    pass

def log_read(reader):
    def log_reader(*args):
        data = reader(*args)
        print "s <- " + str(data)
        return data
    return log_reader
def log_write(writer):
    def log_writer(*args):
        data = writer(*args)
        print "s -> " + str(args[1:])
        return data
    return log_writer


class RFS(object):

    def __init__(self, sock, addr):
        self.sock = sock
        self.addr = addr
        self.files = dict()

    def read(self, size):
        data = self.sock.recv(size)
        if data == "":
            raise Disconnected
        return data

    def read_uint32(self):
        data = self.read(4)
        return unpack('I', data)[0]
    def read_uint64(self):
        data = self.read(8)
        return unpack('L', data)[0]
    def write(self, data):
        self.sock.send(data)
    def write_uint32(self, data):
        self.sock.send(pack("I", data))
    def write_uint64(self, data):
        self.sock.send(pack("L", data))

    def handle(self):
        passlen = self.read_uint32()
        if passlen > 0:
            print "Passwords is unsupported"
            raise Disconnected
        self.write_uint32(OK)
        while True:
            id = self.read_uint32()
            cmd = self.read_uint32()
            if cmd == COMMAND_OPEN_FILE:
                namelen = self.read_uint32()
                name = self.read(namelen)
                print "Opening file " + name
                name = name.replace("res://", "../game/")
                self.write_uint32(id)
                self.write_uint32(RESPONSE_OPEN)
                if os.path.exists(name):
                    fd = open(name)
                    self.files[id] = fd
                    self.write_uint32(OK)
                    self.write_uint64(os.fstat(fd.fileno()).st_size)
                else:
                    self.write_uint32(ERR_FILE_NOT_FOUND)
            elif cmd == COMMAND_READ_BLOCK:
                print "Reading block"
                offset = self.read_uint64()
                blocklen = self.read_uint32()
                self.files[id].seek(offset)
                data = self.files[id].read(blocklen)
                self.write_uint32(id)
                self.write_uint32(RESPONSE_DATA)
                self.write_uint64(offset)
                self.write_uint32(len(data))
                self.write(data)
            else:
                "Command %s not implemented" % cmd



def handle(sock, addr):
    rfs = RFS(sock, addr)
    try:
        rfs.handle()
    except Disconnected as e:
        print "Disconnected"

server = StreamServer(('0.0.0.0', 2345), handle)
server.serve_forever()
