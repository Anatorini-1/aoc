const std = @import("std");

const ArrayList = std.ArrayList;
const Stones = std.hash_map.AutoHashMap(i64, i64);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var args = std.process.args();
    _ = args.skip();
    const file = try std.fs.cwd().openFile(
        args.next() orelse unreachable,
        .{},
    );
    var reader = file.reader();
    var line_buffer = ArrayList(u8).init(alloc);
    defer line_buffer.deinit();
    const writer = line_buffer.writer();

    try reader.streamUntilDelimiter(
        writer,
        '\n',
        null,
    );

    var stones = Stones.init(alloc);
    var diff = Stones.init(alloc);
    var strbuff = ArrayList(u8).init(alloc);
    var numbuff: i64 = undefined;
    defer stones.deinit();
    defer diff.deinit();
    defer strbuff.deinit();

    var iter = std.mem.splitSequence(u8, line_buffer.items, " ");
    while (iter.next()) |number| {
        numbuff = try std.fmt.parseInt(i64, number, 10);
        try stones.put(numbuff, 1);
    }
    line_buffer.clearRetainingCapacity();

    for (0..75) |_| {
        try look(
            &stones,
            &diff,
            &strbuff,
        );
    }

    var rval: i64 = 0;
    var iter2 = stones.iterator();
    while (iter2.next()) |e| {
        rval += e.value_ptr.*;
    }
    std.debug.print("Result: {}\n", .{rval});
}

fn printStones(stones: Stones) void {
    std.debug.print("-------------\n", .{});
    var iter = stones.keyIterator();
    while (iter.next()) |kptr| {
        const key = kptr.*;
        if (stones.get(key) == 0) continue;
        std.debug.print("{}:{}\n", .{ key, stones.get(key) orelse 0 });
    }
    std.debug.print("-------------\n", .{});
}

fn addStone(statee: *Stones, key: i64, val: i64) !void {
    const diff_count = statee.get(key) orelse 0;
    try statee.put(key, val + diff_count);
}

fn applyDiff(state: *Stones, diff: *Stones) !void {
    var iter = diff.iterator();
    while (iter.next()) |e| {
        try addStone(state, e.key_ptr.*, e.value_ptr.*);
    }
}

fn look(
    state: *Stones,
    diff: *Stones,
    strbuff: *ArrayList(u8),
) !void {
    var strlen: usize = 0;
    var iter = state.keyIterator();
    var stone: i64 = undefined;
    var stone_count: i64 = undefined;
    var num: i64 = undefined;

    while (iter.next()) |kptr| {
        stone = kptr.*;
        stone_count = state.get(stone) orelse 0;
        if (stone_count == 0) continue;

        if (stone == 0) {
            try addStone(diff, 1, stone_count);
            try addStone(diff, 0, -stone_count);
            continue;
        }
        strbuff.clearRetainingCapacity();
        try std.fmt.format(strbuff.writer(), "{}", .{stone});
        strlen = strbuff.items.len;
        if (strlen % 2 == 0) {
            num = try std.fmt.parseInt(i64, strbuff.items[0 .. strlen / 2], 10);
            try addStone(diff, num, stone_count);
            try addStone(diff, stone, -stone_count);

            num = try std.fmt.parseInt(i64, strbuff.items[strlen / 2 .. strlen], 10);
            const diff_count = diff.get(num) orelse 0;
            try diff.put(num, stone_count + diff_count);
        } else {
            num = stone * 2024;
            try addStone(diff, num, stone_count);
            try addStone(diff, stone, -stone_count);

            continue;
        }
    }
    try applyDiff(state, diff);
    diff.clearRetainingCapacity();
}
