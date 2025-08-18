**This repo is supposed to be used as config by NvChad users!**

- The main nvchad repo (NvChad/NvChad) is used as a plugin by this repo.
- So you just import its modules , like `require "nvchad.options" , require "nvchad.mappings"`
- So you can delete the .git from this repo ( when you clone it locally ) or fork it :)

# How to Install:

- Clone the repo into your "home config" directory i.e. in ~/.config/ directory, using following command:
```bash
git clone https://github.com/HubertasVin/nvim-config.git ~/.config/nvim
```

- Just open neovim using nvim command in your terminal and wait for it to automatically finish setting up nvchad config.
    - Lazy will load all the required plugins automatically at this stage.
    - You can verify the lazy package information by running the command :Lazy
- Now, within the neovim terminal, run the command :MasonInstallAll to install all the mason packages.
- Once Mason finishes all the package installation, quit the Neovim using :q command and reopen.
- That's it! It should be ready to use.

# Credits

1) Lazyvim starter https://github.com/LazyVim/starter as nvchad's starter was inspired by Lazyvim's . It made a lot of things easier!
