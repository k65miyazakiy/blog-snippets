#!/bin/bash

set -e

# サービスアカウント鍵ペアの生成
sudo openssl genrsa -out sa.key 2048
sudo openssl rsa -in sa.key -pubout -out sa.pub