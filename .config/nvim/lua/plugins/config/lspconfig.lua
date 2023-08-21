require 'neodev'.setup {}

local lspconfig = require 'lspconfig'
local schemastore = require 'schemastore'
lspconfig.jsonls.setup {
	settings = {
		json = {
			schemas = schemastore.json.schemas(),
			validate = { enable = true },
		},
	},
}

lspconfig.yamlls.setup {
	settings = {
		yaml = {
			schemas = schemastore.yaml.schemas(),
		},
	},
}

local capabilities = require 'cmp_nvim_lsp'.default_capabilities()

capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}

require 'mason-lspconfig'.setup_handlers {
	function(server)
		lspconfig[server].setup {
			capabilities = capabilities
		}
	end,
}

require 'ufo'.setup()
