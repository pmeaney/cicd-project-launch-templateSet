# Template Step 1

In this example, we keep the script super simple. This is simply a proof of concept.

We focus on adding two fields to 1password, then doing a basic environment variable substitution on a yaml file.

The yaml file represents a future Github Actions CICD file, to which we will add env vars which will be involved in our CICD process-- Such as our preferred Container Registry (in my case, Github Container Registry: ghcr.io), Our Docker username, our Github Username.

In future iterations, we'll also create a github repo for the project, as well as add secrets from 1password to the github repo's Github Action secrets.
