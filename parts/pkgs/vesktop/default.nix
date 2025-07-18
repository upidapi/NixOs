{
  vesktop,
  git,
  ...
}:
vesktop.overrideAttrs (old: rec {
  patches =
    (old.patches or [])
    ++ [
      ./fix-readonly.patch
      # ./remove-splash.patch
      # ./tray-notifications.patch
    ];

  p1 = ./0001-change-shiggy-to-vesktop-icon.patch;

  # you can use https://www.piskelapp.com to create pixel art gifs
  # then use gimp to remove the yellow pixel artifacts

  postPatch =
    (old.postPatch or "")
    + ''
      ${git}/bin/git apply ${p1}
    '';

  # without this the build fails, you may wonder why, if you do
  # then you'll have to continue wondering since i don't know
  pnpmDeps = old.pnpmDeps.overrideAttrs {
    outputHash = "sha256-rizJu6v04wFEpJtakC2tfPg/uylz7gAOzJiXvUwdDI4=";
  };
})
