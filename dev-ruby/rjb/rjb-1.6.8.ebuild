# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby31 ruby32"

RUBY_FAKEGEM_EXTRADOC="readme.txt ChangeLog"
RUBY_FAKEGEM_TASK_TEST=""

RUBY_FAKEGEM_EXTRAINSTALL="data"

RUBY_FAKEGEM_EXTENSIONS=(ext/extconf.rb)

inherit java-pkg-2 ruby-fakegem

DESCRIPTION="Rjb is a Ruby-Java software bridge"
HOMEPAGE="https://github.com/arton/rjb"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples hardened"

DEPEND=">=virtual/jdk-1.8
	hardened? ( sys-apps/paxctl )"
RDEPEND=">=virtual/jre-1.8:*"

pkg_setup() {
	ruby-ng_pkg_setup
	java-pkg-2_pkg_setup
}

all_ruby_prepare() {
	# The console is not available for testing.
	sed -i -e '/test_noarg_sinvoke/,/end/ s:^:#:' test/test.rb || die

	# Avoid encoding tests since not all locales may be available.
	sed -i -e '/test_kjconv/,/^  end/ s:^:#:' test/test.rb || die

	# Fix build on openjdk-11
	sed -i -e 's#javah -classpath ../data/rjb jp.co.infoseek.hp.arton.rjb.RBridge#javac -h . -classpath ../data/rjb RBridge.java#g' ext/extconf.rb || die
}

each_ruby_prepare() {
	#dev-lang/ruby might need the "hardened" flag to enforce the following:
	if use hardened; then
		paxctl -v /usr/bin/ruby 2>/dev/null | grep MPROTECT | grep disabled || ewarn '!!! rjb will only work if ruby is MPROTECT disabled\n  please disable it if required using paxctl -m /usr/bin/ruby'
	fi
	# force compilation of class file for our JVM
	rm -rf data
}

each_ruby_install() {
	each_fakegem_install

	if use examples; then
		dodoc -r samples
	fi
}

each_ruby_test() {
	if use hardened; then
		paxctl -v ${RUBY} 2>/dev/null | grep MPROTECT | grep -q disabled
		if [ $? = 0 ]; then
			${RUBY} -C test -I../lib:.:../ext test.rb || die
		else
			ewarn "${RUBY} has MPROTECT enabled, rjb will not work until it is disabled, skipping tests."
		fi
	else
		${RUBY} -C test -I../lib:.:../ext test.rb || die
	fi
}
