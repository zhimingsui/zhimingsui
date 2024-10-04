# mit-scheme

[编译文档](https://www.gnu.org/software/mit-scheme/documentation/stable/mit-scheme-user/Unix-Installation.html)

Mac m1 无法直接安装[解决方案](https://kennethfriedman.org/thoughts/2021/mit-scheme-on-apple-silicon/)

```bash
cd mit-scheme-{VERSION}/src

./configure --prefix=/opt/mit-scheme

make

make install
```
