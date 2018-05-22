# Macaw Docker Image

Used as a [base image](https://github.com/ArcadiaPower/utility-scrapers/blob/staging/Dockerfile#L1) that rarely changes for macaw. Ubuntu 16.04 base, with Ruby installed (no rvm).

Note: This image is public on dockerhub and should stay generic and avoid containing Arcadia IP.

### Docker basics
```
# Build the image
docker build . -f macaw-base-image.dockerfile -t arcadiapower/macaw-base-image:<version>

# Push the image
docker push arcadiapower/macaw-base-image:<version>

# Spin up a container and log in to a shell
docker run -it --rm push arcadiapower/macaw-base-image:<version> bash
```

### AWS buildspec

The buildspec is used by [AWS Codebuild](https://aws.amazon.com/codebuild/) via a [AWS Codepipeline](https://aws.amazon.com/codepipeline/) to automate building a pushing the base image to [Dockerhub](https://hub.docker.com/).

For production however we are manually pushing to the [base-image-repo](https://hub.docker.com/r/arcadiapower/macaw-base-image).
