# python-cmake

Build python as a library that can be embeded to another application, using cmake.

## Dependencies

Mac OS:

```bash
brew install openssl xz zlib libffi
```

Arch Linux:

```bash
sudo pacman -S bzip2 ncurses expat openssl libffi editline readline sqlite gdbm db5.3 xz tcl tk
```

Ubuntu:

```bash
sudo apt install libssl-dev zlib1g-dev libncurses5-dev \
  libncursesw5-dev libreadline-dev libsqlite3-dev libgdbm-dev \
  libdb5.3-dev libbz2-dev libexpat1-dev liblzma-dev libffi-dev
```
