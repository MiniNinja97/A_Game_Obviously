# A Game Obviously


A browser-based text adventure game built with Elixir, Phoenix LiveView and MariaDB.
Type commands, explore rooms, fight enemies and see how far you get.

## Requirements

Make sure you have the following installed before you start:

- **Elixir** (1.15 or later) — https://elixir-lang.org/install.html
- **Erlang** (comes with Elixir, but check that it's installed)
- **Phoenix** — install with `mix archive.install hex phx_new`
- **MariaDB** (or MySQL) — https://mariadb.org/download
- **Node.js** (for assets) — https://nodejs.org

### Windows
The easiest way to install Elixir on Windows is via the official installer at https://elixir-lang.org/install.html.
For MariaDB, download the installer from https://mariadb.org/download.

### Mac
The easiest way is via Homebrew:
```bash
brew install elixir
brew install mariadb
```

## Getting Started

**1. Clone the repo**
```bash
git clone https://github.com/MiniNinja97/A_Game_Obviously.git
cd A_Game_Obviously
```

**2. Set up the database**

Make sure MariaDB is running, then create a user and database that matches the config in `config/dev.exs`:
```bash
mysql -u root -p
CREATE DATABASE my_app_dev;
CREATE USER 'emma'@'localhost' IDENTIFIED BY 'emma123';
GRANT ALL PRIVILEGES ON my_app_dev.* TO 'emma'@'localhost';
FLUSH PRIVILEGES;
```

**3. Install dependencies and set up the project**
```bash
mix setup
```

This will install dependencies, create the database tables and compile assets.

**4. Start the server**
```bash
mix phx.server
```

**5. Open your browser and go to**
```
http://localhost:4000
```

## How to Play

- Type commands in the input field and press **Continue**
- Follow the instructions on screen
- Commands include things like `move`, `attack`, `run`, `inventory`, `eat`, `sleep` and more
- See how far you can get before it's game over

## Tech Stack

- **Elixir & Phoenix** — backend and web framework
- **Phoenix LiveView** — real-time updates without JavaScript
- **GenServer** — one process per player, holds game state in memory
- **MariaDB + Ecto** — database and query layer
- **PubSub** — real-time communication between game server and frontend

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
