import http.server
import socketserver
import os
import signal
from http import HTTPStatus

import exoscale

api_key = os.environ["EXOSCALE_KEY"]
api_secret = os.environ["EXOSCALE_SECRET"]
api_zone = os.environ["EXOSCALE_ZONE"]
instance_pool_id = os.environ["EXOSCALE_INSTANCEPOOL_ID"]
listen_port = int(os.environ["LISTEN_PORT"])

exo = exoscale.Exoscale(api_key=api_key, api_secret=api_secret, config_file="")
zone = exo.compute.get_zone(api_zone)


class WebhookHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        global exo
        global zone
        instance_pool = exo.compute.get_instance_pool(instance_pool_id, zone=zone)
        if self.path == '/up':
            instance_pool.scale(instance_pool.size + 1)
            self.send_response(HTTPStatus.OK)
        elif self.path == '/down':
            if instance_pool.size > 1:
                instance_pool.scale(instance_pool.size - 1)
            self.send_response(HTTPStatus.OK)
        else:
            self.send_response(HTTPStatus.NOT_FOUND)
        self.end_headers()
        self.wfile.write(b'')


# noinspection PyUnusedLocal
def finish(signum, frame):
    global srv
    srv.shutdown()


signal.signal(signal.SIGTERM, finish)
srv = socketserver.TCPServer(("", listen_port), WebhookHandler)
try:
    srv.serve_forever()
except:
    pass