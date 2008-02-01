# contents: dot files Makefile.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

.PHONY: all diff install

all: diff

# 1: File
# 2: Target
# 3: Mode
define GROUP_template_file
GROUP_diff_target := $(2).diff
.PHONY diff: $$(GROUP_diff_target)
$$(GROUP_diff_target): $(2) $(1)
	@set $$^ && test "$$$$2" -ot "$$$$1" -o "$$$$2" -nt "$$$$1" && $$(DIFF) -u "$$$$2" "$$$$1" || true

install: $(2)
$(2): $(1)
	$$(INSTALL) -D --mode=$(if $(3),$(3),644) --preserve-timestamps "$$<" "$$@"

endef

# 1: Files
# 2: Parent directory
# 3: Prefix to add
# 4: Prefix to strip
# 5: Mode
define GROUP_template
$(eval $(foreach file,$(1),$(call GROUP_template_file,$(file),$(2)/$(3)$(file:$(4)%=%),$(5))))
endef

DIFF = diff
INSTALL = install

systemconfdir = /etc

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

SECRETETCFILES ?= \
		  denyhosts.conf

$(call GROUP_template,$(ETCFILES),$(systemconfdir),,,600)
$(call GROUP_template,$(SECRETETCFILES),$(systemconfdir),,,644)

aliases = $(systemconfdir)/mail/aliases

install: $(aliases).db

$(aliases).db: $(aliases)
	sudo postalias $<
