# Intel Low Power Mode Daemon (absent de nixpkgs).
{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  glib,
  gtk-doc,
  libxml2,
  libnl,
  systemd,
  upower,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "intel-lpmd";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "intel-lpmd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eZBgWpR2tdSDeqYV4Y2h2j5UeJebQg2tXlXcUywwZEA=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    glib.dev # gdbus-codegen, glib-compile-resources
    gtk-doc # macro GTK_DOC_CHECK de configure.ac
  ];

  buildInputs = [
    glib
    libxml2
    libnl
    systemd
    upower
  ];

  configureFlags = [
    "--sysconfdir=${placeholder "out"}/etc"
    "--localstatedir=/var"
    "--with-dbus-sys-dir=${placeholder "out"}/share/dbus-1/system.d"
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
    "--disable-werror"
  ];

  # Les fichiers de service D-Bus/systemd référencent sbindir (dans $out)
  installFlags = [ "localstatedir=${placeholder "out"}/var" ];

  meta = {
    description = "Intel Linux Energy Optimizer (lpmd) : daemon de basse consommation";
    homepage = "https://github.com/intel/intel-lpmd";
    license = lib.licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "intel_lpmd";
  };
})
