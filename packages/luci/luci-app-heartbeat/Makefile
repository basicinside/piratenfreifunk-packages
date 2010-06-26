# $Id: Makefile 2010-02-04 23:25:21Z pg $

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-heartbeat
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-heartbeat
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=Components
  TITLE:=Piraten heartbeat
  DEPENDS+= \
   +luci-web +luci-app-splash \
   +heartbeat
endef

define Package/luci-app-heartbeat/description
  Piraten heartbeat
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-heartbeat/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(CP) ./luasrc/* $(1)/usr/lib/lua/luci
endef

$(eval $(call BuildPackage,luci-app-heartbeat))
