---
title: "Claude Code 装上 Serena，才算真正会用 AI 写代码"
description: "一份写给 AI Vibe Coding 从业者的 Serena MCP 安装使用手册，附对比数据和完整配置流程"
date: 2026-03-03
tags: ["AI", "claude-code", "mcp", "Vibe Coding", "开发工具"]
---

大家好，今天我要介绍一个工具——**Serena**。

如果你在用 Claude Code 写代码，不装这个，你就是在浪费 Token、浪费时间、浪费你的 AI 订阅费。

我不是在夸张，我是在认真说。

---

## 先说问题：大多数人是怎么用 Claude Code 的？

一问一答。让 Claude 读文件、改代码、写逻辑。

听起来没问题，但实际上呢？

- Claude 为了改一个函数，把整个文件读了一遍
- 改完之后，周边代码悄悄被动了，你没发现
- Token 烧了一大堆，效果将将及格
- 项目一大，Claude 开始"失忆"，之前说的它全忘了

这不是 Claude 的问题，这是**工具没配齐**的问题。

---

## Serena 是什么？

**Serena** 是一个 MCP Server，专门为 Claude Code 这类 AI 编程工具设计。

它做的事情，用一句话说就是：**给 Claude 装上能真正看懂代码的眼睛。**

不是读文件，而是理解符号。不是猜结构，而是索引语义。它让 Claude 知道：这个函数在哪、这个类被谁引用、这次修改会影响哪些地方。

> 官方仓库：https://github.com/oraios/serena  
> GitHub Star：20,000+，这不是玩具项目，是生产力基础设施。

---

## 装 vs 不装，差距到底在哪？

| 对比维度 | ❌ 没有 Serena | ✅ 有了 Serena |
|---------|--------------|--------------|
| 代码检索 | 读整个文件，效率低 | 符号级精准检索，只取相关部分 |
| 代码修改 | 容易误改周边代码 | 精准定位，副作用极小 |
| Token 消耗 | 高，反复读大文件 | 低，按需加载片段 |
| 项目理解 | 靠 Claude 自己摸索 | Serena 维护语义索引 |
| 跨文件重构 | 容易遗漏引用 | 全局符号追踪，重构可靠 |
| 大型项目 | 上下文爆炸，Claude 开始"忘事" | 语义压缩，大项目照样丝滑 |

说直白点：**没有 Serena，Claude Code 是个聪明但近视的助手。有了 Serena，它才算真正看清楚了你的代码。**

---

## 安装流程：一步一步来，不跳过

### 第一步：安装 uv（Serena 的运行依赖）

> ⚠️ 注意：必须在**普通 PowerShell 窗口**里装，不要在 Claude Code 的内置终端里运行，会报错。

按 `Win + R`，输入 `powershell`，打开新窗口，执行：

```powershell
irm https://astral.sh/uv/install.ps1 | iex
```

装完之后刷新环境变量（不要关窗口）：

```powershell
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
```

验证一下：

```powershell
uv --version
uvx --version
```

能输出版本号，说明装好了。

---

### 第二步：把 Serena 接入你的项目

进入你的项目目录，执行这条命令：

```powershell
cd D:\code\你的项目名

claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project D:/code/你的项目名
```

执行成功后会提示：

```
Added stdio MCP server serena ...
File modified: C:\Users\你的用户名\.claude.json [project: D:\code\你的项目名]
```

看到这行，说明配置写进去了。

---

### 第三步：验证是否连接成功

启动 Claude Code：

```powershell
claude
```

输入 `/mcp`，看到以下内容就成功了：

```
serena · ✅ connected
```

同时浏览器会自动打开 Serena Dashboard（`http://127.0.0.1:24284/dashboard`），显示：

- **Active Project**：你的项目名
- **Active Tools**：19 个工具已就绪
- **Logs**：实时工具调用日志

---

## 遇到问题？这里有答案

### 问题一：看到 `.mcp.json` 格式无效警告

```
Found invalid settings files: D:\code\项目\.mcp.json. They will be ignored.
```

用 VS Code 打开 `.mcp.json`，替换成这个标准格式：

```json
{
  "mcpServers": {
    "serena": {
      "command": "uvx",
      "args": [
        "--from",
        "git+https://github.com/oraios/serena",
        "serena",
        "start-mcp-server",
        "--context",
        "ide-assistant",
        "--project",
        "D:/code/你的项目名"
      ]
    }
  }
}
```

### 问题二：uvx 找不到

把 command 换成完整路径：

```json
"command": "C:\\Users\\你的用户名\\.local\\bin\\uvx.exe"
```

---

## 每个项目都要单独配吗？

**可以不用。** 全局配置一次，所有项目生效：

```powershell
claude mcp add serena -s user -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project .
```

`-s user` 是用户级配置，`--project .` 自动识别当前目录。**一次配置，永久受益。**

---

## 装好之后，怎么用？

不需要学新命令，不需要记工具名称。**直接说需求就行。**

```
分析一下这个项目的整体架构，主要模块有哪些？
```

```
找到所有定义了 API 路由的文件
```

```
在 src/auth.ts 的 login 函数里增加错误日志
```

```
把 IUser 接口重命名为 IAccount，更新所有引用
```

Serena 在后台自动决定什么时候用语义检索、什么时候直接回答。你不需要感知它的存在，**但你会感知到 Claude 变聪明了。**

---

## 三句最关键的话

1. **Token 烧得多不等于用得好，精准比暴力更重要。**
2. **Serena 不是插件，是 Claude Code 的能力补全。**
3. **装上它，你已经比大多数 Vibe Coder 多了一个核心武器。**

---

## 结语

AI 编程工具的竞争，早就不只是"谁的模型更聪明"了。**工具链配得好不好，才是真正的分水岭。**

Serena 是我目前 Claude Code 工作流里最不能缺少的一环。配置一次，受益每天。

如果你还没装，现在就去装。

---

*本文基于 Claude Code v2.1.63 + Serena MCP 实际安装配置过程整理*  
*最后更新：2026年3月*
