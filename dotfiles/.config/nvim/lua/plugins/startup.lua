return {
    { "nvim-treesitter/nvim-treesitter", branch = 'master', lazy = false, build = ":TSUpdate" },
    { "nvim-lua/plenary.nvim" },
    { "mbbill/undotree" },
    { "mason-org/mason.nvim" },
    { "habamax/vim-habamax" },
    { "fxn/vim-monochrome"},
    { "projekt0n/github-nvim-theme" },
    { "nyoom-engineering/oxocarbon.nvim" },
    { "habamax/vim-habamax" },
    { "theprimeagen/harpoon" },
    { "theprimeagen/vim-be-good" },
    {  "AlexvZyl/nordic.nvim",
    lazy = false,
    priority = 1000,
    config = function()
    end
    },
    { "ramojus/mellifluous.nvim", },
    { "startup-nvim/startup.nvim",
    dependencies = { "nvim-lua/plenary.nvim"},
    config = function()
    local startup_themes = {
      "sleek",
      "default",
      "saturn",
      "rebel",
      "bloody",
      "priest",
      "elite"
    }
    -- Get random theme
    math.randomseed(os.time())
    local random_theme = startup_themes[math.random(#startup_themes)]
    require("startup").setup({ theme = "sleek" })
  end
}
}


