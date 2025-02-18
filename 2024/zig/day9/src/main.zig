const std = @import("std");
const assert = std.debug.assert;

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip();
    const filename = args.next() orelse {
        std.debug.print("Filename missing", .{});
        return;
    };
    const file = std.fs.cwd().openFile(filename, .{}) catch {
        std.debug.print("Failed to open a file", .{});
        return;
    };
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var line_buffer = std.ArrayList(u8).init(alloc);
    defer line_buffer.deinit();

    const reader = file.reader();
    const writer = line_buffer.writer();

    try reader.streamUntilDelimiter(writer, '\n', null);

    const parsed = try parse(line_buffer.items, alloc);
    // const p1 = try part1(parsed);
    const p2 = try part2(parsed, alloc);
    // std.debug.print("Part 1: {}\n", .{p1});
    std.debug.print("Part 2: {}\n", .{p2});
}

fn find_space(i_disk: []segment, start: usize) !usize {
    for (start..i_disk.len) |index| {
        if (i_disk[index].type == .SPACE) return index;
    }
    return error.NoMoreSpace;
}

fn find_file(i_disk: []segment, start: usize) !usize {
    var i = start;
    while (i >= 0) {
        if (i_disk[i].type == .FILE) return i;
        i -= 1;
    }
    return error.EndOfDisk;
}

const inode = struct { start: usize, len: usize, id: ?u32 };

fn find_files(i_disk: *[]segment, alloc: std.mem.Allocator) ![]inode {
    const states = enum { IN_FILE, IN_SPACE };
    var state: states = .IN_FILE;

    var buffer = std.ArrayList(inode).init(alloc);
    defer buffer.deinit();
    var current_file_len: usize = 0;
    var inode_ptr: *inode = undefined;

    inode_ptr = try buffer.addOne();
    inode_ptr.start = 0;
    inode_ptr.id = 0;

    for (i_disk.*, 0..) |seg, i| {
        switch (state) {
            .IN_FILE => {
                switch (seg.type) {
                    .FILE => {
                        if (seg.file_id == inode_ptr.id) {
                            current_file_len += 1;
                        } else {
                            inode_ptr.len = current_file_len;
                            current_file_len = 1;
                            inode_ptr = try buffer.addOne();
                            inode_ptr.start = i;
                            inode_ptr.id = seg.file_id;
                        }
                    },
                    .SPACE => {
                        inode_ptr.len = current_file_len;
                        state = .IN_SPACE;
                    },
                }
            },
            .IN_SPACE => {
                switch (seg.type) {
                    .FILE => {
                        current_file_len = 1;
                        inode_ptr = try buffer.addOne();
                        inode_ptr.start = i;
                        inode_ptr.id = seg.file_id;
                        state = .IN_FILE;
                    },
                    .SPACE => {},
                }
            },
        }
    }
    inode_ptr.len = current_file_len;
    const rval = try alloc.alloc(inode, buffer.items.len);
    std.mem.copyForwards(inode, rval, buffer.items);
    return rval;
}

fn get_space_size(i_disk: *[]segment, start: usize) usize {
    var rval: usize = 0;
    var seg: *segment = undefined;
    for (start..i_disk.len) |i| {
        seg = &i_disk.*[i];
        switch (seg.type) {
            .SPACE => {
                rval += 1;
            },
            .FILE => {
                return rval;
            },
        }
    }
    return rval;
}

fn part2(i_disk: []segment, alloc: std.mem.Allocator) !u128 {
    var checksum: u128 = 0;
    var disk = i_disk;
    var space_size: usize = undefined;
    var space_index: usize = undefined;
    const files = try find_files(&disk, alloc);
    var file: inode = undefined;
    var i: i32 = @intCast(files.len - 1);
    while (i >= 0) {
        file = files[@intCast(i)];
        std.debug.print("File {?} size {}\n", .{ file.id, file.len });
        space_index = 0;
        while (true) {
            space_index = find_space(disk, space_index) catch {
                break;
            };
            if (space_index >= file.start) {
                break;
            }
            space_size = get_space_size(&disk, space_index);
            if (space_size >= file.len) {
                for (0..file.len) |index| {
                    std.mem.swap(segment, &disk[file.start + index], &disk[space_index + index]);
                }
                break;
            } else {
                space_index += space_size;
            }
        }
        i -= 1;
    }

    for (disk, 0..) |seg, index| {
        switch (seg.type) {
            .SPACE => {},
            .FILE => {
                if (seg.file_id) |id| {
                    checksum += @as(u32, @intCast(index)) * id;
                } else {
                    unreachable;
                }
            },
        }
    }
    return checksum;
}
fn part1(i_disk: []segment) !u128 {
    var disk = i_disk;
    var checksum: u128 = 0;

    var space_index: usize = find_space(disk, 0);
    var file_index: usize = try find_file(disk, disk.len - 1);

    while (space_index < file_index) {
        std.mem.swap(segment, &disk[space_index], &disk[file_index]);
        space_index = find_space(disk, space_index + 1);
        file_index = try find_file(disk, file_index - 1);
    }
    for (disk, 0..) |seg, index| {
        switch (seg.type) {
            .SPACE => {},
            .FILE => {
                if (seg.file_id) |id| {
                    checksum += @as(u32, @intCast(index)) * id;
                } else {
                    unreachable;
                }
            },
        }
    }

    return checksum;
}

fn print_disk(disk: []segment) void {
    for (disk) |seg| {
        switch (seg.type) {
            .SPACE => {
                std.debug.print(".", .{});
            },
            .FILE => {
                std.debug.print("{?}", .{seg.file_id});
            },
        }
    }
    std.debug.print("\n", .{});
}

const parse_state = enum { SPACE, FILE };
const segment = struct {
    type: parse_state,
    file_id: ?u32,
};

fn parse(input: []u8, alloc: std.mem.Allocator) ![]segment {
    var disk = std.ArrayList(segment).init(alloc);

    var intbuf = [1]u8{undefined};
    var number: u32 = undefined;
    var state: parse_state = .FILE;
    var file_id: u32 = 0;

    for (input) |char| {
        intbuf[0] = char;
        number = try std.fmt.parseInt(u32, &intbuf, 10);
        var seg_ptr: *segment = undefined;
        switch (state) {
            .FILE => {
                for (0..number) |_| {
                    seg_ptr = try disk.addOne();
                    seg_ptr.file_id = file_id;
                    seg_ptr.type = .FILE;
                }
                file_id += 1;
                state = .SPACE;
            },
            .SPACE => {
                for (0..number) |_| {
                    seg_ptr = try disk.addOne();
                    seg_ptr.file_id = undefined;
                    seg_ptr.type = .SPACE;
                }
                state = .FILE;
            },
        }
    }

    return disk.items;
}
