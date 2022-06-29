#!/bin/bash
# @file lint.sh
# @brief Update und run linters.
#
# @description The script updates linter definitions from the ``infrastructure`` repo and runs linters.
#
# ==== Arguments
#
# The script does not accept any parameters.


echo -e "$LOG_INFO Download latest linter definitions"
linterDefinitions=(
  '.folderslintrc'
  '.ls-lint.yml'
  '.yamllint.yml'
)
for file in "${linterDefinitions[@]}"; do
  rm "$file"
  curl -sL "https://raw.githubusercontent.com/sebastian-sommerfeld-io/infrastructure/main/resources/common-assets/linters/$file" -o "$file"
  git add "$file"
done

echo -e "$LOG_INFO ------------------------------------------------------------------------"

echo -e "$LOG_INFO Run linter containers"

echo -e "$LOG_INFO Lint filesystem structure"
docker run -it --rm --volume "$(pwd):$(pwd)" --workdir "$(pwd)" sommerfeldio/folderslint:latest folderslint

echo -e "$LOG_INFO yamllint"
docker run -it --rm --volume "$(pwd):/data" --workdir "/data" cytopia/yamllint:latest .

echo -e "$LOG_INFO jsonlint"
docker run -it --rm --volume "$(pwd):/data" --workdir "/data" cytopia/jsonlint:latest -i '*node_modules*' "*.json"

echo -e "$LOG_INFO shellcheck"
find . -not \( -path "*node_modules*" \) -name "*.sh" -exec docker run -it --rm --volume "$(pwd):/data" --workdir "/data" koalaman/shellcheck:latest {} \;

echo -e "$LOG_INFO lint Dockerfile"
find . -not \( -path "*node_modules*" \) -name Dockerfile -exec \
    sh -c 'src=${1#./} && echo "$LOG_INFO Lint $1" && docker run -i  --rm hadolint/hadolint < $1' sh "{}" \;

echo -e "$LOG_INFO lint Vagrantfile"
echo -e "$LOG_WARN todo ..." # todo ...

echo -e "$LOG_INFO lslint"
docker run -it --rm --volume "$(pwd):/data" --workdir "/data" lslintorg/ls-lint:1.11.0

echo -e "$LOG_INFO lint .env files"
docker run -it --rm --volume "$(pwd):/app" --workdir "/app" dotenvlinter/dotenv-linter:latest --exclude "*node_modules*" --recursive

echo -e "$LOG_INFO lint terraform files"
find . -not \( -path "*node_modules*" \) -name "*.tf" -exec docker run -it --rm --volume "$(pwd):$(pwd)" --workdir "$(pwd)" ghcr.io/terraform-linters/tflint:latest {} \;

echo -e "$LOG_INFO ------------------------------------------------------------------------"

echo -e "$LOG_DONE Finished linting"
