#!/bin/bash
# @file build-and-deploy.sh
# @brief Build Docker images and deploy to DockerHub
#
# @description The scripts builds Docker images from this repository and deploys the respective image to DockerHub. A
# multiple choice menu is used to control which image is built and whether the image is built or deployed.
#
# ==== Arguments
#
# The script does not accept any parameters.


CMD_BUILD="build_image"
CMD_DEPLOY="deploy_image"

LOCAL_IMAGE_PREFIX="pegasus"
REMOTE_IMAGE_PREFIX="sommerfeldio"
IMAGE_TAG="latest"

TARGET_IMAGE=""

# @description Build docker image locally
#
# @arg $1 string image_name (= directory containing the Dockerfile) - mandatory
#
# @exitcode 8 If param is missing
function buildImage() {
  if [ -z "$1" ]
  then
    echo -e "$LOG_ERROR Param missing: image_name"
    echo -e "$LOG_ERROR exit" && exit 8
  fi


  (
    cd "$1" || exit

    echo -e "$LOG_INFO Lint $P$LOCAL_IMAGE_PREFIX/$1:$IMAGE_TAG$D"
    docker run -i --rm hadolint/hadolint:latest < Dockerfile
    echo -e "$LOG_DONE Finished linting"

    echo -e "$LOG_INFO Build $P$LOCAL_IMAGE_PREFIX/$1:$IMAGE_TAG$D"
    docker build -t "$LOCAL_IMAGE_PREFIX/$1:$IMAGE_TAG" .
    echo -e "$LOG_DONE Finished building $P$LOCAL_IMAGE_PREFIX/$1:$IMAGE_TAG$D"

    # todo ... scan image
    # todo ... https://sommerfeld-io.atlassian.net/browse/SIO-231
  )
}


# @description Deploy local image to DockerHub. Image is re-tagged (from pegasus/THE_IMAGE_NAME) to sommerfeldio/THE_IMAGE_NAME).
#
# @arg $1 string image_name (= directory containing the Dockerfile) - mandatory
#
# @exitcode 8 If param is missing
function deployImage() {
  if [ -z "$1" ]
  then
    echo -e "$LOG_ERROR Param missing: image_name"
    echo -e "$LOG_ERROR exit" && exit 8
  fi

  echo -e "$LOG_INFO Deploy $P$1$D to DockerHub"

  echo -e "$LOG_INFO Login to remote container registry"
  docker login -u=sommerfeldio

  echo -e "$LOG_INFO Re-tag image"
  docker tag "$LOCAL_IMAGE_PREFIX/$1:$IMAGE_TAG" "$REMOTE_IMAGE_PREFIX/$1:$IMAGE_TAG"

  echo -e "$LOG_INFO Push image to remote container registry"
  docker push "$REMOTE_IMAGE_PREFIX/$1:$IMAGE_TAG"

  echo -e "$LOG_INFO Remove local version of $REMOTE_IMAGE_PREFIX/$1:$IMAGE_TAG"
  docker image rm "$REMOTE_IMAGE_PREFIX/$1:$IMAGE_TAG"

  echo -e "$LOG_INFO Pull $REMOTE_IMAGE_PREFIX/$1:$IMAGE_TAG from remote container registry"
  docker pull "$REMOTE_IMAGE_PREFIX/$1:$IMAGE_TAG"

  echo -e "$LOG_INFO Finished deployment of $P$1$D to DockerHub"
}


echo -e "$LOG_INFO Select the image"
select d in */; do
  TARGET_IMAGE="${d::-1}"
  break
done

echo -e "$LOG_INFO Select command"
select s in "$CMD_BUILD" "$CMD_DEPLOY"; do
  case "$s" in
    "$CMD_BUILD" ) buildImage "$TARGET_IMAGE"; break;;
    "$CMD_DEPLOY" ) deployImage "$TARGET_IMAGE"; break;;
  esac
done
