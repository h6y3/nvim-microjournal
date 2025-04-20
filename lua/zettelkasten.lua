-- Enhanced Zettelkasten features for minimal Neovim setup

-- 1. Backlinks functionality
-- Simple function to find files that link to the current file
local function find_backlinks()
  local current_file = vim.fn.expand('%:t')
  if current_file == '' then
    print("No file open")
    return
  end
  
  -- Use grep to find links to this file (much lighter than Telescope)
  local handle = io.popen('grep -l "\\[\\[' .. current_file:gsub('%.md$', '') .. '\\]\\]" *.md 2>/dev/null || grep -l "(' .. current_file .. ')" *.md 2>/dev/null')
  local result = handle:read("*a")
  handle:close()
  
  -- Parse the results
  local backlinks = {}
  for file in string.gmatch(result, "[^\n]+") do
    if file ~= current_file then -- Don't include self-references
      table.insert(backlinks, file)
    end
  end
  
  -- Display backlinks in a split window
  if #backlinks > 0 then
    -- Create a new buffer for backlinks
    vim.cmd('botright new')
    vim.cmd('setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap')
    vim.api.nvim_buf_set_name(0, 'Backlinks to ' .. current_file)
    
    -- Add content to the buffer
    local lines = {"# Backlinks to " .. current_file, ""}
    for _, file in ipairs(backlinks) do
      table.insert(lines, "- [[" .. file:gsub('%.md$', '') .. "]]")
    end
    
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.cmd('setlocal filetype=markdown')
    vim.cmd('setlocal nomodifiable')
    
    -- Add mappings for the backlinks buffer
    vim.api.nvim_buf_set_keymap(0, 'n', '<CR>', 
      ':lua vim.cmd("wincmd p | edit " .. vim.fn.getline("."):match("\\[\\[(.*?)\\]\\]"):gsub("%.md$", "") .. ".md")<CR>', 
      {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(0, 'n', 'q', ':bd<CR>', {noremap = true, silent = true})
  else
    print("No backlinks found for " .. current_file)
  end
end

-- 2. Simple tag navigation
-- Function to find files with specific tag
local function find_files_with_tag()
  local tag = vim.fn.input("Tag to search for: ")
  if tag == "" then return end
  
  -- Use grep to find files with the tag
  local handle = io.popen('grep -l "\\[\\[' .. tag .. '\\]\\]" *.md 2>/dev/null')
  local result = handle:read("*a")
  handle:close()
  
  -- Parse the results
  local files = {}
  for file in string.gmatch(result, "[^\n]+") do
    table.insert(files, file)
  end
  
  -- Display files in a split window
  if #files > 0 then
    vim.cmd('botright new')
    vim.cmd('setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap')
    vim.api.nvim_buf_set_name(0, 'Files with tag [[' .. tag .. ']]')
    
    local lines = {"# Files with tag [[" .. tag .. "]]", ""}
    for _, file in ipairs(files) do
      table.insert(lines, "- [[" .. file:gsub('%.md$', '') .. "]]")
    end
    
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.cmd('setlocal filetype=markdown')
    vim.cmd('setlocal nomodifiable')
    
    -- Add mappings
    vim.api.nvim_buf_set_keymap(0, 'n', '<CR>', 
      ':lua vim.cmd("wincmd p | edit " .. vim.fn.getline("."):match("\\[\\[(.*?)\\]\\]"):gsub("%.md$", "") .. ".md")<CR>', 
      {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(0, 'n', 'q', ':bd<CR>', {noremap = true, silent = true})
  else
    print("No files found with tag [[" .. tag .. "]]")
  end
end

-- 3. Zettelkasten ID Generator
-- Function to generate timestamp-based IDs for Zettelkasten notes
local function generate_zettel_id()
  return os.date("%Y%m%d%H%M")
end

-- Create a new zettelkasten note with proper ID
local function new_zettel_note()
  local id = generate_zettel_id()
  local title = vim.fn.input("Note title: ")
  if title == "" then
    print("Cancelled")
    return
  end
  
  -- Create filename with ID prefix
  local filename = id .. "-" .. sanitize_filename(title) .. ".md"
  
  -- Set the global flag to prevent autocommand from applying template
  vim.g.markdown_template_applied = 1
  
  -- Create and edit the file
  create_and_edit(filename)
  
  -- Apply template with ID and title
  apply_zettel_template("zettel.md", id, title)
  
  -- Reset the flag for future file creations
  vim.defer_fn(function()
    vim.g.markdown_template_applied = 0
  end, 100)
end

-- Modified apply_template function for Zettelkasten notes
function apply_zettel_template(template, id, title)
  local template_path = vim.g.template_dir .. "/" .. template
  if vim.fn.filereadable(template_path) == 1 then
    -- Make sure we're at the start of the file
    vim.cmd("normal! gg")
    
    -- Read template file at the top of the buffer
    vim.cmd("0read " .. template_path)
    
    -- Prompt for tags
    local formatted_tags = prompt_for_tags()
    
    -- Expand common variables
    vim.cmd([[silent! %s/{{date}}/\=strftime('%Y-%m-%d')/ge]])
    vim.cmd([[silent! %s/{{id}}/]] .. id .. [[/ge]])
    vim.cmd([[silent! %s/{{title}}/]] .. vim.fn.escape(title, "/") .. [[/ge]])
    vim.cmd([[silent! %s/{{tags}}/]] .. vim.fn.escape(formatted_tags, "/") .. [[/ge]])
    
    -- Position cursor at the cursor marker if it exists, otherwise at the end of file
    if vim.fn.search("{{cursor}}", "w") > 0 then
      -- Replace the marker with an empty string
      vim.cmd([[s/{{cursor}}//e]])
      -- Enter insert mode
      vim.cmd("startinsert")
    else
      -- Position cursor at the end of the file and enter insert mode
      vim.cmd("normal! G")
      vim.cmd("startinsert")
    end
    
    -- Mark as modified to ensure save works properly
    vim.opt.modified = true
  else
    print("Template not found: " .. template_path)
  end
end

-- 4. Quick capture function
local function quick_capture()
  -- Create a temporary quick note with timestamp
  local id = generate_zettel_id()
  local filename = id .. "-quick-note.md"
  
  -- Create the file
  create_and_edit(filename)
  
  -- Add a simple header
  local lines = {
    "---",
    "title: Quick Note " .. os.date("%Y-%m-%d %H:%M"),
    "date: " .. os.date("%Y-%m-%d"),
    "tags: [[fleeting]]", 
    "status: unread",
    "---",
    "",
    "# Quick Note " .. os.date("%Y-%m-%d %H:%M"),
    "",
    ""
  }
  
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  
  -- Position cursor at the end and enter insert mode
  vim.cmd("normal! G")
  vim.cmd("startinsert")
end

-- 5. Lightweight fuzzy finder for notes
local function fuzzy_find_notes()
  local query = vim.fn.input("Search notes: ")
  if query == "" then return end
  
  -- Use grep for searching note contents
  local handle = io.popen('grep -l "' .. query .. '" *.md 2>/dev/null')
  local result = handle:read("*a")
  handle:close()
  
  -- Parse results
  local files = {}
  for file in string.gmatch(result, "[^\n]+") do
    table.insert(files, file)
  end
  
  -- Display results
  if #files > 0 then
    vim.cmd('botright new')
    vim.cmd('setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap')
    vim.api.nvim_buf_set_name(0, 'Search results for: ' .. query)
    
    local lines = {"# Search results for: " .. query, ""}
    for _, file in ipairs(files) do
      table.insert(lines, "- [[" .. file:gsub('%.md, '') .. "]]")
    end
    
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.cmd('setlocal filetype=markdown')
    vim.cmd('setlocal nomodifiable')
    
    -- Add mappings
    vim.api.nvim_buf_set_keymap(0, 'n', '<CR>', 
      ':lua vim.cmd("wincmd p | edit " .. vim.fn.getline("."):match("\\[\\[(.*?)\\]\\]"):gsub("%.md$", "") .. ".md")<CR>', 
      {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(0, 'n', 'q', ':bd<CR>', {noremap = true, silent = true})
  else
    print("No matching notes found for: " .. query)
  end
end

-- 6. Extract text as a new Zettel note
local function extract_as_zettel()
  -- Get visual selection
  vim.cmd('normal! "zy')
  local selected_text = vim.fn.getreg('z')
  
  -- Create a new note
  local id = generate_zettel_id()
  local title = vim.fn.input("Note title for extracted text: ")
  if title == "" then
    print("Cancelled")
    return
  end
  
  -- Create filename with ID
  local filename = id .. "-" .. sanitize_filename(title) .. ".md"
  
  -- Create file with content
  local file = io.open(filename, "w")
  if file then
    file:write("---\n")
    file:write("title: " .. title .. "\n")
    file:write("id: " .. id .. "\n")
    file:write("date: " .. os.date("%Y-%m-%d") .. "\n")
    file:write("tags: \n")
    file:write("status: unread\n")
    file:write("---\n\n")
    file:write("# " .. title .. "\n\n")
    file:write(selected_text .. "\n\n")
    file:write("## Source\n\n")
    file:write("Extracted from [[" .. vim.fn.expand('%:t:r') .. "]]")
    file:close()
    
    -- Replace selection with link to new note
    vim.cmd('normal! gvc[[' .. id .. ' ' .. title .. ']]')
    
    print("Created note: " .. filename)
  else
    print("Error: Could not create file " .. filename)
  end
end

-- 7. Daily note generator
local function create_daily_note()
  local date = os.date("%Y-%m-%d")
  local filename = date .. "-daily-note.md"
  
  -- Check if daily note already exists
  if vim.fn.filereadable(filename) == 1 then
    -- Open existing daily note
    vim.cmd("edit " .. filename)
    return
  end
  
  -- Create and edit the file
  create_and_edit(filename)
  
  -- Create daily note template
  local lines = {
    "---",
    "title: Daily Note - " .. date,
    "date: " .. date,
    "tags: [[daily]]", 
    "status: unread",
    "---",
    "",
    "# Daily Note - " .. date,
    "",
    "## Tasks",
    "",
    "- [ ] ",
    "",
    "## Notes",
    "",
    "## Links",
    ""
  }
  
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  
  -- Position cursor at the first task
  vim.fn.search("- \\[ \\]")
  vim.cmd("normal! $")
  vim.cmd("startinsert")
end

-- Key mappings for Zettelkasten features
vim.keymap.set("n", "<leader>zn", new_zettel_note, {silent = true, desc = "New Zettelkasten note"})
vim.keymap.set("n", "<leader>zb", find_backlinks, {silent = true, desc = "Find backlinks"})
vim.keymap.set("n", "<leader>zt", find_files_with_tag, {silent = true, desc = "Find files with tag"})
vim.keymap.set("n", "<leader>zq", quick_capture, {silent = true, desc = "Quick capture note"})
vim.keymap.set("n", "<leader>zf", fuzzy_find_notes, {silent = true, desc = "Fuzzy find notes"})
vim.keymap.set("n", "<leader>zd", create_daily_note, {silent = true, desc = "Create/open daily note"})
vim.keymap.set("v", "<leader>ze", extract_as_zettel, {silent = true, desc = "Extract selection as new note"})

-- Add user commands for convenience
vim.api.nvim_create_user_command("ZettelNew", new_zettel_note, {})
vim.api.nvim_create_user_command("Backlinks", find_backlinks, {})
vim.api.nvim_create_user_command("FindTag", find_files_with_tag, {})
vim.api.nvim_create_user_command("QuickCapture", quick_capture, {})
vim.api.nvim_create_user_command("DailyNote", create_daily_note, {})

-- Return the module
return {
  find_backlinks = find_backlinks,
  find_files_with_tag = find_files_with_tag,
  new_zettel_note = new_zettel_note,
  quick_capture = quick_capture,
  fuzzy_find_notes = fuzzy_find_notes,
  extract_as_zettel = extract_as_zettel,
  create_daily_note = create_daily_note
}
