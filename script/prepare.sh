#!/bin/bash

# Make the configuration
. script/config.sh || true
: ${GH_REPO:=iBug/iBug.github.io} ${BRANCH:=master}

set -e

e_info() {
  echo -e "\x1B[36;1m[Info]\x1B[0m $*" >&2
}

e_success() {
  echo -e "\x1B[32;1m[Success]\x1B[0m $*" >&2
}

e_warning() {
  echo -e "\x1B[33;1m[Warning]\x1B[0m $*" >&2
}

e_error() {
  echo -e "\x1B[31;1m[Error]\x1B[0m $*" >&2
}

e_info "Cloning from GitHub:$GH_REPO.git, branch=$BRANCH"
git clone --depth=3 --branch=$BRANCH --single-branch "https://$GH_TOKEN@github.com/$GH_REPO.git" _site &>/dev/null
e_success "Done"
