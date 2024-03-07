{
  res = {data = "data";};

  modules = {
    a = ./a;
    b = ./b;
  };

  res = builtins.mapAttrs (
    (key: val:
      import val {res = res;}
    )
    modules
  );

  res = builtins.trace res res;
}