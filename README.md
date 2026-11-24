# Custom Allocator

A beginner-friendly Zig project that demonstrates how a custom memory
allocator works through a simple command-line contact book.

The program lets you:

- Add a contact with a name, email, and phone number
- List all saved contacts
- Search for a contact by name
- Remove a contact by phone number
- Exit the program

## How it works

This project includes `SimpleBumpAllocator`, a small custom allocator stored in
`src/simpleBumpAllocator.zig`. It reserves a 1 MiB buffer and gives memory to
allocations in order, from one end of the buffer to the other.

The allocator:

- Aligns allocations correctly
- Returns an out-of-memory error when the 1 MiB buffer is full
- Can grow or shrink the final allocation
- Reclaims the whole buffer when `reset()` is called
- Frees individual allocations only when the complete buffer is reset

The contact book in `src/contacts.zig` uses this allocator. `src/main.zig`
provides the interactive menu.

## Requirements

You need:

- **Zig 0.17.0**
- A terminal or command prompt
- Git, if you plan to clone the project

Zig 0.17.0 is required for this project; earlier or later versions may change
the standard library or build API.

Check that Zig is installed and available on your path:

```sh
zig version
```

The command should print `0.17.0`.

If Zig is not installed, download Zig 0.17.0 from the official Zig website and
follow its installation instructions. Make sure the `zig` executable is in your
system's `PATH`.

## Get the project

Clone the repository:

```sh
git clone https://github.com/ripplejb/custom-allocator.git
cd custom-allocator
```

If you already downloaded the project as a ZIP file, open a terminal inside the
folder that contains `build.zig`.

## Run the contact-book app

From the project root, run:

```sh
zig build run
```

You should see a menu similar to this:

```text
Select your option:
====================
[1] New Contact
[2] List Contacts
[3] Search Contacts
[4] Delete Contact
[5] Exit
```

Enter a menu number and press Enter. Contacts are kept in memory while the
program is running; they are not saved to disk.

## Build only

To compile the executable without running it:

```sh
zig build
```

The executable is created at:

```text
zig-out/bin/custom_allocator
```

You can run it directly:

```sh
./zig-out/bin/custom_allocator
```

On Windows, use:

```powershell
.\zig-out\bin\custom_allocator.exe
```

## Run tests

From the project root, run:

```sh
zig build test
```

The tests cover the custom allocator, contact-book operations, and alignment
helpers.

## Other useful commands

Show all build steps:

```sh
zig build --help
```

Format Zig source files:

```sh
zig fmt build.zig src
```

## Project structure

```text
build.zig                 Zig build configuration
build.zig.zon             Zig package metadata
src/main.zig              Interactive command-line interface
src/contacts.zig          Contact-book data and operations
src/simpleBumpAllocator.zig
                          Custom bump allocator implementation
src/root.zig              Shared module and small utility examples
zig-out/bin/              Built executable output
```
