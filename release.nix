with import ./default.nix;
{
 inherit generator;
 server = server.package;
}
