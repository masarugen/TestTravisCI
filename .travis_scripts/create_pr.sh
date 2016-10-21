#!/bin/bash

# PullRequestの生成処理
# 以下の環境変数を追加する
# GH_TOKEN
# GH_USER
#
# 第１引数：repositoryのowner
# 第２引数：repository名
# 第３引数：branch名
# 第４引数：コピー元フォルダ
# 第５引数：コピー先フォルダ

if [ $# -ne 5 ]; then
    # 引数が足りないので終了
    echo "usage: create_pr.sh owner repo branch copy元 copy先"
    exit 1
fi
if [ "${GH_TOKEN}" = "" ]; then
    # GH_TOKENが設定されていない
    echo "not set GH_TOKEN"
    exit 1
fi
if [ "${GH_USER}" = "" ]; then
    # GH_USERが設定されていない
    echo "not set GH_USER"
    exit 1
fi

GH_OWNER="${1}"
GH_REPO="${2}"
GH_BRANCH="${3}"
SOURCE_PATH="${4}"
COPY_PATH="${5}"
BRANCH_PREFIX="auto_generate_pr_"
HUB_VERSION="2.2.1"
HUB_SURFIX="tar.gz"

# 認証情報を設定する
mkdir -p "$HOME/.config"
set +x
echo "https://${GH_TOKEN}:@github.com" > "$HOME/.config/git-credential"
echo "github.com:
- oauth_token: ${GH_TOKEN}
user: ${GH_USER}" > "$HOME/.config/hub"
unset GH_TOKEN
set -x

# Gitを設定する
git config --global user.name  "${GH_USER}"
git config --global user.email "${GH_USER}@users.noreply.github.com"
git config --global hub.protocol "https"
git config --global credential.helper "store --file=$HOME/.config/git-credential"

# hubをインストールする
curl -LO "https://github.com/github/hub/releases/download/v${HUB_VERSION}/hub-linux-amd64-${HUB_VERSION}.${HUB_SURFIX}"
tar -C "$HOME" -zxf "hub-linux-amd64-${HUB_VERSION}.${HUB_SURFIX}"
export PATH="$PATH:$HOME/hub-linux-amd64-${HUB_VERSION}/bin"
if [ ! -e $HOME/hub-linux-amd64-${HUB_VERSION}/bin/hub ]; then
    echo "not found hub command."
    exit 1;
fi
which hub
hub -h

# リポジトリに変更をコミットする
hub clone "${GH_OWNER}/${GH_REPO}" -b "${GH_BRANCH}"
cd ${GH_REPO}
NEW_BRANCH_NAME=${BRANCH_PREFIX}`date "+%Y-%m-%d_%H-%M-%S"`
hub checkout -b ${NEW_BRANCH_NAME}
## ファイルを変更する ##
mkdir -p ${COPY_PATH}
rm -r ${COPY_PATH}
cp -rp ../${SOURCE_PATH} ${COPY_PATH}
hub add .
hub commit -m "[UPDATE File] ${NEW_BRANCH_NAME}"
if [ $? = 0 ] ; then
    # Pull Requestを送る
    hub push origin $NEW_BRANCH_NAME
    hub pull-request -b ${GH_BRANCH} -m "[AUTO PR] ${NEW_BRANCH_NAME}"
else
    echo "There no updates"
fi

cd ..