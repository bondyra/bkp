import glob

from setuptools import setup

setup(
    name='bkp-deployer',
    version='0.1',
    scripts=glob.glob('helpers/*.py') + glob.glob('helpers/*.sh') + glob.glob('scripts/*.sh'),
    install_requires=[
        'kubernetes==11.0.0',
        'requests==2.24.0'
    ]
)
