# Hangman on Rails

This is a simple implementation of the game hangman as a Rails app.

## Installation

This requires ruby and the ruby gem `bundler`.

* Slackware

        # sbopkg -i ruby-bundler

* Others TODO

After cloning this repo run:

        $ bundle install --path vendor/bundle

## Configuration

The default configuration for development uses a PostgreSQL database. The  
configuration for this should be done in `config/database.yml`. You'll need  
adapt this for your PostgreSQL instance. To get started quickly, you can  
comment out the PostgreSQL development database in the file, and restore the  
sqlite values.

## Running

To start the server in development mode:

        $ ./bin/rails s

The server needs a file with singles words on each line. By default it will use  
`/usr/share/dict/words` if it exists. If not, you must point to the file with an  
environment variable when starting the server:

        $ HANGMAN_WORD_LIST=path_to_my_file ./bin/rails s

To listen on all interfaces:

        $ ./bin/rails s --binding=0.0.0.0

The UI is available an [http://localhost:3000](http://localhost:3000)

You can also play hangman in the console against a server running elsewhere  
using a shell script:

        $ ./cli.sh                         # connects to http://localhost:3000
        $ ./cli.sh --url https://somehost  # for a remote server
