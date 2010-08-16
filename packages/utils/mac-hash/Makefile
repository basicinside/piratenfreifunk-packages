#
# Copyright (C) 2009 Jo-Philipp Wich <xm@subsignal.org>
#
# This is free software, licensed under the Apache 2.0 license.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mac-hash
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/mac-hash
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=Freifunk
  TITLE:=MacHash
  DEPENDS:=
endef

define Package/mac-hash/description
  Reads DHCP Acks and saves hashed mac addr to /tmp/machashes.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/mac-hash/install
	$(CP) ./files/* $(1)/
	chmod +x /sbin/heartbeat
endef

$(eval $(call BuildPackage,mac-hash))
