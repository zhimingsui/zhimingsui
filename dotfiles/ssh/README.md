# ssh

## 生成密钥
```sh
ssh-keygen -t ed25519
```

## 拷贝密钥到目标服务器
```sh
ssh-copy-id -i id_ed25519.pub 用户名@服务器IP地址或域名
```

