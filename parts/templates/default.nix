{
  # nix flake init -t /persist/nixos#python-venv
  # nix flake update
  # dirwnv allow

  flake.templates = {
    python-venv = {
      path = ./python-venv;
      description = "Development environment for python";
    };
    python-uv = {
      path = ./python-uv;
      description = "Development environment for python";
    };
    # https://lavafroth.is-a.dev/post/cuda-on-nixos-without-sacrificing-ones-sanity/
  };
}
