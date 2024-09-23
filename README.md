# nucomment.nvim
My personal commenting plugin for neovim

# Usage
## Features:
- Floating comments: comment without changing indentation, i.e.
  ```c
     int x = 2;
  // int y = 4;
     return x;
  ```
- Provides commenting as a text object, extending the built-in vim motions such as `<leader>cip` - "comment in paragraph"
- Visual and normal mode support

## Default configuration:
```lua
local default_config = {
    floating_comments = false,
    normal_mapping = "<leader>c",
    visual_mapping = "<leader>c",
    single_line_mapping = "<leader>cc"
}
```
# Not yet supported:
- Markdown and HTML-style comments
