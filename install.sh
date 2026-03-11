#!/bin/sh
# 下載 fallback_recovery.sh
curl -o /root/fallback_recovery.sh https://raw.githubusercontent.com/ngchok/netlab/main/fallback_recovery.sh

# 給執行權限
chmod +x /root/fallback_recovery.sh

# 加入開機自啟（插入 exit 0 前面）
if ! grep -q "fallback_recovery" /etc/rc.local; then
  sed -i '/^exit 0/i /root/fallback_recovery.sh \&' /etc/rc.local
fi

# 立即啟動
nohup /root/fallback_recovery.sh > /var/log/fallback_recovery.log 2>&1 &

echo "安裝完成，腳本已啟動"
