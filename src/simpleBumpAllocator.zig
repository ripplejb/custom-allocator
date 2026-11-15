const std = @import("std");
const Alignment = std.mem.Alignment;
const SimpleBumpAllocator = @This();

_buffer: []u8,
_offset: usize,

pub fn init() !SimpleBumpAllocator {
    return .{
        ._buffer = try std.heap.page_allocator.alloc(u8, 1024 * 1024),
        ._offset = 0,
    };
}

pub fn deinit(self: *SimpleBumpAllocator) void {
    std.heap.page_allocator.free(self._buffer);
    self._offset = 0;
}

pub fn reset(self: *SimpleBumpAllocator) void {
    @memset(self._buffer[0..self._offset], undefined);
    self._offset = 0;
}

pub fn allocator(self: *SimpleBumpAllocator) std.mem.Allocator {
    return .{
        .ptr = self,
        .vtable = &.{
            .alloc = allocImpl,
            .resize = resizeImpl,
            .remap = remapImpl,
            .free = freeImpl,
        },
    };
}

pub fn allocImpl(ptr: *anyopaque, len: usize, alignment: Alignment, _: usize) ?[*]u8 {
    const self: *SimpleBumpAllocator = @ptrCast(@alignCast(ptr));

    const new_addr_padding = self.calculateNewOffset(alignment) catch {
        return null;
    };

    const new_offset = std.math.add(usize, new_addr_padding, len) catch {
        return null;
    };
    if (new_offset > self._buffer.len) {
        return null;
    }
    self._offset = new_offset;
    const result_ptr: [*]u8 = self._buffer[new_addr_padding..].ptr;
    return result_ptr;
}

pub fn resizeImpl(ptr: *anyopaque, memory: []u8, _: Alignment, new_len: usize, _: usize) bool {
    const self: *SimpleBumpAllocator = @ptrCast(@alignCast(ptr));

    // Check if the memory is the last block.
    if (memory.ptr != self._buffer[self._offset - memory.len ..].ptr) {
        return false;
    }

    const new_offset = std.math.add(usize, self._offset - memory.len, new_len) catch {
        return false;
    };

    if (new_offset > self._buffer.len) {
        return false;
    }

    self._offset = new_offset;

    return true;
}

pub fn remapImpl(ptr: *anyopaque, memory: []u8, alignment: Alignment, new_len: usize, ret_addr: usize) ?[*]u8 {
    _ = ptr; // autofix
    _ = memory; // autofix
    _ = alignment; // autofix
    _ = new_len; // autofix
    _ = ret_addr; // autofix
    return null;
}

pub fn freeImpl(_: *anyopaque, _: []u8, _: Alignment, _: usize) void {}

fn calculateNewOffset(self: *const SimpleBumpAllocator, alignment: Alignment) !usize {
    const mysize: usize = alignment.toByteUnits();
    // _offset = 0
    const padded = try std.math.add(usize, self._offset, mysize - 1);

    return padded & ~(mysize - 1);
}

test "test allocImpl success" {
    var sba = try SimpleBumpAllocator.init();
    defer sba.deinit();
    const allocatr = sba.allocator();
    const buffer64 = try allocatr.alloc(u64, 100);
    try std.testing.expectEqual(100, buffer64.len);
}

test "test allocImpl failed" {
    var sba = try SimpleBumpAllocator.init();
    defer sba.deinit();
    const allocatr = sba.allocator();
    const buffer64 = allocatr.alloc(u64, 1024 * 1024);
    try std.testing.expectError(error.OutOfMemory, buffer64);
}

test "test Reset success" {
    var sba = try SimpleBumpAllocator.init();
    defer sba.deinit();
    const allocatr = sba.allocator();
    var buffer64 = try allocatr.alloc(u8, 1024 * 1024);
    try std.testing.expectError(error.OutOfMemory, allocatr.alloc(u64, 1));
    sba.reset();
    buffer64 = try allocatr.alloc(u8, 20);
    try std.testing.expectEqual(20, buffer64.len);
}

test "test resize success" {
    var sba = try SimpleBumpAllocator.init();
    defer sba.deinit();
    const alloctr = sba.allocator();
    var buffer64 = try alloctr.alloc(u64, 20);
    try std.testing.expectEqual(@as(usize, 20), buffer64.len);
    buffer64[0] = 123;
    const inc_size = alloctr.resize(buffer64, 25);
    buffer64.len = 25;
    buffer64[24] = 234;
    try std.testing.expect(inc_size);
    try std.testing.expectEqual(@as(usize, 25), buffer64.len);
    const dec_size = alloctr.resize(buffer64, 10);
    buffer64.len = 10;
    try std.testing.expect(dec_size);
    try std.testing.expectEqual(@as(usize, 10), buffer64.len);
    try std.testing.expectEqual(@as(usize, 123), buffer64[0]);
}
