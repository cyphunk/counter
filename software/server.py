#!/usr/bin/python

import web
from web.wsgiserver import CherryPyWSGIServer
import subprocess
import os
import time

DEBUG=True

DIR='/home/pi'
COUNTSETTINGSFILE=DIR+'/countinit.sh'
STATEFILE=DIR+'/state.txt'

urls = (
    '/pause', 'pause',
    '/go', 'go',
    '/reset', 'reset',
    '/testsegments', 'testsegments',
    '/', 'index'
)

def debug(message):
    if not DEBUG:
        return
    print message

def readcountsettings():
    f = open(COUNTSETTINGSFILE, 'r')
    values={}
    for line in f.readlines():
        items = line.rstrip().split('=')
        if len(items) != 2:
            continue
        name=items[0]
        value=items[1]
        if (value[0] == value[-1]) and value.startswith(("'", '"')):
            value = value[1:-1]
        values[name]=value
    #import json
    #print json.dumps(values)
    # return json.dumps(values)
    return values

def dopause():
    # subprocess.call(['killall countup.sh'], shell=True)
    f = open(STATEFILE,'w')
    f.write('PAUSE')
    f.close()

def dogo():
    # subprocess.call(['killall countup.sh'], shell=True)
    #subprocess.call(['/bin/ps aux | grep countup.sh | grep -v grep | awk \'{ print $2}\' | xargs kill'], shell=True)
    f = open(STATEFILE,'w')
    f.write('GO')
    f.close()

def doreset():
    #time.sleep(0.2)
    #stopcount()
    #time.sleep(1)
    #startcount()
    f = open(STATEFILE,'w')
    f.write('RESET')
    f.close()

def dotestsegments():
    subprocess.call([DIR+'/testseg.sh'], shell=True)

class pause:
    def GET(self):
        dopause()
class go:
    def GET(self):
        dogo()
class reset:
    def GET(self):
        doreset()
class testsegments:
    def GET(self):
        dotestsegments()
        doreset()

class myApp(web.application):
    def run(self, port=80, *middleware):
        func = self.wsgifunc(*middleware)
        return web.httpserver.runsimple(func, ('0.0.0.0', port))

class index:
    def GET(self, file=None):
        #file is static files such as style sheets or index.html
        if file:
            f = open(file, 'r')
            return f.read()

        settings=readcountsettings()
        return """
        <html><head><style>* {font-family: sans-serif}</style><script>
        function http_get(url){
            var xh=null;
            try{ xh = new XMLHttpRequest(); xh.open("GET", url, false); xh.send(null); }
            catch(err) { console.log(err); return null; }
        }
        </script>
        </head><body><br>
        <b>Control:</b><br><br>
        &nbsp;&nbsp;&nbsp;&nbsp;<button onclick="javascript:http_get('/go')">click here to <b>GO</b> and start counter</button><br>
        &nbsp;&nbsp;&nbsp;&nbsp;<button onclick="javascript:http_get('/pause')">click here to <b>PAUSE</b> counter</button><br>
        &nbsp;&nbsp;&nbsp;&nbsp;<button onclick="javascript:http_get('/reset')">click here to <b>RESET</b> counter</button><br>
        &nbsp;&nbsp;&nbsp;&nbsp;<button onclick="javascript:http_get('/testsegments')">click here to run startup <b>TEST DISPLAY</b> sequence</button><br>
        <br><br>
        <b>Settings:</b><br><br>
        <form method=post>
        &nbsp;&nbsp;&nbsp;&nbsp;Start count at <input type=text size=3 name=countstart value="%s"> seconds<br>
        &nbsp;&nbsp;&nbsp;&nbsp;Stop count at <input type=text size=3 name=countuntil value="%s"> seconds<br>
        &nbsp;&nbsp;&nbsp;&nbsp;When finished show <input type=text size=3 maxlength=3 name=endwith value='%s'> and leave up for <input type=text size=3 name=endseconds value="%s"> seconds<br>
        <br>&nbsp;&nbsp;&nbsp;&nbsp;<input type=submit value="click here to CHANGE settings"><br>
        &nbsp;&nbsp;&nbsp;&nbsp;<span style="font-size: 0.7em; opacity: 0.8;">(This will also RESET the counter)</span><br>
        </form>
        </body></html>
        """%(settings['COUNTSTART'], settings['COUNTUNTIL'], settings['ENDWITH'], settings['ENDSECONDS'])
    def POST(self):
        x = web.input()
        # sanity check
        # if 'countstart' not in x or 'countuntil' not in x or 'endwidth' not in x:
        #     return web.internalerror("missing form values.")
        # def is_digit(s):
        #     return s.isdigit() or (s[0] == '-' and s[1:].isdigit())
        # if not is_digit(x.countstart) or not is_digit(x.countuntil):
        #     return web.internalerror("count start and count until must be numbers")
        # force x.endwith to be string of 3 chars with spaces at LEAST
        x.endwith = "%3s"%x.endwith
        f = open(COUNTSETTINGSFILE, 'w')
        f.write("""COUNTSTART=%s\nCOUNTUNTIL=%s\nENDWITH="%s"\nENDSECONDS=%s
        """%(x.countstart, x.countuntil, x.endwith, x.endseconds))
        time.sleep(1)
        doreset()
        raise web.seeother('/')

app = myApp(urls, globals())

if __name__ == '__main__':
    app.run()
