import json
import os
import pprint
import time

import exoscale
from exoscale import Exoscale
from exoscale.api.compute import Zone


def service_discovery(exo: Exoscale, zone: Zone, pool_id: str, port: int, file: str):
    instance_pool = exo.compute.get_instance_pool(pool_id, zone=zone)
    instances = instance_pool.instances
    targets = []
    for instance in instances:
        targets.append(instance.ipv4_address + ":" + str(port))

    with open(file, "w") as f:
        f.write(json.dumps(
            [
                {
                    "targets": targets,
                    "labels": {}
                }
            ]
        ))


def loop_service_discovery(
        key: str,
        secret: str,
        zone: str,
        pool_id: str,
        port: int,
        file: str
):
    exo = exoscale.Exoscale(api_key=key, api_secret=secret, config_file="")

    zone = exo.compute.get_zone(zone)

    failed_sd = 0
    while True:
        if failed_sd > 3:
            raise Exception("Too many service discovery failures.")
        try:
            service_discovery(exo, zone, pool_id, port, file)
            failed_sd = 0
            time.sleep(10)
        except Exception as err:
            pprint.pprint(err)
            failed_sd = failed_sd + 1


if __name__ == "__main__":
    api_key = os.environ["EXOSCALE_KEY"]
    api_secret = os.environ["EXOSCALE_SECRET"]
    api_zone = os.environ["EXOSCALE_ZONE"]
    instance_pool_id = os.environ["EXOSCALE_INSTANCEPOOL_ID"]
    target_port = int(os.environ["TARGET_PORT"])
    sd_file = "/srv/service-discovery/config.json"

    loop_service_discovery(api_key, api_secret, api_zone, instance_pool_id, target_port, sd_file)
