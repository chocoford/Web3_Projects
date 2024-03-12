read -p "输入你的节点名称: " node_name

sudo apt update && sudo apt upgrade -y
sudo apt install curl wget -y

cd ~

if [ -d "avail" ]; then
    echo "Directory exists."
else
    mkdir avail
fi
cd ~/avail

avail_path=$(pwd)

wget https://github.com/availproject/avail/releases/download/v1.9.0.0/x86_64-ubuntu-2204-data-avail.tar.gz && tar -xf ./x86_64-ubuntu-2204-data-avail.tar.gz

sudo bash -c "cat > /etc/systemd/system/avail.service <<EOF
[Unit]
Description=Avail Node

[Service]
ExecStart=$avail_path/data-avail --chain goldberg -d $avail_path/node-data --validator --name $node_name
Restart=on-failure
RestartSec=5s
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl daemon-reload
sudo systemctl enable avail.service
sudo systemctl start avail.service

while true; do
    result=$(curl -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "author_rotateKeys", "params":[]}' http://localhost:9944)  # 执行curl命令并获取结果
    if echo "$result" | grep -q '{"jsonrpc":"2.0","result":'; then
        echo "Desired string found!"
        echo "$result"
        break  # 如果找到期望的字符串，退出循环
    else
        echo "Desired string not found. Retrying..."
    fi
    sleep 5  # 等待5秒后再次尝试
done