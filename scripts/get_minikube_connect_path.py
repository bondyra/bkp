import argparse

from kubernetes import config, client

config.load_kube_config()


def main(namespace: str, claim_name: str):
    c = client.CoreV1Api()
    pvc_list = c.list_namespaced_persistent_volume_claim(namespace)
    connect_pvc = [pvc for pvc in pvc_list.items if pvc.metadata.name == claim_name][0]

    assert connect_pvc.status.phase == 'Bound', connect_pvc.status.phase
    assert connect_pvc.spec.volume_mode == 'Filesystem', connect_pvc.spec.volume_name
    pv_name = connect_pvc.spec.volume_name

    pv_info = c.read_persistent_volume(name=pv_name)
    assert pv_info.status.phase == 'Bound', pv_info.status.phase
    print(pv_info.spec.host_path.path)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('-n', dest='namespace', type=str, required=True,
                        help='Kubernetes namespace where connect is deployed')
    parser.add_argument('-c', dest='claim', type=str, required=True,
                        help='Name of connect persistent volume claim')
    args = parser.parse_args()
    main(args.namespace, args.claim)
