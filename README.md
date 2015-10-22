## Talk 2.0

### Deprecated

This repo is no longer maintanined. Issues opened in it will likely be closed and not fixed.

### About

Talk codebase for projects launched on our old platform generally between Sept. 2012 and June 2015. Examples include http://talk.chimpandsee.org/, http://talk.galaxyzoo.org/, and http://talk.planethunters.org/.

### Requirements

Uses the 1.x.x version of the Ruby AWS SDK gem, which is unfortunately not specified in the gemfile. Be sure you are using the corret version.

Also uses hem as a front-end builder, which only works with node version ~0.10.x. 

### Setup

Install the dependencies:  `npm install .`

Fix hem's dependencies: *a recently introduced regression; maybe we should just fork the repository?*
  - `cd ./node_modules/hem`
  - edit `./package.json`
  - locate line 27, `"uglify-js": "~1.1.1",`
  - set to `"uglify-js": "~1.3.3",`
  - `rm -rf ./node_modules/uglify-js`
  - `npm install .`
  - `cd ../../`

### Script helpers

Switch projects:  `./configure.rb <project_name>`

Initialize a new project:  `./bootstrap.rb planet_four 'Planet Four' PF`

Deploy a project by name or `all` projects:  `./deploy.rb <project_name>`
