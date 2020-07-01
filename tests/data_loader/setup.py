from setuptools import find_packages, setup

setup(
    name='bkp-test-data-loader',
    version='0.1',
    description='Stuff',
    author='Jakub Bondyra',
    author_email='jb10193@gmail.com',
    packages=find_packages(),
    install_requires=[
        'Click==7.0',
        'confluent-kafka[schema-registry,avro]==1.4.2'
    ],
    entry_points={
        'console_scripts': [
            'launch=loader.run:run'
        ]
    }
)
