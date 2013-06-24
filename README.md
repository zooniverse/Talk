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
