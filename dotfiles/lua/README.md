# Install



```sh
curl -R -O http://www.lua.org/ftp/lua-5.4.6.tar.gz

tar -zxf lua-*.tar.gz

cd lua-*

make linux test

sudo make install
```

```sh
curl -R -O http://luarocks.github.io/luarocks/releases/luarocks-3.11.1.tar.gz

tar -zxf luarocks-3.11.1.tar.gz

cd luarocks-3.11.1

./configure --with-lua-include=/usr/local/include

make

make install
```
