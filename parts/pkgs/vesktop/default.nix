{vesktop, ...}:
vesktop.overrideAttrs (old: {
  patches =
    (old.patches or [])
    ++ [
      ./fix-readonly.patch
      ./remove-splash.patch
      ./tray-notifications.patch
    ];

  /*
  pnpmDeps = old.pnpmDeps.overrideAttrs {
    outputHash = "sha256-o7Hkyuh2HBYNBXYEauQocBrkWmP2CsFS0PiLkeDYrF8=";
  };
  */
})
