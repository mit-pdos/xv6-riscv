#!/usr/bin/env python3
"""Extract /pwalk.txt from an xv6 RISC-V filesystem image."""

import argparse
import math
import struct
import sys
from pathlib import Path

BLOCK_SIZE = 1024
FSMAGIC = 0x10203040
ROOT_INUM = 1
T_FILE = 2
NDIRECT = 12
NINDIRECT = BLOCK_SIZE // 4
DINODE_SIZE = 64
DIRENT_SIZE = 16
TARGET_NAME = b"pwalk.txt"


class ImageError(Exception):
    """Raised when the image is invalid or /pwalk.txt cannot be read."""


class Xv6Image:
    def __init__(self, image):
        self.image = image
        self.image.seek(0, 2)
        self.image_size = self.image.tell()
        if self.image_size < 2 * BLOCK_SIZE:
            raise ImageError("image is too small to contain an xv6 superblock")

        self.fs_size = self.image_size // BLOCK_SIZE
        superblock = self.read_block(1)
        (
            magic,
            self.fs_size,
            _nblocks,
            self.ninodes,
            _nlog,
            _logstart,
            self.inodestart,
            _bmapstart,
        ) = struct.unpack_from("<8I", superblock)
        if magic != FSMAGIC:
            raise ImageError(f"unexpected filesystem magic: 0x{magic:08x}")
        if self.fs_size * BLOCK_SIZE > self.image_size:
            raise ImageError("filesystem size in superblock exceeds image size")
        if self.ninodes == 0:
            raise ImageError("superblock declares no inodes")

    def read_block(self, blockno):
        if blockno <= 0 or blockno >= self.fs_size:
            raise ImageError(f"invalid filesystem block number {blockno}")
        self.image.seek(blockno * BLOCK_SIZE)
        data = self.image.read(BLOCK_SIZE)
        if len(data) != BLOCK_SIZE:
            raise ImageError(f"could not read filesystem block {blockno}")
        return data

    def read_inode(self, inum):
        if inum <= 0 or inum >= self.ninodes:
            raise ImageError(f"invalid inode number {inum}")
        blockno = self.inodestart + inum // (BLOCK_SIZE // DINODE_SIZE)
        block = self.read_block(blockno)
        offset = (inum % (BLOCK_SIZE // DINODE_SIZE)) * DINODE_SIZE
        fields = struct.unpack_from("<hhhhI13I", block, offset)
        inode_type, _major, _minor, _nlink, size = fields[:5]
        addresses = fields[5:]
        return inode_type, size, addresses

    def inode_blocks(self, addresses, size):
        count = math.ceil(size / BLOCK_SIZE)
        for index in range(count):
            if index < NDIRECT:
                blockno = addresses[index]
            else:
                indirect_block = addresses[NDIRECT]
                if indirect_block == 0:
                    raise ImageError("file has no indirect block for its recorded size")
                indirect = self.read_block(indirect_block)
                indirect_index = index - NDIRECT
                if indirect_index >= NINDIRECT:
                    raise ImageError("file exceeds xv6's supported inode size")
                blockno = struct.unpack_from("<I", indirect, indirect_index * 4)[0]
            if blockno == 0:
                raise ImageError(f"file is missing data block {index}")
            yield blockno

    def read_inode_data(self, addresses, size):
        output = bytearray()
        for blockno in self.inode_blocks(addresses, size):
            output.extend(self.read_block(blockno))
        return bytes(output[:size])

    def read_pwalk(self):
        inode_type, directory_size, directory_addresses = self.read_inode(ROOT_INUM)
        if inode_type != 1:
            raise ImageError("root inode is not a directory")

        directory = self.read_inode_data(directory_addresses, directory_size)
        target_inum = None
        for offset in range(0, len(directory) - DIRENT_SIZE + 1, DIRENT_SIZE):
            inum = struct.unpack_from("<H", directory, offset)[0]
            name = directory[offset + 2 : offset + DIRENT_SIZE]
            if inum != 0 and name.split(b"\0", 1)[0] == TARGET_NAME:
                target_inum = inum
                break
        if target_inum is None:
            raise ImageError("/pwalk.txt was not found in the root directory")

        inode_type, size, addresses = self.read_inode(target_inum)
        if inode_type != T_FILE:
            raise ImageError("/pwalk.txt is not a regular file")
        return self.read_inode_data(addresses, size)


def main():
    parser = argparse.ArgumentParser(
        description="Extract /pwalk.txt from an xv6 filesystem image.",
        epilog=(
            "Stop QEMU before extraction so fs.img contains the latest writes. "
            "Example: python3 tools/extract_pwalk.py fs.img -o pwalk.txt"
        ),
    )
    parser.add_argument("image", nargs="?", type=Path, default=Path("fs.img"))
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=Path("pwalk.txt"),
        help="host output path (default: pwalk.txt)",
    )
    args = parser.parse_args()

    try:
        with args.image.open("rb") as image_file:
            contents = Xv6Image(image_file).read_pwalk()
        args.output.write_bytes(contents)
    except (OSError, ImageError, struct.error) as error:
        print(f"extract_pwalk: {error}", file=sys.stderr)
        return 1

    print(f"extracted {len(contents)} bytes to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
