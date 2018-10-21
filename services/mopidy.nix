{ pkg }:

{
  enable = true;
  extensionPackages = [ pkg ];
  configuration = ''
    [local]
    media_dir = /var/local/music/

    [audio]
    output = pulsesink server=127.0.0.1
'';
}
