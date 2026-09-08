local M = {}

---@param cmd string
---@param split string
local function run_in_terminal(cmd, split)
  vim.cmd(split)
  vim.fn.termopen(cmd)
  vim.cmd 'startinsert'
end

M.run_in_terminal = run_in_terminal

M.defaults = {
  -- Terminal'i acmak icin kullanilan komut (bkz. :help :new)
  split = 'noautocmd new',
  languages = {
    python = {
      filetypes = { 'python' },
      commands = {
        { name = 'Python', cmd = 'python3', default_args = '%:p' },
        { name = 'Ptest', cmd = 'python3 -m pytest' },
      },
    },
    node = {
      filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
      commands = {
        { name = 'Npm', cmd = 'npm' },
        { name = 'Node', cmd = 'node', default_args = '%:p' },
        { name = 'Ntest', cmd = 'npm test', nargs = 0 },
        { name = 'Ninstall', cmd = 'npm install', nargs = 0 },
      },
    },
    dotnet = {
      filetypes = { 'cs', 'fsharp' },
      commands = {
        { name = 'Dotnet', cmd = 'dotnet' },
        { name = 'Drun', cmd = 'dotnet run' },
        { name = 'Dtest', cmd = 'dotnet test' },
        { name = 'Dbuild', cmd = 'dotnet build' },
      },
    },
  },
}

---@param opts? table
function M.setup(opts)
  local config = vim.tbl_deep_extend('force', {}, M.defaults, opts or {})
  local group = vim.api.nvim_create_augroup('run.nvim', { clear = true })

  for _, lang in pairs(config.languages) do
    vim.api.nvim_create_autocmd('FileType', {
      pattern = lang.filetypes,
      group = group,
      callback = function(ev)
        for _, c in ipairs(lang.commands) do
          vim.api.nvim_buf_create_user_command(ev.buf, c.name, function(cmd_opts)
            local args = cmd_opts.args ~= '' and cmd_opts.args or (c.default_args and vim.fn.expand(c.default_args) or '')
            run_in_terminal(vim.trim(c.cmd .. ' ' .. args), config.split)
          end, { nargs = c.nargs or '*', complete = 'file', desc = 'run.nvim: ' .. c.cmd })
        end
      end,
    })
  end
end

return M
