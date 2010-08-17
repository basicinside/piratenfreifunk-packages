#
# Copyright (C) 2009 Jo-Philipp Wich <xm@subsignal.org>
#
# This is free software, licensed under the Apache 2.0 license.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=heartbeat
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/heartbeat
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=Freifunk
  TITLE:=Heartbeat
  DEPENDS:=\
  +node-id \
  +mac-hash
endef

define Package/heartbeat/description
  Heartbeat polls a heartbeat server everyday which sends position, version, node-id, hostname, landesverband and crew, if choosen.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/heartbeat/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) ./files/sbin/heartbeat $(1)/sbin/heartbeat
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/etc/uci-defaults/* $(1)/etc/uci-defaults
endef

$(eval $(call BuildPackage,heartbeat))
