# ImmortalWrt-Builder-24.10

这是一个用于自动编译 [ImmortalWrt 24.10](https://github.com/padavanonly/immortalwrt-mt798x-24.10) 固件的 GitHub Actions 工作流，专为 CMCC RAX3000M EMMC设计。支持每周检查源码更新、自动编译固件，并将 `sysupgrade.bin` 文件上传到 GitHub Release。

## 提示
- 刷机有风险！有风险！有风险！
- 由于上游更新造成的uboot和固件不匹配造成无法刷入，原先引用`padavanonly/immortalwrt-mt798x-6.6`仓库转为`padavanonly-mt798x-6.6`分支，下载`RAX3000M-eMMC_XR30-eMMC_Tutorial-Files.7z`获取具体刷机教程和文件，[刷入文件获取](https://github.com/lgs2007m/Actions-OpenWrt/releases/tag/Router-Flashing-Files)。
- 当前main分支转为使用immortalwrt官方的openwrt-24.10

## 功能
- **支持的设备**：`cmcc_rax3000m-emmc`
- **自动编译**：每周一检查源仓库更新，若有新提交，自动为 CMCC RAX3000M EMMC 机型编译固件。
- **固件上传**：上传 `sysupgrade.itb` 文件到 GitHub Release。
- **清理机制**：保留最近 30 个 GitHub Release 和 30 次工作流运行，自动删除旧记录以节省空间。

## 使用方法

### 1. 配置仓库
- Fork 或单独创建一个独立的新仓库到你的GitHub。

### 2. 手动触发编译
- 进入仓库的 **Actions** 页面，选择 `ImmortalWrt-24.10` 工作流。
- 点击 **Run workflow**，选择：
  - `device_model`：默认`cmcc_rax3000m`。
  - `上传所有文件（包括 GPT、preloader、FIP、recovery、sysupgrade）`：用于底层刷机。
- 运行成功后，固件将上传到 GitHub Release 。

### 3. 编译失败
 - 在创建发布时失败：HTTP 403: Resource not accessible by integration (https://api.github.com/repos/PlanetEditorX/ImWRT-798X/releases)
    - 方式一：在 fork 仓库下新建一个 Personal Access Token (classic)（需要 repo 权限），在仓库 Secrets 里添加，比如叫 GH_TOKEN，然后 workflow 里用它替换 GITHUB_TOKEN
    - 方式二：创建一个新仓库，将该仓库除`.git`目录的其它内容移至新仓库（无提交记录）
    - 方式三：裸克隆+镜像推送（包含提交记录）
      ```bash
      git clone --bare https://github.com/PlanetEditorX/ImmortalWrt-CMCC-RAX3000M-EMMC.git
      cd ImmortalWrt-CMCC-RAX3000M-EMMC.git
      git push --mirror <新空仓库地址>
      ```
### 4. 下载固件
- **GitHub Release**：在仓库的 **Releases** 页面查下载 `sysupgrade.itb`固件。

### 5. 刷写固件
- 确认设备型号与固件匹配。
- 备份设备原有固件。
- 进入`U-Boot`配合`TFTP`刷入 `initramfs-recovery.itb`临时系统。
- 使用 `系统-备份与升级-刷写新的固件` 输入`sysupgrade.itb` 文件。
- 具体步骤查看[刷机教程](/files/刷机教程.md)。

### 6. 测试功能
- luci-app-keepalived-ha (主从路由管理)
  - 代码：https://github.com/PlanetEditorX/luci-app-build/tree/main/luci-app-keepalived-ha
  - 功能：仅界面端，方便简化配置keepalived
  - 介绍：在主从路由分别安装好keepalived后，自主编译ipk，或运行一键部署脚本，配置好主从路由信息和虚拟IP地址，将局域网需要的设备打上标签，并在接口`lan`的`DHCP服务器`-`高级设置`中配置`DHCP选项`:`tag:proxy,3,192.168.1.5`和`tag:proxy,6,192.168.1.5`。
  - 正常情况：主路由仅做管理，从路由绑定虚拟IP，标签设备的流量指向从路由
  - 故障情况：从路由9090端口打开失败，或从路由无法被Ping通，主路由接管虚拟IP，标签设备的流量指向主路由
  - 适用场景：主路由如`CMCC RAX3000M EMMC`性能一般，主要负责拨号和管理，在性能较好的从路由上进行相应的流量处理，不影响局域网的其它普通设备上网。仅当从路由失联后，主路由才会接管对应流量，作为后备处理，从路由恢复后又释放虚拟IP，让所有标签流量走从路由

## 源码
- immortalwrt官方仓库：[immortalwrt](https://github.com/immortalwrt/immortalwrt)
- immortalwrt官方分支：[openwrt-24.10](https://github.com/immortalwrt/immortalwrt/tree/openwrt-24.10)
- padavanonly源码仓库：[immortalwrt-mt798x-24.10](https://github.com/padavanonly/immortalwrt-mt798x-24.10)
- padavanonly仓库分支：[openwrt-24.10-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6/tree/openwrt-24.10-6.6)
- 原工作流：[ImWRT-798X](https://github.com/hhCodingCat/ImWRT-798X)
