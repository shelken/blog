## Agents Remind

### jsconfig.json

`assets/jsconfig.json` 是 Hugo 生成的编辑器辅助文件（路径指向本机模块缓存），已从 git 中删除并加入 `.gitignore`。不影响构建和功能，Hugo 每次运行自动再生。

### Hugo 主题更新

```bash
# 在项目根目录 02-Projects/Blog/ 下执行
hugo mod get -u github.com/CaiJimmy/hugo-theme-stack/v3
hugo mod tidy
# go.mod / go.sum 会自动更新，一起提交即可
```
