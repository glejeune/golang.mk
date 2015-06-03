package main
 import (
 "fmt"
 "go/parser"
 "go/token"
 "os"
 "os/exec"
 "strings"
 )
 func stripchars(str, chr string) string {
 return strings.Map(func(r rune) rune {
 if strings.IndexRune(chr, r) < 0 {
 return r
 }
 return -1
 }, str)
 }
 func main() {
 pkgs := make(map[string]bool)
 for _, goSrc := range os.Args[1:] {
 fset := token.NewFileSet()
 f, err := parser.ParseFile(fset, goSrc, nil, parser.ImportsOnly)
 if err != nil {
 fmt.Println(err)
 return
 }
 for _, s := range f.Imports {
 if !pkgs[s.Path.Value] {
 pkgs[s.Path.Value] = true
 }
 }
 }
 for p, _ := range pkgs {
 fmt.Printf("GET %s\n", p)
 out, _ := exec.Command("go", "get", stripchars(p, "\"")).Output()
 if len(out) > 0 {
 fmt.Printf("  !! %s\n", out)
 }
 }
 }