{
  pkgs,
  lib,
  python3Packages,
  buildPythonPackage ? pkgs.python3Packages.buildPythonPackage,
  setuptools ? pkgs.python3Packages.setuptools,
  numpy ? pkgs.python3Packages.numpy,
  torch ? pkgs.python3Packages.torch,
}:
let
  project = (lib.importTOML ./pyproject.toml).project;

  version = lib.pipe ./zuko/__init__.py [
    builtins.readFile
    (builtins.match ''.*__version__ *= *["']([^"']+)["'].*'')
    builtins.head
  ];
in
buildPythonPackage (finalAttrs: {
  pname = project.name;
  version = version;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./zuko
      ./tests
      ./pyproject.toml
    ];
  };

  pyproject = true;
  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    torch
  ];

  # Test that the package can be imported
  pythonImportsCheck = [ "zuko" ];
  # tests
  doCheck = true;
  nativeCheckInputs = [
    python3Packages.pytestCheckHook
  ];
})
