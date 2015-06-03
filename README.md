# golang.mk

Common Makefile rules for building and testing Golang applications.

Also features support for dependencies and a package index.

## Why golang.mk?

This project was inspired by the awsome [erlang.mk](https://github.com/ninenines/erlang.mk) project.

## Usage

Add the file `golang.mk` to your project, then use the following base
Makefile:

``` Makefile
PROJECT = my_project
PROJECT_PATH = github.com/my_username/my_project
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
make -f golang.mk
make -f golang.mk bootstrap
make
```

