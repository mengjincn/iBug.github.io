#!/bin/bash

. ${0%/*}/config.sh
. ${0%/*}/util.sh
: ${SRC:=_site} ${BRANCH:=master}

set -e

# Prepare SSH stuff
if [ -z "$SSH_KEY_E" ]; then
  e_error "SSH key not found, not deploying"
  exit 1
fi
base64 -d <<< "$SSH_KEY_E" | gunzip -c > ~/.ssh/id_rsa
export SSH_AUTH_SOCK=none GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa"
ssh-keyscan -H "git.dev.tencent.com" >> ~/.ssh/known_hosts


# Fetch extra necessary things
pushd "$SRC" &>/dev/null
git clone --depth=1 --branch=master https://github.com/iBug/image.git image
rm -rf image/.git CNAME


# Prepare Git stuff
source_msg="$(git log -1 --pretty="[%h] %B")"

e_info "Adding commit info"
# Since we're pushing to another host, we want to torch the history
rm -rf .git
git init
git remote add origin "${ORIGIN:-git@git.dev.tencent.com:iBugOne/iBugOne.coding.me.git}"
git config user.name "iBug"
git config user.email "iBug@users.noreply.github.com"
git add --all
git commit --quiet --message "Auto deploy from Travis CI build ${TRAVIS_BUILD_NUMBER:-?}" --message "$source_msg" &>/dev/null

e_info "Pushing to Coding.net"
git push origin +${BRANCH:-master} &>/dev/null

popd &>/dev/null
e_success "Successfully deployed to Coding Pages"
