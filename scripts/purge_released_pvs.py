import argparse
import logging

from kubernetes import config, client

logging.basicConfig(level=logging.INFO)


def main(dry_run: bool):
    config.load_kube_config()
    v1 = client.CoreV1Api()
    pv_list = v1.list_persistent_volume()
    released_pvs = [item for item in pv_list.items if item.status.phase == 'Released']
    for pv in released_pvs:
        if not dry_run:
            logging.info(f'Deleting: {pv.metadata.name}')
            v1.delete_persistent_volume(name=pv.metadata.name)
        else:
            logging.info(f'Would delete: {pv.metadata.name}')
    logging.info('Finished.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('--dry-run', dest='dry_run', type=bool, default=True)
    args = parser.parse_args()
    main(args.dry_run)
