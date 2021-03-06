# golang.mk

Common Makefile rules for building and testing Golang applications.

Also features support for dependencies and a package index.

## Why golang.mk?

This project was inspired by the awsome [erlang.mk](https://github.com/ninenines/erlang.mk) project.

## Usage

Add the file `golang.mk` to your project, then use the following base
Makefile:

``` Makefile
PROJECT_MAIN = my_project
PROJECT_MODULE = github.com/my_username/my_project
include golang.mk
```

Then run

```
make
make help
```

## Start

```
mkdir my_project
cd my_project
wget https://raw.githubusercontent.com/glejeune/golang.mk/master/golang.mk
make -f golang.mk bootstrap
```

This wil generate :

```
.
├── .gitignore
├── golang.mk
├── Makefile
├── my_project
│   ├── my_project.go
│   └── my_project_test.go
└── README.md
```

## Contributing

1. Fork it ( https://github.com/glejeune/golang.mk/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Licence

golang.mk is available for use under the following license, commonly known as the 3-clause (or "modified") BSD license:

Copyright (c) 2015 Grégoire Lejeune

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
