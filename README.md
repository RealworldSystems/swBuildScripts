swBuildScripts
==============

Introduction
------------



Features
--------

 * override vars
 * see build output
 * filter output
 * return a sensible exit code to the environment
 * incremental builds

 * set of useful Magik code
  * normalize sources
  * opening of database
  * etc.

Install
-------

 * Ruby
 * gem install file-tail
 * zip (retrieve from Info-Zip)

Integration / Install Instructrions
-----------

Take a deployment package, and copy in the src/rake/* files. Upd


copy in BuildSmallworldImage.rb
define your smallworld images with SmallworldImage

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
