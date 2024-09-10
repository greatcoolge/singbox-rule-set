#!/bin/bash

set -e -o pipefail

# 输出当前工作目录
echo "当前工作目录：$(pwd)"

# 打印下载的文件是否存在
echo "检查下载的文件是否存在..."
ls -la sing-box.tar.gz geoip.db geosite.db

# 执行下载和解压命令
echo "下载和解压文件..."
VERSION=$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases/latest | grep tag_name | cut -d ":" -f2 | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')
curl -Lo sing-box.tar.gz "https://github.com/SagerNet/sing-box/releases/download/v${VERSION}/sing-box-${VERSION}-linux-amd64.tar.gz"
curl -Lo geoip.db "https://github.com/lyc8503/sing-box-rules/releases/latest/download/geoip.db"
curl -Lo geosite.db "https://github.com/lyc8503/sing-box-rules/releases/latest/download/geosite.db"

tar -xzvf sing-box.tar.gz
mv ./sing-box-${VERSION}-linux-amd64/sing-box .
chmod +x sing-box

# 打印文件夹和文件列表
echo "打印文件夹和文件列表..."
ls -la

# 执行导出和编译命令
echo "导出和编译规则..."
geoipAddresses=("cn" "de" "facebook" "google" "netflix" "telegram" "twitter")
geositeDomains=("amazon" "apple" "bilibili" "category-ads-all" "category-games" "cn" "discord" "disney" "facebook" "geolocation-!cn" "github" "google" "instagram" "microsoft" "netflix" "onedrive" "openai" "primevideo" "telegram" "tiktok" "tld-!cn" "twitch" "hbo" "twitter" "youtube" "threads" "nvidia" "spotify")

for item in "${geoipAddresses[@]}"; do
    ./sing-box geoip export "$item"
done

for item in "${geositeDomains[@]}"; do
    ./sing-box geosite export "$item"
done

for item in *.json; do
    ./sing-box rule-set compile "$item"
    mv "${item%.json}.srs" bin/
    mv "$item" rule-set/
done

# 删除临时文件
echo "清理临时文件..."
rm -rf sing-box.tar.gz sing-box-${VERSION}-linux-amd64/ geoip.db geosite.db sing-box
