const std = @import("std");
const os = std.os;
const mem = std.mem;
const math = std.math;
const assert = std.debug.assert;
const MakeFilesystemStep = @This();

const InstallDir = std.build.InstallDir;
const Builder = std.build.Builder;
const CompileStep = std.build.CompileStep;
const Step = std.build.Step;

const fs = @import("fs.zig");
const stat = @import("stat.zig");
const param = @import("param.zig");

const NINODES = 200;

// Disk layout:
// [ boot block | sb block | log | inode blocks | free bit map | data blocks ]

const nbitmap: i32 = param.FSSIZE / (fs.BSIZE * 8) + 1;
const ninodeblocks: i32 = NINODES / fs.IPB + 1;
const nlog: i32 = param.LOGSIZE;

const zeroes = [_]u8{0} ** fs.BSIZE;
var sb: fs.SuperBlock = undefined;
var freeinode: u32 = 1;
var freeblock: u32 = undefined;
var file: std.fs.File = undefined;

step: Step,
builder: *Builder,
artifacts: std.ArrayList(*CompileStep),
dest_dir: InstallDir,
dest_filename: []const u8,
output_file: std.build.GeneratedFile,

pub fn create(builder: *Builder, artifacts: std.ArrayList(*CompileStep), dest_filename: []const u8) *MakeFilesystemStep {
    const self = builder.allocator.create(MakeFilesystemStep) catch unreachable;
    self.* = MakeFilesystemStep{
        .step = Step.init(.custom, builder.fmt("make filesystem image {s}", .{dest_filename}), builder.allocator, make),
        .builder = builder,
        .artifacts = artifacts,
        .dest_dir = .bin,
        .dest_filename = dest_filename,
        .output_file = std.build.GeneratedFile{ .step = &self.step },
    };

    for (artifacts.items) |artifact| {
        self.step.dependOn(&artifact.step);
    }

    builder.pushInstalledFile(self.dest_dir, dest_filename);
    return self;
}

pub fn getOutputSource(self: *const MakeFilesystemStep) std.build.FileSource {
    return std.build.FileSource{ .generated = &self.output_file };
}

fn make(step: *Step) !void {
    const self = @fieldParentPtr(MakeFilesystemStep, "step", step);
    const b = self.builder;

    var full_src_paths = std.ArrayList([]const u8).init(b.allocator);
    try full_src_paths.append("README");
    for (self.artifacts.items) |artifact| {
        try full_src_paths.append(artifact.getOutputSource().getPath(b));
    }

    const full_dest_path = b.getInstallPath(self.dest_dir, self.dest_filename);
    self.output_file.path = full_dest_path;

    std.fs.cwd().makePath(b.getInstallPath(self.dest_dir, "")) catch unreachable;

    var dir = try std.fs.cwd().openDir(b.getInstallPath(self.dest_dir, ""), .{});
    defer dir.close();

    var de: fs.Dirent = undefined;
    var buf: [fs.BSIZE]u8 = undefined;
    var din: fs.Dinode = undefined;

    assert(fs.BSIZE % @sizeOf(fs.Dinode) == 0);
    assert(fs.BSIZE % @sizeOf(fs.Dirent) == 0);

    file = try dir.createFile(
        self.dest_filename,
        .{
            .read = true,
            .truncate = true,
            .mode = os.S.IRUSR | os.S.IWUSR | os.S.IRGRP |
                os.S.IWGRP | os.S.IROTH | os.S.IWOTH,
        },
    );
    defer file.close();

    const nmeta = 2 + nlog + ninodeblocks + nbitmap;
    const nblocks = param.FSSIZE - nmeta;

    sb = fs.SuperBlock{
        .magic = fs.FSMAGIC,
        .size = param.FSSIZE,
        .nblocks = nblocks,
        .ninodes = NINODES,
        .nlog = nlog,
        .logstart = 2,
        .inodestart = 2 + nlog,
        .bmapstart = 2 + nlog + ninodeblocks,
    };

    freeblock = nmeta; // the first free block that we can allocate
    var i: usize = 0;
    while (i < param.FSSIZE) : (i += 1) {
        try wsect(i, &zeroes);
    }

    mem.set(u8, &buf, 0);
    mem.copy(u8, &buf, mem.asBytes(&sb));
    try wsect(1, &buf);

    const rootino = @intCast(u16, try ialloc(.dir));
    std.debug.assert(rootino == fs.ROOTINO);

    mem.set(u8, mem.asBytes(&de), 0);
    de.inum = mem.readVarInt(u16, mem.asBytes(&rootino), .Little);
    mem.copy(u8, &de.name, ".");
    try iappend(@as(u32, rootino), mem.asBytes(&de));

    mem.set(u8, mem.asBytes(&de), 0);
    de.inum = mem.readVarInt(u16, mem.asBytes(&rootino), .Little);
    mem.copy(u8, &de.name, "..");
    try iappend(@as(u32, rootino), mem.asBytes(&de));

    for (full_src_paths.items) |full_src_path| {
        var path = full_src_path;
        var shortname = std.fs.path.basename(path);

        const bin = try std.fs.cwd().openFile(path, .{});
        defer bin.close();

        if (shortname[0] == '_') {
            shortname = shortname[1..];
        }

        var inum = @intCast(u16, try ialloc(.file));
        mem.set(u8, mem.asBytes(&de), 0);
        de.inum = mem.readVarInt(u16, mem.asBytes(&inum), .Little);
        mem.copy(u8, &de.name, shortname);
        try iappend(@as(u32, rootino), mem.asBytes(&de));

        while (true) {
            const amt = try bin.reader().read(&buf);
            if (amt == 0) break;
            try iappend(@as(u32, inum), buf[0..amt]);
        }
    }

    // fix size of root inode dir
    try rinode(@as(u32, rootino), &din);
    var off = mem.readVarInt(u32, mem.asBytes(&din.size), .Little);
    off = ((off / fs.BSIZE) + 1) * fs.BSIZE;
    din.size = mem.readVarInt(u32, mem.asBytes(&off), .Little);
    try winode(@as(u32, rootino), &din);

    try balloc(@as(usize, freeblock));
}

