# Bootstrap macOS

## Bootable USB drive
```sh
cd $TMPDIR
git clone https://github.com/munki/macadmin-scripts.git --depth 1 && cd macadmin-scripts
sudo ./installinstallmacos.py --raw
```

1. Choose which macOS build should be downloaded.
2. Wait for the files to be download and the image to be created.
3. Follow the instructions at [Apple Support][support] to create a
   bootable USB drive.

[support]: https://support.apple.com/en-us/HT201372


## System Preferences

### Network
* Set the following DNS servers in this exact order, for each network adapter.

```
1.1.1.1
1.0.0.1
2606:4700:4700::1111
2606:4700:4700::1001
```

## Development Environment
* Install the command line developer tools: `xcode-select --install`.
* Install FUSE for macOS, available at https://osxfuse.github.io.
* Bootstrap tools and development environment: `bash bootstrap.sh`.
