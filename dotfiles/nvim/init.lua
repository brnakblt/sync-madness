-- Matugen Theme Integration
local function apply_matugen_colors()
    -- Safely try to load the theme module
    package.loaded["matugen_theme"] = nil
    local ok, matugen = pcall(require, "matugen_theme")
    if not ok then
        return
    end

    local colors = matugen.colors
    
    -- Setup basic settings
    vim.o.termguicolors = true
    
    -- Define highlights
    local highlights = {
        Normal = { fg = colors.foreground, bg = colors.background },
        NormalFloat = { fg = colors.foreground, bg = colors.surface_variant },
        FloatBorder = { fg = colors.outline, bg = colors.surface_variant },
        Visual = { bg = colors.surface_variant },
        CursorLine = { bg = colors.surface_variant },
        Search = { fg = colors.on_primary, bg = colors.primary },
        ErrorMsg = { fg = colors.error },
        WarningMsg = { fg = colors.secondary },
        
        -- UI Elements
        LineNr = { fg = colors.on_surface_variant },
        CursorLineNr = { fg = colors.primary, bold = true },
        StatusLine = { fg = colors.on_surface_variant, bg = colors.surface_variant },
        StatusLineNC = { fg = colors.outline, bg = colors.background },
        VertSplit = { fg = colors.outline },
        WinSeparator = { fg = colors.outline },
        
        -- Syntax (Basic)
        Comment = { fg = colors.on_surface_variant, italic = true },
        Constant = { fg = colors.tertiary },
        String = { fg = colors.tertiary },
        Identifier = { fg = colors.primary },
        Function = { fg = colors.primary, bold = true },
        Statement = { fg = colors.secondary, bold = true },
        Operator = { fg = colors.on_surface_variant },
        Type = { fg = colors.secondary },
        Special = { fg = colors.tertiary },
    }

    -- Apply highlights
    for group, settings in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, settings)
    end
end

-- Apply colors on startup
apply_matugen_colors()

-- File watcher for hot-reloading
local theme_path = vim.fn.stdpath("config") .. "/lua/matugen_theme.lua"
-- Store watcher in global _G to prevent GC
if _G.matugen_watcher then
    _G.matugen_watcher:stop()
end

_G.matugen_watcher = vim.loop.new_fs_event()
_G.matugen_watcher:start(theme_path, {}, vim.schedule_wrap(function(err, fname, events)
    if err then return end
    apply_matugen_colors()
end))
