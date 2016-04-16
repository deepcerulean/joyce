# joyce


* [Homepage](https://rubygems.org/gems/joyce)
* [Documentation](http://rubydoc.info/gems/joyce/frames)
* [Email](mailto:jweissman1986 at gmail.com)

[![Code Climate GPA](https://codeclimate.com/github//joyce/badges/gpa.svg)](https://codeclimate.com/github//joyce)

## Description

Joyce is a multiplayer game server framework built on top of Metacosm

## What is the big idea?

The idea is to build 'isomorphic' Ruby games: to target both a Gosu game client as well as a game server
running in the cloud. Both are running the same code, but the responsibilities are split: 

  - The game server runs game business logic, and publishes events that the clients consume to hydrate their local views
  - Clients publish commands the the server validates and handles, updating game state and generating events

One upshot of this is that all game processing is kept on the server, and clients are doing nothing but
rendering views and when necessary figuring out what commands to publish (when the user interacts).

## Features

## Examples

    require 'joyce'
   
## Requirements

## Install

    $ gem install joyce

## Synopsis

    $ joyce

## Copyright

Copyright (c) 2016 Joseph Weissman

See {file:LICENSE.txt} for details.
