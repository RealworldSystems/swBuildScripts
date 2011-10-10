swBuildScripts
==============

Introduction
------------



Features
--------

 * override environment variables
  * possibility to override environment variables, such as the database, Emacs location, message db dir, etc.
 * see build output
  * the output of Smallworld is redirected to the console
 * filter output
 * return a sensible exit code to the environment
 * incremental builds

 * set of useful Magik code
  * normalize sources
  * opening of database
  * automated running of unit tests / TR tests
  * etc.

Install
-------

 * Ruby
 * gem install file-tail
 * zip (retrieve from Info-Zip)

Integration / Install Instructions
-----------

 * take a deployment package, and copy in the src/rake/* files. Upd
 * copy in BuildSmallworldImage.rb
 * define your smallworld images with SmallworldImage

Usage
-----

 * rake image:build
 * rake -T
 * rake 

Development
-----------

 * rake ln
 * rake update

Smallworld Build Structure
--------------------------
 * config module
 * register image
 * gis_alias
