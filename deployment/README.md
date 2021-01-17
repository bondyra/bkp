This is a python package that contains (nearly) everything to properly setup the platform.
The package contains a bunch of bash and python scripts. I recommend to use this in venv.

Structure:
- "scripts" is a folder that contains bash scripts that setup the k8s cluster and perform other necessary tasks. Numeric prefixes provide the correct order of execution.
- "helpers" contains python scripts performing auxiliary k8s actions that are required by "scripts". For example - wait operations.
- "config" contains shared configuration that can be adjusted to your needs
- "images" contains custom docker images utilized in the platform
