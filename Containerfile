ARG MATRIX_TYPE=desktop
ARG MATRIX_VARIANT=desktop-nvidia-open
ARG MATRIX_PARENT_IMAGE=bazzite-nvidia-open
ARG MATRIX_TAG=stable-43
ARG MATRIX_FEDORA_EDITION=kinoite
ARG MATRIX_FEDORA_VERSION=43
ARG MATRIX_RELEASE_TYPE=stable
ARG GITHUB_BRANCH=main
ARG BUILD_DATE=20000101

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/${MATRIX_PARENT_IMAGE}:${MATRIX_TAG}

# We have to reload the args after using FROM
ARG MATRIX_TYPE
ARG MATRIX_VARIANT
ARG MATRIX_PARENT_IMAGE
ARG MATRIX_TAG
ARG MATRIX_FEDORA_EDITION
ARG MATRIX_FEDORA_VERSION
ARG MATRIX_RELEASE_TYPE
ARG GITHUB_BRANCH
ARG BUILD_DATE

# Build script
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
