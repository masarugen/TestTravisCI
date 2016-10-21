#!/bin/bash

# Githubからファイルの取得処理
# 利用する場合は以下の環境変数の設定が必要
# GH_TOKEN githubのPersonal access tokenを設定
# 第１引数：repositoryのowner
# 第２引数：repository名
# 第３引数：ファイル取得先branch名
# 第４引数：github上の対象ファイルのパス
# 第５引数：取得したファイルの保存先名
GH_OWNER="${1}"
GH_REPO="${2}"
GH_BRANCH="${3}"
GH_PATH="${4}"
GH_URL="https://api.github.com/repos/${GH_OWNER}/${GH_REPO}/contents/${GH_PATH}?ref=${GH_BRANCH}"
LOCAL_SAVE_PATH=${5}

echo "${GH_OWNER} ${GH_REPO} ${GH_BRANCH} ${GH_PATH} ${LOCAL_SAVE_PATH}"
if [ $# -ne 5 ]; then
    # 引数が足りないので終了
    echo "usage: get_github_file.sh [owner] [repo] [branch] [copy元] [copy先]"
    exit 1
fi
curl -s -f \
    -H "Authorization: token ${GH_TOKEN}" \
    -H "Accept: application/vnd.github.v3.raw" \
    -o ${LOCAL_SAVE_PATH} \
    -L ${GH_URL} \
    --verbose
if [ $? -ne 0 -o ! -e ${LOCAL_SAVE_PATH} ]; then
    # ファイル取得失敗
    exit 1
fi