# Agent Vanta (binaires précompilés, téléchargement public).
{
  lib,
  stdenvNoCC,
  fetchurl,
  dpkg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "vanta-agent";
  version = "2.20.0";

  src = fetchurl {
    url = "https://agent-downloads.vanta.com/targets/versions/${finalAttrs.version}/vanta-amd64.deb";
    sha256 = "42e67e2b8757239619f2a2aa8093dc32b91b88aa45c2d1538636097fc4b63da6";
  };

  nativeBuildInputs = [ dpkg ];

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -a var $out/
    # L'agent s'exécute et se met à jour depuis /var/vanta (voir le module)
    ln -s /var/vanta/vanta-cli $out/bin/vanta-cli
    runHook postInstall
  '';

  meta = {
    description = "Vanta agent";
    homepage = "https://www.vanta.com/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
