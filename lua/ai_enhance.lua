-- Enhanced AI Integration for Zettelkasten

-- 1. Function to "Expand on this idea with Claude"
-- This asks Claude to expand on the current paragraph or selection
local function expand_with_claude()
  local text = ""
  
  -- Get text from visual selection or current paragraph
  if vim.fn.mode() == 'v' or vim.fn.mode() == 'V' then
    -- Get visual selection
    vim.cmd('normal! "zy')
    text = vim.fn.getreg('z')
  else
    -- Get current paragraph
    vim.cmd('normal! yip')
    text = vim.fn.getreg('"')
  end
  
  if text == "" then
    print("No text selected or under cursor")
    return
  end
  
  -- Prepare prompt for Claude
  local prompt = "Please expand on this idea or concept in the context of a Zettelkasten note. Add depth, connections, and questions to consider:\n\n" .. text

  -- Use Avante.nvim to get Claude's response
  require("avante").text_editor({
    prompt = prompt,
    action = "append" -- Append Claude's response after the current paragraph
  })
end

-- 2. Function to "Transform to permanent note"
-- This prompts Claude to help convert a fleeting note to a permanent note format
local function transform_to_permanent()
  -- Get the entire buffer content
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")
  
  -- Prepare prompt for Claude
  local prompt = [[
  Transform this fleeting note into a permanent note format for my Zettelkasten:
  
  1. Identify and extract the main idea(s)
  2. Rewrite in your own words to be clear and standalone
  3. Organize with appropriate headings
  4. Identify potential connections to other ideas (suggest tags)
  5. Add questions for further exploration
  
  Here's my note:
  
  ]] .. content
  
  -- Open a new buffer for the transformed note
  vim.cmd('new')
  vim.api.nvim_buf_set_name(0, 'Transformed Note (Claude)')
  
  -- Use Avante.nvim to get Claude's response
  require("avante").text_editor({
    prompt = prompt,
    action = "append"
  })
end

-- 3. Function to generate related questions
-- Asks Claude to generate questions related to the current note
local function generate_questions()
  -- Get the entire buffer content
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")
  
  -- Prepare prompt for Claude
  local prompt = [[
  Based on this note, generate 5-7 thought-provoking questions that could lead to new notes in my Zettelkasten system. Focus on:
  
  1. Exploring implications
  2. Connecting to other domains
  3. Challenging assumptions
  4. Applying the ideas in different contexts
  
  Here's my note:
  
  ]] .. content
  
  -- Use Avante.nvim to get Claude's response
  require("avante").text_editor({
    prompt = prompt,
    action = "append" -- Append Claude's response at the end of the file
  })
end

-- 4. Function to summarize a note
-- Creates a concise summary of the current note
local function summarize_note()
  -- Get the entire buffer content
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")
  
  -- Prepare prompt for Claude
  local prompt = [[
  Create a concise summary (3-5 sentences) of this note that captures its essence. 
  This will help me quickly understand the main point when reviewing my Zettelkasten:
  
  ]] .. content
  
  -- Use Avante.nvim to get Claude's response
  require("avante").text_editor({
    prompt = prompt,
    action = "append"
  })
end

-- 5. Function to suggest connections
-- Asks Claude to suggest connections to other notes or concepts
local function suggest_connections()
  -- Get the entire buffer content
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")
  
  -- Prepare prompt for Claude
  local prompt = [[
  Based on this note, suggest:
  
  1. 5-7 potential connections to other concepts that would make sense in a Zettelkasten system
  2. Specific areas of knowledge this might connect to
  3. Potential tags to organize this note
  
  Format your response so I can easily extract these suggestions:
  
  ]] .. content
  
  -- Use Avante.nvim to get Claude's response
  require("avante").text_editor({
    prompt = prompt,
    action = "append"
  })
end

-- 6. Atomic Notes Generator
-- Takes longer text and suggests ways to break it down into atomic notes
local function atomic_notes_generator()
  -- Get the entire buffer content
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")
  
  -- Prepare prompt for Claude
  local prompt = [[
  This text contains multiple ideas that should be separated into atomic notes for a Zettelkasten system.
  
  Please:
  
  1. Identify 3-5 distinct ideas that could be their own atomic notes
  2. For each idea, suggest a title and brief content outline
  3. Recommend how these atomic notes could link to each other
  
  Here's the text:
  
  ]] .. content
  
  -- Open a new buffer for the atomic notes suggestions
  vim.cmd('new')
  vim.api.nvim_buf_set_name(0, 'Atomic Notes Suggestions (Claude)')
  
  -- Use Avante.nvim to get Claude's response
  require("avante").text_editor({
    prompt = prompt,
    action = "append"
  })
end

-- Key mappings for AI-enhanced features
vim.keymap.set("n", "<leader>ae", expand_with_claude, {silent = true, desc = "Expand with Claude"})
vim.keymap.set("v", "<leader>ae", expand_with_claude, {silent = true, desc = "Expand selection with Claude"})
vim.keymap.set("n", "<leader>ap", transform_to_permanent, {silent = true, desc = "Transform to permanent note"})
vim.keymap.set("n", "<leader>aq", generate_questions, {silent = true, desc = "Generate related questions"})
vim.keymap.set("n", "<leader>as", summarize_note, {silent = true, desc = "Summarize note"})
vim.keymap.set("n", "<leader>ac", suggest_connections, {silent = true, desc = "Suggest connections"})
vim.keymap.set("n", "<leader>ab", atomic_notes_generator, {silent = true, desc = "Generate atomic notes"})

-- Add user commands
vim.api.nvim_create_user_command("ExpandWithClaude", expand_with_claude, {})
vim.api.nvim_create_user_command("TransformNote", transform_to_permanent, {})
vim.api.nvim_create_user_command("GenerateQuestions", generate_questions, {})
vim.api.nvim_create_user_command("SummarizeNote", summarize_note, {})
vim.api.nvim_create_user_command("SuggestConnections", suggest_connections, {})
vim.api.nvim_create_user_command("AtomicNotes", atomic_notes_generator, {})

-- Return the module
return {
  expand_with_claude = expand_with_claude,
  transform_to_permanent = transform_to_permanent,
  generate_questions = generate_questions,
  summarize_note = summarize_note,
  suggest_connections = suggest_connections,
  atomic_notes_generator = atomic_notes_generator
}
