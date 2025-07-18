{tuxedo-keyboard}:
tuxedo-keyboard.overrideAttrs (old: {
  patches = (old.patches or []) ++ [./tuxedo-keyboard.patch];
})
