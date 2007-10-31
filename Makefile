# contents: dot files Makefile.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

.PHONY: all diff install

all: diff

define GROUP_strip_prefix
$(if $(1),$(patsubst $(1)/%,%,$(2)),$(2))
endef

define GROUP_diff_template
GROUP_diff_target := $(1)/$(call GROUP_strip_prefix,$(2),$(3)).diff
.PHONY: $$(GROUP_diff_target)
diff: $$(GROUP_diff_target)
$$(GROUP_diff_target):
	-@$$(DIFF) -u $$(patsubst %.diff,%,$$@) $(3)

endef

define GROUP_install_template
GROUP_install_target := $(1)/$(call GROUP_strip_prefix,$(2),$(3))
install: $$(GROUP_install_target)
$$(GROUP_install_target): $(3)
	$$(INSTALL) --mode=$(4) $$< $$@

endef

define GROUP_template
target_DIRS := $(addprefix $(1)/,$(call GROUP_strip_prefix,$(2),$(3)))
install: $$(target_DIRS)
$$(target_DIRS):
	$$(INSTALL) --directory --mode=755 $$@
$(foreach file,$(4),$(call GROUP_diff_template,$(1),$(2),$(file)))
$(foreach file,$(4),$(call GROUP_install_template,$(1),$(2),$(file),$(5)))
endef

DIFF = diff
INSTALL = install

systemconfdir = /etc

ETCDIRS = \
	  X11 \
	  defaults \
	  mail \
	  modules.d \
	  pam.d \
	  portage \
	  postfix \
	  security \
	  syslog-ng \
	  xinetd.d \
	  zsh

ETCFILES ?= \
	    X11/xorg.conf \
	    asound.conf \
	    defaults/cdrdao \
	    etc-update.conf \
	    fstab \
	    hosts \
	    locale.gen \
	    mail/aliases \
	    make.conf \
	    modules.d/alsa \
	    pam.d/login \
	    pam.d/sshd \
	    portage/package.keywords \
	    portage/package.unmask \
	    portage/package.use \
	    postfix/main.cf \
	    postfix/master.cf \
	    screenrc \
	    security/pam_mount.conf \
	    syslog-ng/syslog-ng.conf \
	    xinetd.d/bitlbee \
	    xinetd.d/identd \
	    xinetd.d/pure-ftpd \
	    zsh/zshenv

SECRETETCDIRS =

SECRETETCFILES ?= \
		  denyhosts.conf

BINDIRS = \
	  X11/Sessions

BINFILES ?= \
	    X11/Sessions/ratpoison

$(eval $(call GROUP_template,$(systemconfdir),,$(SECRETETCDIRS),$(SECRETETCFILES),600))
$(eval $(call GROUP_template,$(systemconfdir),,$(ETCDIRS),$(ETCFILES),644))
$(eval $(call GROUP_template,$(systemconfdir),,$(BINDIRS),$(BINFILES),755))

aliases = $(systemconfdir)/mail/aliases

install: $(aliases).db

$(aliases).db: $(aliases)
	sudo postalias $<
