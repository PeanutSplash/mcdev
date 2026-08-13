# mcdev

网易我的世界开发工具链的二开总仓。两个上游项目各自独立维护，这里用 **git submodule** 把你的 fork 放在同一个工作区里，改完仍分别推回对应仓库。

| 目录 | 作用 | 你的 fork | 上游 |
| --- | --- | --- | --- |
| `MCDevTool/` | C++ 核心，产出 `mcdk.exe` | [PeanutSplash/MCDevTool](https://github.com/PeanutSplash/MCDevTool) | [GitHub-Zero123/MCDevTool](https://github.com/GitHub-Zero123/MCDevTool) |
| `mcdev-tools/` | VS Code 插件，封装并驱动 mcdk | [PeanutSplash/mcdev-tools](https://github.com/PeanutSplash/mcdev-tools) | [Dofes/mcdev-tools](https://github.com/Dofes/mcdev-tools) |

插件里内置或调用的就是 `MCDevTool` 编出来的 `mcdk.exe`。二开时一般先改核心，再改插件对接。

## 克隆

```powershell
git clone --recurse-submodules https://github.com/PeanutSplash/mcdev.git
cd mcdev
.\scripts\setup.ps1
```

已经 clone 过、但 submodule 是空目录时：

```powershell
git submodule update --init --recursive
.\scripts\setup.ps1
```

`setup.ps1` 会：

1. 初始化 submodule
2. 切到各子仓 `main`（避免默认的 detached HEAD）
3. 给每个子仓加上 `upstream` remote

## 日常开发

每个子目录都是独立 git 仓库，在里面改、提交、推送即可：

```powershell
cd MCDevTool
# 改代码...
git add .
git commit -m "feat: ..."
git push origin main
```

插件同理，进 `mcdev-tools/` 操作。

子仓提交之后，**回到总仓再记一次指针**，这样别人 clone 总仓能拿到同一版本：

```powershell
cd ..   # 回到 mcdev 根目录
git add MCDevTool mcdev-tools
git commit -m "chore: bump submodules"
git push
```

## 同步上游

```powershell
.\scripts\sync-upstream.ps1
```

默认会 `fetch` 两个上游的 `main`，并分别 rebase 到你的 fork `main` 上。某个子仓有未提交改动时会跳过那个仓。

只同步其中一个：

```powershell
.\scripts\sync-upstream.ps1 -Target MCDevTool
.\scripts\sync-upstream.ps1 -Target mcdev-tools
```

手动同步示例：

```powershell
cd MCDevTool
git fetch upstream
git rebase upstream/main
git push origin main
```

## 注意

- 不要在总仓里直接改子仓文件却不进子仓提交。总仓只跟踪 **commit 指针**，不跟踪子仓工作区。
- 子仓 `origin` 指向你的 fork，`upstream` 指向原作者仓库。不要把二开改动推到 `upstream`。
- 本仓不包含 `mcdk-assistant`。需要的话再单独加 submodule。
