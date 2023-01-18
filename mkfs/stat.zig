pub const FileType = enum(u8) {
    dir = 1, // Directory
    file = 2, // File
    device = 3, // Device
};

pub const Stat = extern struct {
    dev: i32, // File system's disk device
    ino: u32, // Inode number
    type: i16, // Type of file
    nlink: i16, // Number of links to file
    size: u64, // Size of file in bytes
};
