//! By convention, root.zig is the root source file when making a package.
const std = @import("std");
const Io = std.Io;

/// This is a documentation comment to explain the `printAnotherMessage` function below.
///
/// Accepting an `Io.Writer` instance is a handy way to write reusable code.
pub fn printAnotherMessage(writer: *Io.Writer) Io.Writer.Error!void {
    try writer.print("Run `zig build test` to run the tests.\n", .{});
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

pub fn getAlignedAddress(comptime T: type, address: usize) usize {
    const mysize: usize = @alignOf(T);

    const padding = ((address + mysize - 1) & ~(mysize - 1)) - address;

    return address + padding;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}

test "test alignmentHelper" {
    const result1 = getAlignedAddress(u16, 30);
    try std.testing.expectEqual(30, result1);

    const result2 = getAlignedAddress(u32, 31);
    try std.testing.expectEqual(32, result2);

    const result3 = getAlignedAddress(u32, 16);
    try std.testing.expectEqual(16, result3);
}
