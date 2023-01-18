// On-disk file system format.
// Both the kernel and user programs use this header file.

pub const ROOTINO = 1; // root i-number
pub const BSIZE = 1024; // block size

// Disk layout:
// [ boot block | super block | log | inode blocks |
//                                          free bit map | data blocks]
//
// mkfs computes the super block and builds an initial file system. The
// super block describes the disk layout:
pub const SuperBlock = extern struct {
    magic: u32, // Must be FSMAGIC
    size: u32, // Size of file system image (blocks)
    nblocks: u32, // Number of data blocks
    ninodes: u32, // Number of inodes.
    nlog: u32, // Number of log blocks
    logstart: u32, // Block number of first log block
    inodestart: u32, // Block number of first inode block
    bmapstart: u32, // Block number of first free map block

    const Self = @This();
    // Block containing inode i
    pub inline fn IBLOCK(self: *Self, i: u32) u32 {
        return i / IPB + self.inodestart;
    }

    // Block of free map containing bit for block b
    pub inline fn BBLOCK(self: *Self, b: u32) u32 {
        return b / BPB + self.bmapstart;
    }
};

pub const FSMAGIC = 0x10203040;

pub const NDIRECT = 12;
pub const NINDIRECT = (BSIZE / @sizeOf(u32));
pub const MAXFILE = (NDIRECT + NINDIRECT);

// On-disk inode structure
pub const Dinode = extern struct {
    type: i16, // File type
    major: i16, // Major device number (T_DEVICE only)
    minor: i16, // Minor device number (T_DEVICE only)
    nlink: i16, // Number of links to inode in file system
    size: u32, // Size of file (bytes)
    addrs: [NDIRECT + 1]u32, // Data block addresses
};

// Inodes per block.
pub const IPB = (BSIZE / @sizeOf(Dinode));

// Bitmap bits per block
pub const BPB = (BSIZE * 8);

// Directory is a file containing a sequence of dirent structures.
pub const DIRSIZ = 14;

pub const Dirent = struct {
    inum: u16,
    name: [DIRSIZ]u8,
};
