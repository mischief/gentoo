# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=maturin
PYTHON_COMPAT=( python3_{10..12} pypy3 )

CRATES="
	autocfg@1.1.0
	bitflags@1.3.2
	cc@1.0.83
	cfg-if@1.0.0
	crossbeam-channel@0.5.7
	crossbeam-utils@0.8.15
	filetime@0.2.20
	fsevent-sys@4.1.0
	heck@0.4.1
	indoc@2.0.4
	inotify-sys@0.1.5
	inotify@0.9.6
	kqueue-sys@1.0.3
	kqueue@1.0.7
	libc@0.2.140
	lock_api@0.4.9
	log@0.4.17
	memoffset@0.9.0
	mio@0.8.6
	notify@5.1.0
	once_cell@1.17.1
	parking_lot@0.12.1
	parking_lot_core@0.9.7
	proc-macro2@1.0.53
	pyo3-build-config@0.20.0
	pyo3-ffi@0.20.0
	pyo3-macros-backend@0.20.0
	pyo3-macros@0.20.0
	pyo3@0.20.0
	python3-dll-a@0.2.9
	quote@1.0.26
	redox_syscall@0.2.16
	same-file@1.0.6
	scopeguard@1.1.0
	smallvec@1.10.0
	syn@2.0.12
	target-lexicon@0.12.6
	unicode-ident@1.0.8
	unindent@0.2.3
	walkdir@2.3.3
	wasi@0.11.0+wasi-snapshot-preview1
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.5
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-sys@0.42.0
	windows-sys@0.45.0
	windows-targets@0.42.2
	windows_aarch64_gnullvm@0.42.2
	windows_aarch64_msvc@0.42.2
	windows_i686_gnu@0.42.2
	windows_i686_msvc@0.42.2
	windows_x86_64_gnu@0.42.2
	windows_x86_64_gnullvm@0.42.2
	windows_x86_64_msvc@0.42.2
"

inherit cargo distutils-r1

DESCRIPTION="Simple, modern file watching and code reload in Python"
HOMEPAGE="
	https://pypi.org/project/watchfiles/
	https://github.com/samuelcolvin/watchfiles/
"
SRC_URI="
	https://github.com/samuelcolvin/watchfiles/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0-with-LLVM-exceptions ISC MIT Unicode-DFS-2016
	|| ( Artistic-2 CC0-1.0 )
"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"

RDEPEND="
	=dev-python/anyio-3*[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools-rust[${PYTHON_USEDEP}]
	test? (
		dev-python/dirty-equals[${PYTHON_USEDEP}]
		dev-python/pytest-mock[${PYTHON_USEDEP}]
		dev-python/pytest-timeout[${PYTHON_USEDEP}]
	)
"

# enjoy Rust
QA_FLAGS_IGNORED=".*/_rust_notify.*"

distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare

	# fix version number
	sed -i -e "/^version/s:0\.0\.0:${PV}:" Cargo.toml || die
}

python_test() {
	rm -rf watchfiles || die
	epytest
}
