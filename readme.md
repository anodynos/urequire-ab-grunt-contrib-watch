# urequire-ab-grunt-contrib-watch

## Introduction

Automagically generates and runs a `grunt-contrib-watch` task from a [uRequire](http://urequire.org) config running within grunt.

## Usage

You can use this library directly or inderectly through [`grunt-urequire`](https://github.com/aearly/grunt-urequire) or [`urequire-ab-specrunner`](https://github.com/anodynos/urequire-ab-specrunner])

The direct usage is :

      urequire:
        UMD:
          ...
          path: 'some/source/path'
          ...
          afterBuild: require('urequire-ab-grunt-contrib-watch')

## Options

You can pass options by invoking `options`:


      UMD:
        path: 'some/source/path'
        afterBuild: require('urequire-ab-grunt-contrib-watch').options({
            someOption: someValue })

### Watch Options blending

Note that you don't need `build.watch` to be set to `true` or anything else in your `grunt-urequire` config.
If `watch` is there though, any configuration it has is blended properly into the final watch object (precedence given to `options`).

For example:

      UMD:
        path: 'some/source/path'
        watch: 1439
        afterBuild: require('urequire-ab-grunt-contrib-watch')

will set `debounceDelay: 1439` to the `options` of the watch, i.e its equivalent to

      UMD:
        path: 'some/source/path'
        afterBuild: require('urequire-ab-grunt-contrib-watch').options({
            debounceDelay: 1439
        })

Also `files`, `after` and `before` items (see below) are carried forward and added to the final `watch` arrays.

### debounceDelay

Sets the `debounceDelay` of [`grunt-contrib-watch`](https://github.com/gruntjs/grunt-contrib-watch#optionsdebouncedelay)

### `before` & `after` tasks

You can add any other grunt (or [`grunt-urequire`](https://github.com/aearly/grunt-urequire)) tasks to run `before` or `after` the current task at each watch cycle:

      UMD:
        path: 'some/source/path'
        afterBuild: require('urequire-ab-grunt-contrib-watch').options
            before: ['clean:cache', 'concat:useless']                   # an `Array` of grunt tasks to run before current at each cycle
            after:  'urequire:spec zip:UMD email:me'                    # a `String` with space separated grunt tasks is also fine

You 'll be happy to know that if the task is a `urequire:someTask`, then its `bundle.path` (as a files pattern) is added to `files` of the `grunt-contrib-watch` task automatically (and the urequire build task is also initialized if not already so).

### `files` to be watched

You can add `files` to the watch task [`grunt-contrib-watch`](https://github.com/gruntjs/grunt-contrib-watch#files) to be watched and trigger a watch cycle if they change. They can be added in two ways:

 * File patterns [as defined in `grunt-contrib-watch`](https://github.com/gruntjs/grunt-contrib-watch#files)

 * Some other grunt `urequire:task`, where its `path` is added so you'll never repeat your self.

Example:

     urequire:
       UMD:
         ...
         watch:
           files: ['urequire:spec', 'some/files/path/**.ext']

       spec:
         path: 'some/source/path'
         ...

In this case `'some/source/path/**/*'` will be added to `files` along with `'some/files/path/**.ext'`.

### `debugLevel`

Prints debug info, goes from `0` (default) to `100`.

### All other options

Any other key is added directly to [`grunt-contrib-watch`](https://github.com/gruntjs/grunt-contrib-watch) options object, but be warned that `atBegin: true` and `spawn: true` should not be set.

# License

The MIT License

Copyright (c) 2014 Agelos Pikoulas (agelos.pikoulas@gmail.com)

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.