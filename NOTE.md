# Dotfiles

## 安装 comtrya

```sh
curl -fsSL https://get.comtrya.dev | sh
```

## 克隆 Dotfiles 仓库

```sh
git clone https://github.com/zhimingsui/Dotfiles ~/Dotfiles
```

## 执行

```sh
comtrya -d ~/Dotfiles/manifests apply
```

### brew

备份

```sh
brew bundle dump --describe --force --file="~/Dotfiles/Brewfile"
```

还原

```sh
brew bundle --file="~/dotfiles/Brewfile"
```

### 软连接

```sh
mv ~/.zshrc ~/Dotfiles/\~/.zshrc
```

```sh
ln -s ~/Dotfiles/\~/.zshrc ~/.zshrc
```

### osx 快捷键相关

- 默认快捷键 map `/System/Library/ExtensionKit/Extensions/KeyboardSettings.appex/Contents/Resources/zh_CN.lproj/DefaultShortcutsTable.xml`
- 快捷键 map 翻译 `/System/Library/ExtensionKit/Extensions/KeyboardSettings.appex/Contents/Resources/zh_CN.lproj/DefaultShortcutsTable.xml`
- 读取当前快捷键 `defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys | less`

- 删除聚焦快捷键 `defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "{ enabled = 0; value = { parameters = ( 32, 49, 1048576 ); type = standard; }; }"`

### comtrya

```sh
comtrya -d dotfiles apply
```
