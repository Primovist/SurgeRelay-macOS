<div align="center">
  <img src="SurgeRelay/WebResources/app-icon.png" width="112" alt="Surge Relay 图标">
  <h1>Surge Relay</h1>
  <p>在 Mac 上管理 Surge 模块和机场订阅。</p>
  <p>
    <a href="https://github.com/EEliberto/SurgeRelay-macOS/releases/latest"><strong>下载 Surge Relay</strong></a>
    &nbsp;·&nbsp;
    <a href="CHANGELOG.md">更新日志</a>
    &nbsp;·&nbsp;
    <a href="docs/Automation.md">自动化访问</a>
  </p>
  <p><sub>需要 macOS 26 或更高版本，以及搭载 Apple 芯片的 Mac。</sub></p>
</div>

<p align="center">
  <a href="docs/images/module-overview.png"><img width="920" alt="Surge Relay 主窗口：按平台选择汇总模块的来源" src="docs/images/module-overview.png"></a>
</p>

## 开始使用

<p align="center">
  一款用于集中管理、转换、编辑和发布 Surge 模块与机场节点的 macOS 应用程序。
</p>

使用 GitHub 与 Cloudflare 时，请参阅[配置指南](docs/GitHub-Cloudflare-Guide.md)。

## 管理模块

Surge Relay 可读取 Surge 模块，并通过内置的 [Script Hub](https://github.com/Script-Hub-Org) 引擎转换 Loon 插件和 Quantumult X 重写。转换在 Mac 上完成。

选择一个来源模块后，可以查看来源地址、刷新状态及可用参数。点按“编辑”可更改名称、来源格式、刷新间隔和转换选项。刷新间隔选择“自动”时，使用通用设置中的间隔。

<p align="center">
  <a href="docs/images/module-editor.png"><img width="920" alt="编辑模块的名称、来源和刷新间隔" src="docs/images/module-editor.png"></a>
</p>

<p align="center">
  <a href="docs/images/module-arguments.png"><img width="920" alt="在模块详情中调整脚本参数" src="docs/images/module-arguments.png"></a>
</p>

在“预览”中可以搜索和编辑生成的内容。写入的自定义修改会在后续处理中保留；如果上游变更与修改冲突，请检查提示和当前内容。

<p align="center">
  <a href="docs/images/module-preview.png"><img width="920" alt="模块正文预览，按元数据、配置段和链接显示不同颜色" src="docs/images/module-preview.png"></a>
</p>

## 管理机场订阅

选择侧栏中的“订阅汇总”，添加机场名称和订阅链接。添加 Surge 配置后，开启需要写入的配置，并点按“写入配置”。

每个机场的节点保存在目标配置旁的独立 `.proxies` 文件中，主配置通过 `policy-path` 引用。订阅地址、重定向地址和节点服务器对应的直连规则会一并维护。

在“编辑机场”中，可以按关键词或正则表达式筛选节点、调整排序、设置名称模板，以及修改 UDP Relay、TCP Fast Open 等代理属性。代理属性选择“自动”时保留订阅原值。

<p align="center">
  <a href="docs/images/airport-overview.png"><img width="920" alt="机场订阅列表、Surge 配置和写入入口" src="docs/images/airport-overview.png"></a>
</p>

<p align="center">
  <a href="docs/images/airport-options.png"><img width="920" alt="编辑机场的代理属性、名称模板和移除关键词" src="docs/images/airport-options.png"></a>
</p>

## 选择同步方式

在“设置”>“同步”中选择以下一种方式：

- **iCloud 云盘**：将生成的模块保存到 Surge 文件夹，通过 iCloud 同步。请确保其他设备已启用 iCloud 云盘，并等待文件下载完成。
- **GitHub 私有仓库**：将模块和生成的脚本发布到私有仓库，通过 Cloudflare Worker 提供订阅地址。完成配置后，在 Surge 中添加对应的固定 URL。

<p align="center">
  <a href="docs/images/sync-icloud.png"><img width="920" alt="iCloud 云盘同步设置" src="docs/images/sync-icloud.png"></a>
</p>

<p align="center">
  <a href="docs/images/sync-github.png"><img width="920" alt="GitHub 私有仓库与 Cloudflare 发布设置" src="docs/images/sync-github.png"></a>
</p>

发布后的文件可继续被设备读取。Mac 离线期间不会获取或转换新的上游内容；重新上线后，可手动刷新或等待下一次自动刷新。

## 在 Surge 中使用汇总模块

Surge Relay 分别生成适用于 iOS 和 iPadOS、macOS、tvOS、visionOS 的汇总模块。不同平台可以启用不同的来源。请在设备上安装对应平台的模块，并在 Surge 中启用。

<p align="center">
  <a href="docs/images/surge-macos.png"><img width="68%" align="middle" alt="在 Surge Mac 的模块设置中启用 macOS 汇总模块" src="docs/images/surge-macos.png"></a>
  <a href="docs/images/surge-iphone.png"><img width="28%" align="middle" alt="在 Surge iPhone 中启用 iOS 和 iPadOS 汇总模块" src="docs/images/surge-iphone.png"></a>
</p>

## 服务器与客户端模式

在“设置”>“Surge Ponte”中选择这台 Mac 的用途：

- **服务器模式**：在这台 Mac 上保存来源配置、获取订阅、执行转换和发布。服务器需要保持运行，可以关闭主窗口并通过菜单栏使用。
- **客户端模式**：连接另一台运行 Surge Relay 的 Mac，查看和管理服务器上的模块与机场订阅。输入服务器的 Surge Ponte 地址后，点按“测试连接”。

使用客户端前，请在服务器上开启 Web 管理，并确保客户端可以通过 Surge Ponte 访问该地址。客户端不再开启另一套 Web 服务。

<p align="center">
  <a href="docs/images/ponte-client.png"><img width="920" alt="Surge Ponte 设置中的服务器模式和客户端模式切换，以及服务器地址输入框" src="docs/images/ponte-client.png"></a>
</p>

## 使用 Web 管理

在服务器的“设置”>“Web 管理”中开启服务，然后在浏览器中打开显示的地址。同一网络中的设备可使用 Bonjour 地址；通过 Surge Ponte 连接时，使用服务器的 Ponte 地址及 Web 管理端口。

Web 界面支持模块与机场编辑、正文预览、刷新和设置管理，适用于 Mac、iPad 和 iPhone 的浏览器。

<p align="center">
  <a href="docs/images/web-ipad.png"><img width="68%" align="middle" alt="iPad Safari 中的 Surge Relay Web 管理界面" src="docs/images/web-ipad.png"></a>
  <a href="docs/images/web-iphone.png"><img width="28%" align="middle" alt="iPhone Safari 中的 Surge Relay Web 管理界面" src="docs/images/web-iphone.png"></a>
</p>

### 7. 机场订阅的两种输出方式

机场订阅继续复用同一套下载、解析、过滤、重命名、节点处理和去重流程，并可在编辑界面二选一：

- **写入 Surge 配置**：保持原有行为，将处理后的节点写入所选 Surge 配置。
- **发布为 `.proxies`**：只生成 Surge Proxy Definition，不包含 `[Proxy]`、`[Proxy Group]` 或其他 Section；刷新成功后原子更新 GitHub 文件。

GitHub 发布仓库使用两个根目录下的平级资源族：

```text
modules/*.sgmodule
modules/assets/*.js
airports/*.proxies
```

模块与机场界面都会给出可以直接复制的 Cloudflare Worker URL，分别采用 `/modules/...` 和 `/airports/...` 路径。机场文件名使用机场名称，中文、英文、数字和空格会被保留，URL 请求时逐段正确编码；非法路径名称和同名冲突会被阻止。

## 构建、发布与自动更新

本 fork 仅构建 Apple Silicon `arm64`。PR 与非 `main` 分支 push 会运行 arm64 编译、测试、Worker 路由测试和 executable 架构校验；代码进入 `main` 后自动执行正式 Release。GitHub Actions 的 **Release arm64 → Run workflow** 仍可用于手动补发。

正式版本、Build、Tag 均为 Asia/Shanghai 构建时间生成的 12 位 `yyyyMMddHHmm`，不带 `v` 前缀。发布包名称为 `Surge-Relay-yyyyMMddHHmm-arm64.zip`。Actions 自动提交的纯 `appcast.xml` 变更不会再次触发 Release。Sparkle Feed 已切换到 `Primovist/SurgeRelay-macOS`，签名与首次部署步骤见 [Fork Release 与 Sparkle 配置](docs/Fork-Release-Sparkle.md)。

## 如果遇到“App 已损坏，无法打开，你应将其移到废纸篓”
此提示并不代表 App 真的损坏。只是因为没有经过 Apple 付费公证，macOS 自动加上了“隔离”标记。

在服务器的“设置”>“Web 管理”中开启“允许本机 Agent 访问”，拷贝访问令牌，并选择允许的操作。外部工具可通过 REST API 或 MCP 查询状态、搜索配置、预览修改，以及执行刷新和发布。

默认只允许读取。修改会先生成预览，应用前检查内容是否已经变化。具体配置和调用示例见[自动化访问](docs/Automation.md)。

## 如果 Mac 无法打开 Surge Relay

如果系统提示 App 已损坏或无法验证开发者，请先确认安装包来自本仓库的 Releases 页面。确认后，可打开“终端”App，输入以下命令并按下 Return 键：

```bash
sudo xattr -rd com.apple.quarantine "/Applications/Surge Relay.app"
```

输入 Mac 登录密码后，再次打开 Surge Relay。输入密码时，“终端”不会显示字符。

## 从源码构建

使用 Xcode 打开 `Surge Relay.xcodeproj`，选择 `Surge Relay` scheme 后运行。项目使用 Swift 6 和 SwiftUI；首次构建需要下载 Sparkle 依赖。

本仓库 fork 自 [EEliberto/SurgeRelay-macOS](https://github.com/EEliberto/SurgeRelay-macOS)。原项目版权、许可证、第三方声明与署名继续保留，详见 [LICENSE](LICENSE) 与 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。

本项目展示页面中的模块、模块名称、作者名称及相关来源，仅用于说明 Surge Relay 的模块管理、转换、汇总和分发能力，不代表本项目对任何模块内容、使用方式、适用场景或安全性的推荐、背书、指导或保证。

```sh
xcodegen generate
```

<details>
  <summary>模块来源与使用声明</summary>
  <br>
  Surge Relay 仅提供模块管理、转换、编辑和发布功能。README 中出现的模块、作者和来源仅用于展示产品能力，不代表推荐、背书或安全保证。模块的版权、署名、许可协议和使用限制均归原作者或原项目所有。使用、转换、编辑、分发或订阅模块前，请确认相应来源、许可、用途和风险。
  <br><br>
  示例可能包含 Surge Relay、@小白脸、@xream、@keywos、@ckyb、Ethan、<a href="https://github.com/RuCu6">RuCu6</a>、<a href="https://github.com/Maasea">Maasea</a>、<a href="https://github.com/fmz200">fmz200</a>、<a href="https://github.com/kelv1n1n">kelv1n1n</a>、<a href="https://github.com/luestr/ProxyResource/blob/main/README.md">可莉</a>、<a href="https://github.com/zmqcherish">zmqcherish</a>、<a href="https://github.com/VirgilClyne">VirgilClyne</a>、<a href="https://github.com/zirawell">zirawell</a>、wish 和奶思等来源。
</details>

<br>

<div align="center">
  <p><a href="https://github.com/EEliberto/SurgeRelay-macOS/issues">报告问题</a>&nbsp;&nbsp;·&nbsp;&nbsp;<a href="LICENSE">Apache License 2.0</a>&nbsp;&nbsp;·&nbsp;&nbsp;<a href="THIRD_PARTY_NOTICES.md">第三方软件声明</a></p>
  <sub>Surge Relay 与 Surge、Apple、GitHub、Cloudflare 及文中提及的模块项目无隶属关系。相关名称和商标归各自所有者所有。</sub>
</div>
