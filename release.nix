with import ./default.nix;
{
 inherit generator tests;
 server = server.package;
}
