# This file is generated by Dist::Zilla::Plugin::CPANFile v6.032
# Do not edit this file directly. To change prereqs, edit the `dist.ini` file.

requires "DateTime" => "0";
requires "Moose::Role" => "0";
requires "Moose::Util::TypeConstraints" => "0";
requires "Text::CSV_XS" => "0";
requires "perl" => "5.010";

on 'build' => sub {
  requires "Module::Build" => "0.28";
};

on 'test' => sub {
  requires "File::Spec" => "0";
  requires "File::Temp" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Test::More" => "0";
};

on 'configure' => sub {
  requires "Module::Build" => "0.28";
};
