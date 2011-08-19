# $Id: Makefile 2010-02-04 23:25:21Z pg $

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-bugreport
PKG_VERSION:=0.0.1
PKG_RELEASE:=2

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-bugreport
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=Applications
  TITLE:=Bugreport
# Uncomment to build package
#  DEPENDS+=+luci-lib-web +luci-app-heartbeat
endef

define Package/luci-app-bugreport/description
  Send a bugreport - outdated. 
endef

define Build/Prepare
# Uncomment to build package
#	mkdir -p $(PKG_BUILD_DIR)
#	$(CP) ./luasrc $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile
# Uncomment to build package
#	$(MAKE) -C $(PKG_BUILD_DIR)/luasrc
endef

define Package/luci-app-bugreport/install
# Uncomment to build package
#	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
#	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
#	$(CP) $(PKG_BUILD_DIR)/luasrc/controller/* $(1)/usr/lib/lua/luci/controller
#	$(CP) $(PKG_BUILD_DIR)/luasrc/view/* $(1)/usr/lib/lua/luci/view
#	$(CP) ./files/* $(1)/
endef

# Uncomment to build package
#$(eval $(call BuildPackage,luci-app-bugreport))
