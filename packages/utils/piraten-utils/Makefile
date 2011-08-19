#
# Copyright (C) 2009 Jo-Philipp Wich <xm@subsignal.org>
#
# This is free software, licensed under the Apache 2.0 license.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=piraten-utils
PKG_RELEASE:=2

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/piraten-utils
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=Freifunk
  TITLE:=PiratenUtils
  DEPENDS+= +node-id
endef

define Package/piraten-utils/description
  Useful utils for the piraten-community.
endef

define Build/Prepare
# Uncomment to build package
#	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/piraten-utils/install
# Uncomment to build package
#	$(CP) ./files/* $(1)/
endef

# Uncomment to build package
#$(eval $(call BuildPackage,piraten-utils))
