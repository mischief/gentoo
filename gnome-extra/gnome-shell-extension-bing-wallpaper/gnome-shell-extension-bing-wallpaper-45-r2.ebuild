# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit gnome2-utils

DESCRIPTION="Changes your wallpaper daily to the bing.com background image"
HOMEPAGE="https://github.com/neffo/bing-wallpaper-gnome-extension"
SRC_URI="https://github.com/neffo/bing-wallpaper-gnome-extension/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://patch-diff.githubusercontent.com/raw/neffo/bing-wallpaper-gnome-extension/pull/215.patch -> ${P}-gnome45.patch"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-libs/glib:2
	app-eselect/eselect-gnome-shell-extensions
	>=gnome-base/gnome-shell-3.36
	net-libs/libsoup:2.4
"
DEPEND=""
BDEPEND=""

S="${WORKDIR}/bing-wallpaper-gnome-extension-${PV}"
extension_uuid="BingWallpaper@ineffable-gmail.com"

PATCHES=(
	# https://github.com/neffo/bing-wallpaper-gnome-extension/issues/113
	"${FILESDIR}/${PN}-44-unlock-screen.patch"
	# https://github.com/neffo/bing-wallpaper-gnome-extension/pull/215
	"${DISTDIR}/${P}-gnome45.patch"
)

src_install() {
	einstalldocs
	rm -f README.md LICENSE || die
	insinto /usr/share/glib-2.0/schemas
	doins schemas/*.xml
	rm -rf schemas
	insinto /usr/share/gnome-shell/extensions/"${extension_uuid}"
	doins -r *
}

pkg_preinst() {
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_schemas_update
	ebegin "Updating list of installed extensions"
	eselect gnome-shell-extensions update
	eend $?
}

pkg_postrm() {
	gnome2_schemas_update
}
