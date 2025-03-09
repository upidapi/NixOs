{
  flake.templates = {
    python-venv = {
      path = ./python-venv;
      description = "Development environment for python";
    };
    python = {
      path = ./python;
      description = "Development environment for python";
    };
  };
}
