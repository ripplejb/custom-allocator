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

pub fn allocImpl(ptr: *anyopaque, len: usize, alignment: Alignment, ret_addr: usize) ?[*]u8 {
    _ = ret_addr; // autofix
    const self: *SimpleBumpAllocator = @ptrCast(@alignCast(ptr));

    const new_addr_padding = self.calculateNewOffset(alignment) catch {
        return null;
    };
    // move _offset
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

pub fn resizeImpl(ptr: *anyopaque, memory: []u8, alignment: Alignment, new_len: usize, ret_addr: usize) bool {
    _ = ptr; // autofix
    _ = memory; // autofix
    _ = alignment; // autofix
    _ = new_len; // autofix
    _ = ret_addr; // autofix
    return false;
}

pub fn remapImpl(ptr: *anyopaque, memory: []u8, alignment: Alignment, new_len: usize, ret_addr: usize) ?[*]u8 {
    _ = ptr; // autofix
    _ = memory; // autofix
    _ = alignment; // autofix
    _ = new_len; // autofix
    _ = ret_addr; // autofix
    return null;
}

pub fn freeImpl(ptr: *anyopaque, memory: []u8, alignment: Alignment, ret_addr: usize) void {
    _ = ptr; // autofix
    _ = memory; // autofix
    _ = alignment; // autofix
    _ = ret_addr; // autofix
}

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
