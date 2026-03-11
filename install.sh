#!/bin/sh
# 下載主腳本
curl -o /root/fallback_recovery.sh https://raw.githubusercontent.com/ngchok/netlab/main/fallback_recovery.sh
chmod +x /root/fallback_recovery.sh
# 詢問 API 地址
echo "請輸入路由器 IP（預設 192.168.11.1）："
read INPUT_IP
IP=${INPUT_IP:-192.168.11.1}
echo "請輸入 API 端口（預設 9090）："
read INPUT_PORT
PORT=${INPUT_PORT:-9090}
# 寫入 API 地址
sed -i "s|API=.*|API=\"http://$IP:$PORT\"|" /root/fallback_recovery.sh
# 加入開機自啟
if ! grep -q "fallback_recovery" /etc/rc.local; then
  sed -i '/^exit 0/i /root/fallback_recovery.sh \&' /etc/rc.local
fi
# 立即啟動
nohup /root/fallback_recovery.sh > /var/log/fallback_recovery.log 2>&1 &
echo "安裝完成！API: http://$IP:$PORT"
