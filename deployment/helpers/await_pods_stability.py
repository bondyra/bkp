#!/usr/bin/env python3
import argparse
import logging
import time
from typing import List

from kubernetes import config, client

logging.basicConfig(level=logging.INFO)

config.load_kube_config()
c = client.CoreV1Api()


def _is_pod_running(v1, namespace: str, pod_name: str) -> bool:
    statuses = v1.read_namespaced_pod(namespace=namespace, name=pod_name).status.container_statuses
    return statuses[-1].ready if statuses else False


def main(namespace: str, pod_names: List[str]):
    c = client.CoreV1Api()
    succesful_checks = 0
    retries = 0
    while True:
        logging.info(
            f'Stability check {succesful_checks + 1}/3...'
            if succesful_checks > 0
            else f'Retry {retries + 1}/20'
        )
        if all(_is_pod_running(c, namespace, pod_name) for pod_name in pod_names):
            logging.info(f'Pods are stable! {2 - succesful_checks} check(s) to go.')
            succesful_checks += 1
        else:
            logging.info(f'Failed check - not all pods are stable.')
            succesful_checks = 0
        if succesful_checks >= 3:
            logging.info(f'Three successful checks - everything looks ok!')
            return
        if succesful_checks == 0:
            retries += 1
        if retries >= 20:
            raise Exception('After 10 minutes - environment is still not stable.')
        logging.info('Sleeping for 30 secs...')
        time.sleep(30)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('-n', dest='namespace', type=str, required=True,
                        help='Kubernetes namespace where kafka is deployed')
    parser.add_argument('-p', dest='pod_names', type=str, nargs='+', required=True,
                        help='List of pod names to check')
    args = parser.parse_args()
    main(args.namespace, args.pod_names)
