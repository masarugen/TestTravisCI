#!/bin/bash

# ソースコード生成処理
# 以下の環境変数を設定
# GET_FILE_BRANCH：ファイル取得してくるブランチ
# APP_DEVELOP_BRANCH：アプリの開発ブランチ

if [[ $TRAVIS_EVENT_TYPE = "api" ]] ; then
    # API経由での起動の場合に自動でソースを生成してPRを送る
    echo "--- master ---"
fi
