# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
inherit cmake python-any-r1

DESCRIPTION="C Markdown parser. Fast, SAX-like interface, CommonMark Compliant"
HOMEPAGE="https://github.com/mity/md4c"
SRC_URI="
	https://github.com/mity/md4c/archive/refs/tags/release-${PV}.tar.gz
		-> ${P}.tar.gz
"
S=${WORKDIR}/md4c-release-${PV}

LICENSE="MIT test? ( CC-BY-SA-4.0 )"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~hppa ~loong ppc ppc64 ~riscv x86"

IUSE="+md2html static-libs test"
REQUIRED_USE="test? ( md2html )"
RESTRICT="!test? ( test )"

BDEPEND="
	test? ( ${PYTHON_DEPS} )
"

# md4c upstream doesn't support building both shared and static in one pass.
# CMake respects BUILD_SHARED_LIBS but has no dual-output option, so we do
# a separate configure+compile into a different build dir for static.
CLM_STATIC_BUILD_DIR="${WORKDIR}/${P}_build-static"

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_MD2HTML_EXECUTABLE=$(usex md2html)
		-DBUILD_SHARED_LIBS=ON
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile

	if use static-libs; then
		local BUILD_DIR="${CLM_STATIC_BUILD_DIR}"
		local mycmakeargs=(
			-DBUILD_MD2HTML_EXECUTABLE=OFF
			-DBUILD_SHARED_LIBS=OFF
		)
		cmake_src_configure
		cmake_src_compile
	fi
}

src_install() {
	cmake_src_install

	if use static-libs; then
		insinto "/usr/$(get_libdir)"
		doins "${CLM_STATIC_BUILD_DIR}"/src/libmd4c.a
		doins "${CLM_STATIC_BUILD_DIR}"/src/libmd4c-html.a
	fi
}

src_test() {
	cd "${BUILD_DIR}" || die
	"${EPYTHON}" "${S}"/scripts/run-tests.py || die
}
