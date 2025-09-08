{
  # nix flake init -t /persist/nixos#python-venv
  # nix flake update
  # dirwnv allow

  flake.templates = {
    python-venv = {
      path = ./python-venv;
    };
    python-uv = {
      path = ./python-uv;
    };
    python-uv-old = {
      path = ./python-uv-old;
    };
    # https://lavafroth.is-a.dev/post/cuda-on-nixos-without-sacrificing-ones-sanity/
  };
}
