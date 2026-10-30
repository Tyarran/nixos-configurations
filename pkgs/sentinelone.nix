# Agent SentinelOne (binaire propriétaire fourni par l'IT / Barracuda).
# Le .deb n'est JAMAIS dans le dépôt : il doit être ajouté au store de la machine
# avant le build (voir `message`).
{
  lib,
  stdenvNoCC,
  requireFile,
  dpkg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sentinelone-agent";
  version = "25.4.2.21";

  src = requireFile rec {
    name = "SentinelAgent_linux_x86_64_v${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}.deb";
    sha256 = "b26265873b4a1da74655a3cbad4fed919ee545b68a1ff0da909fa77e5886bfdf";
    message = ''
      L'installeur SentinelOne n'est pas redistribuable et n'est pas dans ce dépôt.
      Récupère ${name} (portail Barracuda / IT) puis ajoute-le au store :

        nix-store --add-fixed sha256 /chemin/vers/${name}

      (hash attendu : ${sha256})
    '';
  };

  nativeBuildInputs = [ dpkg ];

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true; # binaires propriétaires : ne rien patcher (nix-ld à l'exécution)

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -a opt $out/
    runHook postInstall
  '';

  meta = {
    description = "SentinelOne Next-Generation Endpoint Protection (installeur .deb)";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
