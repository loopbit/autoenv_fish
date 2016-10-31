# autoenv_fish

[Autoenv](https://github.com/kennethreitz/autoenv) magic for [fish shell](https://fishshell.com)!

Please note that this project is intended to make autoenv available for fish shell users, this basically means that this version will always be a bit behind the main project. Any bugs, bugfixes and contributions are very much appreciated, but keep in mind that any feature requests (unless strictly fish-related) should be posted [here](https://github.com/kennethreitz/autoenv/issues).

## Installation

To install it, just copy activate.fish somewhere to your computer and source it by typing the following in terminal:

	source <path/to/script>/activate.fish

If you want to have autoenv always enabled, add the previous line to your fish config file (~/.config/fish/config.fish).


### Homebrew

This formula is not in the core homebrew, but if you prefer to use it (to get automatic updates, for example) you can use this tap (see the code [here](https://github.com/loopbit/homebrew-tap)):

	brew tap loopbit/tap
	brew install autoenv_fish

