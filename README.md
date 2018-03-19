# Ruby Docker images

Using this as a base for other Docker work. Ubuntu 16.04 base, with Ruby
installed (no rvm).

```
# Build the image
docker build . -f <dockerfile> -t <your_namespace_or_account_name>/<your_repository_name>

# Example:
#
#   docker build . -f macaw-base-image.dockerfile -t arcadiapower/macaw-base-image

# Optionally, you can log in to your docker account & push the image to the
# public docker hub repository

docker push <your_namespace_or_account_name>/<your_repository_name>

# Example:
#
#  docker push arcadiapower/macaw-base-image

# Spin up a container and log in to a shell

docker run -it --rm <your_namespace_or_account_name>/<your_repository_name>

# Example:
#
#  docker run -it --rm arcadiapower/macaw-base-image /bin/bash
```
