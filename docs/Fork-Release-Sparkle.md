# Fork Release 与 Sparkle 配置

本 fork 的自动更新源固定为：

```text
https://raw.githubusercontent.com/Primovist/SurgeRelay-macOS/main/appcast.xml
```

Release Workflow 在代码进入 `main` 后自动运行，也保留 `workflow_dispatch` 手动入口。它只生成 Apple Silicon arm64 ZIP，版本、Build 和 Tag 均使用 Asia/Shanghai 时间的 `yyyyMMddHHmm`。一分钟内重复运行检测到同名 Tag 或 Release 会明确失败，不覆盖旧版本。

## 一次性生成 fork 专用 Sparkle 密钥

不要继续使用上游项目的更新密钥，也不要把私钥提交到 Git。请从 [Sparkle 官方 Release](https://github.com/sparkle-project/Sparkle/releases) 下载与项目版本兼容的 Sparkle 工具，然后在一台可信 Mac 上执行：

```bash
./bin/generate_keys
./bin/generate_keys -x /安全位置/surge-relay-sparkle-private-key
```

第一条命令生成密钥并把私钥保存在当前用户登录钥匙串，同时打印 Base64 公钥。第二条命令导出私钥用于录入 CI。导出的文件应保存在加密、受控的备份位置；录入 GitHub 后不要放进仓库目录。

## GitHub Actions 配置

打开仓库 **Settings → Secrets and variables → Actions**：

1. 在 **Secrets** 新建 `SPARKLE_PRIVATE_KEY`，值为导出私钥文件的完整内容。
2. 在 **Variables** 新建 `SPARKLE_PUBLIC_ED_KEY`，值为 `generate_keys` 打印的 Base64 公钥。

`GITHUB_TOKEN` 由 GitHub Actions 自动提供，无需手工创建。公钥不是秘密，但必须与私钥严格配对。App 的 `SUPublicEDKey` 在 CI 构建时从 `SPARKLE_PUBLIC_ED_KEY` 注入；仓库不会包含伪造公钥或上游私钥。

## 第一次 Release

1. 在 GitHub 仓库中先配置上述 Secret 与 Variable。
2. 提交并推送包含公钥占位构建设置、Workflow 和空 appcast 的代码到 `main`。
3. 该 push 会自动启动 Release Workflow；也可以打开 **Actions → Release arm64 → Run workflow** 手动补发。
4. Workflow 生成 12 位版本并检查冲突，运行测试与 arm64 Release build。
5. Workflow 通过 `lipo -archs` 验证主 executable 只有 `arm64`，检查两个 Bundle 版本、Feed URL 和公钥。
6. Workflow 使用 Sparkle 官方 `generate_appcast` 从标准输入读取私钥，为 ZIP 生成 EdDSA 签名。
7. Workflow 创建同名 Tag 与 `Surge Relay <版本>` Release，上传 `Surge-Relay-<版本>-arm64.zip`，实际下载并比对 ZIP。
8. Workflow 将新条目与最多九条历史记录合并，校验 XML、版本、下载地址和签名后提交 `appcast.xml` 到 `main`。`push` 触发器忽略只有 `appcast.xml` 的提交，因此不会递归创建 Release。

## 更新验证

首次 Release 完成后检查：

```bash
curl -fLO https://github.com/Primovist/SurgeRelay-macOS/releases/download/<版本>/Surge-Relay-<版本>-arm64.zip
unzip -q Surge-Relay-<版本>-arm64.zip
lipo -archs "Surge Relay.app/Contents/MacOS/Surge Relay"
/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "Surge Relay.app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "Surge Relay.app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Print :SUFeedURL' "Surge Relay.app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Print :SUPublicEDKey' "Surge Relay.app/Contents/Info.plist"
```

`lipo` 必须只输出 `arm64`，两个版本必须等于 Tag，Feed 必须指向 Primovist fork，公钥必须等于 GitHub Variable。再从已安装的较旧构建执行“检查更新”，确认 Sparkle 能识别并验证新版本。

当前流程不要求 Developer ID 证书。Sparkle EdDSA 验证的是更新包完整性，与 Developer ID code signing / notarization 是不同层次；未来可在 ZIP 前插入 Developer ID、`notarytool` 和 `stapler` 步骤。

## 上游旧密钥的迁移限制

已经安装、且只信任上游 `SUPublicEDKey` 的旧二进制不能直接信任本 fork 的全新密钥。没有上游私钥时，要让这类二进制无缝自动迁移，需要同一 Developer ID 信任链支持 Sparkle 密钥轮换；当前第一阶段没有该证书。因此第一次使用 fork 独立密钥时，应手工安装本 fork 的首个 arm64 Release 作为引导版本。此后由同一 `SPARKLE_PRIVATE_KEY` 签名的 Release 可以正常自动更新。不要为绕过这项校验而保留上游公钥或伪造密钥。
