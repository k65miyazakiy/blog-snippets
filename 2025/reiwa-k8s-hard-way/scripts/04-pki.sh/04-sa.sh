#!/bin/bash

set -e
cd /etc/kubernetes/pki

# サービスアカウント鍵ペアの生成
openssl genrsa -out sa.key 2048
openssl rsa -in sa.key -pubout -out sa.pub