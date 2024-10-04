# rustup

## 安装

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
```

```sh
rustup component add rustfmt clippy rust-analyzer
```

```sh
mkdir -p ~/.config/fish/completions

rustup completions fish > ~/.config/fish/completions/rustup.fish
```
