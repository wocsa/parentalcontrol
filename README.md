# parentalcontrol
Parental Control tools for children safety

## Network filtering

### Openwrt Routers

### Safe Search

https://openwrt.org/packages/pkgdata/safe-search

### Blacklists

[blacklist update script](tools/openwrt/openwrt_blacklist_update.sh)

### Proxy

[TinyProxy Transparent Proxy](https://openwrt.org/docs/guide-user/services/proxy/tinyproxy)

[LUCI Interface for Tiny Proxy](https://openwrt.org/packages/pkgdata_lede17_1/luci-app-tinyproxy)

#### Whitelist Filtering

 * Go into LUCI Interface, Services, TinyProxy
 * Go into Filtering and ACLs Tab
 * Tick "Default deny"
 * Upload white list of domains in "Filter file" item
 * Click on Save & Apply