fn wsect(sec: usize, buf: []const u8) !void {
    std.debug.assert(buf.len == fs.BSIZE);
    try file.seekTo(sec * fs.BSIZE);
    const num_write = try file.writer().write(buf);
    std.debug.assert(num_write == buf.len);
}

fn rsect(sec: usize, buf: []u8) !void {
    std.debug.assert(buf.len == fs.BSIZE);
    try file.seekTo(sec * fs.BSIZE);
    const num_read = try file.reader().read(buf);
    std.debug.assert(num_read == buf.len);
}

fn winode(inum: u32, ip: *fs.Dinode) !void {
    var buf: [fs.BSIZE]u8 = undefined;
    var bn = sb.IBLOCK(inum);
    try rsect(bn, &buf);
    var dip = buf[(inum % fs.IPB) * @sizeOf(fs.Dinode) ..];
    mem.copy(u8, dip, mem.asBytes(ip));
    try wsect(bn, &buf);
}

fn rinode(inum: u32, ip: *fs.Dinode) !void {
    var buf: [fs.BSIZE]u8 = undefined;
    var bn = sb.IBLOCK(inum);
    try rsect(bn, &buf);
    var dip = buf[(inum % fs.IPB) * @sizeOf(fs.Dinode) ..];
    mem.copy(u8, mem.asBytes(ip), dip[0..@sizeOf(fs.Dinode)]);
}

fn ialloc(@"type": stat.FileType) !u32 {
    var inum = freeinode;
    defer freeinode += 1;

    var din: fs.Dinode = undefined;
    mem.set(u8, mem.asBytes(&din), 0);
    var din_bytes = mem.toBytes(@enumToInt(@"type"));
    din.type = mem.readVarInt(i16, &din_bytes, .Little);
    din.nlink = mem.readVarInt(i16, &[_]u8{1}, .Little);
    din.size = mem.readVarInt(u32, &[_]u8{0}, .Little);

    try winode(inum, &din);
    return inum;
}

fn balloc(used: usize) !void {
    var buf: [fs.BSIZE]u8 = undefined;
    mem.set(u8, &buf, 0);

    std.debug.assert(used < fs.BSIZE * 8);

    for (buf[0..used]) |_, i| {
        buf[i / 8] |= @as(u8, 0x1) << @intCast(u3, (i % 8));
    }

    try wsect(sb.bmapstart, &buf);
}

fn iappend(inum: u32, data: []const u8) !void {
    var din: fs.Dinode = undefined;
    var buf: [fs.BSIZE]u8 = undefined;
    var n: usize = data.len;
    var n1: usize = undefined;
    var idx: usize = 0;
    var indirect: [fs.NINDIRECT]u32 = undefined;

    try rinode(inum, &din);
    var off = mem.readVarInt(u32, mem.asBytes(&din.size), .Little);

    while (n > 0) : ({
        n -= n1;
        off += @intCast(u32, n1);
        idx += n1;
    }) {
        var fbn = off / fs.BSIZE;
        std.debug.assert(fbn < fs.MAXFILE);
        var x = if (fbn < fs.NDIRECT) blk: {
            if (mem.readVarInt(u32, mem.asBytes(&din.addrs[fbn]), .Little) == 0) {
                var fblk = mem.readVarInt(u32, mem.asBytes(&freeblock), .Little);
                defer freeblock += 1;
                din.addrs[fbn] = fblk;
            }
            break :blk mem.readVarInt(usize, mem.asBytes(&din.addrs[fbn]), .Little);
        } else blk: {
            if (mem.readVarInt(u32, mem.asBytes(&din.addrs[fs.NDIRECT]), .Little) == 0) {
                var fblk = mem.readVarInt(u32, mem.asBytes(&freeblock), .Little);
                defer freeblock += 1;
                din.addrs[fs.NDIRECT] = fblk;
            }
            var num = mem.readVarInt(usize, mem.asBytes(&din.addrs[fs.NDIRECT]), .Little);
            try rsect(num, mem.sliceAsBytes(&indirect));
            if (indirect[fbn - fs.NDIRECT] == 0) {
                var fblk = mem.readVarInt(u32, mem.asBytes(&freeblock), .Little);
                defer freeblock += 1;
                indirect[fbn - fs.NDIRECT] = fblk;
                try wsect(num, mem.sliceAsBytes(&indirect));
            }
            break :blk mem.readVarInt(usize, mem.asBytes(&indirect[fbn - fs.NDIRECT]), .Little);
        };
        n1 = math.min(n, (fbn + 1) * fs.BSIZE - off);
        try rsect(x, &buf);

        mem.copy(u8, buf[off - (fbn * fs.BSIZE) ..], data[idx..][0..n1]);
        try wsect(x, &buf);
    }
    din.size = mem.readVarInt(u32, mem.asBytes(&off), .Little);
    try winode(inum, &din);
}
